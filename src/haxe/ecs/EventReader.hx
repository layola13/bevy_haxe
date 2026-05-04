package haxe.ecs;

/**
 * Reader for consuming events.
 * 
 * EventReader<T> provides a safe way to read events from systems.
 * It tracks which events have been read to prevent duplicate processing.
 * 
 * # Usage
 * ```haxe
 * function handleEventsSystem(reader:EventReader<MyEvent>) {
 *     for (event in reader.read()) {
 *         trace('Got event: ${event.data}');
 *     }
 * }
 * ```
 */
class EventReader<T:Event> {
    /** Reference to the events storage */
    private var events:Events<T>;
    
    /** Last read position in the read buffer */
    private var lastReadIndex:Int;
    
    /** Reader ID for tracking across frames */
    private var readerId:Int;
    
    /** Reference to world ticks for change detection */
    private var lastRun:Int;
    
    private static var nextReaderId:Int = 0;
    
    /**
     * Creates a new EventReader.
     * @param events The Events<T> resource to read from
     */
    public function new(events:Events<T>) {
        this.events = events;
        this.lastReadIndex = 0;
        this.readerId = nextReaderId++;
        this.lastRun = 0;
    }
    
    /**
     * Reads all unread events since the last read.
     * @return Array of unread events
     */
    public function read():Array<T> {
        var buffer = events.getReadBuffer();
        var start = lastReadIndex;
        var end = buffer.length;
        lastReadIndex = end;
        return buffer.slice(start, end);
    }
    
    /**
     * Reads events with a transform/filter function.
     * @param transform Function to transform each event
     * @return Array of transformed events
     */
    public function readInto<R>(transform:T->R):Array<R> {
        var result = [];
        var buffer = events.getReadBuffer();
        for (i in lastReadIndex...buffer.length) {
            result.push(transform(buffer[i]));
        }
        lastReadIndex = buffer.length;
        return result;
    }
    
    /**
     * Gets the number of events available to read.
     * @return Number of unread events
     */
    public inline function available():Int {
        return events.getReadBuffer().length - lastReadIndex;
    }
    
    /**
     * Checks if there are any events to read.
     * @return True if unread events exist
     */
    public inline function hasEvents():Bool {
        return lastReadIndex < events.getReadBuffer().length;
    }
    
    /**
     * Iterates over all unread events.
     * @return Iterator over unread events
     */
    public function iterator():Iterator<T> {
        var buffer = events.getReadBuffer();
        var start = lastReadIndex;
        lastReadIndex = buffer.length;
        return buffer.slice(start).iterator();
    }
    
    /**
     * Peeks at events without consuming them.
     * @param count Maximum number of events to peek
     * @return Array of events (up to count)
     */
    public function peek(?count:Int):Array<T> {
        var buffer = events.getReadBuffer();
        var from = lastReadIndex;
        var to = if (count != null) 
            Std.int(Math.min(lastReadIndex + count, buffer.length))
        else buffer.length;
        return buffer.slice(from, to);
    }
    
    /**
     * Clears the read history, making all events available again.
     */
    public function clear():Void {
        lastReadIndex = 0;
    }
    
    /**
     * Gets the reader's unique ID.
     * @return Reader ID
     */
    public inline function getReaderId():Int {
        return readerId;
    }
    
    /**
     * Updates the reader for the next frame.
     * Should be called after events.update() to reset read position.
     */
    public function updateForNextFrame():Void {
        lastReadIndex = 0;
        lastRun = events.getReadBuffer().length;
    }
    
    /**
     * Gets the last world tick when this reader ran.
     * @return Last run tick
     */
    public inline function getLastRun():Int {
        return lastRun;
    }
    
    /**
     * Sets the last run tick.
     * @param tick The tick value
     */
    public inline function setLastRun(tick:Int):Void {
        lastRun = tick;
    }
}

/**
 * Extension methods for EventReader.
 */
class EventReaderExtension {
    /**
     * Creates an EventReader from the world for a specific event type.
     */
    public static function eventReader<T:Event>(world:World, cls:Class<T>):EventReader<T> {
        var events:Events<T> = world.getResource(cls);
        if (events == null) {
            events = new Events<T>(cls);
            world.insertResource(cast events);
        }
        return new EventReader<T>(events);
    }
    
    /**
     * Reads all events of a type from the world.
     */
    public static function readEvents<T:Event>(world:World, cls:Class<T>):Array<T> {
        var events:Events<T> = world.getResource(cls);
        if (events == null) {
            return [];
        }
        return events.getReadBuffer().copy();
    }
}
