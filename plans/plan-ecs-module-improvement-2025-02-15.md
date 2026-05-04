# Bevy ECS Haxe 模块改进计划

## 1. 概述

基于 Bevy Rust ECS 实现，为 Haxe 移植增强 bevy_ecs 模块。

### 目标
- 增强 World.hx - 添加 archetype 支持、更好的变更检测
- 增强 Query.hx - 支持更复杂的查询模式
- 添加/改进 QueryFilter.hx - 实现 Changed, Added, With, Without 等过滤器
- 改进 Component.hx - 添加 @:component 宏支持
- 改进 Bundle.hx - 添加 @:bundle 宏支持
- 添加 Schedule.hx - 调度器实现
- 改进 SystemParam.hx - 系统参数接口
- 添加/改进 Events.hx - 事件系统
- 改进 Commands.hx - 命令队列

### 成功标准
- 所有代码与 Bevy Rust API 保持接近的命名和结构
- 使用 Haxe 宏来处理组件注册
- 所有文件编译通过

---

## 2. 详细实现步骤

### Step 1: 增强 World.hx

**文件**: `src/haxe/ecs/World.hx`

**改进内容**:
- 添加 archetype 存储管理
- 实现组件变更检测系统
- 添加 spawn_batch 批量生成
- 添加资源管理方法
- 实现 Entities 管理

**关键代码结构**:
```haxe
class World {
    // 现有字段保持
    private var nextEntityId:Int = 1;
    private var entities:Map<Int, Map<Int, Dynamic>> = new Map();
    
    // 新增字段
    private var archetypes:Array<Archetype>;
    private var componentTimestamps:Map<Int, Map<Int, Int>>;
    private var resources:Map<Int, Dynamic>;
    private var changeTick:Int = 1;
    private var lastChangeTick:Int = 0;
    
    // 新增方法
    public function registerArchetype(archetype:Archetype):ArchetypeId;
    public function getArchetype(id:ArchetypeId):Archetype;
    public function getOrCreateArchetype(componentIds:Array<ComponentId>):ArchetypeId;
    public function moveEntity(entity:Entity, newArchetypeId:ArchetypeId):Void;
    public function spawnBatch(components:Array<Dynamic>):Array<Entity>;
    public function insert(entity:Entity, bundle:Dynamic):Void;
    public function remove<T:Component>(entity:Entity, cls:Class<T>):Void;
    public function getResource<T>(cls:Class<T>):T;
    public function insertResource<T>(resource:T):Void;
    public function containsResource<T>(cls:Class<T>):Bool;
    public function getEntitiesWith(componentId:ComponentId):Array<Entity>;
    public function getArchetypesWith(componentId:ComponentId):Array<ArchetypeId>;
}
```

### Step 2: 增强 Query.hx

**文件**: `src/haxe/ecs/Query.hx`

**改进内容**:
- 重构 Query 类实现现代 API
- 添加 QueryState 管理
- 实现 WorldQuery 接口
- 添加查询迭代器

**关键代码结构**:
```haxe
interface QueryData {
    // 标记接口
}

interface WorldQuery<D> {
    function getComponentData(entity:Entity):D;
    function matches(entity:Entity):Bool;
}

class Query<D:QueryData, F:QueryFilter> implements WorldQuery<D> {
    private var world:World;
    private var filter:QueryFilter;
    private var dataTypes:Array<Int>;
    
    public function new(world:World, filter:QueryFilter);
    public function iter():QueryIter<D>;
    public function getComponentData(entity:Entity):D;
    public function matches(entity:Entity):Bool;
    public function count():Int;
}

class QueryIter<D> {
    public function hasNext():Bool;
    public function next():D;
}
```

### Step 3: 增强 QueryFilter.hx

**文件**: `src/haxe/ecs/QueryFilter.hx`

**改进内容**:
- 实现完整的过滤系统
- 添加 Changed, Added, With, Without 过滤器
- 实现 Or 组合过滤器
- 添加 Has 过滤器

**关键代码结构**:
```haxe
interface QueryFilter {
    var isArchetypal(get, never):Bool;
    function getRequiredTypes():Array<Int>;
    function matches(components:Map<Int, Dynamic>):Bool;
}

// With<T> - 必须包含组件
@:generic
class With<T:Component> extends QueryFilterBase {
    private var typeId:Int;
    public function new(?cls:Class<T>);
    public override function matches(components:Map<Int, Dynamic>):Bool;
}

// Without<T> - 必须不包含组件
@:generic
class Without<T:Component> extends QueryFilterBase {
    private var typeId:Int;
    public function new(?cls:Class<T>);
    public override function matches(components:Map<Int, Dynamic>):Bool;
}

// Changed<T> - 检测组件变更
@:generic
class Changed<T:Component> extends QueryFilterBase {
    private var typeId:Int;
    private var changeTick:Int;
    public function new(?cls:Class<T>);
    public override function matches(components:Map<Int, Dynamic>):Bool;
}

// Added<T> - 检测组件添加
@:generic
class Added<T:Component> extends QueryFilterBase {
    private var typeId:Int;
    public function new(?cls:Class<T>);
    public override function matches(components:Map<Int, Dynamic>):Bool;
}

// Or<Filters> - 任一匹配
@:generic
class Or<Fs:QueryFilter> extends QueryFilterBase {
    private var filters:Array<QueryFilter>;
    public function new();
    public override function matches(components:Map<Int, Dynamic>):Bool;
}

// And<Filters> - 全部匹配
@:generic
class And<Fs:QueryFilter> extends QueryFilterBase {
    private var filters:Array<QueryFilter>;
    public function new();
    public override function matches(components:Map<Int, Dynamic>):Bool;
}

// Has<T> - 检测是否包含组件
@:generic
class Has<T:Component> extends QueryFilterBase {
    private var typeId:Int;
    public function new(?cls:Class<T>);
    public override function matches(components:Map<Int, Dynamic>):Bool;
}

// AnyOf<T1, T2, ...> - 任意组件
@:generic
class AnyOf<T:Component> extends QueryFilterBase {
    private var typeIds:Array<Int>;
    public function new();
    public override function matches(components:Map<Int, Dynamic>):Bool;
}
```

### Step 4: 改进 Component.hx

**文件**: `src/haxe/ecs/Component.hx`

**改进内容**:
- 添加组件存储类型支持
- 实现组件信息注册
- 添加必需的组件系统

**关键代码结构**:
```haxe
interface Component {
    // 标记接口
}

enum StorageType {
    Table;      // 密集存储
    SparseSet;  // 稀疏存储
}

class ComponentInfo {
    public var id:ComponentId;
    public var name:String;
    public var storageType:StorageType;
    public var isSparse:Bool;
    
    public function new(id:ComponentId, name:String, storageType:StorageType);
}

class ComponentRegistry {
    private static var components:Map<Int, ComponentInfo> = new Map();
    private static var nextId:Int = 1;
    
    public static function register<T:Component>(cls:Class<T>, storage:StorageType):ComponentId;
    public static function getInfo(id:ComponentId):ComponentInfo;
    public static function getId<T:Component>(cls:Class<T>):ComponentId;
}

// 自动注册宏支持
@:native("::class::")
@:autoBuild(haxe.macro.ComponentMacro.build())
interface ComponentMacro {
    // 元数据标记
}
```

### Step 5: 改进 Bundle.hx

**文件**: `src/haxe/ecs/Bundle.hx`

**改进内容**:
- 实现 FromComponents trait
- 添加 BundleInfo 管理
- 实现 bundle 插入/移除

**关键代码结构**:
```haxe
interface Bundle {
    function getComponentTypes():Array<ComponentId>;
    function componentCount():Int;
    function insertInto(entities:Map<Int, Map<Int, Dynamic>>, entity:Entity):Void;
    function removeFrom(entities:Map<Int, Map<Int, Dynamic>>, entity:Entity):Void;
}

interface FromComponents<C> {
    function from(componentArray:Array<Dynamic>):C;
}

// Bundle 实现生成器
class BundleBuilder {
    public static function build<T:Bundle>():Void {
        // 生成 getComponentTypes 实现
        // 生成 insertInto 实现
    }
}

// 宏支持
@:native("::class::")
@:autoBuild(haxe.macro.BundleMacro.build())
class BundleMacro {
    // 元数据标记
}
```

### Step 6: 改进 Schedule.hx

**文件**: `src/haxe/ecs/Schedule.hx`

**改进内容**:
- 添加 ScheduleExecutor 接口
- 实现多阶段调度
- 添加条件系统支持

**关键代码结构**:
```haxe
interface ScheduleExecutor {
    function execute(schedule:Schedule, world:World):Void;
}

class Schedule {
    public var label:ScheduleLabel;
    public var stages:Array<SystemSet>;
    public var graph:ScheduleGraph;
    
    private var initialized:Bool = false;
    
    public function new(?label:ScheduleLabel);
    public function addSystem(system:System, ?set:SystemSet):Void;
    public function addSystemSet(systemSet:SystemSet):Void;
    public function configureSets(sets:Array<SystemSetConfig>):Void;
    public function run(world:World):Void;
    public function initialize(world:World):Void;
}

interface SystemSet {
    var label:SystemSetLabel;
    function intern():String;
}

// 阶段定义
class ScheduleStages {
    public static var First:SystemSet;
    public static var PreUpdate:SystemSet;
    public static var Update:SystemSet;
    public static var PostUpdate:SystemSet;
    public static var Last:SystemSet;
}
```

### Step 7: 改进 SystemParam.hx

**文件**: `src/haxe/ecs/SystemParam.hx`

**改进内容**:
- 完善 SystemParam 接口
- 添加 ParamState 管理
- 实现更完整的系统参数

**关键代码结构**:
```haxe
interface SystemParam {
    function getItem(world:World, changeTick:Int):Dynamic;
    function applyDeferred(world:World):Void;
    function init(world:World):Void;
    function getState():Dynamic;
}

interface Deferred {
    function applyDeferred(world:World):Void;
}

interface ReadOnlySystemParam {
    // 只读参数标记
}

// Query 参数
class Query<D:QueryData, F:QueryFilter> implements SystemParam {
    private var world:World;
    private var state:QueryState;
    
    public function getItem(world:World, changeTick:Int):Dynamic;
    public function applyDeferred(world:World):Void;
    public function init(world:World):Void;
    public function getState():QueryState;
}

// Commands 参数
class Commands implements SystemParam implements Deferred {
    private var queue:CommandQueue;
    private var world:World;
    
    public function new();
    public function getItem(world:World, changeTick:Int):Commands;
    public function applyDeferred(world:World):Void;
    public function init(world:World):Void;
    public function getState():Dynamic;
}

// Local 参数
@:generic
class Local<T> {
    public var value:T;
    public function new(?value:T);
}

// EventWriter
@:generic
class EventWriter<T:Event> implements Deferred {
    private var events:Events<T>;
    public function new(events:Events<T>);
    public function send(event:T):Void;
    public function sendBatch(batch:EventBatch<T>):Void;
    public function applyDeferred(world:World):Void;
}

// EventReader  
@:generic
class EventReader<T:Event> {
    private var events:Events<T>;
    private var lastReadTick:Int;
    public function new(events:Events<T>);
    public function read():Array<T>;
    public function readWithIteration():Iterator<T>;
    public function clear():Void;
}
```

### Step 8: 改进 Events.hx

**文件**: `src/haxe/ecs/Events.hx`

**改进内容**:
- 实现 Bevy 风格的事件系统
- 添加事件批处理
- 实现双缓冲事件读取

**关键代码结构**:
```haxe
class Events<T:Event> implements Resource {
    private var events:Array<T>;
    private var batches:Array<EventBatch<T>>;
    private var lastReaders:Map<Int, Int>;
    private var eventCount:Int = 0;
    
    public function new();
    public function send(event:T):Void;
    public function sendBatch(batch:EventBatch<T>):Void;
    public function update():Void;
    public function clear():Void;
    public function isEmpty():Bool;
}

class EventBatch<T:Event> {
    public var events:Array<T>;
    public var tick:Int;
    public function new(events:Array<T>, tick:Int);
}

interface Event {
    // 事件标记接口
}

class EventListener<T:Event> {
    public function onEvent(event:T):Void;
}
```

### Step 9: 改进 Commands.hx

**文件**: `src/haxe/ecs/Commands.hx`

**改进内容**:
- 实现 EntityCommands 接口
- 添加更多命令类型
- 实现 Commands 链式 API

**关键代码结构**:
```haxe
interface Command {
    function apply(world:World):Void;
}

interface EntityCommand {
    function apply(entity:Entity, world:World):Void;
}

class CommandQueue {
    private var commands:Array<Command>;
    
    public function new();
    public function push(command:Command):Void;
    public function queue(command:Command):Void;
    public function apply(world:World):Void;
    public function clear():Void;
    public function isEmpty():Bool;
}

class Commands implements SystemParam implements Deferred {
    private var queue:CommandQueue;
    private var world:World;
    private var currentEntity:Entity;
    
    public function new();
    public function getItem(world:World, changeTick:Int):Commands;
    public function applyDeferred(world:World):Void;
    public function init(world:World):Void;
    
    // 实体命令
    public function spawn():EntityCommands;
    public function spawnAt(entity:Entity):EntityCommands;
    public function getEntity(entity:Entity):EntityCommands;
    
    // 资源命令
    public function insertResource<T>(resource:T):Void;
    public function removeResource<T>(cls:Class<T>):Void;
    
    // 批量命令
    public function spawn_batch(entities:Array<Entity>):Void;
}

class EntityCommands {
    private var entity:Entity;
    private var commands:Commands;
    
    public function new(entity:Entity, commands:Commands);
    public function insert<T:Component>(component:T):EntityCommands;
    public function insertBundle<T:Bundle>(bundle:T):EntityCommands;
    public function remove<T:Component>(cls:Class<T>):EntityCommands;
    public function despawn():Void;
    public function id():Entity;
}

// 常用命令实现
class SpawnCommand implements Command {
    private var bundle:Dynamic;
    public function new(bundle:Dynamic);
    public function apply(world:World):Void;
}

class DespawnCommand implements Command {
    private var entity:Entity;
    public function new(entity:Entity);
    public function apply(world:World):Void;
}

class InsertCommand<T:Component> implements Command {
    private var entity:Entity;
    private var component:T;
    public function new(entity:Entity, component:T);
    public function apply(world:World):Void;
}

class RemoveCommand<T:Component> implements Command {
    private var entity:Entity;
    public function new(entity:Entity);
    public function apply(world:World):Void;
}
```

---

## 3. 文件变更总结

### 新建文件
| 文件 | 描述 |
|------|------|
| - | (所有文件已存在，需要改进) |

### 修改文件
| 文件 | 描述 |
|------|------|
| `src/haxe/ecs/World.hx` | 增强 archetype 支持和变更检测 |
| `src/haxe/ecs/Query.hx` | 重构查询系统 |
| `src/haxe/ecs/QueryFilter.hx` | 增强过滤系统 |
| `src/haxe/ecs/Component.hx` | 添加存储类型支持 |
| `src/haxe/ecs/Bundle.hx` | 实现完整的 Bundle 接口 |
| `src/haxe/ecs/Schedule.hx` | 改进调度器实现 |
| `src/haxe/ecs/SystemParam.hx` | 完善系统参数 |
| `src/haxe/ecs/Events.hx` | 改进事件系统 |
| `src/haxe/ecs/Commands.hx` | 改进命令系统 |

### 宏文件
| 文件 | 描述 |
|------|------|
| `src/haxe/macro/ComponentMacro.hx` | 组件自动注册 |
| `src/haxe/macro/BundleMacro.hx` | Bundle 自动生成 |

---

## 4. 测试策略

### 单元测试
- 组件注册和查询
- Bundle 插入/移除
- 事件发送和读取
- 命令队列执行

### 集成测试
- 完整的 ECS 工作流
- Schedule 系统调度
- 变化检测正确性

---

## 5. 预估工作量

- **复杂度**: 中等
- **时间估计**: 4-6 小时
- **文件数量**: 9 个主要文件 + 2 个宏文件

---

**创建时间**: 2025-02-15
**参考**: `/home/vscode/projects/bevy/crates/bevy_ecs/src/`
