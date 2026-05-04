# Bevy ECS 核心完善计划

## 1. 概述

本计划旨在完善 `/home/vscode/projects/bevy_haxe` 中的 bevy_ecs 核心实现，参考 Rust 版本 `/home/vscode/projects/bevy/crates/bevy_ecs/src/` 的设计。

### 目标
- Entity 使用 index + generation 模式，支持 entity 复用
- Component 用 interface 标记，支持运行时类型信息
- Bundle 支持任意组件数量的类型安全实现
- Query 支持泛型参数 `Query<T1, T2, ...>`
- 使用宏简化组件注册流程

### 成功标准
- 所有文件编译通过
- 示例代码可以正常运行
- API 与 Rust Bevy 保持一致

## 2. 文件清单

### 2.1 需要修改的文件
1. `src/haxe/ecs/Entity.hx` - 增强 generation 支持
2. `src/haxe/ecs/Component.hx` - 检查 ComponentId 实现
3. `src/haxe/ecs/Bundle.hx` - 增强 Bundle 实现
4. `src/haxe/ecs/World.hx` - 增强存储结构
5. `src/haxe/ecs/Query.hx` - 增强查询功能

### 2.2 需要创建的文件
1. `src/haxe/ecs/QueryFilter.hx` - 创建过滤系统
2. `src/haxe/ecs/QueryIter.hx` - 创建查询迭代器

## 3. 实现详情

### 3.1 Entity (index + generation)

```
Entity {
    index: UInt  (24 bits) - 实体的槽位索引
    generation: UInt (8 bits) - 复用计数器
}
```

- `Entity.NULL` 表示无效实体
- `isValid()` 检查 generation 是否匹配
- 支持 entity 复用避免碎片化

### 3.2 Component

```haxe
interface Component {
    // Marker interface - 无需方法
}

interface SparseComponent {
    // 可选: 稀疏存储组件
}
```

- 所有组件类型自动注册
- ComponentId 基于类型名生成
- 支持 ComponentInfo 存储元数据

### 3.3 Bundle

```haxe
interface Bundle {
    function getComponentIds():Array<ComponentId>;
    function componentCount():Int;
}

// 类型安全的 Tuple Bundle
class Bundle1<T1:Component> implements Bundle { ... }
class Bundle2<T1:Component, T2:Component> implements Bundle { ... }
// ... Bundle3 - Bundle16
```

### 3.4 World

- 使用 Archetype 存储相似组件
- Entity 映射表维护 index → generation
- 组件存储使用 Map<Int, T> 结构

### 3.5 Query 和 QueryFilter

```haxe
// Query 基础类型
class Query<T:Component> {
    var world:World;
    var archetypeMask:Int;
    
    function iterator():QueryIter<T>;
}

// QueryFilter
interface QueryFilter {}

// With<T> - 必须包含组件
class With<T:Component> implements QueryFilter {}

// Without<T> - 不能包含组件
class Without<T:Component> implements QueryFilter {}

// 组合过滤
class Or<T1:QueryFilter, T2:QueryFilter> implements QueryFilter {}
```

### 3.6 QueryIter

```haxe
interface QueryIterator<T:Component> {
    function hasNext():Bool;
    function next():T;
    function entity():Entity;
}

// 多组件查询迭代器
class QueryIter2<T1:Component, T2:Component> {
    // 返回 { entity: Entity, c1: T1, c2: T2 }
}
```

## 4. 测试策略

1. 单元测试: Entity generation, Component 注册
2. 集成测试: Bundle 插入/删除, Query 查询
3. 手动测试: 运行 examples/QueryExampleUpdated.hx

## 5. 估计工作量

- Entity.hx: 2 小时
- Component.hx: 1 小时  
- Bundle.hx: 3 小时
- World.hx: 4 小时
- Query.hx: 3 小时
- QueryFilter.hx: 2 小时
- QueryIter.hx: 2 小时

**总计**: 约 17 小时
