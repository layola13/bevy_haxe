package haxe.ecs;

/**
 * Entity identifier - a simple wrapper around an integer ID
 */
abstract Entity(Int) {
    public inline function new(id:Int) {
        this = id;
    }
    
    public var id(get, never):Int;
    private inline function get_id():Int return this;
    
    public static var NULL(get, never):Entity;
    private static inline function get_NULL():Entity return new Entity(0);
    
    @:op(A == B) public static function eq(a:Entity, b:Entity):Bool;
    @:op(A != B) public static function ne(a:Entity, b:Entity):Bool;
}

/**
 * Base interface for all components
 */
interface Component {
    var componentTypeId(get, never):Int;
}

/**
 * Component type info for runtime type checking
 */
class ComponentType {
    public var id:Int;
    public var name:String;
    
    private static var nextId:Int = 1;
    private static var typeMap:Map<String, Int> = new Map();
    
    public static function get<T:Component>(cls:Class<T>):Int {
        var name = Type.getClassName(cls);
        if (!typeMap.exists(name)) {
            typeMap.set(name, nextId++);
        }
        return typeMap.get(name);
    }
}
