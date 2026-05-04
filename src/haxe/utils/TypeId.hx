package haxe.utils;

/**
 * Type identifier system for compile-time type differentiation.
 * Provides unique type IDs at runtime for type-based dispatching.
 * 
 * Equivalent to Rust's `core::any::TypeId`.
 */
class TypeId {
    private static var _counter:Int = 0;
    private static var _cache:Map<String, TypeId> = new Map();
    
    /**
     * Internal type identifier value
     */
    public var id(default, null):Int;
    
    /**
     * The name of the type this ID represents
     */
    public var typeName(default, null):String;
    
    private function new(id:Int, typeName:String) {
        this.id = id;
        this.typeName = typeName;
    }
    
    /**
     * Returns the TypeId for the specified type T.
     * The same type always returns the same TypeId within a program execution.
     */
    public static function of<T>():TypeId {
        var typeName = Type.getClassName(Type.getClass(Type.createEmptyInstance(T)));
        return getFromCache(typeName);
    }
    
    /**
     * Returns the TypeId for an instance's actual runtime type.
     * Includes information about generic type parameters.
     */
    public static function ofInstance<T>(value:T):TypeId {
        var typeName = Type.getClassName(Type.getClass(value));
        return getFromCache(typeName);
    }
    
    /**
     * Returns the TypeId for a specific class type.
     */
    public static function ofClass<T>(clazz:Class<T>):TypeId {
        var typeName = Type.getClassName(clazz);
        return getFromCache(typeName);
    }
    
    private static function getFromCache(typeName:String):TypeId {
        if (_cache.exists(typeName)) {
            return _cache.get(typeName);
        }
        var id = ++_counter;
        var typeId = new TypeId(id, typeName);
        _cache.set(typeName, typeId);
        return typeId;
    }
    
    /**
     * Returns a unique TypeId for anonymous structures.
     */
    public static function ofAnon(fields:Array<String>):TypeId {
        var key = "anon_" + fields.join("_") + "_" + fields.length;
        if (_cache.exists(key)) {
            return _cache.get(key);
        }
        var id = ++_counter;
        var typeId = new TypeId(id, key);
        _cache.set(key, typeId);
        return typeId;
    }
    
    /**
     * Generates a unique sequential ID for dynamic type registration.
     * Useful for plugin systems and component registration.
     */
    public static function getNextId():Int {
        return ++_counter;
    }
    
    /**
     * Resets the type ID counter.
     * WARNING: Should only be used for testing purposes.
     */
    public static function reset():Void {
        _counter = 0;
        _cache.clear();
    }
    
    /**
     * Check if this TypeId equals another.
     */
    @:op(A == B)
    public function equals(other:TypeId):Bool {
        return id == other.id;
    }
    
    /**
     * Check if this TypeId is not equal to another.
     */
    @:op(A != B)
    public function notEquals(other:TypeId):Bool {
        return id != other.id;
    }
    
    public function hashCode():Int {
        return id;
    }
    
    public function toString():String {
        return 'TypeId($typeName: $id)';
    }
}

/**
 * Type-safe type ID wrapper that ensures only one instance per type.
 */
@:forward
abstract TypeIdOf<T>(TypeId) from TypeId to TypeId {
    public function new() {
        this = TypeId.of(T);
    }
    
    /**
     * Get the actual TypeId value.
     */
    public var value(get, never):TypeId;
    private inline function get_value():TypeId return this;
}
