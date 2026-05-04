# Bevy ECS 模块改进计划

## 1. 概述

基于 Bevy Rust ECS 实现，为 Haxe 移植创建增强的 ECS 模块。

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
- 所有接口和类编译通过
- 与 Bevy Rust API 保持接近的命名和结构
- 使用 Haxe 宏来处理组件注册

---

## 2. 文件清单

### 修改的文件
| 文件 | 描述 |
|------|------|
| `src/haxe/ecs/World.hx` | 增强 archetype 支持和变更检测 |
| `src/haxe/ecs/Query.hx` | 支持复杂查询模式 |
| `src/haxe/ecs/Component.hx` | 添加 @:component 宏支持 |
| `src/haxe/ecs/Bundle.hx` | 添加 @:bundle 宏支持 |
| `src/haxe/ecs/QueryFilter.hx` | 实现 Changed, Added, With, Without 等过滤器 |
| `src/haxe/ecs/Schedule.hx` | 改进调度器实现 |
| `src/haxe/ecs/SystemParam.hx` | 改进系统参数接口 |
| `src/haxe/ecs/Events.hx` | 改进事件系统 |
| `src/haxe/ecs/Commands.hx` | 改进命令队列 |

### 新增的文件
| 文件 | 描述 |
|------|------|
| `src/haxe/ecs/prelude/Prelude.hx` | ECS 预导入模块 |
| `src/haxe/ecs/WorldQuery.hx` | WorldQuery trait |
| `src/haxe/ecs/ChangeDetection.hx` | 变更检测实现 |

---

## 3. 核心实现细节

### 3.1 World.hx 增强

**新增功能**:
- `archetypes:Archetypes` - 原型管理
- `components:Components` - 组件存储
- `bundles:Bundles` - Bundle 注册
- `storages:Map<Int, ComponentStorage>` - 组件存储
- `entityLocation:Map<Int, EntityLocation>` - 实体位置追踪

**原型管理**:
```haxe
// 获取实体的原型
function getArchetype(entity:Entity):ArchetypeId

// 根据组件集合获取/创建原型
function getOrCreateArchetype(componentIds:Array<ComponentId>):ArchetypeId

// 在原型之间移动实体
function moveEntity(entity:Entity, newArchetype:ArchetypeId):Void
```

**变更检测**:
```haxe
// Tick 管理
var changeTick:UInt
var lastChangeTick:Tick

// 组件变更追踪
function getComponentTicks(entity:Entity, componentId:ComponentId):ComponentTicks
function checkComponentChanged(entity:Entity, componentId:ComponentId, lastRun:Tick):Bool
```

### 3.2 Query.hx 增强

**Query 结构**:
```haxe
class Query<D:WorldQuery, F:QueryFilter> {
    var world:World;
    var state:QueryState<D, F>;
    
    function iter():QueryIter<D, F>;
    function iterWith(filter:F):FilteredQueryIter<D, F>;
    function get(entity:Entity):Option<D>;
    function getMut(entity:Entity):Option<D>;
    function contains(entity:Entity):Bool;
    function count():Int;
}
```

**QueryState**:
```haxe
class QueryState<D:WorldQuery, F:QueryFilter> {
    var archetypeAccess:FilteredAccess;
    var matchedArchetypes:Array<ArchetypeId>;
    var matchedTables:Array<TableId>;
}
```

### 3.3 QueryFilter.hx 增强

**过滤器类型**:
```haxe
// With<T> - 必须包含组件 T
@:generic
class With<T:Component> implements QueryFilter {
    var isArchetypal:Bool = true;
    function matches(entity:Entity):Bool;
}

// Without<T> - 不能包含组件 T
@:generic
class Without<T:Component> implements QueryFilter {
    var isArchetypal:Bool = true;
    function matches(entity:Entity):Bool;
}

// Changed<T> - 组件 T 被修改
@:generic
class Changed<T:Component> implements QueryFilter {
    var isArchetypal:Bool = false;
    function matches(entity:Entity):Bool;
}

// Added<T> - 组件 T 被添加
@:generic
class Added<T:Component> implements QueryFilter {
    var isArchetypal:Bool = false;
    function matches(entity:Entity):Bool;
}

// Or<F1, F2> - 任一过滤器匹配
@:generic
class Or<F1:QueryFilter, F2:QueryFilter> implements QueryFilter {
    var isArchetypal:Bool = false;
    function matches(entity:Entity):Bool;
}
```

### 3.4 Component.hx 宏支持

**@:component 宏生成**:
```haxe
@:component
class Position {
    public var x:Float;
    public var y:Float;
}

// 宏生成:
class Position implements Component {
    public var x:Float;
    public var y:Float;
    
    static var COMPONENT_ID:ComponentId = ComponentRegistry.register(
        "Position", 
        sizeof(Position), 
        StorageType.Table
    );
    
    public var componentTypeId(get, never):Int;
    private inline function get_componentTypeId():Int return COMPONENT_ID.id;
}
```

### 3.5 Bundle.hx 宏支持

**@:bundle 宏生成**:
```haxe
@:bundle
class PlayerBundle {
    public var position:Position;
    public var velocity:Velocity;
    public var sprite:Sprite;
}

// 宏生成:
class PlayerBundle implements Bundle {
    public var position:Position;
    public var velocity:Velocity;
    public var sprite:Sprite;
    
    static var BUNDLE_ID:BundleId = BundleRegistry.register(
        "PlayerBundle",
        [Position.COMPONENT_ID, Velocity.COMPONENT_ID, Sprite.COMPONENT_ID]
    );
    
    function getComponentTypes():Array<ComponentId> {
        return [
            Position.COMPONENT_ID,
            Velocity.COMPONENT_ID,
            Sprite.COMPONENT_ID
        ];
    }
    
    function componentCount():Int return 3;
    
    function spawnInto(world:World):Entity {
        return world.spawnBundle(this);
    }
}
```

### 3.6 Schedule.hx 增强

**Schedule 结构**:
```haxe
class Schedule {
    var label:ScheduleLabel;
    var graph:ScheduleGraph;
    var stages:Array<SystemSet>;
    var executor:ScheduleExecutor;
    
    function addSystem(system:System, ?set:SystemSet):Void;
    function addSystemSet(systemSet:SystemSet):Void;
    function addCondition(condition:SystemCondition):Void;
    function run(world:World):Void;
    function build():Void;
}
```

**ScheduleGraph**:
```haxe
class ScheduleGraph {
    var systems:Map<String, SystemNode>;
    var conditions:Map<String, Array<SystemCondition>>;
    var hierarchy:DiGraph<String>;
}
```

### 3.7 SystemParam.hx 增强

**SystemParam 接口**:
```haxe
interface SystemParam {
    function getItem(world:World, changeTick:UInt):Dynamic;
    function applyDeferred(world:World):Void;
    function init(world:World):Void;
    function getState():Dynamic;
}
```

**实现类**:
- `Res<T>` - 只读资源
- `ResMut<T>` - 可变资源
- `Query<D, F>` - 组件查询
- `Query<D, F>.Item` - 单个查询结果
- `Commands` - 命令队列
- `Local<T>` - 系统本地状态
- `NonSend<T>` / `NonSendMut<T>` - 非 Send 资源

### 3.8 Events.hx 增强

**Events 结构**:
```haxe
class Events<T:Event> implements Resource {
    var events:Array<T>;
    var eventReaderCursor:Map<Int, UInt>;
    var autoClear:Bool;
    
    function send(event:T):Void;
    function sendBatch(batch:Array<T>):Void;
    function update():Void;
    function clear():Void;
    function reader():EventReader<T>;
}
```

**EventReader**:
```haxe
class EventReader<T:Event> {
    var lastReadCursor:UInt;
    
    function read():Array<T>;
    function readLatest():Array<T>;
    function isEmpty():Bool;
}
```

### 3.9 Commands.hx 增强

**Command 接口**:
```haxe
interface Command {
    function apply(world:World):Void;
}

interface EntityCommand {
    function apply(entity:Entity, world:World):Void;
}
```

**Commands 类**:
```haxe
class Commands implements SystemParam {
    var queue:CommandQueue;
    var world:World;
    var currentEntity:Entity;
    
    function spawn():EntityCommands;
    function spawnBundle(bundle:Bundle):Entity;
    function insert(entity:Entity, bundle:Bundle):Void;
    function remove<T:Component>(entity:Entity, cls:Class<T>):Void;
    function despawn(entity:Entity):Void;
    function queueCommand(command:Command):Void;
}
```

---

## 4. 使用示例

```haxe
// 定义组件
@:component
class Position {
    public var x:Float = 0;
    public var y:Float = 0;
}

@:component
class Velocity {
    public var x:Float = 0;
    public var y:Float = 0;
}

// 定义 Bundle
@:bundle
class PlayerBundle {
    public var position:Position;
    public var velocity:Velocity;
}

// 创建世界
var world = new World();

// 生成实体
var player = world.spawn([
    new Position(0, 0),
    new Velocity(1, 0)
]);

// 使用 Query
var query = world.query([Position, Velocity], [With(Velocity)]);
for (entity in query.entities()) {
    var pos = query.get(entity);
    pos.y += 1;
}

// 使用 Changed 过滤器
var changedQuery = world.query([Position], [Changed(Position)]);
for (entity in changedQuery.entities()) {
    trace('Position changed for entity $entity');
}

// 使用 Schedule
var schedule = new Schedule();
schedule.addSystem("Update", movement_system);
schedule.run(world);

// 使用 Events
world.sendEvent(new CollisionEvent(player, enemy));
```

---

## 5. 测试策略

### 单元测试
- Component 宏正确生成注册代码
- Bundle 宏正确生成组件列表
- Query 过滤器正确匹配实体
- 变更检测正确追踪组件修改

### 集成测试
- 世界正确管理实体和组件
- 原型正确分组实体
- Schedule 正确执行系统
- Commands 延迟执行正确

---

## 6. 文件清单

```
src/haxe/ecs/
├── World.hx           (增强 - archetype 支持)
├── Query.hx           (增强 - 复杂查询)
├── Component.hx       (增强 - @:component 宏)
├── Bundle.hx          (增强 - @:bundle 宏)
├── QueryFilter.hx     (增强 - Changed, Added 等)
├── Schedule.hx        (增强 - 调度器)
├── SystemParam.hx     (增强 - 系统参数)
├── Events.hx          (增强 - 事件系统)
├── Commands.hx        (增强 - 命令队列)
├── Archetype.hx       (现有)
├── Entity.hx          (现有)
├── ChangeDetection.hx (现有)
└── prelude/
    └── Prelude.hx     (新建 - 预导入)
```

---

**创建时间**: 2025-02-20
**参考**: `/home/vscode/projects/bevy/crates/bevy_ecs/src/`
