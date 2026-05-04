# Implementation Plan: Bevy Haxe Reflect Module Enhancement

## 1. Overview

### Goals
Enhance the `bevy_reflect` Haxe module to provide a comprehensive runtime reflection system that mirrors the functionality of Rust's `bevy_reflect` crate while leveraging Haxe's native dynamic capabilities.

### Success Criteria
- Complete `Reflect.hx` interface with full field operations, cloning, and applying
- Enhanced `TypeInfo.hx` with proper type-specific info classes (StructInfo, EnumInfo, etc.)
- Improved `TypePath.hx` with TypePathTable support
- New `TypeRegistry.hx` for centralized type registration and lookup

### Scope Boundaries
**Included:**
- Reflect interface and implementations
- TypeInfo with all variant types
- TypePath with static type information
- TypeRegistry for type management

**Excluded:**
- Serialization/deserialization (separate module)
- Function reflection (future enhancement)
- Path-based field access (future enhancement)

---

## 2. Prerequisites

### Required Dependencies
- `haxe.utils.TypeId` - already exists
- `haxe.ds.*` - standard library
- `haxe.ds.Map` and `haxe.ds.HashMap`

### Environment Requirements
- Haxe 4.x or later
- No external dependencies (leveraging Haxe standard library)

---

## 3. Implementation Steps

### Step 1: Enhance Reflect.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/reflect/Reflect.hx`

**Changes:**
1. Add `ReflectOwned` wrapper for ownership semantics
2. Add `ReflectRef` enum for non-mutable access
3. Add `ReflectMut` wrapper for mutable access
4. Enhance `ReflectApply` class with complete logic
5. Add `ReflectClone` error handling
6. Add `ApplyError` enum for apply failures
7. Improve field iteration support

**Key Code:**
```haxe
// ReflectRef enum for non-mutable access
enum ReflectRef<T> {
    Struct(value:T);
    Tuple(value:T);
    List(value:T);
    Map(value:T);
    Set(value:T);
    Enum(value:T);
    Other(value:T);
}

// ReflectOwned wrapper
class ReflectOwned {
    public var value:Dynamic;
    public function new(value:Dynamic) this.value = value;
    public function free():Void value = null;
}
```

---

### Step 2: Improve TypeInfo.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/reflect/TypeInfo.hx`

**Changes:**
1. Complete `StructInfo` class with field metadata
2. Complete `TupleInfo` class with field count
3. Complete `ListInfo` class
4. Complete `MapInfo` class
5. Complete `SetInfo` class
6. Complete `EnumInfo` with variant information
7. Add `NamedField` class for field metadata
8. Add `ArrayInfo` class
9. Implement proper error handling

**Key Code:**
```haxe
// Named field with metadata
class NamedField {
    public var name(default, null):String;
    public var typeId(default, null):TypeId;
    public var typePath(default, null):String;
    
    public function new(name:String, typeId:TypeId, typePath:String) {
        this.name = name;
        this.typeId = typeId;
        this.typePath = typePath;
    }
}

// StructInfo with field iteration
class StructInfo {
    private var _fields:Array<NamedField>;
    private var _fieldMap:Map<String, Int>;
    
    public function fieldCount():Int return _fields.length;
    public function fieldAt(index:Int):NamedField return _fields[index];
    public function field(name:String):Null<NamedField> {
        var idx = _fieldMap.get(name);
        return idx != null ? _fields[idx] : null;
    }
}
```

---

### Step 3: Enhance TypePath.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/reflect/TypePath.hx`

**Changes:**
1. Add `TypePathTable` class for cached type path lookups
2. Add `DynamicTypePath` interface for dynamic type paths
3. Improve `Typed` interface with helper methods
4. Add `TypePathError` for path resolution errors

**Key Code:**
```haxe
// TypePathTable for cached lookups
class TypePathTable {
    public var typePath(default, null):String;
    public var shortTypePath(default, null):String;
    public var typeIdent(default, null):Null<String>;
    public var crateName(default, null):Null<String>;
    public var modulePath(default, null):Null<String>;
    
    public static function of<T>(typePath:String):TypePathTable {
        return new TypePathTable(typePath);
    }
    
    public function path():String return typePath;
    public function shortPath():String return shortTypePath;
    public function ident():Null<String> return typeIdent;
    public function crateName():Null<String> return crateName;
    public function modulePath():Null<String> return modulePath;
}

// Dynamic type path for anonymous types
interface DynamicTypePath {
    function get_type_path():String;
    function get_short_type_path():String;
}
```

---

### Step 4: Create TypeRegistry.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/reflect/TypeRegistry.hx`

**Changes:**
1. Create `TypeRegistration` class for type entry
2. Create `TypeRegistry` class with registration management
3. Add type data storage and retrieval
4. Implement short path resolution
5. Add `GetTypeRegistration` interface

**Key Code:**
```haxe
// Type registration entry
class TypeRegistration {
    public var typeId(default, null):TypeId;
    public var typeInfo(default, null):TypeInfo;
    public var typePath(default, null):String;
    
    private var _data:Map<TypeId, Dynamic>;
    
    public function new(typeId:TypeId, typeInfo:TypeInfo, typePath:String) {
        this.typeId = typeId;
        this.typeInfo = typeInfo;
        this.typePath = typePath;
        this._data = new Map();
    }
    
    public function data<T>(typeId:TypeId):Null<T> return _data.get(typeId);
    public function insert<T>(data:T):Void _data.set(TypeId.of(T), data);
    public function remove(typeId:TypeId):Bool return _data.remove(typeId);
}

// Main type registry
class TypeRegistry {
    private var _registrations:Map<TypeId, TypeRegistration>;
    private var _shortPathToId:Map<String, TypeId>;
    private var _typePathToId:Map<String, TypeId>;
    private var _ambiguousNames:Map<String, Bool>;
    
    public function new() {
        _registrations = new Map();
        _shortPathToId = new Map();
        _typePathToId = new Map();
        _ambiguousNames = new Map();
    }
    
    public function register<T>(registration:TypeRegistration):Void {
        _registrations.set(registration.typeId, registration);
        _typePathToId.set(registration.typePath, registration.typeId);
        
        var shortPath = getShortPath(registration.typePath);
        if (_shortPathToId.exists(shortPath)) {
            _ambiguousNames.set(shortPath, true);
        } else {
            _shortPathToId.set(shortPath, registration.typeId);
        }
    }
    
    public function get(typeId:TypeId):Null<TypeRegistration> 
        return _registrations.get(typeId);
    
    public function getByPath(typePath:String):Null<TypeRegistration> {
        var id = _typePathToId.get(typePath);
        return id != null ? _registrations.get(id) : null;
    }
    
    public function getByShortPath(shortPath:String):Null<TypeRegistration> {
        if (_ambiguousNames.exists(shortPath)) return null;
        var id = _shortPathToId.get(shortPath);
        return id != null ? _registrations.get(id) : null;
    }
    
    public function iter():Iterator<TypeRegistration> 
        return _registrations.iterator();
}
```

---

## 4. File Changes Summary

| File | Action | Description |
|------|--------|-------------|
| `src/haxe/reflect/Reflect.hx` | Modified | Enhanced with ReflectOwned, ReflectRef, ReflectMut, ApplyError |
| `src/haxe/reflect/TypeInfo.hx` | Modified | Complete StructInfo, TupleInfo, EnumInfo, NamedField implementations |
| `src/haxe/reflect/TypePath.hx` | Modified | Add TypePathTable, DynamicTypePath |
| `src/haxe/reflect/TypeRegistry.hx` | Created | New file with TypeRegistry and TypeRegistration |

---

## 5. Testing Strategy

### Unit Tests to Write
1. **Reflect Tests:**
   - Test field get/set operations
   - Test clone functionality
   - Test apply between matching types
   - Test apply error on type mismatch

2. **TypeInfo Tests:**
   - Test StructInfo field iteration
   - Test TupleInfo field access
   - Test EnumInfo variant access
   - Test type casting (asStruct, asEnum, etc.)

3. **TypePath Tests:**
   - Test type path extraction from class
   - Test short path generation
   - Test TypePathTable creation

4. **TypeRegistry Tests:**
   - Test registration and retrieval
   - Test short path resolution
   - Test ambiguous name detection
   - Test type data insertion and retrieval

### Manual Testing Steps
1. Create a test class with @:reflect metadata
2. Verify type registration works
3. Test dynamic field access
4. Verify type info matches expected structure

---

## 6. Rollback Plan

**Rollback Steps:**
1. Revert changes to Reflect.hx, TypeInfo.hx, TypePath.hx from git
2. Delete TypeRegistry.hx if created
3. Re-run existing tests to verify integrity

**Data Migration:** Not applicable (no persistent data)

---

## 7. Estimated Effort

- **Time Estimate:** 4-6 hours
- **Complexity:** Medium
- **Risk Level:** Low (additive changes, no breaking modifications)

### Breakdown
- Step 1 (Reflect.hx): 1.5 hours
- Step 2 (TypeInfo.hx): 1.5 hours
- Step 3 (TypePath.hx): 1 hour
- Step 4 (TypeRegistry.hx): 1.5 hours
- Testing and verification: 1 hour

---

## 8. Implementation Notes

### Haxe-Specific Optimizations
1. **Dynamic Field Access:** Use `Reflect.getProperty` and `Reflect.setProperty` for field operations
2. **Type Introspection:** Leverage `Type.getClassFields()` and `Type.getInstanceFields()` for auto-implementation
3. **Generic Constraints:** Use `implements` for interface composition
4. **Enum Matching:** Use `Std.is()` and `Std.downcast()` for type checking

### Design Philosophy
1. Keep interfaces minimal - let implementations handle specifics
2. Use Haxe's dynamic capabilities where appropriate
3. Maintain API compatibility with Rust bevy_reflect concepts
4. Provide sensible defaults that can be overridden
