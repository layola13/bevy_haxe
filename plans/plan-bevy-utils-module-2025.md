# Bevy Utils Module Enhancement Plan

## 1. Overview

Enhance the `haxe.utils` module to better align with Rust's `bevy_utils` crate. The module provides essential utility types for ECS, type identification, hashing, and string interning.

**Goals:**
- Improve Hash.hx with additional hash functions and HashMap support
- Enhance HashUtils.hx with more hash utilities and BloomFilter
- Improve TypeId.hx with TypeIdMap support
- Enhance InternedString.hx with better utilities
- Improve Label.hx with LabelId and additional methods
- Enhance EntityHashMap.hx with better Entity support and new utility types
- Update Module.hx with improved module organization and prelude

**Success Criteria:**
- API mirrors Bevy Utils where appropriate
- Type safety maintained
- Performance considerations addressed
- Comprehensive documentation

---

## 2. Prerequisites

- Haxe 4.x+
- No external dependencies required (pure Haxe implementation)
- Uses standard Haxe Map, Array, and collection types

---

## 3. Implementation Steps

### Step 1: Enhance Hash.hx
**Files to modify:** `src/haxe/utils/Hash.hx`

**Changes:**
- Add `PassHash` and `NoOpHash` hash strategies
- Add `FixedHasher` for fixed-output hashing
- Add `HashMap<K, V>` with configurable hasher
- Add `HashSet<T>` for hash-based sets
- Add `getOrInsertWith` extension for maps
- Add `hashCombine` for combining multiple hashes
- Add comprehensive iterator support

### Step 2: Enhance HashUtils.hx
**Files to modify:** `src/haxe/utils/HashUtils.hx`

**Changes:**
- Add `mixHash` for hash distribution improvement
- Add `hashCombine` function for combining multiple hash values
- Add `BloomFilter` class for probabilistic filtering
- Add `HashState` for incremental hashing
- Add `Hashed<T>` wrapper type improvement

### Step 3: Enhance TypeId.hx
**Files to modify:** `src/haxe/utils/TypeId.hx`

**Changes:**
- Add `TypeIdMap<V>` for TypeId-keyed maps
- Add `getOrInsert` and `entry` methods
- Add TypeId comparison operators
- Improve hashCode implementation
- Add `TypeIdOf<T>` abstract type

### Step 4: Enhance InternedString.hx
**Files to modify:** `src/haxe/utils/InternedString.hx`

**Changes:**
- Add `InternedStringMap<V>` (already exists, ensure completeness)
- Add `internMany` for batch interning
- Add `clear` method for testing
- Add `totalCount` static method
- Add comparison operators

### Step 5: Enhance Label.hx
**Files to modify:** `src/haxe/utils/Label.hx`

**Changes:**
- Add `LabelId` type for unique label identification
- Add `LabelMap<V>` (already exists, ensure completeness)
- Add `LabelHashSet` for sets of labels
- Improve Label comparison methods
- Add namespace-aware operations

### Step 6: Enhance EntityHashMap.hx
**Files to modify:** `src/haxe/utils/EntityHashMap.hx`

**Changes:**
- Update Entity to work with ECS module
- Add `EntityMap<V>` (alias for EntityHashMap)
- Add `EntitySet` (already exists, ensure completeness)
- Add `getOrInsert` method
- Add `entry` API for map entries
- Add batch operations support

### Step 7: Update Module.hx
**Files to modify:** `src/haxe/utils/Module.hx`

**Changes:**
- Add comprehensive module documentation
- Add re-export of all utility types
- Add `UtilsPrelude` class for convenient imports
- Add initialization methods
- Add module metadata (version, name)
- Add BloomFilter and AtomicId

---

## 4. File Changes Summary

### Modified Files:
1. `src/haxe/utils/Hash.hx` - Extended hash functions and HashMap/HashSet
2. `src/haxe/utils/HashUtils.hx` - Added BloomFilter and hash utilities
3. `src/haxe/utils/TypeId.hx` - Added TypeIdMap and comparison operators
4. `src/haxe/utils/InternedString.hx` - Enhanced string interning utilities
5. `src/haxe/utils/Label.hx` - Added LabelId and improved label system
6. `src/haxe/utils/EntityHashMap.hx` - Enhanced Entity utilities
7. `src/haxe/utils/Module.hx` - Updated module organization

---

## 5. Testing Strategy

### Unit Tests to Create:
1. Hash function tests - verify FNV-1a consistency
2. HashMap/HashSet operations - insert, get, remove, iterate
3. TypeId uniqueness tests - same type returns same ID
4. InternedString deduplication - same string returns same instance
5. Label with namespaces - proper fullName generation
6. EntityHashMap with generation - stale entity handling
7. BloomFilter false positive rate tests

### Integration Tests:
1. Use all utils types together in a combined test
2. Test performance of hash-based collections

---

## 6. Rollback Plan

To rollback changes:
1. Restore original file contents from version control
2. No database migrations needed (pure in-memory structures)
3. Clear any cached type IDs using `TypeId.reset()`

---

## 7. Estimated Effort

**Time Estimate:** 4-6 hours
**Complexity:** Medium
**Risk:** Low (improvements to existing working code)

---

## 8. Implementation Details

### Hash.hx Key Additions:

```haxe
// Hash strategies
enum HashStrategy {
    PassHash;     // Use object's own hashCode
    NoOpHash;     // Hash is pre-computed, ignore value
}

// HashMap with configurable hashing
@:generic
class HashMap<K, V, S:HashStrategy = PassHash> {
    // Core operations
}

// HashSet
@:generic  
class HashSet<T, S:HashStrategy = PassHash> {
    // Set operations
}
```

### HashUtils.hx Key Additions:

```haxe
// Bloom filter for probabilistic membership
@:generic
class BloomFilter<N:Int, K:Int = 2> {
    public static function new():BloomFilter<N, K>;
    public function insert(item:Dynamic):Void;
    public function contains(item:Dynamic):Bool;
    public function checkInsert(item:Dynamic):Bool;
}
```

### TypeId.hx Key Additions:

```haxe
// TypeId-keyed map (ordered iteration)
@:generic
class TypeIdMap<V> {
    public function set(id:TypeId, value:V):Void;
    public function get(id:TypeId):Null<V>;
    public function entry(id:TypeId):MapEntry<TypeId, V>;
}
```

### Module.hx Updates:

```haxe
class Module {
    // Re-exports
    public static inline var TypeId = haxe.utils.TypeId;
    public static inline var HashUtils = haxe.utils.HashUtils;
    // ... etc
}

class UtilsPrelude {
    // Convenient imports
}
```
