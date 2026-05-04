# Bevy ECS 模块改进计划

## 1. 概述

基于 Bevy Rust ECS 实现，为 Haxe 移植版本进行模块增强。本次改进将：
- 增强 World.hx 添加 archetype 支持和更好的变更检测
- 增强 Query.hx 支持更复杂的查询模式
- 添加 QueryFilter.hx 实现完整的过滤器
- 改进 Component.hx 添加 @:component 宏支持
- 改进 Bundle.hx 添加 @:bundle 宏支持
- 完善 Schedule.hx 调度器实现
- 完善 SystemParam.hx 系统参数接口
- 完善 Events.hx 事件系统
- 完善 Commands.hx 命令队列

### 目标
- 尽可能保持与 Bevy Rust API 接近的命名和结构
- 使用 Haxe 宏来处理组件注册
- 工作目录: /home/vscode/projects/bevy_haxe

---

## 2. 目录结构

```
src/haxe/ecs/
├── World.hx              # 增强：Archetype 支持、变更检测
├── Query.hx              # 增强：复杂查询模式
├── QueryFilter.hx        # 新增：完整的过滤器实现
├── QueryIter.hx          # 新增：查询迭代器
├── WorldQuery.hx         # 新增：WorldQuery trait
├── Component.hx          # 改进：@:component 宏
├── Bundle.hx             # 改进：@:bundle 宏
├── Schedule.hx           # 完善：调度器
├── SystemParam.hx        # 完善：系统参数
├── Events.hx            # 完善：事件系统
├── Commands.hx           # 完善：命令队列
├── Archetype.hx         # 已有：Archetype 实现
├── prelude/
│   └── EcsTypes.hx      # 新增：预导入类型
└── schedule/
    └── ScheduleGraph.hx # 已有：调度图
```

---

## 3. 实现步骤

### 3.1 World.hx 增强

**文件**: `src/haxe/ecs/World.hx`

**改进内容**:
1. 添加 `Archetypes` 管理器 - 存储和检索 archetypes
2. 添加 `Components` 注册表 - 组件类型注册
3. 添加 `Entities` 管理器 - 实体生命周期
4. 实现 `Table` 和 `SparseSet` 存储
5. 完善变更检测 (ChangeDetection) 系统
6. 添加 `CommandQueue` 支持

**关键结构**:
```haxe
class World {
    public var entities:Entities;           // 实体管理器
    public var archetypes:Archetypes;       // Archetype 管理器
    public var components:Components;       // 组件注册表
    public var storages:Storage;            // 存储
    public var removedComponents:RemovedComponents; // 被移除组件追踪
    public var changeTick:UInt;             // 变更 tick
    public var lastChangeTick:UInt;          // 上次变更 tick
    
    // 核心方法
    public function spawn():Entity;
    public function spawnBundle(components:Array<Dynamic>):Entity;
    public function despawn(entity:Entity):Void;
    public function add<T:Component>(entity:Entity, component:T):T;
    public function get<T:Component>(entity:Entity, cls:Class<T>):T;
    public function remove<T:Component>(entity:Entity, cls:Class<T>):Void;
    public function query<D, F>(desc:QueryDescription):Query<D, F>;
    public function registerComponent<T:Component>(?storage:StorageType):Void;
    public function getResource<T:Resource>():T;
    public function insertResource<T:Resource>(resource:T):Void;
}
```

### 3.2 Query.hx 增强

**文件**: `src/haxe/ecs/Query.hx`

**改进内容**:
1. 实现 `Query` 结构体 - 类型安全的查询
2. 实现 `QueryState` - 查询状态缓存
3. 添加 `QueryIter` 迭代器
4. 支持 `&T` (只读) 和 `&mut T` (可变) 访问
5. 支持多组件查询
6. 添加 `Option<T>` 支持

**关键结构**:
```haxe
interface QueryData {
    // 只读查询数据
}

interface QueryFilter {
    // 过滤条件
}

class Query<D:QueryData, F:QueryFilter = ()->Bool> {
    private var state:QueryState<D, F>;
    private var world:World;
    
    public function iter():QueryIter<D, F>;
    public function iterWithFilter():FilteredQueryIter<D, F>;
    public function get(entity:Entity):D;
    public function getMut(entity:Entity):D;
    public function contains(entity:Entity):Bool;
}

class QueryIter<D, F> {
    public function hasNext():Bool;
    public function next():D;
}
```

### 3.3 QueryFilter.hx 实现

**文件**: `src/haxe/ecs/QueryFilter.hx`

**过滤器类型**:
```haxe
// With<T> - 必须包含组件 T
@:generic
class With<T:Component> implements QueryFilter {
    public function matches(entity:Entity, world:World):Bool;
}

// Without<T> - 必须不包含组件 T
@:generic
class Without<T:Component> implements QueryFilter {
    public function matches(entity:Entity, world:World):Bool;
}

// Changed<T> - 组件 T 已被修改
@:generic
class Changed<T:Component> implements QueryFilter {
    public function matches(entity:Entity, world:World):Bool;
}

// Added<T> - 组件 T 刚被添加
@:generic
class Added<T:Component> implements QueryFilter {
    public function matches(entity:Entity, world:World):Bool;
}

// Or<A, B> - 任一过滤器匹配
class Or<A:QueryFilter, B:QueryFilter> implements QueryFilter {}

// And<A, B> - 所有过滤器都匹配
class And<A:QueryFilter, B:QueryFilter> implements QueryFilter {}

// None<T> - 不包含 T
@:generic
class None<T:Component> implements QueryFilter {}

// Has<T> - 包含 T (可用于任意类型，包括资源)
@:generic
class Has<T> implements QueryFilter {}
```

### 3.4 WorldQuery.hx 实现

**文件**: `src/haxe/ecs/WorldQuery.hx`

**WorldQuery trait 实现**:
```haxe
interface WorldQuery<D> {
    // 初始化查询状态
    function initState(world:World):QueryState;
    
    // 获取组件数据
    function getItem(entity:Entity, world:World, state:QueryState):D;
    
    // 更新访问权限
    function updateAccess(state:QueryState, access:FilteredAccess):Void;
}
```

**实现**:
- `Read<T>` - 只读组件访问
- `Write<T>` - 可变组件访问
- `Option<T>` - 可选组件访问
- `Entity` - 实体 ID 访问

### 3.5 Component.hx 改进

**文件**: `src/haxe/ecs/Component.hx`

**改进内容**:
1. 添加 `StorageType` 枚举 (Table, SparseSet, TableBundle)
2. 添加 `ComponentDescriptor` 结构
3. 添加 `ComponentHooks` 支持
4. 完善 `@:component` 宏集成

**关键结构**:
```haxe
enum StorageType {
    Table;        // 表格存储（大多数组件）
    SparseSet;    // 稀疏集存储（少数组件）
    TableBundle;  // 表束存储
}

interface Component {
    // 实现此接口表示这是一个组件类型
}

class ComponentInfo {
    public var id:ComponentId;
    public var name:String;
    public var storageType:StorageType;
    public var layout:Int;  // 内存布局大小
    public var drop:Dynamic;
}

interface ComponentHook {
    function onAdd(entity:Entity, world:World):Void;
    function onRemove(entity:Entity, world:World):Void;
    function onReplace(entity:Entity, world:World):Void;
}
```

### 3.6 Bundle.hx 改进

**文件**: `src/haxe/ecs/Bundle.hx`

**改进内容**:
1. 完善 `Bundle` trait
2. 添加 `BundleInfo` 结构
3. 实现 `DynamicBundle` 接口
4. 添加 `FromComponents` 支持
5. 完善 `@:bundle` 宏集成

**关键结构**:
```haxe
interface Bundle {
    function getComponentTypes():Array<ComponentId>;
    function componentCount():Int;
}

class BundleInfo {
    public var id:BundleId;
    public var componentTypes:Array<ComponentId>;
    public var archetypeId:ArchetypeId;
}

interface DynamicBundle {
    function writeToWorld(world:World, entity:Entity):Void;
}

// 元组 Bundle
typedef Bundle2<T1:Component, T2:Component> = {c1:T1, c2:T2};
typedef Bundle3<T1:Component, T2:Component, T3:Component> = {c1:T1, c2:T2, c3:T3};
// ... 扩展到 16
```

### 3.7 Schedule.hx 完善

**文件**: `src/haxe/ecs/Schedule.hx`

**改进内容**:
1. 添加 `ScheduleLabel` 标识
2. 实现 `ScheduleExecutor` 接口
3. 添加 `SystemSet` 配置
4. 实现条件系统
5. 添加阶段和图结构

**关键结构**:
```haxe
interface ScheduleLabel {
    function intern():String;
}

class Schedule implements ScheduleLabel {
    public var label:ScheduleLabel;
    public var graph:ScheduleGraph;
    public var stages:Array<SystemSet>;
    
    public function addSystem(system:System, ?set:SystemSet):Void;
    public function addSystemSet(systemSet:SystemSet):Void;
    public function configureSystems(target:System, deps:Array<System>):Void;
    public function run(world:World):Void;
}

// 执行器
interface ScheduleExecutor {
    function execute(schedule:Schedule, world:World):Void;
}

class SingleThreadedExecutor implements ScheduleExecutor {}
class MultiThreadedExecutor implements ScheduleExecutor {}
```

### 3.8 SystemParam.hx 完善

**文件**: `src/haxe/ecs/SystemParam.hx`

**改进内容**:
1. 完善 `SystemParam` 接口
2. 实现 `SystemParamState`
3. 添加 `Deferred` 接口
4. 实现 `Query<T>` 参数
5. 添加 `EventReader<T>` 和 `EventWriter<T>`

**关键结构**:
```haxe
interface SystemParam {
    function getItem(world:World, changeTick:UInt):Dynamic;
    function applyDeferred(world:World):Void;
    function init(world:World):Void;
    function getState():Dynamic;
}

// 资源参数
class Res<T:Resource> implements SystemParam {
    public var value:T;
    public var lastChangeTick:UInt;
}

// 可变资源参数
class ResMut<T:Resource> implements SystemParam {
    public var value:T;
    public var lastChangeTick:UInt;
}

// 查询参数
class QueryParam<D:QueryData, F:QueryFilter> implements SystemParam {
    public var query:Query<D, F>;
}

// 命令参数
class Commands implements SystemParam {
    public var queue:CommandQueue;
    public var currentEntity:Entity;
}
```

### 3.9 Events.hx 完善

**文件**: `src/haxe/ecs/Events.hx`

**改进内容**:
1. 实现双缓冲事件系统
2. 添加 `EventReader` 和 `EventWriter`
3. 实现批处理事件
4. 添加自动清除控制

**关键结构**:
```haxe
class Events<T:Event> implements Resource {
    private var eventsA:Array<T>;
    private var eventsB:Array<T>;
    private var readerCount:Int;
    
    public function new():Void;
    public function send(event:T):Void;
    public function update():Void;
    public function clear():Void;
}

class EventReader<T:Event> implements SystemParam {
    private var cursor:UInt;
    
    public function read():Array<T>;
    public function clear():Void;
}

class EventWriter<T:Event> implements SystemParam {
    public function send(event:T):Void;
    public function sendBatch(events:Array<T>):Void;
}
```

### 3.10 Commands.hx 完善

**文件**: `src/haxe/ecs/Commands.hx`

**改进内容**:
1. 实现 `Command` trait
2. 实现 `EntityCommand` trait
3. 实现 `CommandQueue`
4. 实现 `Commands` 系统参数
5. 添加常见命令实现

**关键结构**:
```haxe
interface Command {
    function apply(world:World):Void;
}

interface EntityCommand {
    function apply(entity:Entity, world:World):Void;
}

class CommandQueue {
    private var commands:Array<Command>;
    
    public function queue(command:Command):Void;
    public function apply(world:World):Void;
}

class Commands implements SystemParam {
    private var queue:CommandQueue;
    private var currentEntity:Entity;
    
    public function spawn():EntityCommands;
    public function getEntity(entity:Entity):EntityCommands;
    public function queue(command:Command):Void;
}

// 常见命令
class SpawnCommand implements Command {
    public var bundle:Dynamic;
    public function apply(world:World):Void;
}

class DespawnCommand implements Command {
    public var entity:Entity;
    public function apply(world:World):Void;
}

class InsertCommand<T:Component> implements Command {
    public var entity:Entity;
    public var component:T;
    public function apply(world:World):Void;
}

class RemoveCommand<T:Component> implements Command {
    public var entity:Entity;
    public function apply(world:World):Void;
}
```

### 3.11 prelude/EcsTypes.hx 新增

**文件**: `src/haxe/ecs/prelude/EcsTypes.hx`

**预导入类型**:
```haxe
package haxe.ecs.prelude;

// ECS Core
import haxe.ecs.World;
import haxe.ecs.Entity;
import haxe.ecs.Component;
import haxe.ecs.Bundle;
import haxe.ecs.Resource;

// Query
import haxe.ecs.Query;
import haxe.ecs.QueryFilter;
import haxe.ecs.QueryIter;
import haxe.ecs.WorldQuery;

// Filters
typedef With<T:Component> = haxe.ecs.query.With<T>;
typedef Without<T:Component> = haxe.ecs.query.Without<T>;
typedef Changed<T:Component> = haxe.ecs.query.Changed<T>;
typedef Added<T:Component> = haxe.ecs.query.Added<T>;

// System
import haxe.ecs.System;
import haxe.ecs.SystemParam;
import haxe.ecs.FunctionSystem;
import haxe.ecs.Commands;

// Events
import haxe.ecs.Events;
import haxe.ecs.EventReader;
import haxe.ecs.EventWriter;

// Schedule
import haxe.ecs.Schedule;
import haxe.ecs.ScheduleStages;
import haxe.ecs.SystemSet;

// Change Detection
import haxe.ecs.ChangeDetection;

// Storage
import haxe.ecs.Storage;
import haxe.ecs.StorageType;
```

---

## 4. 文件变更清单

### 新增文件
| 文件 | 描述 |
|------|------|
| `src/haxe/ecs/prelude/EcsTypes.hx` | ECS 预导入类型 |
| `src/haxe/ecs/WorldQuery.hx` | WorldQuery trait |
| `src/haxe/ecs/QueryIter.hx` | 查询迭代器 |

### 修改文件
| 文件 | 描述 |
|------|------|
| `src/haxe/ecs/World.hx` | 增强 archetype 支持 |
| `src/haxe/ecs/Query.hx` | 增强复杂查询支持 |
| `src/haxe/ecs/QueryFilter.hx` | 完善过滤器实现 |
| `src/haxe/ecs/Component.hx` | 添加存储类型和宏支持 |
| `src/haxe/ecs/Bundle.hx` | 添加 BundleInfo 和宏支持 |
| `src/haxe/ecs/Schedule.hx` | 完善调度器 |
| `src/haxe/ecs/SystemParam.hx` | 完善系统参数 |
| `src/haxe/ecs/Events.hx` | 完善事件系统 |
| `src/haxe/ecs/Commands.hx` | 完善命令队列 |

### 宏文件
| 文件 | 描述 |
|------|------|
| `src/haxe/macro/ComponentMacro.hx` | 已有，增强组件宏 |
| `src/haxe/macro/BundleMacro.hx` | 已有，增强 Bundle 宏 |

---

## 5. 测试策略

### 单元测试
1. **World 测试**
   - 实体创建和销毁
   - 组件添加/获取/移除
   - Archetype 组织
   - 资源管理

2. **Query 测试**
   - 简单组件查询
   - 多组件查询
   - 带过滤器的查询
   - 变更检测查询

3. **Commands 测试**
   - 命令入队和应用
   - 延迟执行
   - 命令链

4. **Events 测试**
   - 事件发送和读取
   - 双缓冲
   - 批处理

### 集成测试
1. 完整的系统执行流程
2. 调度器运行
3. 事件驱动系统

---

## 6. 依赖关系

```
World.hx
├── Entity.hx
├── Archetype.hx (存在)
├── Component.hx
├── Bundle.hx
├── Commands.hx
└── Resource.hx

Query.hx
├── World.hx
├── QueryFilter.hx
├── WorldQuery.hx
└── QueryIter.hx

SystemParam.hx
├── World.hx
├── Query.hx
├── Commands.hx
└── Events.hx

Schedule.hx
├── System.hx
├── SystemParam.hx
└── Commands.hx
```

---

## 7. 估计工作量

| 任务 | 复杂度 | 时间估计 |
|------|--------|----------|
| World.hx 增强 | 高 | 2-3 小时 |
| Query.hx 增强 | 高 | 2-3 小时 |
| QueryFilter.hx 实现 | 中 | 1-2 小时 |
| Component.hx 改进 | 中 | 1 小时 |
| Bundle.hx 改进 | 中 | 1 小时 |
| Schedule.hx 完善 | 中 | 1-2 小时 |
| SystemParam.hx 完善 | 中 | 1-2 小时 |
| Events.hx 完善 | 中 | 1 小时 |
| Commands.hx 完善 | 中 | 1 小时 |
| prelude/EcsTypes.hx 新增 | 低 | 30 分钟 |

**总计**: 约 12-16 小时

---

**创建时间**: 2025-02-10
**参考**: `/home/vscode/projects/bevy/crates/bevy_ecs/src/`
