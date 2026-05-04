package haxe.prelude;

/**
 * ECS (Entity Component System) module prelude.
 * Provides convenient access to ECS types and helpers.
 */
class EcsPrelude {
    public function new() {}

    /**
     * Creates an entity ID for the given index.
     */
    public static inline function entity(id:Int):Entity return {id: id};

    /**
     * Creates a component marker for the given component type.
     * @param typeName The string name of the component type
     */
    public static inline function component(typeName:String):ComponentMarker return {typeName: typeName};
}

/**
 * Entity identifier type.
 */
typedef Entity = {
    var id:Int;
}

/**
 * Component marker for type-safe component access.
 */
typedef ComponentMarker = {
    var typeName:String;
}

/**
 * System function signature.
 */
typedef SystemFn = Void -> Void;

/**
 * Query filter for component queries.
 */
typedef QueryFilter = {
    var include:Array<String>;
    var ?exclude:Array<String>;
}
