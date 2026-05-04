# Implementation Plan: Improve bevy_utils Module

## 1. Overview

This plan details the improvements to the `bevy_utils` Haxe module, enhancing utility types for the Bevy Haxe engine implementation. The goal is to align the Haxe implementation with Rust's `bevy_utils` crate while leveraging Haxe's language features.

**Goals:**
- Enhance Hash.hx with additional hash functions and HashMap types
- Improve HashUtils.hx with better hash utilities and Hashed wrapper
- Expand TypeId.hx with TypeIdMap and TypeIdOf abstract
- Add new InternedString features (comparators, bloom filter)
- Enhance Label.hx with label derive macros and additional utilities
- Improve EntityHashMap.hx with EntityHashSet and entry APIs
- Update Module.hx with comprehensive prelude exports

**Success Criteria:**
- All existing tests pass
- API matches Rust bevy_utils patterns where possible
- Zero runtime overhead compared to current implementation
- Proper documentation with examples

---

## 2. Prerequisites

### Dependencies
- Haxe 4.x or later
- No external dependencies required (uses only Haxe standard library)

### Environment
- Working directory: `/home/vscode/projects/bevy_haxe`
- Target: Cross-compilation (JS, C++, etc.)

### Migration Requirements
- None - all changes are additive or compatible with existing API

---

## 3. Implementation Steps

### Step 1: Enhance Hash.hx
**File:** `src/haxe/utils/Hash.hx`

**Changes:**
1. Add `hashString`, `hashInt`, `hashBool`, `hashFloat` static methods
2. Add `FixedHasher` class for deterministic hashing
3. Add `NoOpHasher` for passthrough hashing (TypeIdMap use case)
4. Add `PreHashMap` generic class
5. Add `PreHashMapExt` extension methods
6. Add `TypeIdMap` generic class
7. Add `TypeIdMapEntry` enum for entry API
8. Add `EntityHashMapEntry` for Entity HashMap entry operations

**Key Implementation:**
```haxe
// Add to Hash class
public static function hashString(s:String):Int { ... }
public static function hashInt(i:Int):Int { ... }
public static function hashBool(b:Bool):Int { ... }
public static function hashFloat(f:Float):Int { ... }
public static function hashObject<T>(obj:T):Int { ... }
```

---

### Step 2: Enhance HashUtils.hx
**File:** `src/haxe/utils/HashUtils.hx`

**Changes:**
1. Rename `fnv1a` to `fnv1aString` for clarity
2. Add `hashCombine` for combining multiple hash values
3. Add `twoHash` returning a two-part hash (lo/hi)
4. Keep existing `Hashed<T>` wrapper, ensure it works with new hash functions
5. Add `PassHash` and `NoOpHash` hasher types for specialized maps
6. Add `FixedHasherBuilder` for fixed/deterministic hashing

**Key Implementation:**
```haxe
class HashUtils {
    public static function fnv1aString(s:String):Int { ... }
    public static function fnv1aInt(i:Int):Int { ... }
    public static function fnv1aInt64(lo:Int, hi:Int):Int { ... }
    public static function hashCombine(seed:Int, value:Dynamic):Int { ... }
    public static function twoHash(s:String):{lo:Int, hi:Int} { ... }
    public static function mixHash(hash:Int):Int { ... }
}
```

---

### Step 3: Enhance TypeId.hx
**File:** `src/haxe/utils/TypeId.hx`

**Changes:**
1. Add `TypeIdMap<V>` class extending Map with TypeId keys
2. Add `TypeIdMapEntry` enum with `Occupied` and `Vacant` variants
3. Add `TypeIdOf<T>` abstract type for type-safe TypeId wrapping
4. Add `getOrInsert` methods to TypeIdMap
5. Add `entry` method for entry-based operations
6. Add `getOrInsertWith` convenience method
7. Add `getOrDefault` method

**Key Implementation:**
```haxe
@:generic
class TypeIdMap<V> {
    public function new():Void;
    public function get(key:TypeId):Null<V>;
    public function set(key:TypeId, value:V):Void;
    public function entry(key:TypeId):TypeIdMapEntry<V>;
    public function getOrInsert<T>(key:TypeId, defaultValue:V):V;
    public function getOrInsertWith<T>(key:TypeId, f:Void->V):V;
    public function remove(key:TypeId):Bool;
    public function clear():Void;
    public var length(get, never):Int;
}

enum TypeIdMapEntry<V> {
    Occupied(entry:TypeIdMapOccupiedEntry<V>);
    Vacant(key:TypeId);
}
```

---

### Step 4: Enhance InternedString.hx
**File:** `src/haxe/utils/InternedString.hx`

**Changes:**
1. Add `InternedStringEq` abstract for equality comparison
2. Add `InternedStringOrd` abstract for ordered comparison  
3. Add `InternedStringHash` for hash-based containers
4. Add `InternedStringMap<V>` generic map class
5. Add `InternedStringSet` for unique string storage
6. Add `compare` static method for ordering
7. Improve documentation with usage examples

**Key Implementation:**
```haxe
@:forward
abstract InternedStringEq(InternedString) {
    // Fast equality comparison using index
}

class InternedStringMap<V> {
    public function new():Void;
    public function get(key:InternedString):Null<V>;
    public function set(key:InternedString, value:V):Void;
    // ...
}

class InternedStringSet {
    public function new():Void;
    public function add(s:InternedString):Bool;
    public function contains(s:InternedString):Bool;
    public function remove(s:InternedString):Bool;
}
```

---

### Step 5: Enhance Label.hx
**File:** `src/haxe/utils/Label.hx`

**Changes:**
1. Add `LabelId` type alias for hash-based identification
2. Add `LabelHashMap<V>` generic map class
3. Add `LabelEq` abstract for fast label comparison
4. Add `LabelOrd` abstract for ordered labels
5. Add `DynamicLabel` for runtime label creation
6. Add `SystemLabel` for system ordering
7. Add `AppLabel` for app-level labels
8. Add `PluginLabel` for plugin identification
9. Improve toString with namespace support
10. Add Comparable interface implementation

**Key Implementation:**
```haxe
enum LabelType {
    System;
    App;
    Plugin;
    Custom;
}

class Label {
    // Keep existing implementation
    // Add new static methods
    public static function system(name:String):Label;
    public static function app(name:String):Label;
    public static function plugin(name:String):Label;
    
    // Add type-safe label variants
    public static function ofType<T:Label>(name:String):T;
}

@:generic
class LabelHashMap<V> {
    public function new():Void;
    public function get(label:Label):Null<V>;
    public function set(label:Label, value:V):Void;
    // ...
}
```

---

### Step 6: Enhance EntityHashMap.hx
**File:** `src/haxe/utils/EntityHashMap.hx`

**Changes:**
1. Keep existing `Entity` struct
2. Add `EntityHashMapEntry<V>` enum with `Occupied` and `Vacant`
3. Add `EntityHashMapOccupiedEntry<V>` for entry manipulation
4. Add `entry` method for entry-based operations
5. Add `getOrInsert` method
6. Add `getOrInsertWith` method  
7. Add `getOrDefault` method
8. Add `containsEntity` explicit method
9. Add `insert` method that returns old value
10. Keep existing `EntityHashSet` implementation
11. Add `EntityHashSetExt` extension methods

**Key Implementation:**
```haxe
@:generic
class EntityHashMap<V> {
    private var data:Map<Int, V>;
    private var entityData:Map<UInt, EntityEntry<V>>;
    
    public function new():Void;
    
    // Entry API
    public function entry(entity:Entity):EntityHashMapEntry<V>;
    public function getOrInsert(entity:Entity, defaultValue:V):V;
    public function getOrInsertWith(entity:Entity, f:Void->V):V;
    public function getOrDefault(entity:Entity):V;
    
    // Existing methods
    public function set(entity:Entity, value:V):Void;
    public function get(entity:Entity):Null<V>;
    public function contains(entity:Entity):Bool;
    public function remove(entity:Entity):Bool;
    public function clear():Void;
}

enum EntityHashMapEntry<V> {
    Occupied(entry:EntityHashMapOccupiedEntry<V>);
    Vacant(entity:Entity);
}
```

---

### Step 7: Update Module.hx
**File:** `src/haxe/utils/Module.hx`

**Changes:**
1. Add comprehensive module documentation
2. Add `Hash` to prelude exports
3. Add `HashUtils` to prelude exports
4. Add `TypeId` to prelude exports
5. Add `InternedString` to prelude exports
6. Add `Label` to prelude exports
7. Add `Entity` to prelude exports
8. Add `EntityHashMap` to prelude exports
9. Add `TypeIdMap` to prelude exports
10. Add `PreHashMap` to prelude exports
11. Add convenience factory methods
12. Add module-level constants
13. Add initialization tracking

**Key Implementation:**
```haxe
class Module {
    public static var MODULE_NAME = "haxe.utils";
    public static var MODULE_VERSION = "0.2.0";
    
    public static var DEFAULT_LABEL = Label.fromName("default");
    public static var EMPTY_ENTITY = new Entity(0, 0);
    
    public static function init():Void;
    public static function isInitialized():Bool;
}

/**
 * Prelude imports for utils module
 */
class Prelude {
    public static inline function label(name:String, ?ns:String):Label;
    public static inline function entity(id:UInt, gen:UInt = 0):Entity;
    public static inline function intern(s:String):InternedString;
    public static inline function typeId<T>():TypeId;
    public static inline function hash<T>(value:T):Int;
    public static function default<T>():T;
}
```

---

## 4. File Changes Summary

### Modified Files

| File | Changes |
|------|---------|
| `src/haxe/utils/Hash.hx` | Add hash functions, PreHashMap, TypeIdMap, entry types |
| `src/haxe/utils/HashUtils.hx` | Add hashCombine, twoHash, improve existing functions |
| `src/haxe/utils/TypeId.hx` | Add TypeIdMap, TypeIdMapEntry, TypeIdOf abstract |
| `src/haxe/utils/InternedString.hx` | Add InternedStringMap, InternedStringSet, comparators |
| `src/haxe/utils/Label.hx` | Add LabelHashMap, label types, label ordering |
| `src/haxe/utils/EntityHashMap.hx` | Add entry API, getOrInsert methods, entry types |
| `src/haxe/utils/Module.hx` | Add comprehensive prelude, update documentation |

### New Files

| File | Purpose |
|------|---------|
| `src/haxe/utils/BloomFilter.hx` | Bloom filter for probabilistic membership |

---

## 5. Testing Strategy

### Unit Tests

1. **Hash Tests**
   - Test `fnv1aString` consistency
   - Test `hashInt` distribution
   - Test `hashCombine` produces different values
   - Test `twoHash` produces two distinct parts

2. **TypeId Tests**
   - Test same type returns same ID
   - Test different types return different IDs
   - Test TypeIdMap insertion and retrieval
   - Test TypeIdMap entry API

3. **InternedString Tests**
   - Test interning returns same instance
   - Test new string creates new instance
   - Test InternedStringMap operations
   - Test comparison speed vs regular strings

4. **Label Tests**
   - Test label creation from string
   - Test namespace handling
   - Test LabelHashMap operations
   - Test label ordering

5. **EntityHashMap Tests**
   - Test basic insert/remove
   - Test entry API (Occupied/Vacant)
   - Test getOrInsert operations
   - Test generation handling

### Integration Tests

1. Test utils module initialization
2. Test prelude imports work correctly
3. Test cross-module compatibility (Label + EntityHashMap)

---

## 6. Rollback Plan

### Revert Strategy

1. **Git-based rollback:**
   ```bash
   git checkout HEAD -- src/haxe/utils/
   ```

2. **Manual rollback:**
   - Restore original file contents from backup
   - Remove any newly added types

### Data Migration
- No persistent data to migrate
- All types are runtime-allocated

---

## 7. Estimated Effort

### Time Estimate
- **Phase 1 (Hash.hx, HashUtils.hx):** 2-3 hours
- **Phase 2 (TypeId.hx, InternedString.hx):** 2-3 hours
- **Phase 3 (Label.hx, EntityHashMap.hx):** 2-3 hours
- **Phase 4 (Module.hx, Testing):** 1-2 hours
- **Total:** 7-11 hours

### Complexity Assessment
- **Overall:** Medium
- **Most complex:** Entry APIs for TypeIdMap and EntityHashMap
- **Risk areas:** Generic type handling in Haxe
- **Dependencies:** None (self-contained module)

---

## 8. Implementation Priority

1. **High Priority:**
   - Hash.hx enhancements (foundation for other types)
   - EntityHashMap entry API (frequently used)
   - TypeIdMap (needed for component registration)

2. **Medium Priority:**
   - Label.hx enhancements
   - InternedString additions
   - HashUtils improvements

3. **Low Priority:**
   - Module.hx prelude updates
   - Documentation improvements
   - Performance optimizations
