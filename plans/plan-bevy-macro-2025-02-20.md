# Bevy Haxe Macro System - Implementation Plan

## Overview

Improve the bevy_macro module in `/home/vscode/projects/bevy_haxe/src/haxe/macro/` to create a more robust and efficient macro system that mirrors Bevy's Rust ECS macro implementation. The goal is to generate clean, efficient code with proper compile-time validation.

## Goals

1. Create `@:system` macro for system registration with query injection
2. Create `@:component` macro for component registration with auto-implementation
3. Create `@:bundle` macro for bundle/group registration
4. Create `@:query` macro for query type definitions
5. Create `@:module` macro for plugin/module definition
6. Generate efficient runtime code with minimal overhead
7. Provide proper compile-time error checking

## Reference Files

- `/home/vscode/projects/bevy/crates/bevy_ecs/macros/src/lib.rs` - Main macro library
- `/home/vscode/projects/bevy/crates/bevy_ecs/macros/src/world_query.rs` - WorldQuery derive
- `/home/vscode/projects/bevy/crates/bevy_ecs/macros/src/query_data.rs` - QueryData derive
- `/home/vscode/projects/bevy/crates/bevy_ecs/macros/src/query_filter.rs` - QueryFilter derive
- `/home/vscode/projects/bevy/crates/bevy_ecs/macros/src/resource.rs` - Resource derive
- `/home/vscode/projects/bevy/crates/bevy_ecs/macros/src/event.rs` - Event derive

## Implementation Steps

### Step 1: Improve SystemMacro.hx

**Location:** `/home/vscode/projects/bevy_haxe/src/haxe/macro/SystemMacro.hx`

**Key Features:**
- `@:system` metadata processing
- Query field detection and initialization
- SystemParam injection (Commands, World, Resources)
- Schedule ordering (before/after)
- archetype tracking
- Generate `SystemDescriptor` static field

**Generated Code:**
```haxe
@:system
class MovementSystem {
    var query:Query<Position, &mut Velocity>;
    
    function run() { /* ... */ }
}

// Generates:
class MovementSystem {
    static var _systemDescriptor = SystemRegistry.register({
        name: "MovementSystem",
        queries: [{components: [Position, Velocity], access: ReadWrite}],
        schedule: Update,
        before: [],
        after: []
    });
    
    var _state:QueryState;
    var query:Query<Position, &mut Velocity>;
    
    function new() {
        _state = QueryState.create(Position, Velocity);
    }
    
    function run() { /* ... */ }
}
```

### Step 2: Create ComponentMacro.hx

**Location:** `/home/vscode/projects/bevy_haxe/src/haxe/macro/ComponentMacro.hx`

**Key Features:**
- `@:component` metadata processing
- Automatic IComponent interface implementation
- ComponentId registration
- Field extraction for serialization
- Sparse/Table storage detection
- Generate `ComponentDescriptor` static field

**Generated Code:**
```haxe
@:component
class Position {
    public var x:Float;
    public var y:Float;
}

// Generates:
class Position implements IComponent {
    static var _componentDescriptor = ComponentRegistry.register({
        name: "Position",
        fields: ["x", "y"],
        storageType: Table,
        size: 16
    });
    
    public var x:Float;
    public var y:Float;
    
    @:keep public inline function new(x:Float = 0, y:Float = 0) {
        this.x = x;
        this.y = y;
    }
}
```

### Step 3: Create BundleMacro.hx

**Location:** `/home/vscode/projects/bevy_haxe/src/haxe/macro/BundleMacro.hx`

**Key Features:**
- `@:bundle` metadata processing
- Component field detection
- FromComponents implementation
- Bundle registration
- Archetype optimization hints
- Generate `BundleDescriptor` static field

**Generated Code:**
```haxe
@:bundle
class PlayerBundle {
    var position:Position;
    var velocity:Velocity;
    var sprite:Sprite;
}

// Generates:
class PlayerBundle implements IBundle {
    static var _bundleDescriptor = BundleRegistry.register({
        name: "PlayerBundle",
        components: [Position, Velocity, Sprite]
    });
    
    var position:Position;
    var velocity:Velocity;
    var sprite:Sprite;
    
    static function fromComponents(get:ComponentGetter):PlayerBundle {
        return new PlayerBundle(
            get(Position),
            get(Velocity),
            get(Sprite)
        );
    }
}
```

### Step 4: Create QueryMacro.hx

**Location:** `/home/vscode/projects/bevy_haxe/src/haxe/macro/QueryMacro.hx`

**Key Features:**
- `@:query` metadata processing
- Query type definition generation
- Filter support (With/Without)
- Change detection setup
- Query item type generation
- Query state management

**Generated Code:**
```haxe
// User writes:
typedef MyQuery = @:query {
    data: QueryData<Position, &mut Velocity>,
    filter: QueryFilter<With<Transform>, Without<Camera>>
}

// Generates:
typedef MyQuery = {
    data: {
        component0: Position,
        component1: Velocity
    },
    state: QueryState
}

// Or for inline queries:
@:query(With(Transform), Without(Camera))
typedef PositionQuery = Query<Position>;
```

### Step 5: Create ModuleMacro.hx

**Location:** `/home/vscode/projects/bevy_haxe/src/haxe/macro/ModuleMacro.hx`

**Key Features:**
- `@:module` metadata processing
- Plugin registration
- System registration
- Resource initialization
- Startup system support
- Dependency management

**Generated Code:**
```haxe
@:module
class PhysicsModule {
    static function register(builder:AppBuilder) {
        builder.addPlugin(PhysicsPlugin);
        builder.addSystem(MovementSystem, PreUpdate);
        builder.addSystem(GravitySystem, Update);
    }
}

// Generates:
class PhysicsModule {
    static var _moduleDescriptor = ModuleRegistry.register({
        name: "PhysicsModule",
        plugins: [PhysicsPlugin],
        systems: [MovementSystem, GravitySystem],
        resources: []
    });
}
```

## Supporting Infrastructure

### Registry Classes (to be placed in appropriate modules)

1. **ComponentRegistry** - Component type registration
2. **SystemRegistry** - System type registration
3. **BundleRegistry** - Bundle type registration
4. **QueryRegistry** - Query type registration
5. **ModuleRegistry** - Module/plugin registration

### Descriptor Types

```haxe
typedef ComponentDescriptor = {
    var name:String;
    var typeId:Int;
    var fieldNames:Array<String>;
    var storageType:StorageType;
    var size:Int;
    var alignment:Int;
}

typedef SystemDescriptor = {
    var name:String;
    var typeId:Int;
    var queries:Array<QueryDescriptor>;
    var schedule:ScheduleOrder;
    var before:Array<String>;
    var after:Array<String>;
    var isExclusive:Bool;
    var isReadOnly:Bool;
}

typedef BundleDescriptor = {
    var name:String;
    var typeId:Int;
    var components:Array<Int>;
}

typedef QueryDescriptor = {
    var componentTypes:Array<Int>;
    var access:QueryAccess;
    var filters:Array<FilterDescriptor>;
}
```

## Testing Strategy

1. Create test cases for each macro
2. Verify generated code compiles correctly
3. Test error cases (invalid usage)
4. Test edge cases (empty bundles, no-query systems)
5. Verify runtime behavior matches expectations

## Files to Modify/Create

### New Files:
1. `/home/vscode/projects/bevy_haxe/src/haxe/macro/SystemMacro.hx` - Overwrite with improved version
2. `/home/vscode/projects/bevy_haxe/src/haxe/macro/ComponentMacro.hx` - Overwrite with improved version
3. `/home/vscode/projects/bevy_haxe/src/haxe/macro/BundleMacro.hx` - Overwrite with improved version
4. `/home/vscode/projects/bevy_haxe/src/haxe/macro/QueryMacro.hx` - Overwrite with improved version
5. `/home/vscode/projects/bevy_haxe/src/haxe/macro/ModuleMacro.hx` - Overwrite with improved version

### Files to Reference:
- `/home/vscode/projects/bevy_haxe/src/haxe/ecs/Component.hx`
- `/home/vscode/projects/bevy_haxe/src/haxe/ecs/Bundle.hx`
- `/home/vscode/projects/bevy_haxe/src/haxe/ecs/System.hx`
- `/home/vscode/projects/bevy_haxe/src/haxe/ecs/Query.hx`
- `/home/vscode/projects/bevy_haxe/src/haxe/ecs/World.hx`

## Complexity Assessment

**Medium-High** - The macros involve complex code generation with:
- Type introspection
- Expression transformation
- Interface implementation generation
- Registration infrastructure

## Estimated Effort

- SystemMacro.hx: 4-6 hours
- ComponentMacro.hx: 3-4 hours
- BundleMacro.hx: 3-4 hours
- QueryMacro.hx: 4-5 hours
- ModuleMacro.hx: 2-3 hours
- Testing: 4-6 hours

**Total: ~20-28 hours**
