# Implementation Plan: Improve Bevy Utils Module

## 1. Overview

### Goal
Improve the `haxe.utils` module to better mirror the Rust `bevy_utils` crate, providing efficient hash collections, type identification, string interning, and labeling systems for the Haxe game engine port.

### Success Criteria
- All 7 tasks completed with API consistency matching Rust patterns
- Hash functions provide consistent 64-bit hashing support
- TypeId system supports compile-time type differentiation
- EntityHashMap provides efficient Entity-based lookups
- Proper module organization with clear prelude exports
- Tests verify functionality

### Scope
**Included:**
- Hash.hx - FNV-1a and other hash functions
- HashUtils.hx - Utility hash operations
- TypeId.hx - Type identification system
- InternedString.hx - String interning
- Label.hx - Label system
- EntityHashMap.hx - Entity-keyed hash map
- Module.hx - Module entry point

**Excluded:**
- Parallel queue (requires async runtime)
- Buffered channel (requires async runtime)
- Platform-specific atomic operations (JS/Flash limitations)

---

## 2. Prerequisites

### Dependencies
- Haxe 4.x standard library
- No external dependencies required

### Data/Migration Changes
- Consolidate `Entity` class definition (currently in both `EntityHashMap.hx` and `ecs/Entity.hx`)
- Move `Entity` to a shared location to avoid duplication

---

## 3. Implementation Steps

### Step 1: Enhance Hash.hx
**Description:** Add comprehensive hash functions including FNV-1a variants and support for 64-bit hashing.

**Files to modify:** `src/haxe/utils/Hash.hx`

**Key improvements:**
```haxe
// Add 64-bit hash support using dual Int32
class Hash {
    // FNV-1a 64-bit hash constants
    private static inline var FNV_PRIME_64:Int64 = Int64.ofInt(16777619);
    private static inline var FNV_OFFSET_64:haxe.Int64 = Int64.make(2166136261, 0);
    
    // Hash for strings (consistent with Rust's FxHash)
    public static function hashString(s:String):Int;
    
    // Hash for any object
    public static function hashObject<T>(obj:T):Int;
    
    // 64-bit hash returning two Int32 values
    public static function hash64<T>(value:T):{lo:Int, hi:Int};
}
```

**Testing:** Add unit tests for hash consistency.

---

### Step 2: Enhance HashUtils.hx
**Description:** Add utility functions for hash computation and the `Hashed<T>` wrapper type.

**Files to modify:** `src/haxe/utils/HashUtils.hx`

**Key improvements:**
```haxe
class HashUtils {
    // Dual 32-bit hash for 64-bit values
    public static function fnv1a64(lo:Int, hi:Int):Int;
    
    // Mix function for better distribution
    public static function mixHash(hash:Int):Int;
    
    // Hash combine for multiple values
    public static function combine(h1:Int, h2:Int):Int;
}

// Hashed wrapper with pre-computed hash
@:structInit
class Hashed<T> {
    public var value:T;
    public var hash(default, null):Int;
    
    public static function make<T>(value:T):Hashed<T>;
}
```

**Testing:** Verify hash distribution quality.

---

### Step 3: Enhance TypeId.hx
**Description:** Add `TypeIdOf<T>` abstract and `TypeIdMap` class for type-based lookups.

**Files to modify:** `src/haxe/utils/TypeId.hx`

**Key improvements:**
```haxe
// Type-safe abstract wrapper
@:forward
abstract TypeIdOf<T>(TypeId) from TypeId to TypeId {
    public function new() this = TypeId.of(T);
}

// TypeId-based map for fast type lookups
@:generic
class TypeIdMap<V> {
    private var data:Map<Int, V>;
    
    public function new();
    public function set<T>(value:V):Void;
    public function get<T>():Null<V>;
    public function remove<T>():Bool;
    public function contains<T>():Bool;
}
```

**Testing:** Verify type ID stability across invocations.

---

### Step 4: Enhance InternedString.hx
**Description:** Add comparison operators and utility methods.

**Files to modify:** `src/haxe/utils/InternedString.hx`

**Key improvements:**
```haxe
@:forward(value)
abstract InternedString abstracts Int {
    // Fast comparison using index
    @:op(A == B) public static function eq(a:InternedString, b:InternedString):Bool;
    @:op(A != B) public static function ne(a:InternedString, b:InternedString):Bool;
    
    // Get length
    public var length(get, never):Int;
}

class InternedStringInterner {
    // Global interner instance
    public static var global(default, never):InternedStringInterner;
}

// InternedStringMap for efficient string-keyed maps
@:generic
class InternedStringMap<V> {
    // Uses index-based lookup for O(1) operations
}
```

**Testing:** Verify string interning consistency.

---

### Step 5: Enhance Label.hx
**Description:** Add `LabelId` and improve label system.

**Files to modify:** `src/haxe/utils/Label.hx`

**Key improvements:**
```haxe
// Unique label identifier
typedef LabelId = Int;

// Label with dynamic ID
@:structInit
class Label {
    public var id:LabelId;
    public var name:InternedString;
    public var namespace:Null<InternedString>;
    
    // Static label creation
    public static function of(name:String, ?namespace:String):Label;
}

// LabelHashMap for label-keyed maps
@:generic
class LabelHashMap<V> {
    public function new();
    public function get(label:Label):Null<V>;
    public function set(label:Label, value:V):Void;
}
```

**Testing:** Verify label comparisons.

---

### Step 6: Enhance EntityHashMap.hx
**Description:** Fix Entity duplication and add EntityHashSet.

**Files to modify:** `src/haxe/utils/EntityHashMap.hx`

**Key improvements:**
```haxe
// Entity (moved from ecs/Entity.hx)
// Use generation tracking for ID reuse

@:structInit
class Entity {
    public var id(default, null):UInt;
    public var generation(default, null):UInt;
    
    public static var INVALID(default, never):Entity;
    public var isValid(get, never):Bool;
    
    @:op(A == B) public static function equals(a:Entity, b:Entity):Bool;
    public function hashCode():Int;
}

@:generic
class EntityHashMap<V> {
    // Uses composite key (id | generation << 32)
    public function new();
    public function insert(entity:Entity, value:V):Bool;
    public function get(entity:Entity):Null<V>;
    public function contains(entity:Entity):Bool;
    public function remove(entity:Entity):Bool;
    public var length(get, never):Int;
}

@:generic
class EntityHashSet {
    public function new();
    public function insert(entity:Entity):Bool;
    public function contains(entity:Entity):Bool;
    public function remove(entity:Entity):Bool;
}
```

**Testing:** Verify entity lookups and generation handling.

---

### Step 7: Add/Enhance Module.hx
**Description:** Create proper module entry point with prelude exports.

**Files to create/modify:** `src/haxe/utils/Module.hx`

**Key improvements:**
```haxe
package haxe.utils;

/**
 * Utils module entry point.
 * Import with `import haxe.utils.Module;` or use prelude.
 */
class Module {
    public static inline var MODULE_NAME = "haxe.utils";
    public static inline var MODULE_VERSION = "0.2.0";
    
    public static function init():Void;
    public static var initialized(get, never):Bool;
}

/**
 * Prelude for convenient access.
 */
class Prelude {
    public static inline function entity(id:UInt, gen:UInt = 0):Entity;
    public static inline function label(name:String, ?ns:String):Label;
    public static inline function intern(s:String):InternedString;
    public static inline function typeId<T>():TypeId;
    public static inline function hash<T>(v:T):Int;
}
```

**Testing:** Module initialization test.

---

## 4. File Changes Summary

### Files to Create:
| File | Description |
|------|-------------|
| None | All files already exist |

### Files to Modify:
| File | Changes |
|------|---------|
| `src/haxe/utils/Hash.hx` | Add 64-bit hash, improve hash functions |
| `src/haxe/utils/HashUtils.hx` | Add mixHash, Hashed class improvements |
| `src/haxe/utils/TypeId.hx` | Add TypeIdMap, TypeIdOf abstract |
| `src/haxe/utils/InternedString.hx` | Add InternedString abstract, InternedStringMap |
| `src/haxe/utils/Label.hx` | Add LabelId, improve Label system |
| `src/haxe/utils/EntityHashMap.hx` | Add EntityHashSet, improve Entity |
| `src/haxe/utils/Module.hx` | Enhance module entry point |
| `src/haxe/ecs/Entity.hx` | Reference utils.Entity instead of duplicate |

### Files to Delete:
| File | Reason |
|------|--------|
| None | - |

---

## 5. Testing Strategy

### Unit Tests
```haxe
// Test Hash
class HashTest {
    static function testFnv1a():Void {
        var h1 = Hash.fnv1aString("hello");
        var h2 = Hash.fnv1aString("hello");
        // Same input = same output
        Assert.isTrue(h1 == h2);
    }
    
    static function test64Hash():Void {
        var hash = Hash.hash64("test");
        // Returns {lo:Int, hi:Int}
        Assert.isTrue(hash.lo != 0 || hash.hi != 0);
    }
}

// Test TypeId
class TypeIdTest {
    static function testTypeId():Void {
        var id1 = TypeId.of<MyClass>();
        var id2 = TypeId.of<MyClass>();
        // Same type = same ID
        Assert.isTrue(id1.equals(id2));
        
        var id3 = TypeId.of<OtherClass>();
        Assert.isFalse(id1.equals(id3));
    }
}

// Test InternedString
class InternedStringTest {
    static function testInterning():Void {
        var s1 = InternedString.intern("test");
        var s2 = InternedString.intern("test");
        // Same string = same instance
        Assert.isTrue(s1 == s2);
    }
}

// Test EntityHashMap
class EntityHashMapTest {
    static function testBasic():Void {
        var map = new EntityHashMap<Int>();
        var entity = new Entity(1, 0);
        
        map.set(entity, 42);
        Assert.isTrue(map.get(entity) == 42);
        Assert.isTrue(map.contains(entity));
    }
}
```

### Manual Testing Steps
1. Import module and verify all types accessible
2. Test hash consistency
3. Test Entity creation and lookup
4. Test string interning efficiency
5. Test Label operations

---

## 6. Rollback Plan

### Revert Steps
1. Restore original files from version control if available
2. If not versioned, manually restore the original implementations
3. Revert ECS Entity.hx changes

### Data Migration
- No persistent data affected by these changes
- All changes are code-only

---

## 7. Estimated Effort

### Complexity: Medium

### Time Estimate:
- **Step 1-2 (Hash):** 2 hours
- **Step 3 (TypeId):** 1 hour
- **Step 4 (InternedString):** 1.5 hours
- **Step 5 (Label):** 1 hour
- **Step 6 (EntityHashMap):** 2 hours
- **Step 7 (Module):** 1 hour
- **Testing:** 2 hours

**Total:** ~10.5 hours

---

## 8. Implementation Order

1. **Hash.hx** - Foundation for other utilities
2. **HashUtils.hx** - Uses Hash
3. **TypeId.hx** - Independent, foundational
4. **InternedString.hx** - Uses TypeId internals
5. **Label.hx** - Uses InternedString
6. **EntityHashMap.hx** - Uses Hash
7. **Module.hx** - Imports all, create prelude
8. **ECS Entity.hx** - Reference unified Entity
