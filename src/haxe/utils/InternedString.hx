package haxe.utils;

/**
 * String interning system for efficient string comparisons.
 * Interned strings are stored once and reused, allowing fast equality checks.
 * 
 * Equivalent to Rust's `std::borrow::Cow` or a custom string interning system.
 */
class InternedString {
    private static var _strings:Map<Int, String> = new Map();
    private static var _reverseLookup:Map<String, Int> = new Map();
    private static var _nextIndex:Int = 0;
    
    /**
     * The interned string value
     */
    public var value(default, null):String;
    
    /**
     * The unique index of this interned string
     */
    public var index(default, null):Int;
    
    private function new(value:String, index:Int) {
        this.value = value;
        this.index = index;
    }
    
    /**
     * Intern a string, returning a cached version if available.
     * @param s The string to intern
     * @return An InternedString instance
     */
    public static function intern(s:String):InternedString {
        if (_reverseLookup.exists(s)) {
            var idx = _reverseLookup.get(s);
            return new InternedString(s, idx);
        }
        
        var idx = _nextIndex++;
        _strings.set(idx, s);
        _reverseLookup.set(s, idx);
        
        return new InternedString(s, idx);
    }
    
    /**
     * Try to get an existing interned string without creating a new one.
     * @param s The string to look up
     * @return The InternedString if found, null otherwise
     */
    public static function get(s:String):Null<InternedString> {
        if (_reverseLookup.exists(s)) {
            var idx = _reverseLookup.get(s);
            return new InternedString(s, idx);
        }
        return null;
    }
    
    /**
     * Clear all interned strings.
     * WARNING: Should only be used for testing.
     */
    public static function clear():Void {
        _strings.clear();
        _reverseLookup.clear();
        _nextIndex = 0;
    }
    
    /**
     * Get the number of interned strings.
     */
    public static var count(get, never):Int;
    private static inline function get_count():Int return _strings.count();
    
    /**
     * Get the underlying string value.
     */
    public inline function toString():String {
        return value;
    }
    
    /**
     * Compare two interned strings by index (O(1) comparison).
     */
    @:op(A == B)
    public static function equals(a:InternedString, b:InternedString):Bool {
        return a.index == b.index;
    }
    
    /**
     * Compare interned string with regular string.
     */
    @:op(A == B)
    public static function equalsWithString(a:InternedString, b:String):Bool {
        return a.value == b;
    }
    
    @:op(A != B)
    public static function notEquals(a:InternedString, b:InternedString):Bool {
        return a.index != b.index;
    }
    
    public function hashCode():Int {
        return index;
    }
    
    /**
     * Check if this interned string is the same as another.
     * Uses index comparison for O(1) performance.
     */
    public inline function is(a:InternedString):Bool {
        return index == a.index;
    }
    
    /**
     * Check if the underlying string equals the given string.
     */
    public inline function equalsStr(s:String):Bool {
        return value == s;
    }
}

/**
 * Extension methods for working with interned strings.
 */
class InternedStringTools {
    /**
     * Intern a string with additional context (prefix).
     * Useful for namespacing interned strings.
     */
    public static inline function internPrefixed(s:String, prefix:String):InternedString {
        return InternedString.intern(prefix + s);
    }
    
    /**
     * Create an interned string from a computed value.
     */
    public static function internComputed<T>(value:T, toString:Void->String):InternedString {
        return InternedString.intern(toString());
    }
}

/**
 * A fast hash map using interned string keys.
 * Provides O(1) key comparison after initial interning.
 */
@:generic
class InternedStringMap<V> {
    private var data:Map<Int, V>;
    private var keyData:Map<Int, InternedString>;
    
    public inline function new() {
        data = new Map();
        keyData = new Map();
    }
    
    /**
     * Insert a value with an interned string key.
     */
    public inline function set(key:InternedString, value:V):Null<V> {
        var old:V = data.get(key.index);
        data.set(key.index, value);
        keyData.set(key.index, key);
        return old;
    }
    
    /**
     * Get a value by interned string key.
     */
    public inline function get(key:InternedString):Null<V> {
        return data.get(key.index);
    }
    
    /**
     * Check if the map contains the key.
     */
    public inline function exists(key:InternedString):Bool {
        return data.exists(key.index);
    }
    
    /**
     * Remove a key.
     */
    public inline function remove(key:InternedString):Bool {
        keyData.remove(key.index);
        return data.remove(key.index);
    }
    
    /**
     * Get the number of entries.
     */
    public var length(get, never):Int;
    private inline function get_length():Int return data.count();
    
    /**
     * Clear the map.
     */
    public inline function clear():Void {
        data.clear();
        keyData.clear();
    }
    
    /**
     * Get all interned string keys.
     */
    public inline function keys():Iterator<InternedString> {
        return keyData.iterator();
    }
    
    /**
     * Get all values.
     */
    public inline function iterator():Iterator<V> {
        return data.iterator();
    }
    
    /**
     * Check if empty.
     */
    public var isEmpty(get, never):Bool;
    private inline function get_isEmpty():Bool return data.isEmpty();
}
