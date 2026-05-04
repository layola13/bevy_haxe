# Bevy ECS Core Implementation Plan

## Overview

完善 bevy_ecs 核心，实现 Bevy 风格的 ECS (Entity-Component-System) 架构。

### Goals
- Entity 使用 index + generation 模式，支持高效的 ID 重用
- Component 用 interface 标记，简化组件定义
- Bundle 支持任意组件数量
- Query 支持泛型参数 Query<T1, T2, ...>
- 使用宏简化组件注册

### Success Criteria
- 所有核心文件正确编译
- Entity ID 支持 generation 验证
- Query 支持多组件类型查询
- Bundle 支持 1-16 个组件

## Files to Create/Modify

### 1. Entity.hx (修改)
- 增加 EntityIndex 和 EntityGeneration 类型
- 使用 index + generation 编码的 Entity
- 增加 EntityLocation 结构
- 增强 EntityRef 和 EntityMut

### 2. Component.hx (修改)
- 确认 Component 接口实现
- 增加 ComponentInfo 完整实现
- 增加 ComponentType 注册系统

### 3. Bundle.hx (修改)
- 增加 Bundle1 - Bundle16 泛型类
- 增加 DynamicBundle 支持
- 增加 BundleBuilder 辅助类

### 4. World.hx (修改)
- 增加 archetype 存储
- 增加 component storage 映射
- 增强 spawn/insert/remove 方法
- 增加 query 方法支持

### 5. Query.hx (修改)
- 增加泛型 Query<T1, T2, ...>
- 增加 QueryState 管理
- 增加 QueryIteration 支持

### 6. QueryFilter.hx (新建)
- With<T> 过滤
- Without<T> 过滤
- Or 条件过滤
- Added/Changed 检测

### 7. QueryIter.hx (新建)
- QueryIterator 迭代器
- 多种迭代模式 (immutable/mutable/changed)

## Implementation Steps

### Step 1: Create Entity.hx with generation support
- Define EntityIndex as UInt (0-0xFFFFFF)
- Define EntityGeneration as UInt (0-0xFF)
- Entity encoded as (index << 8) | generation
- Add EntityLocation for archetype tracking

### Step 2: Create QueryFilter.hx
- With<T:Component> filter interface
- Without<T:Component> filter interface
- FilterSet for combining filters
- Or<T1, T2> for disjunction

### Step 3: Create QueryIter.hx
- QueryIterator<T> interface
- MutableQueryIterator<T> for write access
- FilteredQueryIterator for filtered queries
- ChangeDetection variants

### Step 4: Update Query.hx
- Generic Query<T:Component...> class
- QueryState for query caching
- QueryBuilder with filter support
- World.query() method

### Step 5: Update Bundle.hx
- Bundle1 through Bundle16 generic classes
- DynamicBundle for runtime bundles
- BundleRegistry for type tracking

### Step 6: Update World.hx
- Archetype storage structure
- ComponentSparseSet support
- Enhanced spawn/insert methods
- EntityLocation tracking

### Step 7: Update Component.hx
- Complete Component interface
- ComponentId registry
- ComponentType metadata

## Testing Strategy
- Unit tests for Entity generation
- Query iteration tests
- Bundle component count tests
- World spawn/despawn tests

## Rollback Plan
- Keep original files with .bak extension
- Can revert by renaming .bak files
