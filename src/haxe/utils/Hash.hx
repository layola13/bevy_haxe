package haxe.utils;

/**
 * Hash utility functions and data structures.
 * Provides FNV-1a hash implementation and specialized hash collections.
 * 
 * Equivalent to Rust's `bevy_utils::hash` module.
 */
class Hash {
    /**
     * FNV-1a hash constants (64-bit)
     */
    private static inline var FNV_PRIME:Int = 16777619;
    private static inline var FNV_OFFSET:Int = 2166136261;
    
    /**
     * Computes a FNV-1a 32-bit hash for a string.
     * FNV-1a provides good distribution for short strings and is fast.
     */
    public static inline function fnv1aString(s:String):Int {
        var hash = FNV_OFFSET;
        for (i in 0...s.length) {
            hash ^= s.charCodeAt(i);
            hash = (hash * FNV_PRIME) & 0xFFFFFFFF;
        }
        return hash;
    }
    
    /**
     * Computes a FNV-1a 32-bit hash for an integer.
     */
    public static inline function fnv1aInt(i:Int):Int {
        var hash = FNV_OFFSET;
        // Mix all 4 bytes
        hash ^= i & 0xFF;
        hash = (hash * FNV_PRIME) & 0xFFFFFFFF;
        hash ^= (i >> 8) & 0xFF;
        hash = (hash * FNV_PRIME) & 0xFFFFFFFF;
        hash ^= (i >> 16) & 0xFF;
        hash = (hash * FNV_PRIME) & 0xFFFFFFFF;
        hash ^= (i >> 24) & 0xFF;
        hash = (hash * FNV_PRIME) & 0xFFFFFFFF;
        return hash;
    }
    
    /**
     * Computes a FNV-1a hash for a 64-bit value (two 32-bit integers).
     */
    public static inline function fnv1aInt64(lo:Int, hi:Int):Int {
        var hash = FNV_OFFSET;
        // Mix lower 32 bits
        hash ^= lo & 0xFF;
        hash = (hash * FNV_PRIME) & 0xFFFFFFFF;
        hash ^= (lo >> 8) & 0xFF;
        hash = (hash * FNV_PRIME) & 0xFFFFFFFF;
        hash ^= (lo >> 16) & 0xFF;
        hash = (hash * FNV_PRIME) & 0xFFFFFFFF;
        hash ^= (lo >> 24) & 0xFF;
        hash = (hash * FNV_PRIME) & 0xFFFFFFFF;
        // Mix upper 32 bits
        hash ^= hi & 0xFF;
        hash = (hash * FNV_PRIME) & 0xFFFFFFFF;
        hash ^= (hi >> 8) & 0xFF;
        hash = (hash * FNV_PRIME) & 0xFFFFFFFF;
        hash ^= (hi >> 16) & 0xFF;
        hash = (hash * FNV_PRIME) & 0xFFFFFFFF;
        hash ^= (hi >> 24) & 0xFF;
        hash = (hash * FNV_PRIME) & 0xFFFFFFFF;
        return hash;
    }
    
    /**
     * Computes hash for an object using its field values.
     */
    public static function hashObject<T>(obj:T):Int {
        if (obj == null) return 0;
        return fnv1aString(haxe.Json.stringify(obj));
    }
    
    /**
     * Combines two hash values (like Java's HashMap).
     */
    public static inline function combine(h1:Int, h2:Int):Int {
        return ((h1 << 5) + h1) ^ h2;
    }
    
    /**
     * Mixes a hash value to improve distribution.
     * Based on the finalizer step of the FNV-1a algorithm.
     */
    public static inline function mix(h:Int):Int {
        var x = h;
        x ^= x >> 16;
        x = (x * 0x85EBCA6B) & 0xFFFFFFFF;
        x ^= x >> 13;
        x = (x * 0xC2B2AE35) & 0xFFFFFFFF;
        x ^= x >> 16;
        return x;
    }
}

/**
 * BuildHasher trait interface for custom hashers.
 */
interface BuildHasher {
    /**
     * Creates a new hasher instance.
     */
    function createHasher():Hasher;
}

/**
 * Hasher interface for custom hashing.
 */
interface Hasher {
    /**
     * Writes data to be hashed.
     */
    function write(data:Dynamic):Void;
    
    /**
     * Finishes hashing and returns the final hash value.
     */
    function finish():Int;
}

/**
 * Default hasher using FNV-1a.
 */
class DefaultHasher implements BuildHasher {
    public inline function new() {}
    
    public inline function createHasher():Hasher {
        return new FnvHasher();
    }
}

/**
 * FNV-1a hasher implementation.
 */
class FnvHasher implements Hasher {
    private var hash:Int;
    
    public inline function new() {
        this.hash = 0x811C9DC5; // FNV offset basis for 32-bit
    }
    
    public inline function write(data:Dynamic):Void {
        if (Std.is(data, Int)) {
            writeInt(data);
        } else if (Std.is(data, String)) {
            writeString(data);
        } else if (Std.is(data, Float)) {
            writeFloat(data);
        } else if (Std.is(data, Bool)) {
            writeBool(data);
        } else {
            writeString(haxe.Json.stringify(data));
        }
    }
    
    private inline function writeInt(i:Int):Void {
        hash ^= i & 0xFF;
        hash = (hash * 0x01000193) & 0xFFFFFFFF;
        hash ^= (i >> 8) & 0xFF;
        hash = (hash * 0x01000193) & 0xFFFFFFFF;
        hash ^= (i >> 16) & 0xFF;
        hash = (hash * 0x01000193) & 0xFFFFFFFF;
        hash ^= (i >> 24) & 0xFF;
        hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    
    private inline function writeString(s:String):Void {
        for (i in 0...s.length) {
            hash ^= s.charCodeAt(i);
            hash = (hash * 0x01000193) & 0xFFFFFFFF;
        }
    }
    
    private inline function writeFloat(f:Float):Void {
        var bits = Std.int(f);
        writeInt(bits);
    }
    
    private inline function writeBool(b:Bool):Void {
        hash ^= b ? 1 : 0;
        hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    
    public inline function finish():Int {
        return hash;
    }
}

/**
 * A HashMap using FNV-1a hashing.
 * Provides efficient key-value storage with O(1) average lookup.
 */
@:generic
@:structInit
class FnvHashMap<K, V> {
    private var buckets:Array<FnvHashMapEntry<K, V>>;
    private var size:Int;
    private var capacity:Int;
    private var loadFactor:Float;
    
    private static inline var DEFAULT_CAPACITY:Int = 16;
    private static inline var DEFAULT_LOAD_FACTOR:Float = 0.75;
    
    public inline function new(?initialCapacity:Int) {
        this.capacity = initialCapacity != null ? initialCapacity : DEFAULT_CAPACITY;
        this.size = 0;
        this.loadFactor = DEFAULT_LOAD_FACTOR;
        this.buckets = [];
        for (i in 0...this.capacity) {
            buckets.push(null);
        }
    }
    
    private inline function hashKey(key:K):Int {
        if (Std.is(key, Int)) {
            return Hash.fnv1aInt(cast key);
        } else if (Std.is(key, String)) {
            return Hash.fnv1aString(cast key);
        } else {
            return Hash.hashObject(key);
        }
    }
    
    private inline function indexFor(hash:Int):Int {
        return (hash & 0x7FFFFFFF) % capacity;
    }
    
    private function grow():Void {
        var oldBuckets = buckets;
        var oldCapacity = capacity;
        
        capacity = capacity * 2;
        buckets = [];
        for (i in 0...capacity) {
            buckets.push(null);
        }
        
        size = 0;
        var entry:FnvHashMapEntry<K, V> = null;
        for (i in 0...oldCapacity) {
            entry = oldBuckets[i];
            while (entry != null) {
                putInternal(entry.key, entry.value);
                entry = entry.next;
            }
        }
    }
    
    private inline function putInternal(key:K, value:V):Void {
        var hash = hashKey(key);
        var idx = indexFor(hash);
        
        var entry = buckets[idx];
        while (entry != null) {
            if (compareKeys(entry.key, key)) {
                entry.value = value;
                return;
            }
            entry = entry.next;
        }
        
        var newEntry = new FnvHashMapEntry(key, value, buckets[idx]);
        buckets[idx] = newEntry;
        size++;
    }
    
    private inline function compareKeys(a:K, b:K):Bool {
        if (Reflect.compare(a, b) == 0) return true;
        return false;
    }
    
    /**
     * Insert a key-value pair.
     * @return The previous value if key existed, null otherwise.
     */
    public inline function set(key:K, value:V):Null<V> {
        if (size >= capacity * loadFactor) {
            grow();
        }
        
        var hash = hashKey(key);
        var idx = indexFor(hash);
        
        var entry = buckets[idx];
        while (entry != null) {
            if (compareKeys(entry.key, key)) {
                var oldValue = entry.value;
                entry.value = value;
                return oldValue;
            }
            entry = entry.next;
        }
        
        var newEntry = new FnvHashMapEntry(key, value, buckets[idx]);
        buckets[idx] = newEntry;
        size++;
        return null;
    }
    
    /**
     * Alias for set().
     */
    public inline function setTyped(key:K, value:V):Null<V> {
        return set(key, value);
    }
    
    /**
     * Get a value by key.
     */
    public inline function get(key:K):Null<V> {
        var hash = hashKey(key);
        var idx = indexFor(hash);
        
        var entry = buckets[idx];
        while (entry != null) {
            if (compareKeys(entry.key, key)) {
                return entry.value;
            }
            entry = entry.next;
        }
        return null;
    }
    
    /**
     * Check if key exists.
     */
    public inline function exists(key:K):Bool {
        var hash = hashKey(key);
        var idx = indexFor(hash);
        
        var entry = buckets[idx];
        while (entry != null) {
            if (compareKeys(entry.key, key)) {
                return true;
            }
            entry = entry.next;
        }
        return false;
    }
    
    /**
     * Remove a key-value pair.
     * @return The removed value if key existed, null otherwise.
     */
    public inline function remove(key:K):Null<V> {
        var hash = hashKey(key);
        var idx = indexFor(hash);
        
        var entry = buckets[idx];
        var prev:FnvHashMapEntry<K, V> = null;
        
        while (entry != null) {
            if (compareKeys(entry.key, key)) {
                if (prev != null) {
                    prev.next = entry.next;
                } else {
                    buckets[idx] = entry.next;
                }
                size--;
                return entry.value;
            }
            prev = entry;
            entry = entry.next;
        }
        return null;
    }
    
    /**
     * Get the number of entries.
     */
    public var length(get, never):Int;
    private inline function get_length():Int return size;
    
    /**
     * Check if empty.
     */
    public var isEmpty(get, never):Bool;
    private inline function get_isEmpty():Bool return size == 0;
    
    /**
     * Clear all entries.
     */
    public inline function clear():Void {
        for (i in 0...capacity) {
            buckets[i] = null;
        }
        size = 0;
    }
    
    /**
     * Iterate over key-value pairs.
     */
    public inline function keyValueIterator():FnvHashMapIterator<K, V> {
        return new FnvHashMapIterator(buckets, size);
    }
    
    /**
     * Iterate over keys.
     */
    public inline function keys():Iterator<K> {
        var result:Array<K> = [];
        for (i in 0...capacity) {
            var entry = buckets[i];
            while (entry != null) {
                result.push(entry.key);
                entry = entry.next;
            }
        }
        return result.iterator();
    }
    
    /**
     * Iterate over values.
     */
    public inline function iterator():Iterator<V> {
        var result:Array<V> = [];
        for (i in 0...capacity) {
            var entry = buckets[i];
            while (entry != null) {
                result.push(entry.value);
                entry = entry.next;
            }
        }
        return result.iterator();
    }
    
    /**
     * Get all keys as an array.
     */
    public inline function keyArray():Array<K> {
        var result = [];
        for (i in 0...capacity) {
            var entry = buckets[i];
            while (entry != null) {
                result.push(entry.key);
                entry = entry.next;
            }
        }
        return result;
    }
    
    /**
     * Get all values as an array.
     */
    public inline function valueArray():Array<V> {
        var result = [];
        for (i in 0...capacity) {
            var entry = buckets[i];
            while (entry != null) {
                result.push(entry.value);
                entry = entry.next;
            }
        }
        return result;
    }
}

/**
 * Entry in FnvHashMap.
 */
@:structInit
private class FnvHashMapEntry<K, V> {
    public var key:K;
    public var value:V;
    public var next:FnvHashMapEntry<K, V>;
    
    public inline function new(key:K, value:V, next:FnvHashMapEntry<K, V>) {
        this.key = key;
        this.value = value;
        this.next = next;
    }
}

/**
 * Iterator for FnvHashMap key-value pairs.
 */
@:generic
private class FnvHashMapIterator<K, V> {
    private var buckets:Array<FnvHashMapEntry<K, V>>;
    private var currentBucket:Int;
    private var currentEntry:FnvHashMapEntry<K, V>;
    private var remaining:Int;
    
    public inline function new(buckets:Array<FnvHashMapEntry<K, V>>, size:Int) {
        this.buckets = buckets;
        this.currentBucket = 0;
        this.currentEntry = null;
        this.remaining = size;
        findNext();
    }
    
    private inline function findNext():Void {
        while (currentEntry == null && currentBucket < buckets.length) {
            currentEntry = buckets[currentBucket];
            currentBucket++;
        }
    }
    
    public inline function hasNext():Bool {
        return remaining > 0;
    }
    
    public inline function next():{key:K, value:V} {
        if (remaining <= 0) return null;
        
        var result = {key: currentEntry.key, value: currentEntry.value};
        currentEntry = currentEntry.next;
        remaining--;
        
        if (currentEntry == null) {
            findNext();
        }
        
        return result;
    }
}

/**
 * A HashSet using FNV-1a hashing.
 * Provides efficient unique value storage with O(1) average lookup.
 */
@:generic
@:structInit
class FnvHashSet<T> {
    private var map:FnvHashMap<T, Bool>;
    
    public inline function new(?initialCapacity:Int) {
        map = new FnvHashMap(initialCapacity);
    }
    
    /**
     * Add a value to the set.
     * @return true if the value was added, false if it already existed.
     */
    public inline function add(value:T):Bool {
        if (map.exists(value)) return false;
        map.set(value, true);
        return true;
    }
    
    /**
     * Check if value exists in set.
     */
    public inline function exists(value:T):Bool {
        return map.exists(value);
    }
    
    /**
     * Alias for exists().
     */
    public inline function contains(value:T):Bool {
        return exists(value);
    }
    
    /**
     * Remove a value from the set.
     */
    public inline function remove(value:T):Bool {
        return map.remove(value) != null;
    }
    
    /**
     * Get the number of elements.
     */
    public var length(get, never):Int;
    private inline function get_length():Int return map.length;
    
    /**
     * Check if empty.
     */
    public var isEmpty(get, never):Bool;
    private inline function get_isEmpty():Bool return map.isEmpty;
    
    /**
     * Clear all elements.
     */
    public inline function clear():Void {
        map.clear();
    }
    
    /**
     * Iterate over values.
     */
    public inline function iterator():Iterator<T> {
        return map.keys();
    }
    
    /**
     * Convert to array.
     */
    public inline function toArray():Array<T> {
        return map.keyArray();
    }
}

/**
 * A pre-hashed value wrapper that caches the hash.
 * Useful when the same value will be hashed multiple times.
 */
@:structInit
class PreHashed<T> {
    /**
     * The original value.
     */
    public var value:T;
    
    /**
     * The pre-computed hash of the value.
     */
    public var hash:Int;
    
    public inline function new(value:T, hash:Int) {
        this.value = value;
        this.hash = hash;
    }
    
    /**
     * Create a PreHashed wrapper with auto-computed hash.
     */
    public static function make(value:T):PreHashed<T> {
        var h:Int;
        if (Std.is(value, Int)) {
            h = Hash.fnv1aInt(cast value);
        } else if (Std.is(value, String)) {
            h = Hash.fnv1aString(cast value);
        } else {
            h = Hash.hashObject(value);
        }
        return new PreHashed(value, h);
    }
}

/**
 * A HashMap that uses pre-computed hashes for keys.
 * This avoids re-hashing the same key multiple times.
 */
@:generic
@:structInit
class PreHashedMap<K, V> {
    private var data:FnvHashMap<Int, PreHashedMapEntry<K, V>>;
    
    public inline function new(?initialCapacity:Int) {
        data = new FnvHashMap(initialCapacity);
    }
    
    /**
     * Insert with pre-computed hash.
     */
    public inline function insert(key:K, hash:Int, value:V):Void {
        data.set(hash, {key: key, value: value});
    }
    
    /**
     * Get using pre-computed hash.
     */
    public inline function getWithHash(hash:Int):Null<V> {
        var entry = data.get(hash);
        return entry != null ? entry.value : null;
    }
    
    /**
     * Check existence using pre-computed hash.
     */
    public inline function containsHash(hash:Int):Bool {
        return data.exists(hash);
    }
    
    /**
     * Remove using pre-computed hash.
     */
    public inline function removeWithHash(hash:Int):Bool {
        return data.remove(hash) != null;
    }
    
    /**
     * Get value by key (will re-hash).
     */
    public inline function get(key:K):Null<V> {
        var h = Hash.hashObject(key);
        return getWithHash(h);
    }
    
    /**
     * Check existence by key (will re-hash).
     */
    public inline function exists(key:K):Bool {
        return containsHash(Hash.hashObject(key));
    }
    
    /**
     * Get the number of entries.
     */
    public var length(get, never):Int;
    private inline function get_length():Int return data.length;
    
    /**
     * Check if empty.
     */
    public var isEmpty(get, never):Bool;
    private inline function get_isEmpty():Bool return data.isEmpty;
    
    /**
     * Clear all entries.
     */
    public inline function clear():Void {
        data.clear();
    }
}

/**
 * Entry for PreHashedMap.
 */
@:structInit
private class PreHashedMapEntry<K, V> {
    public var key:K;
    public var value:V;
}
