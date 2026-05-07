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
- Done: `test/constraint` query constraint coverage no longer relies on empty component shells or no-op `toArray()` probes. Allowed/disjoint query constraints now construct real entities, run the registered `Update` system, and assert `ConstraintCounter` totals from actual component fields; rejected conflict constraints now use stateful component/event data and field-reading iteration bodies while still failing at the intended compile-time diagnostics.
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
- Done: tuple-style query data now has a macro-backed bridge path without breaking existing `Query2/Query3` interfaces: `@:system` parameter injection supports `Query<Tuple2<A,B>, F>` and `Query<Tuple3<A,B,C>, F>` by lowering to the existing typed world pair/triple query core (`queryFilteredPair/queryFilteredTriple`) and wrapping back into `Query`-compatible item shape (`QueryItem.component` as tuple data).
- Done: `bevy.ecs.Tuple` moved from hand-written fixed tuple classes to Haxe macro generation (`@:genericBuild` + `Context.defineType`), so tuple carrier types are compiler-generated instead of manually hardcoded.
- Done: tuple query compatibility keeps existing call sites intact (no interface regression): legacy `Query2/Query3` system params and APIs remain valid, while tuple-style `Query<TupleN<...>>` adds an upstream-closer query-data expression path in Haxe.
- Done: tuple carrier coverage now includes `Tuple1` in `bevy.ecs.Tuple`, so tuple macro path is no longer artificially restricted to arity >= 2.
- Done: compile-time query conflict analysis in `SystemMacro` now recognizes tuple query data (`Query<Tuple2<...>>` / `Query<Tuple3<...>>`) and applies the same overlap/disjoint checks as existing `Query` / `Query2` / `Query3` paths.
- Done: tuple query system-injection and conflict behavior are covered by tests (`AppScheduleTest` tuple query systems and `QueryTupleConflictConstraint` in `MacroConstraintTest`).
- Done: tuple query injection path keeps strong typing end-to-end (no Dynamic placeholder fallback): tuple data construction is generated by `SystemMacro` from concrete tuple type arguments, and `QueryTuple<T>` receives a typed tuple factory closure instead of runtime `Dynamic` class fallback.
- Done: tuple query system injection was generalized from fixed `Tuple2`/`Tuple3` lowering to a single macro path over `QueryTuple<T>` plus world-side tuple scan (`World.queryTuple(...)`), so tuple query arity can scale without hand-written `Query4/Query5/...` classes.
- Done: tuple query regression coverage now includes arity-4 runtime behavior (`Query<Tuple4<...>>` in `AppScheduleTest`) and arity-4 conflict diagnostics (`QueryTuple4ConflictConstraint` in `MacroConstraintTest`).
- Done: tuple query regression coverage is now extended to arity-5 as well (`Query<Tuple5<...>>` runtime injection in `AppScheduleTest` and `QueryTuple5ConflictConstraint` compile-fail diagnostics in `MacroConstraintTest`), confirming the generalized tuple macro path keeps scaling without hand-written `Query5`.
- Done: tuple query generalized path now also has double-digit arity verification (`Query<Tuple10<...>>` runtime injection + `QueryTuple10ConflictConstraint` compile-fail coverage), reducing risk that tuple-name parsing or macro lowering only works for low arities.
- Done: tuple query generalized path now also has upper-bound arity verification (`Query<Tuple15<...>>` runtime injection in `AppScheduleTest` + `QueryTuple15ConflictConstraint` compile-fail coverage), confirming the macro tuple bridge remains stable at the current tuple carrier ceiling without introducing `Query15`-style hand-written APIs.
- Done: tuple query upper-bound arity checks now include both reject and allow compile-time proofs (`QueryTuple15ConflictConstraint` reject + `QueryTuple15DisjointConstraint` allow), reducing risk that high-arity tuple conflict analysis only handles failure cases but regresses disjoint acceptance.
- Done: tuple query arity parity is now widened further with additional mid/high arities. `MacroConstraintTest` now includes both conflict and disjoint checks for `Tuple6` (`QueryTuple6ConflictConstraint`, `QueryTuple6DisjointConstraint`) and `Tuple12` (`QueryTuple12ConflictConstraint`, `QueryTuple12DisjointConstraint`), and `AppScheduleTest` runtime injection now includes `Query<Tuple6<...>>` and `Query<Tuple12<...>>` systems with deterministic totals. This reduces the remaining risk that tuple macro lowering only holds for the previously validated 1/2/4/5/10/15 arity set.
- Done: tuple query synthetic-data coverage is now extended for `Ref<T>` / `Mut<T>` inside tuple data. Runtime system injection in `AppScheduleTest` now includes `Query<Tuple<Ref<AppPosition>, AppTag>>` and `Query<Tuple<Mut<AppVelocity>, AppTag>>` with deterministic first-run totals and change-marker assertions. Compile-time conflict matrix in `MacroConstraintTest` now includes tuple forms as well: reject `Tuple<Ref<T>, ...>` overlap (`QueryTupleRefConflictConstraint`), allow explicit disjoint (`QueryTupleRefDisjointConstraint`), reject `Tuple<Mut<T>, ...>` overlap (`QueryTupleMutConflictConstraint`), allow explicit disjoint (`QueryTupleMutDisjointConstraint`), and reject tuple `Ref<T>`/`Mut<T>` overlap (`QueryTupleRefMutConflictConstraint`).
- Done: query-conflict analysis breadth is now extended for `Query2` / `Query3` with tuple-filter and nested tuple-or filter forms (not only `Query<T, Tuple...>`). `MacroConstraintTest` now includes:
  - `QueryPairFilterTupleConflictConstraint` / `QueryPairFilterTupleDisjointConstraint`
  - `QueryTripleFilterTupleConflictConstraint` / `QueryTripleFilterTupleDisjointConstraint`
  - `QueryPairNestedTupleOrConflictConstraint` / `QueryPairNestedTupleOrDisjointConstraint`
  - `QueryTripleNestedTupleOrConflictConstraint` / `QueryTripleNestedTupleOrDisjointConstraint`
  These lock branch-level satisfiability behavior for `Tuple2<...>` conjunctions and `Or<Tuple2<...>, ...>` compositions in pair/triple query signatures, reducing a previous coverage gap in `SystemMacro` disjointness proofs.
- Done: duplicate-data conflict diagnostics now explicitly cover `Ref<T>` / `Mut<T>` wrappers inside the same query parameter, not just plain `T` duplicates. `MacroConstraintTest` now includes reject cases for:
  - `Query2<Ref<T>, T>`, `Query2<Mut<T>, T>`, `Query2<Ref<T>, Mut<T>>`
  - `Query3<Ref<T>, T, ...>`, `Query3<Mut<T>, T, ...>`, `Query3<Ref<T>, Mut<T>, ...>`
  - `Query<Tuple<Ref<T>, T>>`, `Query<Tuple<Mut<T>, T>>`, `Query<Tuple<Ref<T>, Mut<T>>>`
  via `QueryPairRefDuplicateConstraint`, `QueryPairMutDuplicateConstraint`, `QueryPairRefMutDuplicateConstraint`, `QueryTripleRefDuplicateConstraint`, `QueryTripleMutDuplicateConstraint`, `QueryTripleRefMutDuplicateConstraint`, `QueryTupleRefDuplicateConstraint`, `QueryTupleMutDuplicateConstraint`, `QueryTupleRefMutDuplicateConstraint`. This locks the “same-component key cannot appear twice in one query data shape” rule across wrapper forms.
- Done: tuple query now also supports generic tuple carrier spelling (`Query<Tuple<...>>`) in addition to `TupleN`, with runtime injection coverage in `AppScheduleTest` and compile-time conflict/disjoint checks (`QueryTupleGenericConflictConstraint` / `QueryTupleGenericDisjointConstraint`) in `MacroConstraintTest`, while preserving existing `Tuple1..Tuple15` interfaces.
- Done: generic tuple carrier conflict analysis parity was extended to temporal filters as well (`QueryTupleGenericAddedConflictConstraint` / `QueryTupleGenericAddedDisjointConstraint` and `QueryTupleGenericChangedConflictConstraint` / `QueryTupleGenericChangedDisjointConstraint`), confirming `Query<Tuple<...>, Added/Changed<...>>` follows the same reject/allow rules as existing `TupleN` query paths.
- Done: runtime semantics for generic tuple carrier were expanded beyond base iteration: `Query<Tuple<...>, With<...>>`, `Query<Tuple<...>, Added<...>>`, and `Query<Tuple<...>, Changed<...>>` are now covered in `AppScheduleTest`, verifying generic tuple query behavior across filter and change-tick paths, not only plain tuple data fetch.
- Done: compile-time conflict analysis parity for generic tuple carrier now also covers composite filter branches (`QueryTupleGenericCompositeConflictConstraint`, `QueryTupleGenericCompositeDisjointConstraint`, `QueryTupleGenericOrBranchConflictConstraint`), aligning `Query<Tuple<...>>` branch-sensitive `Or`/`Without` overlap behavior with the existing `TupleN` tuple-query constraint model.
- Done: runtime generic tuple carrier coverage now includes composite filter behavior (`Or`/`All`, plus `Or<Added<...>, ...>` and `Or<Changed<...>, ...>`), so `Query<Tuple<...>>` runtime semantics are validated across both structural and temporal composite filter paths, not only simple `With`/`Added`/`Changed`.
- Done: runtime generic tuple carrier coverage now also includes parameterized generic component key paths (`Query<Tuple<Handle<AppAssetA>, Handle<AppAssetB>>>` data and `With<Handle<AppAssetB>>` filter), confirming the generic `Tuple` spelling keeps the same `TypeKey` behavior as existing `Tuple2` query paths for erased-generic component families.
- Done: generic tuple carrier compile-time checks now also cover duplicate data rejection and data-driven disjoint proofs (`QueryTupleGenericDuplicateConstraint`, `QueryTupleGenericDataDisjointConstraint`), aligning `Query<Tuple<...>>` safety diagnostics with existing tuple-query rules for repeated component access and `Without<...>`-based disjointness.
- Done: generic tuple carrier runtime path now also validates mixed `Entity + Component` query data (`Query<Tuple<Entity, T>, Filter>` in `AppScheduleTest`), confirming `Entity` is treated as tuple data (not a component storage key) under the generic `Tuple` spelling just like existing `TupleN` / `Query2<Entity, T>` semantics.
- Done: generic tuple carrier compile-time diagnostics now also cover mixed `Entity + Component` data in conflict/disjoint analysis (`QueryTupleGenericEntityConflictConstraint`, `QueryTupleGenericEntityDisjointConstraint`), validating that `Entity` in tuple data does not weaken overlap detection on component `T`.
- Done: generic tuple carrier temporal composite diagnostics are now covered with explicit reject/allow proofs (`QueryTupleGenericAddedCompositeConflictConstraint` / `QueryTupleGenericAddedCompositeDisjointConstraint` and `QueryTupleGenericChangedCompositeConflictConstraint` / `QueryTupleGenericChangedCompositeDisjointConstraint`), aligning `Query<Tuple<...>>` branch-sensitive temporal overlap rules with existing `TupleN` diagnostics.
- Done: generic tuple carrier mixed-entity temporal diagnostics were expanded (`QueryTupleGenericEntityChangedConflictConstraint`, `QueryTupleGenericEntityChangedDisjointConstraint`), validating that `Query<Tuple<Entity, A, B>>` participates correctly in `Changed<A>` overlap/disjoint analysis under explicit `With/Without` filters.
- Done: `Query2<A, B, Filter>` conflict-analysis parity was expanded with temporal and composite branch coverage (`QueryPairAdded*`, `QueryPairChanged*`, `QueryPairComposite*`, `QueryPairOrBranchConflictConstraint`), aligning pair-query overlap/disjoint proofs with the tuple-query branch model instead of relying only on the original minimal pair-overlap case.
- Done: `Query3<Entity, A, B, Filter>` temporal overlap/disjoint diagnostics are now explicitly covered (`QueryTripleEntityAddedConflictConstraint` / `QueryTripleEntityAddedDisjointConstraint` and `QueryTripleEntityChangedConflictConstraint` / `QueryTripleEntityChangedDisjointConstraint`), with the allowed cases constructing real component data, running the registered `Update` system, and asserting query-derived resource totals rather than relying on empty constraint shells.
- Done: tuple query generalized path now also has arity-1 verification (`Query<Tuple1<...>>` runtime injection in `AppScheduleTest`, plus `QueryTuple1ConflictConstraint` reject and `QueryTuple1DisjointConstraint` allow in `MacroConstraintTest`), closing the single-item tuple edge case.
- Done: tuple query type detection in `SystemMacro` was tightened to explicit tuple-type paths (`TupleN` / `bevy.ecs.Tuple.TupleN`) rather than broad prefix matching, reducing accidental tuple-query lowering on unrelated types while preserving current API shape.
- Done: query conflict analysis tuple-branch selection in `SystemMacro` now only lowers into tuple conflict logic when tuple data is actually present, preserving plain `Query<T>` behavior while adding `Tuple1` conflict coverage.
- Done: newly introduced tuple-query internal bridge (`QueryTuple` / `World.queryTuple` / generated tuple factory signature) now uses `Any`-typed carriers instead of introducing extra `Dynamic`-typed public-facing plumbing, keeping the path aligned with the project constraint of minimizing new Dynamic-layer APIs.
- Done: `src/bevy/ecs/Tuple.hx` no longer carries hand-written empty `Tuple1` ... `Tuple15` classes. `Tuple` is the single `@:genericBuild` anchor and the numbered names are now typedef compatibility aliases (`Tuple2<A, B> = Tuple<A, B>` etc.), while `SystemMacro` resolves numbered aliases back to the macro-generated `Tuple_<arity>` runtime carrier so existing `Query<TupleN<...>>` interfaces continue to work.
- Done: upstream-style tuple `QueryFilter` blanket behavior is now represented for Haxe tuple carriers: macro-generated `Tuple_<arity>` classes implement `QueryFilter`, and `SystemMacro` treats `Tuple<With<A>, Without<B>, ...>` / `TupleN<...>` filter parameters as conjunctions, matching Bevy's `impl QueryFilter for (F0, F1, ...)` shape instead of inventing another wrapper API. `AppScheduleTest.tupleFilterQuerySystem` verifies real system injection and filtering, `AppScheduleTest.nestedTupleFilterOrQuerySystem` verifies nested `Or<Tuple2<...>, ...>` keeps the tuple as one AND branch instead of flattening it into separate OR branches, and `QueryFilterTupleConflictConstraint` / `QueryFilterTupleDisjointConstraint` verify compile-time conflict rejection and allowed disjoint tuple-filter proofs.
- Done: tuple query conflict coverage now includes both rejection and allowed-disjoint paths (`QueryTupleDisjointConstraint`), so macro diagnostics are validated for valid `With/Without` tuple query splits as well as overlap failures.
- Done: reserved/spawned entity access boundaries got explicit regression coverage (`testReservedEntityAccessSemantics` in `EcsCoreTest`) for `containsEntity` / `isAlive` / `getEntity` / `getEntityMut` before and after deferred `Commands.spawn().apply()`.
- Done: tuple query conflict diagnostics now also cover duplicate tuple data access (`Query<Tuple2<T, T>>` compile-fail via `QueryTupleDuplicateConstraint`), preventing silent aliasing inside tuple query data declarations.
- Done: tuple query conflict analysis coverage now includes `Changed<T>` interaction paths (`QueryTupleChangedConflictConstraint` reject + `QueryTupleChangedDisjointConstraint` allow), extending tuple-filter access checks beyond plain `With/Without` overlap.
- Done: tuple query conflict analysis coverage now also includes `Added<T>` interaction (`QueryTupleAddedConflictConstraint` compile-fail, wired into `MacroConstraintTest`), ensuring tuple query access overlap rules remain consistent across both `Added<T>` and `Changed<T>` filters.
- Done: query conflict analysis now treats query data components as branch-level required access for disjoint proofs, fixing a real false-positive case (`Query<Tuple2<A,B>>` vs `Query<A, Without<B>>`) and locking it via `QueryTupleDataDisjointConstraint`.
- Done: the same data-required disjoint proof fix is now validated across the ladder (`Query2` + `Query3` with `Without<...>` disjoint cases), not only tuple-query wrappers, via `QueryPairDataDisjointConstraint` and `QueryTripleDataDisjointConstraint`.
- Done: tuple disjoint proof coverage now also includes composite `Or<...>` filter branches (`QueryTupleCompositeDisjointConstraint`), strengthening conflict-analysis validation for non-linear filter trees.
- Done: tuple query composite conflict coverage now also includes an explicit reject path with `Or<With<...>, With<...>>` vs `Without<...>` (`QueryTupleCompositeConflictConstraint`), verifying that tuple-query branch analysis rejects overlap when at least one branch remains satisfiable.
- Done: tuple query branch-sensitive conflict coverage now includes an `Or` case where one branch overlaps and another is impossible (`QueryTupleOrBranchConflictConstraint`), locking the upstream-like rule that any satisfiable overlapping branch must be rejected.
- Done: tuple query `Added<T>` disjoint-proof coverage now includes an explicit allow path (`QueryTupleAddedDisjointConstraint`), complementing existing `Added<T>` conflict coverage and aligning `Added` behavior with the existing `Changed` disjoint model.
- Done: tuple query `Added<T>` / `Changed<T>` composite-filter conflict coverage is now expanded with explicit reject paths (`QueryTupleAddedCompositeConflictConstraint`, `QueryTupleChangedCompositeConflictConstraint`) where `Or` branches leave at least one satisfiable overlap.
- Done: tuple query `Added<T>` / `Changed<T>` composite-filter disjoint-proof coverage is now expanded with explicit allow paths (`QueryTupleAddedCompositeDisjointConstraint`, `QueryTupleChangedCompositeDisjointConstraint`) where `All<With/Without/...>` constraints make overlap unsatisfiable.
- Done: runtime tuple-filter coverage now also exercises `Added<T>` / `Changed<T>` on tuple data (`Query<Tuple2<...>, Added<...>>` and `Query<Tuple2<...>, Changed<...>>` paths in `AppScheduleTest`), so tuple query filters are validated beyond `With/Without`.
- Done: runtime tuple-filter coverage now also includes composite `Or<...>` / `All<...>` tuple-query filters (`tupleCompositeOrQuerySystem`, `tupleCompositeAllQuerySystem` in `AppScheduleTest`), confirming tuple query filter composition beyond leaf filters at runtime.
- Done: runtime tuple-filter coverage now also includes composite `Or<Added<...>, ...>` and `Or<Changed<...>, ...>` tuple-query filters (`tupleAddedCompositeOrQuerySystem`, `tupleChangedCompositeOrQuerySystem`), verifying temporal filter semantics remain correct inside composite filter trees across multiple frames.
- Done: tuple-query runtime coverage now also verifies parameterized generic component keys in tuple data and filters (`Query<Tuple2<Handle<AppAssetA>, Handle<AppAssetB>>>` and `Query<Tuple1<...>, With<Handle<AppAssetB>>>` in `AppScheduleTest`), ensuring tuple macro injection keeps `TypeKey.ofParameterizedClass(...)` alignment instead of collapsing erased generic handle storage.
- Done: tuple `Changed<T>` runtime verification now runs after tracked mutation (`@:after("...mutateTrackedPosition")` on tuple-changed system), ensuring second-frame tuple-changed assertions reflect post-mutation state rather than pre-mutation schedule order artifacts.
- Done: `PluginGroupBuilder` was pushed closer to upstream usage as a first-class typed builder surface and now directly implements `PluginGroup`, so `App.addPluginGroup(...)` can consume a configured builder without an adapter wrapper.
- Done: `App.addPlugins(...)` is now a unified typed composition entrypoint over `Plugin`, `PluginGroup`, `PluginGroupBuilder`, and nested arrays of those compositions, which moves `bevy.app` closer to upstream plugin-composition semantics even though Haxe still lacks the original Rust tuple syntax.
- Done: `bevy.app.PluginsDsl.of(...)` now provides a macro-backed varargs composition DSL for plugin/group/builder nesting at the call site, reducing array boilerplate while still lowering into the typed `Plugins` composition core.
- Done: `PluginGroupBuilder` now also exposes overwrite-aware insertion helpers closer to upstream builder semantics (`tryAddBeforeOverwrite(...)`, `tryAddAfterOverwrite(...)`), and `App.isPluginAdded(...)` now exists as a typed plugin registration check.
- Done: system-param borrow diagnostics now also catch same-resource conflicts (`Res<T>` + `ResMut<T>`, duplicate `ResMut<T>`), same-event conflicts (`EventReader<T>` + `EventWriter<T>` / duplicate writer), and exclusive-`World` misuse (`World` mixed with any other system param) at compile time.
- Done: registered schedule tests were updated to use more upstream-like `Res` / `ResMut` / `Commands` / exclusive `World` boundaries instead of loosely mixing `World` with arbitrary other params.
- Done: `World` now supports reserved-then-materialized entity flow with explicit entrypoints `reserveEntity()`, `reserveEntities(...)`, and `spawnReserved(...)`, enabling closer alignment to upstream Bevy's "valid but not spawned" lifecycle stage.
- Done: `Commands.spawn(...)` / `spawnBundle(...)` / `spawnEmpty()` now reserve entity ids first and defer actual world spawn until `apply()`, while preserving the existing public method signatures in this repo.
- Done: `World.containsEntity(...)` now tracks entity id validity (including reserved ids), while `isAlive(...)` / `getEntity(...)` / queries remain spawned-only visibility, matching upstream's valid-vs-spawned distinction more closely.
- Done: typed batch spawn entrypoints were added with preserved public style: `World.spawnBatch(...)` (immediate materialization) and `Commands.spawnBatch(...)` (reserved ids, deferred materialization at apply).
- Done: ECS regression coverage now explicitly verifies deferred spawn invisibility/visibility boundaries and batch spawn ordering/data consistency (`testDeferredSpawnSemantics`, `testSpawnBatchSemantics`) in `EcsCoreTest`.
- Done: reservation/spawn typed error semantics were threaded through world access and spawn paths: `World.spawnReserved(...)` now distinguishes `SpawnError.Invalid(...)` vs `SpawnError.AlreadySpawned`, and `World.entity(...)` / `entityMut(...)` / mutation fast paths now preserve `EntityNotSpawnedKind.Invalid(...)` vs `EntityNotSpawnedKind.ValidButNotSpawned` instead of collapsing to generic fallback errors.
- Done: `EcsCoreTest` typed-error coverage now asserts the concrete error kinds for stale ids, reserved-not-spawned ids, and already-spawned ids, so these semantics are locked by tests instead of relying on ad hoc exception text.
- Done: `Query.single()` error reporting is now closer to upstream `bevy_ecs`: the existing repo-facing catch surface stays intact through `QuerySingleMissingError`, but the underlying kind now distinguishes `NoEntities` from `MultipleEntities`, with dedicated subclasses and regression coverage in `EcsCoreTest`.
- Done: `Query.getMany(...)` now separates entity lifecycle failures from plain query mismatches, closer to upstream `QueryEntityError`: stale / not-spawned entities raise `QueryEntityNotSpawnedError` with preserved `EntityNotSpawnedKind`, while live-but-nonmatching entities still raise `QueryDoesNotMatchError`.
- Done: `Commands` now also exposes explicit entity-lifecycle access split closer to upstream (`getEntity(...)` for valid ids including reserved, `getSpawnedEntity(...)` for currently spawned ids), without changing existing `entity(...)` call shape.
- Done: `EcsCoreTest` now validates the new command-entity split across reserved/spawned/stale cases (`testCommandGetEntitySemantics`), including typed error kinds (`ValidButNotSpawned` vs `Invalid`).
- Done: upstream-shaped unique entity query access is now represented by `UniqueEntityArray` plus `Query.getManyUnique(...)` / `iterManyUnique(...)` on `Query`, `Query2`, `Query3`, and tuple-query wrappers. `UniqueEntityArray` rejects duplicate entities with typed `DuplicateEntityError`; `EcsCoreTest.testQueryUniqueEntityAccess` verifies order preservation, non-matching skip behavior for iteration, mixed `Entity + Component` query data, and duplicate diagnostics, while `AppScheduleTest.tuplePairUniqueQuerySystem` verifies the tuple-query wrapper path under real `@:system` injection.
- Done: upstream-shaped read-only query combinations are now available as `iterCombinations(k)` on `Query`, `Query2`, `Query3`, and tuple-query wrappers. The implementation produces non-repeating entity combinations for arbitrary `k`, with `EcsCoreTest.testQueryIterCombinations` validating pair/triple counts, no repeated entities, multi-component data preservation, and mixed `Entity + Component` query data. `AppScheduleTest.tuplePairCombinationQuerySystem` now also spawns two dedicated tuple-query entities and asserts both combination count and tuple component totals under real `@:system` injection.
- Done: `bevy.ecs.TypeKey` now throws typed ECS errors (`TypeKeyError` + `TypeKeyErrorKind`) instead of raw string exceptions for empty names / classless values / anonymous classes, continuing the error-surface hardening toward upstream-style explicit error types.
- Done: `EcsCoreTest` now validates `TypeKey` typed errors (`testTypeKeyTypedErrors`) for `EmptyName` and `ValueWithoutClass` branches.
- Done: `bevy.ecs.Or` empty-child validation now throws typed ECS errors (`QueryFilterError` + `QueryFilterErrorKind.OrRequiresChildren`) instead of raw string exceptions.
- Done: `EcsCoreTest` now validates typed query-filter error handling for `Or.of([])` (`testQueryFilterTypedErrors`).
- Done: `bevy.app.App` duplicate-plugin uniqueness rejection now throws typed app errors (`AppError` + `AppErrorKind.PluginAlreadyAdded`) instead of raw string exceptions, while preserving the existing `addPlugin` call shape.
- Done: `AppRunTest` now validates duplicate-plugin typed error behavior (`testPluginUniquenessTypedError`), including preservation of plugin-name context.
- Done: `bevy.app.Schedule` ordering/set/run_if validation errors now throw typed app errors (`AppErrorKind.ScheduleOrderingCycle`, `ScheduleOrderingSourceMissing`, `ScheduleOrderingTargetMissing`, `ScheduleSetEmptyName`, `ScheduleSetHasNoSystems`, `ScheduleRunIfNotBool`) instead of raw string exceptions.
- Done: `AppScheduleTest` now validates the new typed schedule error branches (`testScheduleTypedErrors`) with explicit negative cases for cycle, missing ordering reference, empty set name, set-without-members, and non-bool `run_if`.
- Done: `bevy.app.PluginGroupBuilder` error paths now throw typed app errors (`PluginGroupPluginMissing`, `PluginGroupAddFailed`, `PluginWithoutRuntimeClass`, `PluginClassNameUnavailable`) instead of raw string exceptions.
- Done: `AppRunTest` now validates plugin-group typed errors for missing target plugins and nested add failures (`testPluginGroupTypedErrors`).
- Done: upstream `bevy_ecs::query::Spawned` semantics now have a Haxe query-filter bridge: `Spawned` is a zero-component-access filter, entity spawn ticks are recorded when reserved ids are actually materialized, `Query<T, Spawned>` / composite `All<Spawned, ...>` system injection uses each system's last-run tick, and command-spawned entities remain query-invisible until deferred commands apply. Runtime coverage in `EcsCoreTest` and `AppScheduleTest` verifies first-run inclusion, deferred command visibility, and non-repetition after observation; `MacroConstraintTest` adds non-empty conflict/disjoint checks proving `Spawned` itself does not provide component disjointness.
- Done: upstream `bevy_ecs::query::SpawnDetails` now has a Haxe query-data bridge instead of being modeled as a component. `SpawnDetails` exposes `isSpawned()`, `isSpawnedAfter(...)`, `spawnTick()`, and `spawnedBy()`, and World/Query/Query2/Query3/tuple-query paths treat it like `Entity`: synthetic read-only query data with no component storage key and no component conflict access. Entity materialization records real spawn-source metadata for direct `World.spawn*` and deferred `Commands.spawn*` paths, with commands capturing the source at queue time rather than at apply time. Runtime coverage verifies direct `Query<SpawnDetails>`, `Query2<Entity, SpawnDetails>`, spawn batch source metadata, deferred command spawn details, and `Query<Tuple<Entity, SpawnDetails, Component>, Filter>` system injection; `MacroConstraintTest` verifies it can coexist with component queries without false conflicts.
- Done: upstream `bevy_ecs::query::Has<T>` now has a macro-driven Haxe query-data bridge. `SystemMacro` lowers `Query<Has<T>>`, `Query2<..., Has<T>>`, `Query3<..., Has<T>>`, and `Query<Tuple<..., Has<T>>>` to the erased runtime `Has` class while passing the inner component `T` TypeKey, including parameterized keys such as `Has<Handle<AppAssetB>>`. Runtime query paths treat `Has<T>` as synthetic read-only data that matches all otherwise-selected entities and returns true/false based on component presence, rather than acting like `With<T>`. Conflict analysis excludes `Has<T>` from normal component data access, matching upstream's no-component-fetch semantics. Coverage verifies direct world queries, system macro injection, tuple macro injection, parameterized handles, and allowed no-conflict constraint cases with real entity data.
- Done: upstream `bevy_ecs::query::Option<T>` is now represented for component query data in Haxe. `SystemMacro` lowers `Query<Option<T>>`, `Query2<..., Option<T>>`, `Query3<..., Option<T>>`, and `Query<Tuple<..., Option<T>>>` to the erased runtime `Option` class while passing the inner component `T` TypeKey, including parameterized `Handle<T>` keys. Runtime query paths treat `Option<T>` as synthetic data for matching purposes: it matches all otherwise-selected entities and returns `Some`/`None` based on component presence instead of filtering out missing `T`. Conflict analysis now separates accessed data keys from required data keys, so `Option<T>` still conflicts with overlapping access to `T` but does not prove that the query requires `T`. Coverage verifies direct world queries, system macro injection, tuple macro injection, parameterized handles, a rejected overlap case, and an allowed disjoint case with real component totals.
- Done: upstream `bevy_ecs::query::AnyOf<...>` now has a Haxe macro-backed component query-data bridge. `AnyOf<A, B, ...>` is a `@:genericBuild` carrier rather than hand-written arity classes; generated fields are `Option<A>`, `Option<B>`, etc., matching upstream's `AnyOf<(A, B, ...)>` item shape. `SystemMacro` lowers top-level `Query<AnyOf<...>>` into `QueryAnyOf`, passes each component's TypeKey (including parameterized `Handle<T>` keys), and models conflict branches as "at least one of these data components is required" rather than requiring all of them. Runtime coverage verifies entities with only A, only B, both A+B, and no component under a filter, plus parameterized handle components. Constraint coverage verifies overlapping `AnyOf` access is rejected and explicit `With/Without` disjointness is allowed with real component totals. Nested synthetic query data inside `AnyOf` is explicitly rejected rather than stubbed.
- Done: `AnyOf<...>` query data is no longer limited to top-level `Query<AnyOf<...>>`; it now works as a nested query-data item in `Query2`, `Query3`, and tuple query data (`Query<Tuple<AnyOf<...>, ...>>`), closer to upstream `bevy_ecs` usage patterns. `SystemMacro` now lowers non-top-level `AnyOf` with generated runtime class resolution and encoded multi-key metadata (`QueryDataKey`) instead of rejecting it. Runtime query execution in `World.queryTwo/queryThree/queryTuple` now materializes nested `AnyOf` values as generated `AnyOf_N` instances (`Option` fields per branch), requires "at least one branch present" for match semantics, and preserves existing public API shapes. Conflict analysis now treats nested `AnyOf` access as branch-based required data (intersecting required keys across branches) while still tracking full access keys for overlap checks, so disjoint proofs remain branch-sensitive. Coverage was expanded with non-empty compile constraints (`QueryPairAnyOf*`, `QueryTripleAnyOf*`, `QueryTupleAnyOf*`) plus runtime system assertions in `AppScheduleTest` for `Query2<AnyOf<...>, ...>`, `Query3<AnyOf<...>, ...>`, and `Query<Tuple<AnyOf<...>, ...>>`.
- Done: nested `AnyOf` query-data follow-up hardening was completed after initial expansion: `Query2` / `Query3` fast-path `get(...)` now treats encoded `AnyOf` keys as synthetic query data (instead of incorrectly falling back to direct component lookups), preventing false negatives for `get/contains/getMany` paths. `QueryDataKey` now also exposes a lightweight `isAnyOfKey(...)` helper so fast-path checks avoid repeatedly decoding branch lists when only prefix detection is needed. Runtime coverage was expanded in `EcsCoreTest` with a direct-world (non-`@:system`) nested AnyOf matrix over `QueryAnyOf`, `queryPair`, and `queryTriple`, including single-branch/both-branch/no-branch entities and explicit key encoding checks.
- Done: nested `AnyOf` branch-disjointness coverage was tightened for compile-time query-conflict analysis. New constraints verify that a query touching `AnyOf<A, B>` only becomes disjoint when both `A` and `B` branches are excluded (not just one branch), and that single-branch exclusion still conflicts when other overlap remains. This locks branch-sensitive `AnyOf` conflict semantics closer to upstream behavior under `Without<...>` filter composition.
- Done: branch-disjointness coverage for nested `AnyOf` now spans both `Query2` and `Query3` shapes with explicit `Without` branch matrices. Added constraints verify:
  - single-branch `Without` exclusion remains a conflict when another `AnyOf` branch still overlaps;
  - excluding all `AnyOf` branches can compile when the rest of the query overlap is explicitly separated.
  This further hardens `SystemMacro` branch-sensitive disjoint proof behavior for multi-data query params.
- Done: the same branch-sensitive `AnyOf` + `Without` disjointness matrix now also covers tuple query-data form (`Query<Tuple<AnyOf<...>, ...>>`) in compile constraints. This closes a remaining parity gap where `AnyOf` branch reasoning was previously tested on pair/triple params but not tuple-param lowering.
- Done: nested `AnyOf<Handle<...>, Handle<...>>` runtime coverage was expanded across pair/triple/tuple query-data slots (not only top-level `Query<AnyOf<...>>`), with explicit parameterized `TypeKey` handle storage and deterministic score assertions. This locks parameterized-key encoding/decoding parity for nested AnyOf query data instead of validating only plain component branches.
- Done: AppSchedule nested-AnyOf-handle coverage was isolated onto dedicated marker components so newly added AnyOf-handle entities no longer mutate pre-existing tuple/Has/Option/entity-count baseline assertions. Existing baseline expectations stay stable, while the new AnyOf-handle nested query systems validate their own deterministic totals independently.
- Done: nested `AnyOf` synthetic-branch runtime coverage now includes non-handle query-data branches in real `@:system` injection, not only direct-world probes. `AppScheduleTest` now validates:
  - `Query2<AnyOf<Entity, Mut<T>>, Position>` branch materialization (`Entity` always present for alive entities, `Mut<T>` only when component exists, plus `setChanged` write-through);
  - `Query3<AnyOf<Has<T>, Option<U>>, Position, Tag>` always-present synthetic branches with per-entity boolean/option payloads;
  - `Query<Tuple<AnyOf<Ref<T>, Mut<U>>, Position>, Filter>` mixed read/write synthetic branches and `Mut<T>.setChanged()` persistence.
  These additions lock nested AnyOf synthetic data semantics in schedule-driven runtime paths, closer to upstream Bevy query-data behavior.
- Done: upstream-style `AnyOf` conflict matrix parity was tightened in compile constraints with additional non-empty cases mirroring `bevy_ecs/src/system/mod.rs` conflict expectations:
  - `AnyOf<Mut<T>, T>` and `AnyOf<T, Mut<T>>` now have explicit duplicate-access reject tests (`QueryAnyOfWithMutAndRefConflictConstraint`, `QueryAnyOfWithRefAndMutConflictConstraint`);
  - explicit `AnyOf<A, B>` disjointness against a second query gated by `Without<A> + Without<B>` is now covered by a positive compile/runtime constraint (`QueryAnyOfAndWithoutDisjointConstraint`).
  `MacroConstraintTest` now asserts these paths directly so AnyOf branch access rules are guarded against regression.
- Done: `SystemMacro` AnyOf duplicate-access handling now distinguishes read-only duplication from mutable duplication for branch-level access collation. `AnyOf<T, T>` is now accepted as read-only duplicate branch access (matching upstream-style immutable branch compatibility), while `AnyOf<Mut<T>, T>` / `AnyOf<T, Mut<T>>` remain rejected as duplicate component access because mutable access is present. This is locked by `QueryAnyOfWithRefRefNoConflictConstraint` (allow) plus existing mutable conflict constraints (reject), and validated by `MacroConstraintTest`.
- Done: upstream `bevy_ecs::query::Ref<T>` / `Mut<T>` now have Haxe query-data bridges with compile-time and runtime semantics aligned to existing ECS/query shape. `SystemMacro` lowers `Query<Ref<T>>` / `Query<Mut<T>>` (including `Query2` / `Query3` / tuple data forms) to runtime `Ref` / `Mut` classes while preserving inner component `T` TypeKey resolution (including parameterized keys). Runtime query matching treats `Ref<T>` / `Mut<T>` as synthetic query data that still requires component `T` presence, and query/entity fast-path checks now use world key-presence (`hasByKey`) instead of invalid `Dynamic` class lookups. `Mut.setChanged()` persists change-tick updates to world storage, and both `Ref`/`Mut` expose change-detection helpers (`isAdded`, `isChanged`, `isAddedAfter`, `isChangedAfter`, `added`, `lastChanged`, `lastRunTick`, `thisRunTick`). Coverage includes ECS runtime assertions (`EcsCoreTest`), schedule/system injection assertions (`AppScheduleTest`), and new compile-time conflict/disjoint constraint matrix (`QueryRef*` / `QueryMut*` / `QueryRefMut*` in `MacroConstraintTest`) with non-empty, stateful bodies.
- Verified: `haxe -cp src -cp test -main ecs.EcsCoreTest --interp`, `haxe -cp src -cp test -main app.AppScheduleTest --interp`, `haxe -cp src -cp test -main macro.MacroConstraintTest --interp`, `haxe test.hxml`, `haxe build-all.hxml`, plus empty-shell scan for `test/constraint`.
- Remaining: richer async borrow diagnostics, full WebGL2 draw pipeline, and WebGPU-ready render abstraction.
- Remaining: `bevy.ecs` / `bevy.app` / `Query` are still only a minimal subset of upstream Bevy. Missing major upstream-aligned surfaces include broader macro/type-level query data/filter tuple coverage beyond the current `Query` / `Query2` / `Query3` ladder, still-fuller query conflict analysis for more of upstream Bevy's nested tuple/filter space, original tuple plugin composition syntax (`addPlugins((...))`-style rather than Haxe macro/array DSL), richer tuple-style schedule config composition, more exact query/world error/result types instead of string-throwing fast paths, and deeper async borrow-checked system param semantics beyond the current signature-level bans.
- Remaining: tuple query macro path is now validated at arities 1/2/4/5/6/10/12/15 and now includes tuple `Ref<T>` / `Mut<T>` synthetic-data conflict/runtime coverage, but it still needs broader parity coverage across additional arities/filter combinations and deeper borrow-conflict equivalence against upstream `bevy_ecs` for complex nested tuple/filter declarations.
- Remaining (immediate ECS next step): continue tightening ECS semantics against upstream `bevy_ecs` without breaking existing repo-facing interfaces, with priority on deeper query tuple/filter coverage and conflict analysis breadth.

## Asset Notes

- `AssetServer.load(...)` / `loadState(...)` are currently provided through Haxe extension macros in `bevy.asset.AssetLoad`.
- Because of Haxe macro visibility rules, call sites should explicitly opt in with `using bevy.asset.AssetLoad;` when they want the upstream-like `assetServer.load("path")` syntax.
- This keeps the public call shape close to upstream Bevy while avoiding an invented alternate API such as mandatory explicit `Class<T>` arguments at each load call.
