# Bevy ECS Core 完善计划

## 1. Overview

完善 bevy_ecs 核心模块，参考 Rust bevy/crates/bevy_ecs/src/ 实现，转换为 Haxe 版本。

**Goals:**
- Entity 使用 index + generation 模式 (避免 ID 回收后的旧引用问题)
- Component 用 interface 标记，支持 ComponentId
- Bundle 支持任意组件数量的 tuple bundles
- Query 支持泛型参数 Query<T1, T2, ...>
- 使用宏简化组件注册流程

**Success Criteria:**
- 所有核心类型可正常工作
- 迭代器模式完整实现
- 示例代码可编译运行

## 2. Prerequisites

- Haxe 4.3+
- 已有的宏系统 (BundleMacro, ComponentMacro, QueryMacro)
- 数学模块 (Vec3, Quat)

## 3. Implementation Steps

### Step 1: 更新 Entity.hx - 增强 generation 支持

文件: `/home/vscode/projects/bevy_haxe/src/haxe/ecs/Entity.hx`

内容:
- Entity 由 index + generation 组成 (使用 UInt64 存储)
- EntityIndex 结构体
- EntityGeneration 结构体  
- 提供 encode/decode 方法
- 比较运算支持

### Step 2: 更新 Component.hx - ComponentId 实现

文件: `/home/vscode/projects/bevy_haxe/src/haxe/ecs/Component.hx`

内容:
- Component interface 保持 (无方法标记接口)
- ComponentInfo 类
- ComponentIdRegistry 单例
- forType/fromTypeName 静态方法

### Step 3: 更新 Bundle.hx - 增强 Bundle 实现

文件: `/home/vscode/projects/bevy_haxe/src/haxe/ecs/Bundle.hx`

内容:
- Bundle interface with getComponentIds()
- Bundle1-16 泛型 tuple bundles
- BundleBuilder fluent API
- DynamicBundle 支持
- ComponentTypeHolder 用于组件类型存储

### Step 4: 更新 World.hx - 增强存储结构

文件: `/home/vscode/projects/bevy_haxe/src/haxe/ecs/World.hx`

内容:
- 使用 Map<Int, EntityLocation> 存储实体位置
- SparseSet 存储组件
- Archetype 管理
- spawn, despawn, insert, remove 方法
- EntityMut, EntityRef 访问器

### Step 5: 更新 Query.hx - 增强查询功能

文件: `/home/vscode/projects/bevy_haxe/src/haxe/ecs/Query.hx`

内容:
- Query<Q:QueryData, F:QueryFilter> 泛型类
- QueryData interface
- QueryState 查询状态管理
- world_query 方法

### Step 6: 创建 QueryFilter.hx - 过滤系统

文件: `/home/vscode/projects/bevy_haxe/src/haxe/ecs/QueryFilter.hx`

内容:
- QueryFilter interface
- With<T> 过滤器
- Without<T> 过滤器
- Added<T>, Changed<T> 变更检测过滤器
- Or<T> 或过滤器
- 组合支持

### Step 7: 创建 QueryIter.hx - 查询迭代器

文件: `/home/vscode/projects/bevy_haxe/src/haxe/ecs/QueryIter.hx`

内容:
- QueryIter<Q, F> 迭代器
- QueryItem<Q> 访问器
- Iterator 实现
- hasNext/next 方法
- 惰性求值

## 4. File Changes Summary

### Modified Files:
1. `src/haxe/ecs/Entity.hx` - 增强 generation 支持
2. `src/haxe/ecs/Component.hx` - 检查 ComponentId 实现
3. `src/haxe/ecs/Bundle.hx` - 增强 Bundle 实现
4. `src/haxe/ecs/World.hx` - 增强存储结构
5. `src/haxe/ecs/Query.hx` - 增强查询功能

### New Files:
1. `src/haxe/ecs/QueryFilter.hx` - 过滤系统
2. `src/haxe/ecs/QueryIter.hx` - 查询迭代器

## 5. Testing Strategy

- 单元测试验证 Entity generation
- 组件注册测试
- Bundle 组合测试
- Query 查询测试
- 迭代器遍历测试

## 6. Rollback Plan

- 保留旧文件备份在 `~` 目录
- 使用 Git 控制版本

## 7. Estimated Effort

- **Time:** 2-3 hours
- **Complexity:** Medium
- **Dependencies:** Math module, macro system
