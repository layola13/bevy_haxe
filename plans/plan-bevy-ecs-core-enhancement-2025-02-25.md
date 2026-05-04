# Bevy ECS Core Enhancement Plan

## Overview

This plan enhances the bevy_ecs core implementation in Haxe, following the Rust bevy engine's architecture. The goal is to create a robust, type-safe ECS system with proper Entity (index + generation), Component registration, Bundle support, and Query filtering.

## Core Design Principles

1. **Entity**: Uses `index + generation` pattern for handle validity
2. **Component**: Marker interface with runtime type registry
3. **Bundle**: Supports arbitrary component counts via tuples/macros
4. **Query**: Generic parameter support `Query<T1, T2, ...>`
5. **Macro**: Simplified component registration via metadata

## Files to Create/Update

### 1. Entity.hx (Update)
- Add `EntityIndex` type for entity position in storage
- Add `EntityGeneration` for unique version tracking
- Implement `Entity` as `index << 32 | generation` packed structure
- Add validation methods for entity lifecycle
- Include entity reference types (EntityRef, EntityMut)

### 2. Component.hx (Update)
- Extend Component interface with type-safe marker
- Add `ComponentInfo` with id, name, storage type
- Support sparse and table storage modes
- Add component hooks support (on_add, on_remove, on_replace)

### 3. Bundle.hx (Update)
- Support 1-16 component tuples via Bundle1<T1> ... Bundle16<...>
- Add `DynamicBundle` for runtime component arrays
- Implement `getComponentTypes()` and `componentCount()`
- Add BundleBuilder fluent API
- Include macro-generated bundle implementations

### 4. World.hx (Update)
- Add archetype-based storage structure
- Implement component storage (Table and SparseSet)
- Add entity allocator with generation tracking
- Support spawn, despawn, insert, remove operations
- Include deferred command queue

### 5. Query.hx (Update)
- Create generic `Query<T:Component>` type
- Support `Query<T1, T2>` for multi-component queries
- Add QueryBuilder with With/Without filters
- Implement QueryState for archetype caching
- Add change detection filters (Added, Changed)

### 6. QueryFilter.hx (Create)
- `With<T:Component>` - entity must have component
- `Without<T:Component>` - entity must NOT have component
- `Or<F1, F2>` - filter disjunction
- `Added<T>` - component recently added
- `Changed<T>` - component recently modified
- `Spawned` - entity was recently spawned

### 7. QueryIter.hx (Create)
- `QueryIter<T:QueryData>` - iterator for query results
- Support mutable/immutable access modes
- Implement archetype-based iteration
- Add parallel iterator support (future)
- Include drained iterator for consumption

## Implementation Details

### Entity Packing
```
Entity = (index: u32) | (generation: u32 << 32)
- Index: position in entity allocation bitmap
- Generation: incrementing version for recycled indices
```

### Component Registry
- Static `ComponentRegistry` maps Class -> ComponentId
- ComponentId is stable across world lifetime
- Sparse components use HashMap for O(1) lookup
- Table components store in contiguous memory per archetype

### Query State
- Caches archetype matches to avoid rescanning
- Filters are encoded as bit masks
- Change detection uses World.tick() counter

## Testing Strategy

1. **Entity Tests**: Lifecycle, validity, generation wrapping
2. **Component Tests**: Registration, storage modes
3. **Bundle Tests**: Component grouping, spawn/despawn
4. **World Tests**: Entity CRUD, archetype consistency
5. **Query Tests**: Single/multi-component, filters, iteration

## Estimated Effort

- **Time**: 4-6 hours
- **Complexity**: Medium-High
- **Dependencies**: Existing macro system, prelude types
