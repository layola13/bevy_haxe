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

## Upstream Dependency Notes

- Source of truth is the local Rust Bevy workspace at `~/projects/bevy`, not ad hoc Haxe API design.
- The port order must follow upstream crate dependencies from bottom to top:
  1. `bevy_platform`
  2. `bevy_tasks`
  3. `bevy_reflect`
  4. `bevy_ecs`
  5. `bevy_app`
  6. `bevy_asset`
  7. `bevy_window`
  8. `bevy_render`
- Direct upstream dependency facts recorded from `Cargo.toml`:
  - `bevy_platform`: foundational portability layer; provides `std`, `alloc`, `web`, `serialize`, `futures-lite`, `async-io`, synchronization primitives.
  - `bevy_tasks -> bevy_platform`: task executor layer depends on platform abstractions first.
  - `bevy_reflect -> bevy_platform`: reflection sits on top of platform support and derive/macros.
  - `bevy_ecs -> bevy_tasks + bevy_reflect? + bevy_platform`: ECS depends on task execution, platform support, and optional reflection.
  - `bevy_app -> bevy_ecs + bevy_reflect? + bevy_tasks + bevy_platform`: app lifecycle and plugin system sit above ECS, not below it.
  - `bevy_asset -> bevy_app + bevy_ecs + bevy_reflect + bevy_tasks + bevy_platform`: asset pipeline depends on the app/plugin/runtime stack and async task layer.
  - `bevy_window -> bevy_app + bevy_ecs + bevy_input + bevy_math + bevy_platform`, with optional `bevy_asset`/`bevy_image` for custom cursor support.
  - `bevy_render -> bevy_app + bevy_asset + bevy_ecs + bevy_reflect + bevy_tasks + bevy_window + bevy_platform` plus many render-domain crates (`bevy_image`, `bevy_mesh`, `bevy_shader`, `bevy_camera`, `bevy_time`, `bevy_transform`, `wgpu`).
- Practical implication for `bevy_haxe`:
  - Do not continue by inventing top-level render/window APIs first.
  - `bevy.app` runner/plugin lifecycle must be aligned with upstream before deeper `window` and `render` work.
  - `bevy.render` should only be expanded after the `app -> asset/window -> render` dependency chain is explicitly mirrored.

## Implementation Status

- Done: P0 async macro foundation started under `src/bevy/async` and `src/bevy/macro`.
- Done: `AsyncClass` provides `@:autoBuild` support for `@:async` methods.
- Done: `@await expr` and `@:await expr` are rewritten inside `@:async` methods.
- Done: `forAwait(source, value -> { ... @await ... })` is supported as the Haxe-compatible form of `for await`.
- Done: Promise-backed JS scheduling, `Future`, `Task`, `AsyncIterator`, `join`, `race`, and cancellation basics compile and run.
- Done: Core `bevy.ecs` ABI started with generation-safe `Entity`, `World`, resources, events, queries, change ticks, and deferred `Commands`.
- Done: Component/resource/event registration macro skeletons via `@:autoBuild`, feeding `ComponentRegistry`, `ResourceRegistry`, `EventRegistry`, and `TypeRegistry`.
- Done: Reflect macro skeleton via `bevy.reflect.Reflect` `@:autoBuild`, generating `typeInfo`, `getField`, `setField`, and TypeRegistry registration.
- Done: Basic app/schedule/system ABI with `App`, `Schedule`, `SystemRegistry`, `SystemClass`, and `@:system` static method registration.
- Done: `@:async @:system` methods can be registered and run through `App.update()` with schedule ordering preserved by Future chaining.
- Done: `bevy.app` was reshaped toward upstream `bevy_app`: `App` now owns plugin lifecycle state, `setRunner`, exit requests, and runner-driven execution instead of baking the loop directly into top-level app logic.
- Done: `ScheduleRunnerPlugin` and `RunMode` were added as the upstream-aligned headless runner entrypoint, replacing ad hoc loop ownership with plugin-provided runner configuration.
- Done: `App.update()` still drives `First -> PreUpdate -> Update -> PostUpdate -> Last`, advancing world ticks and clearing frame events after each frame.
- Done: Minimal `Plugin` interface is in place with lifecycle helpers (`ready`, `finish`, `cleanup`, uniqueness/name hooks via reflection helpers); `WindowPlugin`, `InputPlugin`, and `RenderPlugin` plug into `App` through `addPlugin` / `addPlugins`.
- Done: System param injection for `World`, `Res<T>`, `ResMut<T>`, and `Commands`, including deferred command apply after async systems complete.
- Done: Bundle macro skeleton via `bevy.ecs.Bundle`, auto-generating `toBundle()` and supporting `World.spawnBundle` / `Commands.spawnBundle`.
- Done: Minimal async asset pipeline with `AssetServer`, `Assets<T>`, `Handle<T>`, `TextAsset`, injectable sources, and JS fetch-backed default source.
- Done: Minimal window/canvas layer with `Window` resource and `WindowPlugin`; JS target can bind or create a canvas, interp target keeps resource state.
- Done: Minimal WebGL-ready render context with `RenderContext` and `RenderPlugin`; JS target compiles WebGL/WebGL2 binding code, interp target validates resource state.
- Done: System param injection now covers `Query<T>`, `Query2<A,B>`, `EventReader<T>`, and `EventWriter<T>`.
- Done: Initial async ECS borrow diagnostics prevent `@:async @:system` methods from taking `Commands` or `ResMut<T>` directly.
- Done: `bevy_asset` minimal upstream-aligned app integration is now in place: `AssetPlugin` installs `AssetServer`, `App.initAsset(...)` creates typed `Assets<T>` world resources, `App.registerAssetLoader(...)` registers typed loaders, and `AssetServer.load(...)` can drive typed asset loads through an extension macro path.
- Done: `World` resource storage now supports explicit parameterized resource keys, which fixes erased-generic collisions for `Assets<T>` and allows `Res<Assets<T>>` / `ResMut<Assets<T>>` system injection to resolve the correct typed asset collection.
- Done: `World` component storage now also supports explicit component keys, allowing erased-generic component families such as `Handle<Mesh>` and `Handle<Image>` to coexist in the same entity without collisions.
- Done: `Query<T>` / `Query2<A,B>` and `@:system` parameter injection were extended to propagate parameterized component keys, so generic component queries can resolve the correct storage instead of collapsing to the raw runtime class.
- Done: `World.isAdded(...)` / `isChanged(...)` now also accept explicit component keys, completing change-tick support for erased-generic component families instead of only plain runtime classes.
- Done: `bevy.app.Plugin` lifecycle remains intact after the ECS/world/query refactor, and current app/plugin tests still pass against the updated world/query internals.
- Done: `PluginGroupBuilder` / `App.addPluginGroup(...)` are now in place for `bevy.app`, with type-driven ordering/enable/disable/contains/set semantics closer to upstream `bevy_app::plugin_group` than the earlier string-based placeholder.
- Done: `Query<T>` / `Query2<A,B>` now expose a less ad hoc surface for ECS work (`iter`, `isEmpty`, `getSingle`, `single`) and allow `with` / `without` filters to target explicit component keys, which matters for typed generic component families.
- Done: dedicated ECS query filter types now exist under `bevy.ecs` as `With<T>`, `Without<T>`, `Added<T>`, and `Changed<T>`, and `World.queryFiltered(...)` / `queryFilteredPair(...)` can consume them instead of relying only on fluent helper methods.
- Done: composite query filters now have runtime support via `All` and `Or`, which gives `bevy.ecs.Query` a concrete path toward upstream tuple-filter and `Or<(...)>` semantics instead of only leaf filter chaining.
- Done: `bevy.ecs.Query` now accepts an optional filter type parameter (`Query<Data, Filter>`), and `@:system` parameter injection can materialize `With` / `Without` / `All` / `Or` filter trees directly from the declared system signature instead of forcing manual post-construction chaining in every system body.
- Done: `Query<Data, Filter>` system injection is verified end-to-end in `AppScheduleTest`, including `Or<With<A>, Without<B>>` composition.
- Done: `@:system` now captures a per-system `lastRunTick` inside the generated closure, which makes `Query<Data, Added<T>>` and `Query<Data, Changed<T>>` filters usable from system parameter signatures with real per-system history instead of placeholder behavior.
- Done: `Query<Data, Added<T>>` and `Query<Data, Changed<T>>` system injection is verified in `AppScheduleTest` across multiple `update()` calls.
- Done: `bevy.app.Schedule` now honors `@:before("...")` / `@:after("...")` metadata on registered `@:system` functions by building a dependency graph and topologically ordering systems within the schedule instead of always running in registration order.
- Done: `before/after` ordering is verified in `AppScheduleTest` with a registered `PostUpdate` system chain that would fail if execution remained purely append-order.
- Done: `bevy.app.Schedule` now honors `@:runIf(...)` metadata on registered `@:system` functions, with support for synchronous `Bool` conditions, asynchronous `Future<Bool>` conditions, and condition functions that consume injected params such as `Res<T>` and `Query<Data, Filter>`.
- Done: `run_if` gating is verified in `AppScheduleTest` with sync, async, and query-backed condition functions.
- Done: `bevy.app.Schedule` now supports simple system-set membership and configuration through `@:inSet("...")`, `@:setAfter("...")`, and `@:setRunIf(...)`, allowing grouped systems to share ordering and conditions instead of repeating configuration per system.
- Done: set-level ordering and set-level `run_if` are verified in `AppScheduleTest`.
- Done: runtime schedule configuration now also has a direct API via `bevy.app.SystemConfigBuilder` and `SystemSetConfigBuilder`, so ordering, set membership, and conditions are not limited to `@:system` metadata entrypoints.
- Done: runtime builder-based schedule configuration is verified in `AppScheduleTest`.
- Done: compile-time guard rails were tightened for unsafe mutable paths: `@:async @:system` now rejects `EventWriter<T>` in addition to `Commands` / `ResMut<T>`, and `@:runIf(...)` conditions now reject `World` / `Commands` / `ResMut<T>` / `EventWriter<T>` entrypoints so read-only conditions cannot quietly become world-mutation hooks.
- Done: macro constraint regressions are now covered by `MacroConstraintTest`, which performs negative compile tests for invalid `@:async` / `@:runIf(...)` signatures, direct query overlaps, composite `All/Or` query disjointness/conflicts, and `Changed<T>`-driven query overlap.
- Done: `World` now exposes more upstream-aligned direct APIs for ECS-heavy code paths: `getResourceOrInsert(...)`, `getResourceOrInsertByKey(...)`, `containsResource(...)`, `containsResourceByKey(...)`, `resourceScope(...)`, and `resourceScopeByKey(...)`.
- Done: `World` now also exposes more upstream-shaped entity access entrypoints: `spawnEmpty()`, `containsEntity(...)`, `getEntity(...)`, `entity(...)`, `getEntityMut(...)`, `entityMut(...)`, and `iterEntities()`, plus typed `EntityRef` / `EntityWorldMut` wrappers for component reads and structural mutation.
- Done: `Query` / `Query2` now expose more upstream-shaped direct access semantics with `contains(...)`, `get(...)`, `getMany(...)`, and `singleOrNull()`, which reduces pressure to drop down to ad hoc `World` iteration for common ECS reads.
- Done: `Query` / `Query2` / `Query3` now also expose `count()` and `iterMany(...)`, and `getMany(...)` was tightened toward upstream semantics by failing if any requested entity does not satisfy the query instead of silently dropping mismatches.
- Done: `World.query(Entity, ...)` and `Query<Entity, Filter>` are now supported, including `@:system` parameter injection coverage for `Query<Entity, With<T>>`, which is a necessary bridge toward upstream `Query<Entity, With<T>>`-style system patterns instead of treating all query data as component fetches only.
- Done: `Query2<A, B, Filter>` is now supported both for direct world usage and `@:system` parameter injection, which closes the type-level filter gap between single-component and pair queries.
- Done: mixed entity/component query data is now supported for the current multi-data ladder as well, so `Query2<Entity, T, Filter>` and `Query3<Entity, A, B, Filter>` work both through direct world queries and `@:system` parameter injection instead of treating `Entity` as if it were a stored component.
- Done: `@:system` compile-time diagnostics now perform a stronger first-pass conflict analysis across multiple `Query` / `Query2` / `Query3` params, rejecting obvious overlapping component accesses and statically proving more disjoint cases across `With<T>` / `Without<T>` / `All<...>` / `Or<...>` filter combinations.
- Done: query-conflict diagnostics now also treat `Added<T>` / `Changed<T>` filter usage as component access for overlap analysis, which closes a real correctness hole where a query filter could alias a direct query on the same component.
- Done: `Query3<A, B, C>` and `Query3<A, B, C, Filter>` are now supported for direct world usage and `@:system` parameter injection, extending the typed multi-component query path one step closer to upstream tuple-query ergonomics.
- Done: `PluginGroupBuilder` was pushed closer to upstream usage as a first-class typed builder surface and now directly implements `PluginGroup`, so `App.addPluginGroup(...)` can consume a configured builder without an adapter wrapper.
- Done: `App.addPlugins(...)` is now a unified typed composition entrypoint over `Plugin`, `PluginGroup`, `PluginGroupBuilder`, and nested arrays of those compositions, which moves `bevy.app` closer to upstream plugin-composition semantics even though Haxe still lacks the original Rust tuple syntax.
- Done: `bevy.app.PluginsDsl.of(...)` now provides a macro-backed varargs composition DSL for plugin/group/builder nesting at the call site, reducing array boilerplate while still lowering into the typed `Plugins` composition core.
- Done: `PluginGroupBuilder` now also exposes overwrite-aware insertion helpers closer to upstream builder semantics (`tryAddBeforeOverwrite(...)`, `tryAddAfterOverwrite(...)`), and `App.isPluginAdded(...)` now exists as a typed plugin registration check.
- Done: system-param borrow diagnostics now also catch same-resource conflicts (`Res<T>` + `ResMut<T>`, duplicate `ResMut<T>`), same-event conflicts (`EventReader<T>` + `EventWriter<T>` / duplicate writer), and exclusive-`World` misuse (`World` mixed with any other system param) at compile time.
- Done: registered schedule tests were updated to use more upstream-like `Res` / `ResMut` / `Commands` / exclusive `World` boundaries instead of loosely mixing `World` with arbitrary other params.
- Verified: `haxe test.hxml`, `haxe build-all.hxml`, JS compile for `app.AppRunTest` and `BuildAll`, plus earlier JS compile/node runs for async, ECS core, ECS macro, reflect macro, app schedule, and asset pipeline tests.
- Remaining: richer async borrow diagnostics, full WebGL2 draw pipeline, and WebGPU-ready render abstraction.
- Remaining: `bevy.ecs` / `bevy.app` / `Query` are still only a minimal subset of upstream Bevy. Missing major upstream-aligned surfaces include broader macro/type-level query data/filter tuple coverage beyond the current `Query` / `Query2` / `Query3` ladder, still-fuller query conflict analysis for more of upstream Bevy's nested tuple/filter space, original tuple plugin composition syntax (`addPlugins((...))`-style rather than Haxe macro/array DSL), richer tuple-style schedule config composition, more exact query/world error/result types instead of string-throwing fast paths, and deeper async borrow-checked system param semantics beyond the current signature-level bans.

## Asset Notes

- `AssetServer.load(...)` / `loadState(...)` are currently provided through Haxe extension macros in `bevy.asset.AssetLoad`.
- Because of Haxe macro visibility rules, call sites should explicitly opt in with `using bevy.asset.AssetLoad;` when they want the upstream-like `assetServer.load("path")` syntax.
- This keeps the public call shape close to upstream Bevy while avoiding an invented alternate API such as mandatory explicit `Class<T>` arguments at each load call.
