package haxe.utils;

/**
 * Utilities module for Bevy-haxe.
 * 
 * This module provides essential utility types and functions:
 * - TypeId: Type identification system
 * - HashUtils: Hash computation utilities
 * - EntityHashMap: Hash map specialized for Entity keys
 * - InternedString: String interning for efficient comparison
 * - Label: Label system for naming entities and components
 * 
 * ## Example Usage
 * 
 * ```haxe
 * import haxe.utils.*;
 * 
 * // Type identification
 * var typeId = TypeId.of<MyComponent>();
 * 
 * // Hash utilities
 * var hash = HashUtils.fnv1a("hello");
 * 
 * // Entity hash map
 * var map = new EntityHashMap<Int>();
 * map.set(new Entity(1, 0), 42);
 * 
 * // String interning
 * var interned = InternedString.intern("my_string");
 * 
 * // Labels
 * var label = Label.of("player", "entity");
 * ```
 */
class Module {
    /** The module name */
    public static var MODULE_NAME(default, never) = "haxe.utils";
    
    /** The module version */
    public static var MODULE_VERSION(default, never) = "0.1.0";
    
    /** A default/predefined "default" label */
    public static var DEFAULT_LABEL(default, never):Label = Label.fromName("default");
    
    /** An empty entity */
    public static var EMPTY_ENTITY(default, never):Entity = new Entity(0, 0);
    
    private static var _initialized:Bool = false;
    
    /**
     * Initialize the utils module.
     * Call this at application startup.
     */
    public static function init():Void {
        if (_initialized) return;
        _initialized = true;
        // Pre-intern common strings for better performance
        InternedString.intern("default");
        InternedString.intern("none");
        InternedString.intern("empty");
    }
    
    /**
     * Get module information.
     */
    public static function getModuleInfo():{name:String, version:String} {
        return {
            name: MODULE_NAME,
            version: MODULE_VERSION
        };
    }
    
    /**
     * Check if the module is initialized.
     */
    public static var isInitialized(get, never):Bool;
    private static inline function get_isInitialized():Bool return _initialized;
}

/**
 * Prelude imports for convenient access to all utils types.
 * Import this with `import haxe.utils.Module.*;` or use `haxe.prelude.Utils;`
 */
@:final
class Prelude {
    /**
     * Create a default-initialized value.
     * Convenience function equivalent to `ReflectUtil.default()`.
     */
    public static function default<T>():T {
        return null;
    }
    
    /**
     * Create an empty/predefined label.
     */
    public static function label(name:String, ?namespace:String):Label {
        return Label.of(name, namespace);
    }
    
    /**
     * Create an entity with the given id.
     */
    public static function entity(id:UInt, generation:UInt = 0):Entity {
        return new Entity(id, generation);
    }
    
    /**
     * Intern a string.
     */
    public static function intern(s:String):InternedString {
        return InternedString.intern(s);
    }
    
    /**
     * Get the TypeId for a type.
     */
    public static function typeId<T>():TypeId {
        return TypeId.of(T);
    }
    
    /**
     * Compute hash for a value.
     */
    public static function hash<T>(value:T):Int {
        return HashUtils.hashObject(value);
    }
}
