 # Bevy Haxe 重构计划：Async Macro 优先版
 
 
  ## Summary


  - 以本地 Bevy 0.19.0-dev 为源版本，逐模块 1:1 概念移植到 Haxe/Web。
  - 重构采用分层替换：新核心使用 bevy.* 包，旧 haxe.* 代码只作参考和可迁移资产。
  - P0 先实现底层 async 宏系统，再在其上实现 ECS、reflect、asset、WebGL2 render。
  - Haxe 4.3.6 不能直接解析 for await (...)；计划提供 await(expr)、async(function(){...})、forAwait(iter, fn) DSL。若必须写原生 for await 语
    法，需要额外预处理器。


  ## Key Changes


  - Async macro runtime 优先实现：
      - 新增 bevy.async.Future<T>、PromiseFuture<T>、Task<T>、AsyncIterator<T>、AsyncRuntime。
      - JS 后端底层使用 js.lib.Promise 和 microtask queue。
      - await(expr) 由宏重写为状态机或 Promise continuation。
      - async(fn) 将函数体转换为 Future<T>。
      - forAwait(source, item -> body) 支持异步迭代；等价目标是 JavaScript for await 语义，但保持 Haxe 可解析。
      - 支持 try/catch/finally、return、throw、嵌套 await、并发 join/race、取消标记。
  - 宏系统分层：
      - P0：AsyncMacro、MacroRuntime、诊断工具、生成代码测试。
      - P1：@:component、@:resource、@:event、@:reflect。
      - P2：@:system，允许 system 返回 Void 或 Future<Void>。
      - P3：ECS schedule 能等待或轮询 async systems，并区分 frame-bound task 与 background task。
  - ECS 与 async 集成：
      - Schedule 默认单帧不阻塞；async system 返回的 Task 交给 runtime poll。
      - Commands 仍在 ApplyDeferred 提交，async system 不能跨 await 持有 mutable world borrow。
      - 宏在编译期禁止 await 跨越 ResMut、QueryMut、Commands 未提交借用；需要先拷贝数据或拆成两个 system。
      - EventReader/EventWriter 支持 async task 完成后发事件。
  - Asset 与 async：
      - AssetServer.load<T>() 返回 Handle<T>，后台通过 Task 执行 fetch。
      - AssetServer.loadAsync<T>() 返回 Future<Handle<T>>。
      - loader 接口统一为 load(reader, settings, context):Future<Dynamic>。
 - Render：
      - WebGL2 先跑通，WebGPU 后端预留。
      - GPU/context 初始化走 async：canvas 获取、WebGL2 context 创建、shader/texture/asset loading 都基于 P0 async runtime。
      - MVP 示例：clear screen、triangle、rotating cube、async texture load。


  ## Implementation Phases


  1. P0 async macro foundation：
      - 建立 build-all.hxml 和宏测试入口。
      - 实现 Future<T>、Task<T>、AsyncRuntime。
      - 实现 async(...)、await(...)、forAwait(...) 宏 DSL。
      - 加入 async 编译期错误诊断和 JS/interp 双目标测试。
  2. Core ABI：
      - 新建 bevy.* runtime 包。
      - 实现 TypeId、registry、Entity generation、World、Resource、Events、Commands。
      - 确保 ECS 核心不依赖旧 haxe.ecs。
  3. Reflect + ECS macros：
      - 实现 @:reflect、@:component、@:resource、@:event、@:bundle。
      - 宏输出统一注册到 bevy.reflect.TypeRegistry 与 ECS registries。
  4. Schedule + systems：
      - 实现 App、Schedules、system params、run_if、sets、before/after。
      - @:system 支持 sync/async system。
      - async system await 边界执行借用检查。
  5. Asset/window/input：
      - Asset loading 完全使用 async runtime。
      - Window/input plugin 将 DOM events 注入 ECS。
      - App runner 使用 requestAnimationFrame。
  6. WebGL2 render：
      - 实现 WebGL2 backend abstraction。
      - 接入 mesh/material/camera/transform。
      - 完成最小渲染 examples 与 Playwright canvas 检查。
      ## Test Plan


  - Async macro：
      - await(Promise.resolve(1))
      - 嵌套 await、try/catch、return、throw。
      - forAwait(asyncRange, item -> ...)
      - join/race/cancel。
      - async system 中跨 await 持有 mutable ECS borrow 必须编译失败。
  - ECS：
      - spawn/insert/remove/despawn generation。
      - query filters、changed/added ticks、resources、events、commands flush。
      - sync 和 async systems 混合调度。
  - Asset/render：
      - fetch text/json/binary/image。
      - WebGL2 clear、triangle、cube。
      - texture 异步加载后渲染结果更新。


  ## Assumptions


  - for await (...) 原生语法不作为 Haxe 源码直接支持，因为 Haxe 4.3.6 解析阶段会报错。
  - 默认采用 forAwait(source, fn) DSL；如果必须使用字面量 for await，另起一个源码预处理阶段。
  - 第一目标平台是 JS/Web；WebGL2 优先，WebGPU 作为后续后端。