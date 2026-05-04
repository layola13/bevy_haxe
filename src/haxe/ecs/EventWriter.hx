package haxe.ecs;

/**
 * Writer for sending events.
 * 
 * EventWriter<T> provides a safe way to send events from systems.
 * It wraps access to the Events<T> resource to prevent direct mutation.
 * 
 * # Usage
 * ```haxe
 * function sendEventSystem(mut writer:EventWriter<MyEvent>) {
 *     writer.send({ data: 42 });  // Use anonymous struct or create event instance
 * }
 * ```
 */
class EventWriter<T:Event> {
    /** Reference to the events storage */
    private var events:Events<T>;
    
    /**
     * Creates a new EventWriter.
     * @param events The Events<T> resource to write to
     */
    public function new(events:Events<T>) {
        this.events = events;
    }
    
    /**
     * Sends a single event.
     * @param event The event to send
     */
    public inline function send(event:T):Void {
        events.send(event);
    }
    
    /**
     * Sends multiple events as a batch.
     * @param batch The events to send
     */
    public inline function sendBatch(batch:EventBatch<T>):Void {
        events.sendBatch(batch.events);
    }
    
    /**
     * Sends an anonymous object as an event.
     * @param data The event data
     */
    public inline function sendData(data:Dynamic):Void {
        var event:T = cast data;
        events.send(event);
    }
    
    /**
     * Gets the current number of events in the write buffer.
     * @return Number of buffered events
     */
    public inline function getBufferCount():Int {
        return events.getWriteBuffer().length;
    }
}

/**
 * Extension methods for EventWriter.
 */
class EventWriterExtension {
    /**
     * Creates an EventWriter from the world for a specific event type.
     */
    public static function eventWriter<T:Event>(world:World, cls:Class<T>):EventWriter<T> {
        var events = world.getResource(cls);
        if (events == null) {
            events = new Events<T>(cls);
            world.insertResource(cast events);
        }
        return new EventWriter<T>(events);
    }
    
    /**
     * Sends an event directly from the world.
     */
    public static function sendEvent<T:Event>(world:World, event:T):Void {
        var cls = Type.getClass(event);
        var events:Events<T> = world.getResource(cls);
        if (events == null) {
            events = new Events<T>(cls);
            world.insertResource(cast events);
        }
        events.send(event);
    }
}
