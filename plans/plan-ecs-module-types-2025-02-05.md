# Bevy ECS Haxe Module Implementation Plan

## 1. Overview

This plan creates the core ECS (Entity-Component-System) module types for the Bevy Haxe game engine, based on the Rust `bevy_ecs` crate.

### Goals
- Create complete, compilable Haxe files for Entity, Component, Bundle, and World
- Implement Entity as abstract Int with index+generation encoding
- Use Haxe interfaces for Component and Bundle markers
- Use IntMap for component storage in World
- Support @:autoBuild macros for component registration

### Success Criteria
- Entity.hx: abstract Int with index/generation encoding, entity comparison
- Component.hx: interface marker with ComponentId tracking
- Bundle.hx: interface with component type enumeration
- World.hx: full World implementation with spawn/despawn/insert/remove/query

## 2. Prerequisites

### Files to Create/Modify
- `src/haxe/ecs/Entity.hx` - Complete rewrite with proper encoding
- `src/haxe/ecs/Component.hx` - Enhanced with ComponentId and registration
- `src/haxe/ecs/Bundle.hx` - Enhanced with interface methods
- `src/haxe/ecs/World.hx` - Complete rewrite with IntMap storage

### Dependencies
- Haxe 4.x standard library
- `haxe.ds.IntMap` for component storage
- Macro support for @:autoBuild

## 3. Implementation Steps

### Step 1: Create Entity.hx
**Description**: Complete Entity implementation with index+generation encoding

**Key Features**:
- `abstract Entity(Int)` wrapping an encoded Int
- Index stored in lower 32 bits (or 24 bits for space efficiency)
- Generation stored in upper bits
- Static `NULL` entity with id=0
- Comparison operators (==, !=)
- Static factory methods (fromBits, new)

**Files Modified**: `src/haxe/ecs/Entity.hx`

### Step 2: Create Component.hx  
**Description**: Component interface and ComponentId system

**Key Features**:
- `interface Component` as marker interface
- `ComponentId` class for type tracking
- Static type registry using Type.getClassName
- ComponentInfo for runtime metadata

**Files Modified**: `src/haxe/ecs/Component.hx`

### Step 3: Create Bundle.hx
**Description**: Bundle interface for component groups

**Key Features**:
- `interface Bundle` with component enumeration
- Tuple bundle implementations (Bundle1-4)
- BundleBuilder for fluent API
- Component extraction methods

**Files Modified**: `src/haxe/ecs/Bundle.hx`

### Step 4: Create World.hx
**Description**: World entity manager with full ECS functionality

**Key Features**:
- IntMap<Entity, ComponentMap> for storage
- Entity spawning with unique ids
- Component insert/remove/get operations
- Basic query system
- Change tracking for components

**Files Modified**: `src/haxe/ecs/World.hx`

## 4. File Changes Summary

### Created Files
- `src/haxe/ecs/Entity.hx` (complete rewrite)
- `src/haxe/ecs/Component.hx` (enhanced)
- `src/haxe/ecs/Bundle.hx` (enhanced)
- `src/haxe/ecs/World.hx` (complete rewrite)

### Deleted Files
- None

## 5. Testing Strategy

### Unit Tests
- Entity encoding/decoding tests
- Entity comparison tests
- Component registration tests
- World spawn/despawn tests
- Component add/get/remove tests

### Manual Testing
- Compile test with `haxe project.hxml`
- Test entity creation and lifecycle
- Test component attachment and queries

## 6. Rollback Plan

Since these are new implementations, rollback involves:
1. Restore previous versions from git
2. Revert to existing stub implementations

## 7. Estimated Effort

- **Time**: 2-3 hours
- **Complexity**: Medium
- **Risk**: Low - follows established patterns from existing code
