# Bevy ECS 模块改进实现计划

## 1. 概述

基于 Bevy Rust ECS 实现，为 Haxe 移植增强 bevy_ecs 模块。目标是创建一个功能完整、API 设计接近 Bevy Rust 的 ECS 框架。

### 目标
- 增强 World.hx - 添加 archetype 支持、更好的变更检测
- 增强 Query.hx - 支持更复杂的查询模式
- 添加 QueryFilter.hx - 实现 Changed, Added, With, Without 等过滤器
- 改进 Component.hx - 添加 @:component 宏支持
- 改进 Bundle.hx - 添加 @:bundle 宏支持
- 添加 Schedule.hx - 调度器实现
- 添加 SystemParam.hx - 系统参数接口
- 添加 Events.hx - 事件系统
- 添加 Commands.hx - 命令队列

### 成功标准
- 所有模块编译通过
- API 设计尽可能接近 Bevy Rust
- 宏系统正常工作
- 示例代码能够运行

---

## 2. 文件结构

```
src/haxe/ecs/
├── World.hx              # 实体组件世界
├── Entity.hx            # 实体标识符
├── Component.hx         # 组件接口
├── ComponentId.hx       # 组件ID
├── Bundle.hx            # Bundle接口
├── Archetype.hx         # 原型管理
├── Storage.hx          # 存储结构
├── Query.hx            # 查询接口
├── QueryIter.hx        # 查询迭代器
├── QueryFilter.hx      # 查询过滤器
├── WorldQuery.hx       # WorldQuery trait
├── Commands.hx         # 命令队列
├── Schedule.hx         # 调度器
├── ScheduleStages.hx    # 调度阶段
├── System.hx           # 系统接口
├── SystemParam.hx      # 系统参数
├── FunctionSystem.hx   # 函数系统
├── SystemSet.hx        # 系统集合
├── Resource.hx         # 资源接口
├── Event.hx            # 事件接口
├── Events.hx           # 事件系统
├── EventReader.hx      # 事件读取器
├── EventWriter.hx      # 事件写入器
├── ChangeDetection.hx  # 变更检测
└── prelude/
    └── EcsTypes.hx    # 导出所有类型
```

---

## 3. 核心改进

### 3.1 World.hx 增强

**文件**: `src/haxe/ecs/World.hx`

**改进内容**:
1. 添加 archetype 缓存系统
2. 改进变更检测机制 (Tick 机制)
3. 添加批量 spawn 方法
4. 添加延迟命令执行支持
5. 添加资源注册方法

```haxe
// 核心数据结构
class World {
    // 实体管理
    private var entities:Map<Int, Map<Int, Dynamic>>;
    private var entityArchetypes:Map<Int, ArchetypeId>;
    private var nextEntityId:Int;
    
    // 原型管理
    private var archetypes:Archetypes;
    private var archetypeEntities:Map<ArchetypeId, Array<Entity>>;
    
    // 组件类型管理
    private var componentTypes:Map<Int, ComponentInfo>;
    private var componentIds:Map<String, Int>;
    
    // 变更检测
    private var changeTick:UInt;
    private var lastChangeTick:UInt;
    private var componentTicks:Map<Int, ComponentTicks>;
    
    // 命令队列
    private var commandQueue:CommandQueue;
    
    // 方法
    public function spawn(?bundle:Bundle):Entity;
    public function spawnBatch(entities:Int, ?bundle:Bundle):Void;
    public function despawn(entity:Entity):Void;
    public function insert(entity:Entity, bundle:Bundle):Void;
    public function remove(entity:Entity, componentType:Class<Dynamic>):Void;
    
    // 原型操作
    public function getArchetype(entity:Entity):Archetype;
    public function getArchetypeEntities(archetypeId:ArchetypeId):Array<Entity>;
    
    // 查询
    public function query<Q:QueryFilter>(cls:Class<Q>):Query<Q>;
    
    // 资源
    public function insertResource<T:Resource>(resource:T):Void;
    public function getResource<T:Resource>(cls:Class<T>):T;
    public function containsResource<T:Resource>(cls:Class<T>):Bool;
    
    // 命令
    public function commands():Commands;
    public function applyDeferred():Void;
}
```

### 3.2 Query.hx 增强

**文件**: `src/haxe/ecs/Query.hx`

**改进内容**:
1. 添加泛型 Query 支持
2. 实现查询迭代器
3. 添加变更检测查询
4. 支持多组件查询

```haxe
// Query 接口
interface Query<D:QueryData, F:QueryFilter = ()->Void> {
    function iter():QueryIter<D>;
    function get(entity:Entity):D;
    function contains(entity:Entity):Bool;
    function count():Int;
}

// 可变查询
interface QueryMut<D:QueryData, F:QueryFilter> extends Query<D, F> {
    function iterMut():QueryIterMut<D>;
    function getMut(entity:Entity):D;
}

// QueryData 标记接口
interface QueryData {
    // 标记接口
}

// 泛型查询实现
@:generic
class GenericQuery<D:QueryData, F:QueryFilter> implements Query<D, F> {
    private var world:World;
    private var archetypeId:ArchetypeId;
    private var componentTypes:Array<Int>;
    
    public function new(world:World, queryState:QueryState<D, F>) {
        this.world = world;
    }
    
    public function iter():QueryIter<D> {
        return new QueryIterImpl<D>(this);
    }
    
    public function get(entity:Entity):D {
        // 返回实体数据
    }
    
    public function contains(entity:Entity):Bool {
        // 检查实体是否匹配查询
    }
    
    public function count():Int {
        var count = 0;
        for (archetype in getMatchingArchetypes()) {
            count += archetype.entityCount();
        }
        return count;
    }
    
    private function getMatchingArchetypes():Array<Archetype> {
        // 返回匹配查询的原型
    }
}
```

### 3.3 QueryFilter.hx 实现

**文件**: `src/haxe/ecs/QueryFilter.hx`

**实现内容**:
1. `With<T>` - 必须包含组件
2. `Without<T>` - 不能包含组件
3. `Changed<T>` - 组件已变更
4. `Added<T>` - 组件刚添加
5. `Or<F1, F2>` - 任一过滤器匹配
6. `And<F1, F2>` - 所有过滤器匹配

```haxe
// 查询过滤器接口
interface QueryFilter {
    function matches(entity:Entity, world:World):Bool;
    function isArchetypal():Bool;
    function getRequiredTypes():Array<Int>;
}

// With<T> - 必须包含组件
@:generic
class With<T:Component> {
    public var componentId:Int;
    
    public function new(?cls:Class<T>) {
        componentId = ComponentType.get(cls);
    }
    
    public inline function matches(entity:Entity, world:World):Bool {
        return world.hasComponent(entity, componentId);
    }
    
    public inline function isArchetypal():Bool return true;
}

// Without<T> - 不能包含组件
@:generic
class Without<T:Component> {
    public var componentId:Int;
    
    public function new(?cls:Class<T>) {
        componentId = ComponentType.get(cls);
    }
    
    public inline function matches(entity:Entity, world:World):Bool {
        return !world.hasComponent(entity, componentId);
    }
    
    public inline function isArchetypal():Bool return true;
}

// Changed<T> - 组件已变更
@:generic
class Changed<T:Component> {
    public var componentId:Int;
    
    public function new(?cls:Class<T>) {
        componentId = ComponentType.get(cls);
    }
    
    public inline function matches(entity:Entity, world:World):Bool {
        return world.isComponentChanged(entity, componentId);
    }
    
    public inline function isArchetypal():Bool return false; // 需要检查变更
}

// Added<T> - 组件刚添加
@:generic
class Added<T:Component> {
    public var componentId:Int;
    
    public function new(?cls:Class<T>) {
        componentId = ComponentType.get(cls);
    }
    
    public inline function matches(entity:Entity, world:World):Bool {
        return world.isComponentAdded(entity, componentId);
    }
    
    public inline function isArchetypal():Bool return false;
}

// Or 组合器
@:generic
class Or<F1:QueryFilter, F2:QueryFilter> {
    private var f1:F1;
    private var f2:F2;
    
    public function new(f1:F1, f2:F2) {
        this.f1 = f1;
        this.f2 = f2;
    }
    
    public inline function matches(entity:Entity, world:World):Bool {
        return f1.matches(entity, world) || f2.matches(entity, world);
    }
}
```

### 3.4 Component.hx 改进

**文件**: `src/haxe/ecs/Component.hx`

**改进内容**:
1. 添加 @:component 宏支持
2. 添加组件存储类型
3. 添加组件生命周期钩子

```haxe
// 组件存储类型
enum ComponentStorage {
    Table;           // 表格存储 (稀疏)
    SparseSet;       // 稀疏集存储 (密集)
    DenseSet;        // 密集集存储
}

// 组件接口
interface Component {
    // 无需方法，标记接口
}

// 组件信息
class ComponentInfo {
    public var id:Int;
    public var name:String;
    public var storage:ComponentStorage;
    public var size:Int;
    public var drop:Dynamic;  // 析构函数
    
    public function new(id:Int, name:String, storage:ComponentStorage);
}

// 组件类型工具
class ComponentType {
    private static var nextId:Int = 0;
    private static var cache:Map<Class<Dynamic>, Int> = new Map();
    
    public static function get<T>(cls:Class<T>):Int {
        if (cache.exists(cls)) {
            return cache.get(cls);
        }
        var id = nextId++;
        cache.set(cls, id);
        return id;
    }
}

// ComponentHooks 用于组件生命周期
class ComponentHooks {
    public var onAdd:Entity -> World -> Void;
    public var onRemove:Entity -> World -> Void;
    public var onInsert:Entity -> World -> Void;
    public var onDespawn:Entity -> World -> Void;
    
    public function new();
}
```

### 3.5 Bundle.hx 改进

**文件**: `src/haxe/ecs/Bundle.hx`

**改进内容**:
1. 添加 @:bundle 宏支持
2. 添加 FromComponents 实现
3. 添加组件类型列表获取

```haxe
// Bundle 接口
interface Bundle {
    function getComponentTypes():Array<Int>;
    function componentCount():Int;
}

// 泛型 Bundle1-16
@:generic
class Bundle1<T1:Component> implements Bundle {
    public var c1:T1;
    
    public function new(c1:T1) {
        this.c1 = c1;
    }
    
    public function getComponentTypes():Array<Int> {
        return [ComponentType.get(Type.getClass(c1))];
    }
    
    public function componentCount():Int return 1;
}

// 便捷的 Spawnable bundle
typedef SpawnBundle = Bundle;

// Bundle 工具类
class BundleUtils {
    public static function fromComponents<T:Component>(components:Array<T>):Dynamic {
        // 创建匿名 bundle
    }
    
    public static function getTypes(bundle:Bundle):Array<Int> {
        return bundle.getComponentTypes();
    }
}
```

### 3.6 Schedule.hx 实现

**文件**: `src/haxe/ecs/Schedule.hx`

**实现内容**:
1. Schedule 调度器
2. ScheduleStages 阶段定义
3. 系统集合 SystemSet
4. 条件系统 Conditions

```haxe
// 调度阶段枚举
enum ScheduleStages {
    First;
    PreUpdate;
    Update;
    PostUpdate;
    Last;
}

// 调度器标签
class ScheduleLabel {
    public var id:String;
    public function new(id:String) this.id = id;
}

// 调度器
class Schedule {
    public var label:ScheduleLabel;
    public var stages:Map<ScheduleStages, Array<SystemNode>>;
    public var conditions:Map<String, Array<System -> Bool>>;
    
    public function new(?label:ScheduleLabel);
    
    public function addSystem(system:System, ?stage:ScheduleStages):Void;
    public function addSystemSet(systemSet:SystemSet, ?stage:ScheduleStages):Void;
    
    public function addCondition(system:System, condition:System -> Bool):Void;
    public function configure(?set:SystemSet, ?before:SystemSet, ?after:SystemSet):Void;
    
    public function run(world:World):Void;
    public function initialize(world:World):Void;
}

// 系统节点
class SystemNode {
    public var system:System;
    public var dependencies:Array<String>;
    public var conditions:Array<System -> Bool>;
    
    public function new(system:System);
}

// 系统集合
interface SystemSet {
    var label:String;
    var systems:Array<System>;
}

// 预定义系统集合
class ScheduleStages {
    public static var First:SystemSet;
    public static var PreUpdate:SystemSet;
    public static var Update:SystemSet;
    public static var PostUpdate:SystemSet;
    public static var Last:SystemSet;
}
```

### 3.7 SystemParam.hx 实现

**文件**: `src/haxe/ecs/SystemParam.hx`

**实现内容**:
1. SystemParam 接口
2. Res<T> 只读资源
3. ResMut<T> 可变资源
4. Query<T> 查询参数
5. Commands 命令队列
6. Local<T> 本地状态

```haxe
// SystemParam 接口
interface SystemParam {
    function getItem(world:World, changeTick:UInt):Dynamic;
    function applyDeferred(world:World):Void;
    function init(world:World):Void;
}

// 只读资源
@:generic
class Res<T:Resource> implements SystemParam {
    private var ptr:T;
    private var ticks:ComponentTicks;
    
    public function getItem(world:World, changeTick:UInt):T {
        ptr = world.getResource(Type.getClass(T));
        return ptr;
    }
    
    public function isChanged():Bool {
        return ticks.check_changed(lastChangeTick, changeTick);
    }
}

// 可变资源
@:generic
class ResMut<T:Resource> implements SystemParam {
    private var ptr:T;
    private var ticks:ComponentTicks;
    
    public function getItem(world:World, changeTick:UInt):T {
        ptr = world.getResource(Type.getClass(T));
        return ptr;
    }
    
    public function set(value:T):Void {
        ptr = value;
        ticks.set_changed(changeTick);
    }
}

// 查询参数
@:generic
class Query<D:QueryData, F:QueryFilter> implements SystemParam {
    private var query:Query<D, F>;
    
    public function getItem(world:World, changeTick:UInt):Query<D, F> {
        return world.query(Type.getClass(D));
    }
}

// 命令队列
class Commands implements SystemParam {
    private var queue:CommandQueue;
    private var world:World;
    
    public function getItem(world:World, changeTick:UInt):Commands;
    public function applyDeferred(world:World):Void;
    
    // Entity 命令
    public function spawn(?bundle:Bundle):EntityCommands;
    public function despawn(entity:Entity):Void;
    public function insert(entity:Entity, bundle:Bundle):Void;
    public function remove(entity:Entity, cls:Class<Dynamic>):Void;
    
    // 世界命令
    public function addCommand(command:Command):Void;
    public function applyDeferred():Void;
}

// 本地状态
@:generic
class Local<T> implements SystemParam {
    private var value:T;
    
    public function new(?value:T) {
        this.value = value != null ? value : cast Type.createEmptyInstance(T);
    }
    
    public function getItem(world:World, changeTick:UInt):T {
        return value;
    }
}
```

### 3.8 Events.hx 实现

**文件**: `src/haxe/ecs/Events.hx`

**实现内容**:
1. Events<T> 事件存储
2. EventReader<T> 事件读取
3. EventWriter<T> 事件写入
4. EventBatch<T> 事件批次

```haxe
// 事件资源
class Events<T:Event> implements Resource {
    private var events:Array<T>;
    private var lastReaders:Map<Int, Int>;
    private var eventCount:Int;
    
    public function new() {
        events = [];
        lastReaders = new Map();
        eventCount = 0;
    }
    
    public function send(event:T):Void;
    public function sendBatch(batch:EventBatch<T>):Void;
    public function update():Void;
    public function clear():Void;
    
    public function getReader(readerId:Int):EventReader<T>;
    public function registerReader():Int;
}

// 事件读取器
class EventReader<T:Event> implements SystemParam {
    private var lastEventIndex:Int;
    private var events:Events<T>;
    
    public function new(events:Events<T>) {
        this.events = events;
        this.lastEventIndex = 0;
    }
    
    public function read():Iterator<T>;
    public function readWithOldest():Iterator<{oldest:Bool, event:T}>;
    
    public function getItem(world:World, changeTick:UInt):EventReader<T>;
}

// 事件写入器
class EventWriter<T:Event> implements SystemParam {
    private var events:Events<T>;
    
    public function new(events:Events<T>);
    public function send(event:T):Void;
    public function sendBatch(batch:EventBatch<T>):Void;
    
    public function getItem(world:World, changeTick:UInt):EventWriter<T>;
}

// 事件批次
class EventBatch<T:Event> {
    public var events:Array<T>;
    public var count:Int;
    
    public function new(events:Array<T>) {
        this.events = events;
        this.count = events.length;
    }
}
```

### 3.9 Commands.hx 实现

**文件**: `src/haxe/ecs/Commands.hx`

**实现内容**:
1. Command 接口
2. EntityCommand 接口
3. CommandQueue 命令队列
4. Commands 系统参数
5. EntityCommands 实体命令
6. 常用命令实现

```haxe
// 命令接口
interface Command {
    function apply(world:World):Void;
}

// 实体命令接口
interface EntityCommand {
    function apply(entity:Entity, world:World):Void;
}

// 命令队列
class CommandQueue {
    private var commands:Array<Command> = [];
    
    public function push(command:Command):Void;
    public function apply(world:World):Void;
    public function clear():Void;
    public function isEmpty():Bool;
    public function length():Int;
}

// Commands 系统参数
class Commands implements SystemParam implements Deferred {
    private var queue:CommandQueue;
    private var world:World;
    private var currentEntity:Entity;
    
    public function getItem(world:World, changeTick:UInt):Commands;
    public function applyDeferred(world:World):Void;
    
    // 实体操作
    public function spawn(?bundle:Bundle):EntityCommands;
    public function despawn(entity:Entity):Void;
    public function insert(entity:Entity, bundle:Bundle):Void;
    public function remove(entity:Entity, cls:Class<Dynamic>):Void;
    
    // 资源操作
    public function insertResource<T:Resource>(resource:T):Void;
    public function removeResource<T:Resource>(cls:Class<T>):Void;
    
    // 命令
    public function addCommand(command:Command):Void;
}

// EntityCommands
class EntityCommands {
    private var entity:Entity;
    private var commands:Commands;
    
    public function id():Entity;
    public function insert(bundle:Bundle):EntityCommands;
    public function remove(cls:Class<Dynamic>):EntityCommands;
    public function despawn():Void;
    public function with<C:Component>(component:C):EntityCommands;
}

// 具体命令实现
class SpawnCommand<T:Bundle> implements Command {
    private var bundle:T;
    private var entity:Entity;
    
    public function new(bundle:T) {
        this.bundle = bundle;
    }
    
    public function apply(world:World):Void {
        entity = world.spawn(bundle);
    }
}

class DespawnCommand implements Command {
    public var entity:Entity;
    
    public function new(entity:Entity) {
        this.entity = entity;
    }
    
    public function apply(world:World):Void {
        world.despawn(entity);
    }
}

class InsertBundleCommand<T:Bundle> implements Command {
    public var entity:Entity;
    public var bundle:T;
    
    public function new(entity:Entity, bundle:T) {
        this.entity = entity;
        this.bundle = bundle;
    }
    
    public function apply(world:World):Void {
        world.insert(entity, bundle);
    }
}

class RemoveComponentCommand<T:Component> implements Command {
    public var entity:Entity;
    public var componentType:Class<T>;
    
    public function new(entity:Entity, componentType:Class<T>) {
        this.entity = entity;
        this.componentType = componentType;
    }
    
    public function apply(world:World):Void {
        world.remove(entity, componentType);
    }
}
```

### 3.10 ChangeDetection.hx 实现

**文件**: `src/haxe/ecs/ChangeDetection.hx`

```haxe
// 变更检测 Tick
class Tick {
    public var value:UInt;
    
    public function new(value:UInt) {
        this.value = value;
    }
    
    public function is_newer_than(other:Tick, threshold:UInt):Bool;
    public function is_older_than(other:Tick, threshold:UInt):Bool;
}

// 组件 Ticks
class ComponentTicks {
    public var changed:Tick;
    public var added:Tick;
    
    public function new();
    
    public function check_changed(lastTick:UInt, currentTick:UInt):Bool;
    public function check_added(lastTick:UInt, currentTick:UInt):Bool;
    public function set_changed(tick:UInt):Void;
    public function set_added(tick:UInt):Void;
}

// 可变引用
class Mut<T> {
    private var ptr:T;
    private var ticks:ComponentTicks;
    
    public function new(ptr:T, ticks:ComponentTicks);
    
    public function get():T;
    public function set(value:T):Void;
    public function is_changed(lastTick:UInt, currentTick:UInt):Bool;
    public function into_inner():T;
}

// 只读引用
class Ref<T> {
    private var ptr:T;
    private var ticks:ComponentTicks;
    
    public function new(ptr:T, ticks:ComponentTicks);
    
    public function get():T;
    public function is_changed(lastTick:UInt, currentTick:UInt):Bool;
    public function is_added(lastTick:UInt, currentTick:UInt):Bool;
    public function into_inner():T;
}
```

---

## 4. 宏系统

### 4.1 @:component 宏

**文件**: `src/haxe/macro/ComponentMacro.hx`

```haxe
class ComponentMacro {
    public static function build():Void {
        // 1. 注册组件类型
        // 2. 生成组件信息
        // 3. 设置存储类型
        // 4. 生成唯一 ID
    }
}
```

### 4.2 @:bundle 宏

**文件**: `src/haxe/macro/BundleMacro.hx`

```haxe
class BundleMacro {
    public static function build():Void {
        // 1. 提取组件字段
        // 2. 生成 Bundle 实现
        // 3. 注册 bundle
    }
}
```

### 4.3 @:system 宏

**文件**: `src/haxe/macro/SystemMacro.hx`

```haxe
class SystemMacro {
    public static function build():Void {
        // 1. 解析函数参数
        // 2. 生成 SystemParam 实现
        // 3. 生成系统元数据
    }
}
```

---

## 5. 实现步骤

### 第一阶段: 核心类型 (1-2 天)
1. [ ] 改进 World.hx - 添加 archetype 和变更检测
2. [ ] 改进 Component.hx - 添加存储类型
3. [ ] 改进 Bundle.hx - 完善 Bundle 接口
4. [ ] 添加 ChangeDetection.hx - Tick 机制

### 第二阶段: 查询系统 (2-3 天)
5. [ ] 改进 Query.hx - 泛型查询支持
6. [ ] 改进 QueryFilter.hx - 实现所有过滤器
7. [ ] 添加 QueryIter.hx - 查询迭代器
8. [ ] 添加 WorldQuery.hx - WorldQuery trait

### 第三阶段: 系统和命令 (2-3 天)
9. [ ] 改进 SystemParam.hx - 完善系统参数
10. [ ] 改进 Commands.hx - 添加所有命令
11. [ ] 改进 Schedule.hx - 完善调度器
12. [ ] 添加 System.hx 改进版本

### 第四阶段: 事件系统 (1-2 天)
13. [ ] 改进 Events.hx - 完善事件系统
14. [ ] 改进 EventReader.hx
15. [ ] 改进 EventWriter.hx

### 第五阶段: 宏系统 (2-3 天)
16. [ ] 改进 ComponentMacro.hx
17. [ ] 改进 BundleMacro.hx
18. [ ] 添加 SystemMacro.hx

### 第六阶段: 测试和文档 (1-2 天)
19. [ ] 编写示例代码
20. [ ] 更新文档
21. [ ] 性能测试

---

## 6. 测试策略

### 6.1 单元测试
- ComponentType 唯一性测试
- Bundle 组件提取测试
- Query 过滤测试
- Tick 变更检测测试

### 6.2 集成测试
- World spawn/insert/remove 流程
- Schedule 系统调度
- Commands 延迟执行
- Events 发送/接收

### 6.3 性能测试
- 查询迭代性能
- 批量 spawn 性能
- 组件插入/删除性能

---

## 7. 依赖关系图

```
Component.hx
    ↓
Bundle.hx ───────────→ ComponentType (共享)
    ↓
World.hx ←─────────── Query.hx
    ↓                   ↓
QueryFilter.hx      QueryIter.hx
    ↓
SystemParam.hx ────→ Commands.hx → CommandQueue
    ↓                   ↓
System.hx ←───────── Schedule.hx
    ↓
Resource.hx ←─────── Events.hx
```

---

## 8. 估算工作量和复杂度

| 模块 | 复杂度 | 估算时间 |
|------|--------|----------|
| World.hx 改进 | 高 | 4-6 小时 |
| Query.hx 改进 | 高 | 6-8 小时 |
| QueryFilter.hx | 中 | 3-4 小时 |
| Component.hx | 中 | 2-3 小时 |
| Bundle.hx | 中 | 2-3 小时 |
| Schedule.hx | 高 | 4-6 小时 |
| SystemParam.hx | 高 | 4-6 小时 |
| Events.hx | 中 | 3-4 小时 |
| Commands.hx | 中 | 3-4 小时 |
| ChangeDetection.hx | 中 | 2-3 小时 |
| 宏系统 | 高 | 6-8 小时 |
| 测试和文档 | 中 | 4-6 小时 |
| **总计** | - | **约 2-3 周** |

---

## 9. 注意事项

1. **Haxe 限制**: Haxe 不支持 Rust 风格的 trait 和泛型约束，需要使用接口和 @:generic 宏
2. **性能**: 考虑使用 @:inline 优化热点代码
3. **安全性**: 使用 @:SuppressWarnings 处理必要的类型转换
4. **宏**: Haxe 宏系统与 Rust proc macro 不同，需要适配
5. **null 处理**: Haxe 中需要显式处理 null，与 Rust 的 Option 不同

---

**创建时间**: 2025-02-06
**参考**: `/home/vscode/projects/bevy/crates/bevy_ecs/src/`
