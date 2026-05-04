package haxe.ecs;

/**
    Marker interface for component types.

    Components are the data portions of the ECS pattern. Any class or struct
    that implements this interface can be attached to entities.

    Components should be pure data containers without complex behavior.
    Logic should be placed in Systems that query and operate on components.

    Example usage:
    ```haxe
    class Position implements Component {
        public var x:Float;
        public var y:Float;
        public var z:Float;

        public function new(x:Float = 0, y:Float = 0, z:Float = 0) {
            this.x = x;
            this.y = y;
            this.z = z;
        }
    }

    class Player implements Component {
        public var name:String;
        public var health:Int;

        public function new(name:String, health:Int) {
            this.name = name;
            this.health = health;
        }
    }

    // Marker component with no data
    class MainPlayer implements Component {
        public inline function new() {}
    }
    ```
**/
interface Component {
    // Component is a marker interface with no required methods.
    // The interface serves only to mark types as components for the ECS.
    // This allows type-safe queries and bundling of components.

    /**
        Returns the ComponentId for this component type.
        Subclasses can override this if they need custom behavior.
    **/
    // public function getComponentId():ComponentId; // Future extension
}

/**
    Helper class for working with component types at runtime.
    Provides type information and identification for component types.
**/
class ComponentInfo {
    /**
        The unique identifier for this component type.
    **/
    public var id(default, null):ComponentId;

    /**
        The name of the component type.
    **/
    public var typeName(default, null):String;

    /**
        Whether this component requires special memory layout.
    **/
    public var isSparse(default, null):Bool;

    public function new(id:ComponentId, typeName:String, isSparse:Bool = false) {
        this.id = id;
        this.typeName = typeName;
        this.isSparse = isSparse;
    }
}
