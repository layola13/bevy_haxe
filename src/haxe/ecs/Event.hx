package haxe.ecs;

/**
 * An Event is something that "happens" at a given moment.
 * 
 * Events can be triggered on the World, causing any Observer watching
 * for that event to run immediately.
 * 
 * Use `#[derive(Event)]` to create custom event types.
 * 
 * # Examples
 * ```
 * @:keep
 * class PlayerHit implements Event {
 *     public var player:Entity;
 *     public var damage:Float;
 *     public var source:Entity;
 *     
 *     public function new(player:Entity, damage:Float, source:Entity) {
 *         this.player = player;
 *         this.damage = damage;
 *         this.source = source;
 *     }
 * }
 * ```
 */
interface Event {
    /**
     * Returns the type ID for this event.
     */
    public function getTypeId():Any;
}

/**
 * Extension methods for Event types.
 */
class EventExtension {
    /**
     * Triggers an event on a world.
     */
    public static function trigger<T:Event>(world:World, event:T):Void {
        world.trigger(event);
    }
    
    /**
     * Triggers an event on a specific entity.
     */
    public static function triggerOn<T:EntityEvent>(world:World, entity:Entity, event:T):Void {
        world.entity(entity).trigger(event);
    }
}

/**
 * Entity-scoped event that targets a specific entity.
 */
interface EntityEvent extends Event {
    /**
     * Gets the target entity for this event.
     */
    public function getTarget():Entity;
}

/**
 * A trigger of an event, containing context about the event firing.
 */
class Trigger<T:Event> {
    /** The event that was triggered */
    public var event(default, null):T;
    
    /** The world the event was triggered in */
    public var world(default, null):World;
    
    /** Whether propagation is enabled */
    public var propagate:Bool;
    
    /** The entity this trigger is associated with */
    public var entity:Null<Entity>;
    
    public function new(event:T, world:World) {
        this.event = event;
        this.world = world;
        this.propagate = false;
    }
    
    /**
     * Gets the type of the event.
     */
    public function getTypeId():Any {
        return event.getTypeId();
    }
}

/**
 * Event iterator for efficient event processing.
 */
class EventIterator<T:Event> {
    private var events:Array<T>;
    private var index:Int = 0;
    
    public function new(events:Array<T>) {
        this.events = events;
    }
    
    /**
     * Returns true if there are more events to iterate.
     */
    public function hasNext():Bool {
        return index < events.length;
    }
    
    /**
     * Gets the next event.
     */
    public function next():T {
        return events[index++];
    }
}

/**
 * Event phase for ordering event handling.
 */
enum EventPhase {
    /** Events processed in the bubble phase (bottom-up) */
    Bubble;
    
    /** Events processed in the capture phase (top-down) */
    Capture;
    
    /** Default event processing */
    Default;
}

/**
 * Listener for events of a specific type.
 */
interface EventListener<T:Event> {
    /**
     * Called when an event is triggered.
     * @param event The triggered event
     */
    public function onEvent(event:T):Void;
}

/**
 * Macro helper for Event implementation.
 * Classes using `@:keep` and implementing Event need to also have:
 * - A static `typeId` property
 * - `getTypeId()` method
 */
class EventMacro {
    /**
     * Registers an event type in the event system.
     */
    public static function register<T:Event>(typeId:Any):Void {
        // Register with the event system for reflection
        #if !macro
        EventRegistry.register(typeId);
        #end
    }
}

/**
 * Registry for event types (used internally).
 */
class EventRegistry {
    private static var registeredTypes:Map<Int, Any> = new Map();
    
    /**
     * Registers an event type.
     */
    public static function register(typeId:Any):Void {
        var hash = Std.hashCode(typeId);
        registeredTypes.set(hash, typeId);
    }
    
    /**
     * Checks if an event type is registered.
     */
    public static function isRegistered(typeId:Any):Bool {
        return registeredTypes.exists(Std.hashCode(typeId));
    }
}

/**
 * Event priority for ordering listeners.
 */
enum EventPriority {
    Low;
    Normal;
    High;
    Critical;
}
