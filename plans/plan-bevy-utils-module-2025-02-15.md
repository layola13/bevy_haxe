# Implementation Plan: Bevy Utils Module Improvements

## 1. Overview

### Goals
Improve the `haxe.utils` module to more closely mirror Rust's `bevy_utils` crate, providing:
- Enhanced hash functions with FNV-1a and other algorithms
- Type-safe type identification system
- String interning for efficient comparisons
- Label system for naming entities/components
- Entity-specialized HashMap with generation support
- Comprehensive module prelude

### Success Criteria
- API consistency with Bevy/Rust patterns
- Proper generic type support in Haxe
- Efficient implementations suitable for game engine use
- Clear documentation matching Rust docs

### Scope
**Included:**
- Hash.hx - Enhanced hash functions
- HashUtils.hx - Hash computation utilities
- TypeId.hx - Type identification with proper generics
- InternedString.hx - String interning
- Label.hx - Label system with namespace support
- EntityHashMap.hx - Entity-specialized map
- Module.hx - Module entry point and prelude

**Excluded:**
- BloomFilter (requires complex generics)
- AtomicId (requires macros)
- ParallelQueue (requires threading)

---

## 2. Prerequisites

### Dependencies
- Haxe 4.x standard library
- `haxe.ds.Map` for hash map implementations
- `haxe.io.Bytes` for byte-level operations

### Build Configuration
- No special hxml flags required
- Standard compilation targets (JS, C++, etc.)

---

## 3. Implementation Steps

### Step 1: Enhance Hash.hx

**File:** `/home/vscode/projects/bevy_haxe/src/haxe/utils/Hash.hx`

**Changes:**
1. Add FNV-1a 64-bit hash support
2. Add FxHash (Rust's default hasher) implementation
3. Add `Hashable` interface for custom hash implementations
4. Add `FixedHasher` for bloom filter support
5. Add `NoOpHash` for pre-computed hashes
6. Add `PassHash` for passthrough hashing

**Key Additions:**
```haxe
interface Hashable {
    function hash():Int;
}

class FxHash {
    // Rust's FxHasher implementation
}

class FixedHasher {
    // For bloom filter support
}
```

**Testing:** Hash distribution tests, collision detection

---

### Step 2: Enhance HashUtils.hx

**File:** `/home/vscode/projects/bevy_haxe/src/haxe/utils/HashUtils.hx`

**Changes:**
1. Add `hashCombine` for combining multiple hash values
2. Add `stableHash` function for deterministic hashing
3. Add `Hashed<T>` struct with pre-computed hash
4. Add `HashMapExt` extension methods for HashMap

**Key Additions:**
```haxe
class HashUtils {
    // Existing methods...
    
    // New: Combine hashes like Rust's Hash::hash_combine
    public static function hashCombine(seed:Int, value:Dynamic):Int;
    
    // New: Stable hash for deterministic output
    public static function stableHash(s:String):Int;
}
```

**Testing:** Hash combination tests, stability tests

---

### Step 3: Enhance TypeId.hx

**File:** `/home/vscode/projects/bevy_haxe/src/haxe/utils/TypeId.hx`

**Changes:**
1. Add `TypeIdMap<V>` class (IndexMap-like with TypeId keys)
2. Add `TypeIdOf<T>` abstract type wrapper
3. Add `NoOpHash` for TypeIdMap
4. Add entry API for type-safe insertion

**Key Additions:**
```haxe
// TypeIdMap: TypeId-keyed map with O(1) lookup
@:generic
class TypeIdMap<V> {
    private var data:Map<Int, V>;  // Int is TypeId.id
    
    public function new():Void;
    public function get<T>():Null<V>;
    public function set<T>(value:V):Void;
    public function entry<T>():TypeIdMapEntry<V>;
    public function remove<T>():Bool;
}

// Entry type for or_insert patterns
enum TypeIdMapEntry<V> {
    Occupied(entry:OccupiedEntry<V>);
    Vacant(entry:VacantEntry<V>);
}
```

**Testing:** TypeId uniqueness tests, map operations

---

### Step 4: Enhance InternedString.hx

**File:** `/home/vscode/projects/bevy_haxe/src/haxe/utils/InternedString.hx`

**Changes:**
1. Add `InternedStringPool` class for managing interned strings
2. Add comparison operators
3. Add iteration support
4. Add `InternedStringMap<V>` class

**Key Additions:**
```haxe
// Pool-based interning
class InternedStringPool {
    public static function intern(s:String):InternedString;
    public static function getOrCreate(s:String):InternedString;
    public static function clear():Void;
    public static var count(get, never):Int;
}

// Map with InternedString keys
@:generic
class InternedStringMap<V> {
    // Existing implementation with enhancements
}
```

**Testing:** String interning performance, equality checks

---

### Step 5: Enhance Label.hx

**File:** `/home/vscode/projects/bevy_haxe/src/haxe/utils/Label.hx`

**Changes:**
1. Add `LabelId` type for efficient label comparison
2. Add `DynamicLabel` for runtime-created labels
3. Add `LabelMap<V>` class
4. Add `LabelSet` class

**Key Additions:**
```haxe
// Label with id-based comparison
class Label {
    // Existing implementation...
    
    // New: Compare labels efficiently
    public function equals(other:Label):Bool;
    
    // New: Get as dynamic label
    public function toDynamic():DynamicLabel;
}

// DynamicLabel for non-static labels
@:structInit
class DynamicLabel {
    public var id:Int;
    public var name:InternedString;
    public var namespace:Null<InternedString>;
}

// Label-based map
@:generic
class LabelMap<V> {
    // Efficient label-keyed storage
}

// Label-based set
class LabelSet {
    // Efficient label storage
}
```

**Testing:** Label comparison tests, namespace tests

---

### Step 6: Enhance EntityHashMap.hx

**File:** `/home/vscode/projects/bevy_haxe/src/haxe/utils/EntityHashMap.hx`

**Changes:**
1. Add `EntityHashMapEntry` enum for entry API
2. Add `getOrInsert` methods
3. Add `getOrInsertWith` methods
4. Add iteration with entities

**Key Additions:**
```haxe
@:generic
class EntityHashMap<V> {
    // Existing implementation...
    
    // New: Get value or insert default
    public function getOrInsert(entity:Entity, defaultValue:V):V;
    
    // New: Get value or compute with function
    public function getOrInsertWith(entity:Entity, f:Void->V):V;
    
    // New: Entry API
    public function entry(entity:Entity):EntityHashMapEntry<V>;
    
    // New: Iteration with entity
    public function iterator():EntityHashMapIterator<V>;
}

// Entry type
enum EntityHashMapEntry<V> {
    Occupied(entry:EntityHashMapOccupied<V>);
    Vacant(entity:Entity);
}
```

**Testing:** Entity generation tests, map operation tests

---

### Step 7: Create/Enhance Module.hx

**File:** `/home/vscode/projects/bevy_haxe/src/haxe/utils/Module.hx`

**Changes:**
1. Add comprehensive module documentation
2. Add prelude exports
3. Add utility functions
4. Add module initialization

**Key Additions:**
```haxe
class Module {
    // Module info
    public static var MODULE_NAME(default, never) = "haxe.utils";
    public static var MODULE_VERSION(default, never) = "0.2.0";
    
    // Initialization
    public static function init():Void;
    public static var initialized(get, never):Bool;
    
    // Utility functions
    public static function defaultValue<T>():Null<T>;
}

// Prelude class for convenient imports
class Prelude {
    public static function entity(id:UInt, ?generation:UInt):Entity;
    public static function label(name:String, ?ns:String):Label;
    public static function intern(s:String):InternedString;
    public static function typeId<T>():TypeId;
}
```

**Testing:** Module initialization tests

---

## 4. File Changes Summary

### Modified Files
| File | Changes |
|------|---------|
| `src/haxe/utils/Hash.hx` | Add Hashable interface, FxHash, FixedHasher, NoOpHash, PassHash |
| `src/haxe/utils/HashUtils.hx` | Add hashCombine, stableHash, HashMapExt |
| `src/haxe/utils/TypeId.hx` | Add TypeIdMap, TypeIdOf, entry API |
| `src/haxe/utils/InternedString.hx` | Add InternedStringPool, comparisons |
| `src/haxe/utils/Label.hx` | Add LabelId, DynamicLabel, LabelMap, LabelSet |
| `src/haxe/utils/EntityHashMap.hx` | Add entry API, getOrInsert, iteration |
| `src/haxe/utils/Module.hx` | Enhance documentation, add prelude |

### New Files
None required - all improvements are modifications to existing files.

---

## 5. Testing Strategy

### Unit Tests
1. **Hash Tests**
   - FNV-1a hash distribution
   - FxHash stability
   - Hash collision detection

2. **TypeId Tests**
   - Same type returns same ID
   - Different types return different IDs
   - TypeIdMap operations

3. **InternedString Tests**
   - Same string returns same interned instance
   - Different strings return different instances
   - Performance comparison with regular strings

4. **Label Tests**
   - Namespace handling
   - Comparison operations
   - LabelMap operations

5. **EntityHashMap Tests**
   - Basic CRUD operations
   - Generation handling
   - Entry API usage

### Manual Testing
1. Create test program using all utils types
2. Verify no runtime errors
3. Verify performance characteristics

---

## 6. Rollback Plan

### Revert Process
1. All changes are additive or modifying existing code
2. No deletions of functionality
3. Can restore from git if needed:
   ```bash
   git checkout HEAD -- src/haxe/utils/
   ```

### Data Migration
- No persistent data to migrate
- All structures are in-memory

---

## 7. Estimated Effort

### Time Estimate
- **Hash.hx enhancements**: 1-2 hours
- **HashUtils.hx enhancements**: 1 hour
- **TypeId.hx enhancements**: 1-2 hours
- **InternedString.hx enhancements**: 1 hour
- **Label.hx enhancements**: 1-2 hours
- **EntityHashMap.hx enhancements**: 1-2 hours
- **Module.hx enhancements**: 30 minutes

**Total**: ~8-10 hours

### Complexity Assessment
**Medium-High**

Key challenges:
1. Proper generic type handling in Haxe
2. Mimicking Rust's entry API patterns
3. Ensuring hash stability across platforms
4. Performance optimization for frequently-called functions

---

## 8. Implementation Order

1. Start with `Hash.hx` as foundation
2. Then `HashUtils.hx` 
3. Then `TypeId.hx` (depends on hash)
4. Then `InternedString.hx` (independent)
5. Then `Label.hx` (depends on InternedString)
6. Then `EntityHashMap.hx` (depends on Hash)
7. Finally `Module.hx` (depends on all)
