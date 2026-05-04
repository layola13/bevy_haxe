# Haxe ECS Macro System Implementation Plan

## Overview

Created a comprehensive Haxe macro system for ECS (Entity Component System) inspired by Bevy's Rust macro implementation. The macros enable declarative component, bundle, system, query, and module definitions with automatic code generation.

## Files Created

### 1. ComponentMacro.hx
- **Location:** `/home/vscode/projects/bevy_haxe/src/haxe/macro/ComponentMacro.hx`
- **Metadata:** `@:component`
- **Features:**
  - Automatic component registration
  - Field extraction for serialization
  - TypeId generation
  - ComponentInfo structure generation
  - Reflection system integration

### 2. BundleMacro.hx
- **Location:** `/home/vscode/projects/bevy_haxe/src/haxe/macro/BundleMacro.hx`
- **Metadata:** `@:bundle`
- **Features:**
  - Multi-component grouping
  - FromComponents implementation
  - Archetype tracking
  - Bundle registry integration
  - Component mask generation

### 3. SystemMacro.hx
- **Location:** `/home/vscode/projects/bevy_haxe/src/haxe/macro/SystemMacro.hx`
- **Metadata:** `@:system`
- **Features:**
  - System registration with scheduling
  - Query field extraction and initialization
  - SystemParam injection (Commands, World, Resources)
  - Archetype requirement tracking
  - Schedule ordering (before/after)

### 4. QueryMacro.hx
- **Location:** `/home/vscode/projects/bevy_haxe/src/haxe/macro/QueryMacro.hx`
- **Metadata:** `@:query`, `@:queryRead`, `@:queryWrite`
- **Features:**
  - Query descriptor generation
  - Component type extraction
  - Filter support (With/Without)
  - Change detection setup
  - Sorting support

### 5. ModuleMacro.hx
- **Location:** `/home/vscode/projects/bevy_haxe/src/haxe/macro/ModuleMacro.hx`
- **Metadata:** `@:module`
- **Features:**
  - Module/plugin definition
  - Plugin, system, resource registration
  - Dependency management
  - Startup system support

## Usage Examples

### Component
```haxe
@:component
class Position {
    public var x:Float;
    public var y:Float;
}
```

### Bundle
```haxe
@:bundle
class PlayerBundle extends haxe.ecs.Bundle {
    public var position:Position;
    public var velocity:Velocity;
}
```

### System
```haxe
@:system
class MovementSystem extends haxe.ecs.System {
    @:query var positions:Query<Position>;
    @:queryWrite var velocities:Query<Velocity>;
    
    function run() {
        for (entity in query) {
            // ...
        }
    }
}
```

### Module
```haxe
@:module
class PhysicsModule {
    @:system var movement:MovementSystem;
    @:resource var gravity:Float = 9.81;
}
```

## Implementation Details

### Build Process
Each macro uses `haxe.macro.Context` and `haxe.macro.Expr` to:
1. Parse class/field metadata
2. Extract type information
3. Generate registration code
4. Add static descriptors
5. Register with runtime registries

### Generated Code
- Static `_componentDescriptor` fields for type registration
- Query initialization code
- Archetype tracking calls
- Schedule ordering constraints

## Next Steps

1. Create corresponding runtime classes (Bundle, System, Query, etc.)
2. Implement ComponentRegistry, SystemRegistry, BundleRegistry
3. Create App/AppBuilder for module composition
4. Add tests for macro expansion
5. Integrate with C++ backend via `untyped __cpp__`

## Reference Files

Based on:
- `/home/vscode/projects/bevy/crates/bevy_ecs/macros/src/lib.rs`
- `/home/vscode/projects/bevy/crates/bevy_ecs/macros/src/world_query.rs`
- `/home/vscode/projects/bevy/crates/bevy_derive/src/lib.rs`
