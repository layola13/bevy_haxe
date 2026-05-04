# Bevy ECS Core Implementation Plan

## 1. Overview

完善 bevy_ecs 核心，参考 Rust bevy/crates/bevy_ecs/src/ 代码，转换为核心 Haxe 实现。

### Goals
- Entity 使用 index + generation 模式（检测悬垂指针）
- Component 用 interface 标记，支持 ComponentId
- Bundle 支持任意组件数量（使用 Tuple 类型）
- Query 支持泛型参数 Query<T1, T2, ...>
- 使用宏简化组件注册

### Success Criteria
- Entity 可正确追踪 generation，检测无效实体
- Component 可通过 interface 标记并获取 ComponentId
- Bundle 可支持 1-16 个组件
- Query 可过滤 With/Without 组件
- QueryIter 提供迭代器接口

---

## 2. Files to Modify/Create

### Existing Files (Modify)
| File | Changes |
|------|---------|
| `src/haxe/ecs/Entity.hx` | 增强 generation 支持，添加 EntityIndex/EntityGeneration |
| `src/haxe/ecs/Component.hx` | 检查 ComponentId 实现 |
| `src/haxe/ecs/Bundle.hx` | 增强 Bundle 实现，添加 Bundle0-Bundle16 |
| `src/haxe/ecs/World.hx` | 增强存储结构，添加 archetype 支持 |
| `src/haxe/ecs/Query.hx` | 增强查询功能 |

### New Files (Create)
| File | Description |
|------|-------------|
| `src/haxe/ecs/QueryFilter.hx` | 过滤系统 (With, Without, Or) |
| `src/haxe/ecs/QueryIter.hx` | 查询迭代器 |
| `src/haxe/ecs/EntityLocation.hx` | 实体位置信息 |
| `src/haxe/ecs/Archetype.hx` | 原型类型 |

---

## 3. Implementation Details

### 3.1 Entity (Entity.hx)

```haxe
// Entity = index + generation
// index: 实体槽位索引
// generation: 代际计数，实体复用时递增

abstract Entity(Long) {
    // from_id_index(32bit index, 32bit generation)
    // to_bits() -> Long
    // index() -> Int
    // generation() -> Int
}

// EntityIndex: 索引部分
abstract EntityIndex(UInt)

// EntityGeneration: 代际部分
abstract EntityGeneration(UInt)
```

### 3.2 Component (Component.hx)

```haxe
interface Component {
    // Marker interface
}

interface ComponentInfo {
    var id:ComponentId;
    var name:String;
    var isSparse:Bool;
}
```

### 3.3 Bundle (Bundle.hx)

```haxe
interface Bundle {
    function getComponentTypes():Array<ComponentId>;
    function componentCount():Int;
}

// Bundle0 到 Bundle16 泛型实现
class Bundle1<T1:Component> implements Bundle { ... }
class Bundle2<T1:Component, T2:Component> implements Bundle { ... }
// ... Bundle16
```

### 3.4 QueryFilter (QueryFilter.hx)

```haxe
interface QueryFilter {
    // 过滤标记接口
}

class With<T:Component> implements QueryFilter {
    // 包含 T 组件
}

class Without<T:Component> implements QueryFilter {
    // 不包含 T 组件
}

class Or<F1:QueryFilter, F2:QueryFilter> implements QueryFilter {
    // 满足 F1 或 F2
}

// Tuple 组合
typedef QueryFilterTuple<T:QueryFilter, Rest:QueryFilter> = Tuple2<T, Rest>;
```

### 3.5 QueryIter (QueryIter.hx)

```haxe
interface QueryIter<Q:QueryData, F:QueryFilter> {
    function hasNext():Bool;
    function next():QueryItem<Q>;
    function count():Int;
}

class QueryIterImpl<Q:QueryData, F:QueryFilter> implements QueryIter<Q, F> {
    // 基于 World 迭代
}
```

### 3.6 World (World.hx 增强)

```haxe
class World {
    // Entity 管理
    var entityAllocs:EntityAllocator;
    var entities:Entities;
    
    // Component 存储
    var components:Components;
    var storages:Map<ComponentId, ComponentStorage>;
    
    // Archetype
    var archetypes:Array<Archetype>;
    var archetypeById:Map<ComponentIdSet, Archetype>;
    
    // 方法
    function spawn<T:Bundle>(bundle:T):Entity;
    function spawnBatch<T:Bundle>(bundles:Array<T>):Void;
    function despawn(entity:Entity):Bool;
    function insert(entity:Entity, bundle:Bundle):Void;
    function remove<T:Bundle>(entity:Entity):Void;
    
    // Query
    function query<Q:QueryData, F:QueryFilter>():Query<Q, F>;
}
```

---

## 4. Component Registration Macro

```haxe
// @:component 宏
@:component
class Position implements Component {
    public var x:Float;
    public var y:Float;
}

// 生成的代码:
// 1. 注册 ComponentId
// 2. 实现 Component 接口方法
// 3. 添加到 ComponentRegistry
```

---

## 5. Testing

### Unit Tests
- `test/ecs/EntityTest.hx` - Entity index/generation 测试
- `test/ecs/BundleTest.hx` - Bundle 组装测试
- `test/ecs/QueryTest.hx` - Query 过滤测试

### Integration Tests
- `examples/QueryExampleUpdated.hx` - 完整示例

---

## 6. Rollback Plan

如需回滚，删除以下新增/修改文件：
- `src/haxe/ecs/QueryFilter.hx`
- `src/haxe/ecs/QueryIter.hx`
- `src/haxe/ecs/EntityLocation.hx`
- 修改后的 Entity.hx, Component.hx, Bundle.hx, World.hx, Query.hx

---

## 7. Estimated Effort

- **Time**: 4-6 小时
- **Complexity**: High
- **Dependencies**: ECS 基础结构, 宏系统
