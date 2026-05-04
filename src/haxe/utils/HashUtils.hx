package haxe.utils;

/**
 * Utility functions for hash computations.
 * Provides consistent hashing for data structures requiring stable hash codes.
 */
class HashUtils {
    /**
     * Default seed for FNV-1a hash algorithm
     */
    private static inline var FNV_PRIME:Int = 16777619;
    private static inline var FNV_OFFSET:Int = 2166136261;
    
    /**
     * Computes a FNV-1a hash for a string.
     * The FNV-1a hash provides good distribution for string keys.
     */
    public static inline function fnv1a(s:String):Int {
        var hash = FNV_OFFSET;
        for (i in 0...s.length) {
            hash ^= s.charCodeAt(i);
            hash *= FNV_PRIME;
        }
        return hash;
    }
    
    /**
     * Computes a FNV-1a hash for an integer.
     */
    public static inline function fnv1aInt(i:Int):Int {
        var bytes = haxe.io.Bytes.ofInt(i);
        var hash = FNV_OFFSET;
        for (j in 0...4) {
            hash ^= bytes.get(j);
            hash *= FNV_PRIME;
        }
        return hash;
    }
    
    /**
     * Computes a FNV-1a hash for a 64-bit integer (stored as two 32-bit values).
     */
    public static inline function fnv1aInt64(lo:Int, hi:Int):Int {
        var hash = FNV_OFFSET;
        // Mix both parts
        hash ^= lo & 0xFF;
        hash *= FNV_PRIME;
        hash ^= (lo >> 8) & 0xFF;
        hash *= FNV_PRIME;
        hash ^= (lo >> 16) & 0xFF;
        hash *= FNV_PRIME;
        hash ^= (lo >> 24) & 0xFF;
        hash *= FNV_PRIME;
        hash ^= hi & 0xFF;
        hash *= FNV_PRIME;
        hash ^= (hi >> 8) & 0xFF;
        hash *= FNV_PRIME;
        hash ^= (hi >> 16) & 0xFF;
        hash *= FNV_PRIME;
        hash ^= (hi >> 24) & 0xFF;
        hash *= FNV_PRIME;
        return hash;
    }
    
    /**
     * Computes a simple hash for combining multiple hash values.
     * Uses XOR and multiplication to spread bits.
     */
    public static inline function combineHash(h1:Int, h2:Int):Int {
        return h1 ^ (h2 * 31 + 1);
    }
    
    /**
     * Computes a hash for a float value.
     * Handles special float values (NaN, infinity) consistently.
     */
    public static function hashFloat(f:Float):Int {
        if (Math.isNaN(f)) return 0;
        if (!Math.isFinite(f)) return f > 0 ? 2143289344 : -939524096; // Handle infinity
        return Std.int(f * 73856093);
    }
    
    /**
     * Computes a hash for a boolean value.
     */
    public static inline function hashBool(b:Bool):Int {
        return b ? 1 : 0;
    }
    
    /**
     * Computes a stable hash for any object using its runtime type and content.
     */
    public static function hashObject<T>(obj:T):Int {
        var hash = 17;
        var typeId = TypeId.ofInstance(obj);
        hash = combineHash(hash, typeId.hashCode());
        
        if (Std.is(obj, String)) {
            hash = combineHash(hash, fnv1a(cast obj));
        } else if (Std.is(obj, Int)) {
            hash = combineHash(hash, cast obj);
        } else if (Std.is(obj, Float)) {
            hash = combineHash(hash, hashFloat(cast obj));
        } else if (Std.is(obj, Bool)) {
            hash = combineHash(hash, hashBool(cast obj));
        } else if (Std.is(obj, Array)) {
            var arr:Array<Dynamic> = cast obj;
            for (item in arr) {
                hash = combineHash(hash, hashObject(item));
            }
        }
        
        return hash;
    }
    
    /**
     * Computes a 64-bit hash by combining high and low 32-bit parts.
     * Returns an object with lo and hi parts.
     */
    public static inline function hash64(s:String):{lo:Int, hi:Int} {
        var hash1 = FNV_OFFSET;
        var hash2 = FNV_OFFSET;
        
        for (i in 0...s.length) {
            var c = s.charCodeAt(i);
            hash1 ^= c;
            hash1 *= FNV_PRIME;
            hash2 ^= c;
            hash2 = (hash2 * FNV_PRIME) ^ (c >> 8);
        }
        
        return {lo: hash1, hi: hash2};
    }
    
    /**
     * Mixes a hash value to improve distribution.
     * Uses the finalizer step of the FNV-1a algorithm.
     */
    public static inline function mixHash(hash:Int):Int {
        var h = hash;
        h ^= h >> 16;
        h *= 0x85EBCA6B;
        h ^= h >> 13;
        h *= 0xC2B2AE35;
        h ^= h >> 16;
        return h;
    }
}

/**
 * A pre-hashed value that stores the computed hash.
 * Useful for avoiding repeated hash computation.
 */
@:structInit
class Hashed<T> {
    /**
     * The original value
     */
    public var value:T;
    
    /**
     * The pre-computed hash of the value
     */
    public var hash(default, null):Int;
    
    public inline function new(value:T, hash:Int) {
        this.value = value;
        this.hash = hash;
    }
    
    /**
     * Create a Hashed wrapper with auto-computed hash.
     */
    public static function make<T>(value:T):Hashed<T> {
        return new Hashed(value, HashUtils.hashObject(value));
    }
}
