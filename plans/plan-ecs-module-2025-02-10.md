# Bevy ECS Haxe 模块改进计划

## 1. 概述

基于 Bevy Rust ECS 实现，为 Haxe 移植创建更完善的 ECS 系统。

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

### 参考
- `/home/vscode/projects/bevy/crates/bevy_ecs/src/` - Rust ECS 实现

---

## 2. 文件修改清单

### 2.1 现有文件修改

| 文件 | 描述 | 改动 |
|------|------|------|
| `World.hx` | 添加 archetype 存储、组件变化追踪、实体映射 | 增强 |
| `Query.hx` | 添加 WorldQuery 支持、更复杂的查询模式 | 增强 |
| `Component.hx` | 添加 @:component 宏支持 | 增强 |
| `Bundle.hx` | 添加 @:bundle 宏支持 | 增强 |
| `QueryFilter.hx` | 添加 Changed, Added 过滤器 | 增强 |

### 2.2 新增文件

| 文件 | 描述 |
|------|------|
| `prelude/WorldQuery.hx` | WorldQuery trait |
| `prelude/Preamble.hx` | 导入导出 prelude |
| `Storage.hx` | 组件存储接口 |
| `EntityRef.hx` | 实体引用 |
| `EntityMut.hx` | 实体可变访问 |
| `Table.hx` | 表格存储 |

---

## 3. 实现细节

### 3.1 World.hx 增强

**新增功能:**
- `archetypes:Archetypes` - 原型管理
- `components:Components` - 组件信息管理
- `entityLocation:Map<Entity, EntityLocation>` - 实体位置追踪
- `changeTick:UInt` - 全局变化计数
- `lastChangeTick:Tick` - 上次检测tick
- `getOrCreateArchetype(components:Array<ComponentId>):ArchetypeId`
- `getArchetype(id:ArchetypeId):Archetype`
- `iterEntities():Iterator<Entity>`

### 3.2 Query.hx 增强

**新增功能:**
- 实现 `WorldQuery` 接口
- 支持可变/只读访问
- `iter():QueryIter<D, F>` - 迭代器
- `getEntity(index:Int):Entity` - 获取实体
- `len():Int` - 结果数量
- `count():Int` - 实体计数

### 3.3 QueryFilter.hx 增强

**新增过滤器和功能:**
- `Changed<T>` - 检测组件变化
- `Added<T>` - 检测组件添加
- `Or<T1, T2>` - 或逻辑过滤
- `AnyOf<T1, T2, T3>` - 任意匹配
- `None<T>` - 不包含
- `optional<T>` - 可选组件

### 3.4 Component.hx 宏增强

**@:component 宏生成:**
```haxe
@:component
class Position {
    public var x:Float = 0;
    public var y:Float = 0;
}
```

**生成代码:**
- `componentId:Int` - 静态组件ID
- `getComponentId():Int` - 获取方法
- `storageType:StorageType` - 存储类型
- 自动注册到全局组件系统

### 3.5 Bundle.hx 宏增强

**@:bundle 宏生成:**
```haxe
@:bundle
class PlayerBundle {
    public var position:Position;
    public var velocity:Velocity;
}
```

**生成代码:**
- `getComponentTypes():Array<ComponentId>` - 组件类型列表
- `FromBundle` 实现
- `spawnInto(world:World):Entity`
- `insertInto(entity:Entity, world:World):Void`

### 3.6 SystemParam.hx 增强

**新增参数类型:**
- `Query<D, F>` - 查询参数
- `Commands` - 命令队列
- `EntityRef` - 实体只读访问
- `EntityMut` - 实体可变访问
- `OptionRes<T>` - 可选资源

### 3.7 Schedule.hx 实现

**核心功能:**
- `stages:Array<SystemSet>` - 系统阶段
- `addSystem(system:System, ?set:SystemSet):Void`
- `addSystemSet(set:SystemSet):Void`
- `run(world:World):Void` - 执行调度
- `build():Void` - 构建执行图

### 3.8 Events.hx 实现

**事件系统:**
- `Events<T>` 类 - 事件缓冲区
- `send(event:T):Void` - 发送事件
- `update():Void` - 更新事件缓冲
- `clear():Void` - 清空事件
- `EventReader<T>` - 事件读取器
- `EventWriter<T>` - 事件写入器

### 3.9 Commands.hx 实现

**命令队列:**
- `CommandQueue` - 命令队列
- `Commands` - 系统参数
- `EntityCommands` - 实体命令
- `SpawnCommand` - 生成实体命令
- `DespawnCommand` - 销毁实体命令
- `InsertCommand` - 插入组件命令
- `RemoveCommand` - 移除组件命令

---

## 4. 数据结构

### 4.1 EntityLocation
```haxe
class EntityLocation {
    var archetypeId:ArchetypeId;
    var index:Int;  // 在 archetype 中的索引
    var generation:Int;  // 实体代数
}
```

### 4.2 ComponentInfo
```haxe
class ComponentInfo {
    var id:ComponentId;
    var name:String;
    var storageType:StorageType;  // Table / SparseSet
    var isRequired:Bool;
}
```

### 4.3 Archetype
```haxe
class Archetype {
    var id:ArchetypeId;
    var componentIds:Array<ComponentId>;
    var entities:Array<Entity>;
    var table:Table;  // 组件数据表
}
```

---

## 5. 测试策略

### 5.1 单元测试
- World 原型管理
- Query 查询过滤
- Commands 命令执行
- Events 事件发送/接收

### 5.2 集成测试
- 系统调度执行
- 组件变化检测
- 实体生命周期

---

## 6. 优先级

1. **高优先级**: World.hx, Query.hx, QueryFilter.hx
2. **中优先级**: Component.hx, Bundle.hx 宏
3. **低优先级**: Schedule.hx, Events.hx, Commands.hx

---

**创建时间**: 2025-02
**参考**: `/home/vscode/projects/bevy/crates/bevy_ecs/src/`
