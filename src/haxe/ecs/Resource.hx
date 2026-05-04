package haxe.ecs;

/**
 * Marker trait for resources that can be stored in the World.
 * 
 * Resources are unique, singleton-like data types that can be accessed
 * from systems and stored in the World.
 * 
 * Use `#[derive(Resource)]` to automatically implement this interface.
 * 
 * # Examples
 * ```
 * @:keep
 * class GameTime implements Resource {
 *     public var deltaTime:Float;
 *     public var elapsed:Float;
 *     
 *     public function new() {
 *         deltaTime = 0;
 *         elapsed = 0;
 *     }
 * }
 * 
 * // In a system:
 * fn updateTime(time:Res<GameTime>) {
 *     trace('Elapsed: ${time.elapsed}');
 * }
 * ```
 */
interface Resource {
    /**
     * Creates a default instance of this resource.
     */
    public static function createDefault():Resource;
}

/**
 * Extension methods for Resource types.
 */
class ResourceExtension {
    /**
     * Checks if a resource type has been initialized in the world.
     */
    public static function exists<T:Resource>(world:World, typeId:Any):Bool {
        return world.containsResource(typeId);
    }
    
    /**
     * Gets a resource from the world, or creates it if it doesn't exist.
     */
    public static function getOrInit<T:Resource>(world:World):T {
        var resource = world.getResource(Type.typeof(T));
        if (resource == null) {
            resource = T.createDefault();
            world.insertResource(cast resource);
        }
        return cast resource;
    }
}

/**
 * Marker component used internally to identify resource entities.
 */
@:keep
class IsResource implements Component {
    public var resourceTypeId:Any;
    
    public function new(typeId:Any) {
        this.resourceTypeId = typeId;
    }
}
