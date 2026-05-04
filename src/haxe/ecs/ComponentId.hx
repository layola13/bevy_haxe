package haxe.ecs;

/**
    A unique identifier for a component type.

    ComponentId is used internally by the ECS to identify and differentiate
    between component types. Each unique component type gets a unique ID
    that remains constant throughout the lifetime of the World.

    ComponentId values are used for:
    - Fast component lookup in storages
    - Archetype construction
    - Query filtering
    - Type-erased operations

    This is an abstract type wrapping UInt to provide type safety
    and a clean API while maintaining efficient storage.
**/
abstract ComponentId(UInt) from UInt to UInt {
    /**
        Creates a ComponentId from a raw UInt value.
    **/
    public inline function new(value:UInt) {
        this = value;
    }

    /**
        The invalid component id, used as a sentinel value.
    **/
    public static var INVALID(default, null):ComponentId = 0;

    /**
        Creates a ComponentId from a Haxe class type.
        This uses reflection to generate a stable ID based on the type name.
    **/
    @:pure
    public static function forType<T>(type:Class<T>):ComponentId {
        var typeName = Type.getClassName(type);
        return fromTypeName(typeName);
    }

    /**
        Creates a ComponentId from a type name string.
        Uses a hash function to generate a stable ID from the type name.
    **/
    @:pure
    public static function fromTypeName(typeName:String):ComponentId {
        var hash:UInt = 0;
        for (i in 0...typeName.length) {
            var charCode = typeName.charCodeAt(i);
            hash = ((hash << 5) - hash + charCode) & 0xFFFFFFFF;
        }
        // Ensure non-zero ID (0 is reserved for INVALID)
        return hash == 0 ? 1 : hash;
    }

    /**
        Returns the raw UInt value of this ComponentId.
    **/
    public inline function getValue():UInt {
        return this;
    }

    /**
        Checks if this ComponentId is valid (not INVALID).
    **/
    public inline function isValid():Bool {
        return this != 0;
    }

    /**
        Checks if this ComponentId equals INVALID.
    **/
    public inline function isInvalid():Bool {
        return this == 0;
    }

    /**
        Checks equality with another ComponentId.
    **/
    @:op(A == B) public inline function equals(other:ComponentId):Bool {
        return this == cast other;
    }

    /**
        Checks inequality with another ComponentId.
    **/
    @:op(A != B) public inline function notEquals(other:ComponentId):Bool {
        return this != cast other;
    }

    /**
        Returns a hash code for this ComponentId.
    **/
    public inline function hashCode():Int {
        return Std.int(this);
    }

    /**
        Returns a string representation of this ComponentId.
        Format: "ComponentId(X)"
    **/
    public function toString():String {
        return 'ComponentId($this)';
    }

    /**
        Returns the next sequential ComponentId.
        Used internally when registering new component types.
    **/
    public inline function next():ComponentId {
        return this + 1;
    }
}

/**
    Static utilities for ComponentId management.
    Tracks registered component types and their IDs.
**/
class ComponentIdRegistry {
    private static var nextId:ComponentId = 1; // Start at 1 (0 is INVALID)
    private static var typeToId:Map<String, ComponentId> = new Map();
    private static var idToType:Map<ComponentId, String> = new Map();

    /**
        Registers a component type and returns its ComponentId.
        If the type is already registered, returns the existing ID.
    **/
    public static function register<T>(type:Class<T>):ComponentId {
        var typeName = Type.getClassName(type);
        
        if (typeToId.exists(typeName)) {
            return typeToId.get(typeName);
        }

        var id = nextId;
        nextId = nextId.next();
        
        typeToId.set(typeName, id);
        idToType.set(id, typeName);
        
        return id;
    }

    /**
        Gets the ComponentId for a registered type.
        Returns INVALID if not registered.
    **/
    public static function getId<T>(type:Class<T>):ComponentId {
        var typeName = Type.getClassName(type);
        return typeToId.exists(typeName) ? typeToId.get(typeName) : ComponentId.INVALID;
    }

    /**
        Gets the type name for a registered ComponentId.
        Returns null if not found.
    **/
    public static function getTypeName(id:ComponentId):String {
        return idToType.exists(id) ? idToType.get(id) : null;
    }

    /**
        Resets the registry (for testing or world reset).
    **/
    public static function reset():Void {
        nextId = 1;
        typeToId.clear();
        idToType.clear();
    }

    /**
        Returns the total number of registered components.
    **/
    public static function count():Int {
        return nextId.getValue() - 1;
    }
}
