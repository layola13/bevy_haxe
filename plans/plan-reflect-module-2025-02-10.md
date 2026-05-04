# Implementation Plan: Improve bevy_reflect Module

## 1. Overview

This plan outlines improvements to the Haxe bevy_reflect module, leveraging Haxe's native dynamic capabilities to simplify reflection while maintaining compatibility with the Rust bevy_reflect design.

### Goals
- Enhance the `Reflect.hx` interface with more complete method coverage
- Improve `TypeInfo.hx` with better type data support
- Strengthen `TypePath.hx` with static type path access
- Add `TypeRegistry.hx` for central type registration management

### Scope Boundaries
- **Included**: Core reflect interfaces, dynamic type support, type registry
- **Excluded**: Serde serialization (separate module), function reflection

---

## 2. Prerequisites

- Working Haxe environment (4.3+)
- Understanding of existing reflect implementation
- Macro system available in `haxe/macro/`

---

## 3. Implementation Steps

### Step 1: Enhance Reflect.hx - Add PartialReflect and Typed traits

**Files to modify**: `/home/vscode/projects/bevy_haxe/src/haxe/reflect/Reflect.hx`

**Key changes**:
1. Add `PartialReflect` interface for read-only reflection operations
2. Add `Typed` static trait for type information without instantiation
3. Add `ReflectMut` interface for mutable reflection
4. Implement `ReflectOwned` and `ReflectRef` enums for value wrapping
5. Add `ReflectCloneError` and `ReflectError` error types
6. Add `DynamicReflect` implementation for anonymous/dynamic types
7. Improve `ReflectApply` helper class

**Implementation details**:
```haxe
// Core enhancement: PartialReflect interface
interface PartialReflect {
    function reflectKind():ReflectKind;
    function typeInfo():TypeInfo;
    function toDynamic():Dynamic;
    function as_reflect():Reflect;
}

interface Typed {
    static function typeInfo():TypeInfo;
    static function typeId():TypeId;
    static function typePath():String;
}
```

### Step 2: Improve TypeInfo.hx - Add comprehensive type data support

**Files to modify**: `/home/vscode/projects/bevy_haxe/src/haxe/reflect/TypeInfo.hx`

**Key changes**:
1. Add `TypeDataRegistry` for storing type-specific metadata
2. Implement `TypeRegistration` for type registration entries
3. Add `Registerable` interface for types that can self-register
4. Implement `OpaqueInfo` for types without field access
5. Add `TypeInfoError` with specific error variants
6. Improve `DynamicTypeInfo` implementation

**Implementation details**:
```haxe
class TypeDataRegistry {
    private var _data:Map<TypeId, Dynamic>;
    
    public function new() {
        _data = new Map();
    }
    
    public function insert<T>(data:T):Void;
    public function get<T>(typeId:TypeId):Null<T>;
    public function remove(typeId:TypeId):Bool;
    public function exists(typeId:TypeId):Bool;
}
```

### Step 3: Improve TypePath.hx - Add DynamicTypePath support

**Files to modify**: `/home/vscode/projects/bevy_haxe/src/haxe/reflect/TypePath.hx`

**Key changes**:
1. Add `DynamicTypePath` for dynamically constructed type paths
2. Implement `TypePathTable` as static accessor
3. Add `TypePathError` for invalid path operations
4. Support for anonymous types (arrays, tuples)

### Step 4: Create TypeRegistry.hx - Central type registration

**Files to create**: `/home/vscode/projects/bevy_haxe/src/haxe/reflect/TypeRegistry.hx`

**Implementation**:
```haxe
package haxe.reflect;

/**
    A registry of reflected types.
    
    This class is the central store for type information.
    Registering a type generates a new TypeRegistration entry.
    
    Example:
    ```haxe
    class Main {
        static function main() {
            var registry = new TypeRegistry();
            registry.register(Position);
            registry.register(Velocity);
            
            var pos = registry.create("Position");
        }
    }
    ```
**/
class TypeRegistry {
    private var _registrations:Map<TypeId, TypeRegistration>;
    private var _shortPathToId:Map<String, TypeId>;
    private var _typePathToId:Map<String, TypeId>;
    
    public function new() {
        _registrations = new Map();
        _shortPathToId = new Map();
        _typePathToId = new Map();
    }
    
    // Core registration methods
    public function register<T>(type:Class<T>):Void;
    public function registerDynamic(typePath:String, info:TypeInfo):Void;
    
    // Lookup methods
    public function get(typeId:TypeId):Null<TypeRegistration>;
    public function getByPath(typePath:String):Null<TypeRegistration>;
    public function getByShortPath(shortPath:String):Null<TypeRegistration>;
    
    // Type checking
    public function contains(typeId:TypeId):Bool;
    public function containsPath(typePath:String):Bool;
    
    // Type creation
    public function create<T>(type:Class<T>):T;
    public function createFromPath(typePath:String):Reflect;
    
    // Iteration
    public function iterator():Iterator<TypeRegistration>;
    public function registrationCount():Int;
    
    // Type registration entry
    public function addTypeData<T>(typeId:TypeId, data:T):Void;
    public function getTypeData<T>(typeId:TypeId):Null<T>;
}

/**
    Represents a single type registration in the registry.
**/
class TypeRegistration {
    public var typeId(default, null):TypeId;
    public var typePath(default, null):String;
    public var shortTypePath(default, null):String;
    public var typeInfo(default, null):TypeInfo;
    
    private var _typeData:Map<TypeId, Dynamic>;
    
    public function new(typeId:TypeId, typePath:String, typeInfo:TypeInfo) {
        this.typeId = typeId;
        this.typePath = typePath;
        this.shortTypePath = typePath.split(".").pop();
        this.typeInfo = typeInfo;
        _typeData = new Map();
    }
    
    public function insert<T>(data:T):Void;
    public function data<T>(typeId:TypeId):Null<T>;
    public function hasData(typeId:TypeId):Bool;
}
```

### Step 5: Add Reflect module prelude

**Files to create**: `/home/vscode/projects/bevy_haxe/src/haxe/reflect/prelude`

**Implementation**:
```haxe
package haxe.reflect.prelude;

// Re-export all reflect types for convenient access
typedef Reflect = haxe.reflect.Reflect;
typedef TypeInfo = haxe.reflect.TypeInfo;
typedef TypePath = haxe.reflect.TypePath;
typedef TypeRegistry = haxe.reflect.TypeRegistry;
typedef Typed = haxe.reflect.Typed;
typedef PartialReflect = haxe.reflect.PartialReflect;
typedef ReflectKind = haxe.reflect.ReflectKind;
```

---

## 4. File Changes Summary

### Created Files
| File | Description |
|------|-------------|
| `src/haxe/reflect/TypeRegistry.hx` | New type registry class |
| `src/haxe/reflect/prelude/ReflectModule.hx` | Module prelude |

### Modified Files
| File | Changes |
|------|---------|
| `src/haxe/reflect/Reflect.hx` | Add PartialReflect, Typed interfaces; improve ReflectApply |
| `src/haxe/reflect/TypeInfo.hx` | Add TypeRegistration, type data support |
| `src/haxe/reflect/TypePath.hx` | Add DynamicTypePath, TypePathTable |

---

## 5. Testing Strategy

### Unit Tests
1. **Reflect tests** (`test/reflect/ReflectTest.hx`)
   - Test basic reflect operations on structs
   - Test field get/set operations
   - Test type info retrieval

2. **TypeInfo tests** (`test/reflect/TypeInfoTest.hx`)
   - Test type info creation
   - Test type data storage/retrieval
   - Test kind checks

3. **TypeRegistry tests** (`test/reflect/TypeRegistryTest.hx`)
   - Test type registration
   - Test type lookup by path
   - Test type creation from registry

### Manual Testing Steps
1. Create a test component with @:reflect macro
2. Register it in a TypeRegistry
3. Create instances via reflection
4. Verify field access works correctly

---

## 6. Rollback Plan

- All changes are additive - no breaking API changes
- If issues arise, simply remove/modify the new files
- No database migrations needed
- No configuration changes required

### Rollback Steps
1. Remove TypeRegistry.hx if created
2. Remove prelude files if created
3. Revert Reflect.hx, TypeInfo.hx, TypePath.hx to previous versions

---

## 7. Estimated Effort

| Step | Effort | Complexity |
|------|--------|------------|
| Step 1: Enhance Reflect.hx | 2-3 hours | Medium |
| Step 2: Improve TypeInfo.hx | 2-3 hours | Medium |
| Step 3: Improve TypePath.hx | 1-2 hours | Low |
| Step 4: Create TypeRegistry.hx | 2-3 hours | Medium |
| Step 5: Add prelude | 30 minutes | Low |
| **Total** | **8-12 hours** | **Medium** |

---

## 8. Key Design Decisions

### Why Haxe Can Simplify Reflection

1. **Haxe's Type API** already provides:
   - `Type.getClass()` / `Type.getClassName()` for class introspection
   - `Type.createInstance()` for dynamic instantiation
   - `Reflect.getField()` / `Reflect.setField()` for field access

2. **No need for:**
   - Manual trait objects (use Haxe interfaces directly)
   - Static lifetime management (Haxe garbage collection)
   - Box<dyn Reflect> patterns (use Dynamic type)

3. **Simplified patterns:**
   - TypeInfo stored as class metadata via macros
   - Type registration uses Haxe Class<> type
   - Dynamic dispatch via native reflection
