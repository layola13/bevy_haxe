package haxe.ecs;

/**
 * Event storage for a specific event type.
 * 
 * Events<T> stores buffered events that can be updated and read during
 * system execution. Events are automatically cleared at the end of each frame
 * unless configured otherwise.
 * 
 * # Usage
 * ```
 * // Creating an event
 * world.trigger(MyEvent { data: 42 });
 * 
 * // Reading events in a system
 * fn handleEvents(events:Events<MyEvent>, mut eventReader:EventReader<MyEvent>) {
 *     for (event in eventReader.read()) {
 *         trace('Got event: ${event.data}');
 *     }
 * }
 * ```
 */
class Events<T:Event> implements Resource {
    /** Internal event storage */
    private var events:Array<T>;
    
    /** Batching state for efficient updates */
    private var batches:Array<EventBatch<T>>;
    
    /** Last event index seen by each reader */
    private var lastReaders:Map<Int, Int>;
    
    public function new() {
        events = [];
        batches = [];
        lastReaders = new Map();
    }
    
    /**
     * Sends an event, adding it to the event buffer.
     * @param event The event to send
     */
    public function send(event:T):Void {
        events.push(event);
    }
    
    /**
     * Sends multiple events at once.
     * @param batch The batch of events to send
     */
    public function sendBatch(batch:EventBatch<T>):Void {
        for (event in batch.events) {
            events.push(event);
        }
        batches.push(batch);
    }
    
    /**
     * Updates the internal event buffer.
     * Called automatically by the event update system.
     */
    public function update():Void {
        // Clear old events if auto-clear is enabled
        if (autoClear) {
            clear();
        }
    }
    
    /**
     * Clears all buffered events.
     */
    public function clear():Void {
        events = [];
    }
    
    /**
     * Gets all events in the buffer.
     */
    public function getEvents():Array<T> {
        return events.copy();
    }
    
    /**
     * Gets events since a specific reader last read.
     * @param readerId The reader identifier
     * @return Events since last read
     */
    public function getEventsSince(readerId:Int):Array<T> {
        var lastIndex = lastReaders.get(readerId);
        if (lastIndex == null) {
            lastIndex = -1;
        }
        
        var result = [];
        for (i in lastIndex + 1...events.length) {
            result.push(events[i]);
        }
        
        lastReaders.set(readerId, events.length);
        return result;
    }
    
    /**
     * Gets the number of events in the buffer.
     */
    public function count():Int {
        return events.length;
    }
    
    /** Whether to automatically clear events after each update */
    public var autoClear:Bool = true;
    
    /**
     * Creates a default instance.
     */
    public static function createDefault():Resource {
        return new Events();
    }
}

/**
 * Batch of events for efficient batch processing.
 */
class EventBatch<T:Event> {
    public var events:Array<T>;
    public var timestamp:Float;
    
    public function new(?events:Array<T>) {
        this.events = events != null ? events : [];
        this.timestamp = 0; // Would use time system in real implementation
    }
    
    public function push(event:T):Void {
        events.push(event);
    }
    
    public function isEmpty():Bool {
        return events.length == 0;
    }
}
