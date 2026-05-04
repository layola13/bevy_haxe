# Bevy ECS Event System Implementation Plan

## 1. Overview

This plan outlines the improvements to the bevy_ecs event system in Haxe, following the Rust implementation in `/home/vscode/projects/bevy/crates/bevy_ecs/src/event/mod.rs`.

### Goals
- Implement proper double-buffered event storage (like Rust's `Messages<E>`)
- Add batch writing support with `write_batch()`
- Add event iteration with cursor-based reading
- Add `Events` resource management and automatic cleanup
- Add event registry for type-based event registration

### Success Criteria
- `Event` interface properly marked
- `Events<T>` implements double-buffered storage
- `EventWriter<T>` supports single and batch writing
- `EventReader<T>` supports iteration access
- Tests pass for all event operations

## 2. Prerequisites

- Haxe 4.x or later
- Existing ECS framework in `/home/vscode/projects/bevy_haxe/src/haxe/ecs/`
- Resource system already implemented

## 3. Implementation Steps

### Step 1: Update Event.hx
**Files to modify:** `/home/vscode/projects/bevy_haxe/src/haxe/ecs/Event.hx`

**Changes:**
- Simplify the `Event` interface (keep `getTypeId()`)
- Add marker interface for batching support
- Keep `EntityEvent` extending `Event`
- Add `EventBatch<T>` class for batch operations
- Add `EventId<T>` for tracking individual events

**Key Code:**
```haxe
interface Event {
    public function getTypeId():Any;
}

interface EntityEvent extends Event {
    public function getTarget():Entity;
}

class EventBatch<T:Event> {
    public var events:Array<T>;
    public var ids:Array<EventId<T>>;
    
    public function new(events:Array<T>) {
        this.events = events;
        this.ids = [];
    }
}

class EventId<T:Event> {
    public var id:Int;
    public var event:T;
    
    public function new(id:Int, event:T) {
        this.id = id;
        this.event = event;
    }
}
```

### Step 2: Create Events.hx with Double Buffering
**Files to modify/create:** `/home/vscode/projects/bevy_haxe/src/haxe/ecs/Events.hx`

**Changes:**
- Implement dual buffer storage (A and B buffers)
- Add `EventsA` and `EventsB` swap mechanism
- Add `write()` for single event
- Add `writeBatch()` for multiple events
- Add `update()` to swap buffers
- Add `updateDrain()` to clear old events
- Add `clear()` method
- Add `getCursor()` for creating readers
- Add `len()` for event count

**Key Code:**
```haxe
class Events<T:Event> implements Resource {
    private var bufferA:Array<T>;
    private var bufferB:Array<T>;
    private var currentBuffer:Int;  // 0 = A, 1 = B
    private var writeIndex:Int;
    private var readerCount:Int;
    
    public function new() {
        bufferA = [];
        bufferB = [];
        currentBuffer = 0;
        writeIndex = 0;
        readerCount = 0;
    }
    
    /** Get the current write buffer */
    private function getWriteBuffer():Array<T> {
        return if (currentBuffer == 0) bufferA else bufferB;
    }
    
    /** Get the current read buffer */
    private function getReadBuffer():Array<T> {
        return if (currentBuffer == 0) bufferB else bufferA;
    }
    
    /** Write a single event */
    public function write(event:T):EventId<T> {
        var id = writeIndex++;
        getWriteBuffer().push(event);
        return new EventId(id, event);
    }
    
    /** Write multiple events as a batch */
    public function writeBatch(events:Array<T>):Iterator<EventId<T>> {
        var ids:Array<EventId<T>> = [];
        for (event in events) {
            var id = writeIndex++;
            getWriteBuffer().push(event);
            ids.push(new EventId(id, event));
        }
        return ids.iterator();
    }
    
    /** Swap read/write buffers */
    public function update():Void {
        currentBuffer = 1 - currentBuffer;
    }
    
    /** Swap buffers and return old events */
    public function updateDrain():Array<T> {
        currentBuffer = 1 - currentBuffer;
        var oldBuffer = getWriteBuffer();
        var events = oldBuffer.copy();
        oldBuffer.resize(0);  // Clear in-place
        return events;
    }
    
    /** Clear all events */
    public function clear():Void {
        bufferA.resize(0);
        bufferB.resize(0);
    }
    
    /** Get number of unread events for a reader */
    public function len(readerIndex:Int):Int {
        return getReadBuffer().length;
    }
}
```

### Step 3: Update EventWriter.hx
**Files to modify:** `/home/vscode/projects/bevy_haxe/src/haxe/ecs/EventWriter.hx`

**Changes:**
- Add `write()` method (alias for `send`)
- Add `writeBatch()` for batch operations returning event IDs
- Add extension method `eventWriter()` for easy creation
- Keep backward compatibility with `send()` method

**Key Code:**
```haxe
class EventWriter<T:Event> {
    private var events:Events<T>;
    
    public function new(events:Events<T>) {
        this.events = events;
    }
    
    /** Write a single event and return its ID */
    public function write(event:T):EventId<T> {
        return events.write(event);
    }
    
    /** Write multiple events and return their IDs */
    public function writeBatch(batch:EventBatch<T>):Iterator<EventId<T>> {
        return events.writeBatch(batch.events);
    }
    
    /** Send an event (alias for write) */
    public function send(event:T):Void {
        events.write(event);
    }
    
    /** Send multiple events as a batch */
    public function sendBatch(batch:EventBatch<T>):Void {
        events.writeBatch(batch.events);
    }
}
```

### Step 4: Update EventReader.hx
**Files to modify:** `/home/vscode/projects/bevy_haxe/src/haxe/ecs/EventReader.hx`

**Changes:**
- Rename `read()` to iterate properly
- Add `read()` returning an `Iterator<T>`
- Add `iter()` for Haxe iterator support
- Add `isEmpty()` check
- Add `len()` for unread count
- Add `update()` for cursor advancement after events.update()

**Key Code:**
```haxe
class EventReader<T:Event> {
    private var events:Events<T>;
    private var cursor:Int;
    private var readerId:Int;
    
    private static var nextReaderId:Int = 0;
    
    public function new(events:Events<T>) {
        this.events = events;
        this.cursor = events.len(this);
        this.readerId = nextReaderId++;
    }
    
    /** Get iterator over unread events */
    public function iter():Iterator<T> {
        var buffer = events.getReadBuffer();
        var start = cursor;
        return {
            cursor: start,
            hasNext: function() return cursor < buffer.length,
            next: function() return buffer[cursor++]
        };
    }
    
    /** Read all unread events into an array */
    public function read():Array<T> {
        var buffer = events.getReadBuffer();
        var result = buffer.slice(cursor);
        cursor = buffer.length;
        return result;
    }
    
    /** Check if there are unread events */
    public function isEmpty():Bool {
        return cursor >= events.len(readerId);
    }
    
    /** Get number of unread events */
    public function len():Int {
        return events.len(readerId) - cursor;
    }
    
    /** Update cursor after events.update() */
    public function update():Void {
        var buffer = events.getReadBuffer();
        if (cursor > buffer.length) {
            cursor = 0;
        }
    }
}
```

### Step 5: Create EventCursor.hx (Optional helper)
**Files to create:** `/home/vscode/projects/bevy_haxe/src/haxe/ecs/EventCursor.hx`

**Purpose:** Separate cursor logic from reader for flexibility

**Key Code:**
```haxe
class EventCursor<T:Event> {
    public var index:Int;
    
    public function new(index:Int = 0) {
        this.index = index;
    }
    
    /** Create a new cursor starting at current read position */
    public function read(events:Events<T>):Iterator<T> {
        var buffer = events.getReadBuffer();
        var start = index;
        return {
            index: start,
            hasNext: function() return this.index < buffer.length,
            next: function() return buffer[this.index++]
        };
    }
    
    /** Clone the cursor */
    public function clone():EventCursor<T> {
        return new EventCursor(index);
    }
}
```

## 4. File Changes Summary

| File | Action | Description |
|------|--------|-------------|
| `/home/vscode/projects/bevy_haxe/src/haxe/ecs/Event.hx` | Modified | Add EventId, EventBatch, simplify interfaces |
| `/home/vscode/projects/bevy_haxe/src/haxe/ecs/Events.hx` | Modified | Implement double-buffering, add cursor support |
| `/home/vscode/projects/bevy_haxe/src/haxe/ecs/EventWriter.hx` | Modified | Add write/writeBatch methods |
| `/home/vscode/projects/bevy_haxe/src/haxe/ecs/EventReader.hx` | Modified | Add iter(), update(), improve cursor tracking |
| `/home/vscode/projects/bevy_haxe/src/haxe/ecs/EventCursor.hx` | Created (optional) | Cursor helper class |

## 5. Testing Strategy

### Unit Tests
1. **Event Creation Test**
   - Create custom event implementing Event interface
   - Verify getTypeId() returns correct type

2. **Events Write Test**
   - Write single event and verify it's in buffer
   - Write multiple events and verify all are stored

3. **Events Double Buffer Test**
   - Write events, call update(), verify buffer swap
   - Verify old events are in read buffer after swap

4. **EventWriter Test**
   - Create writer, write events, verify they're in storage
   - Test batch writing with writeBatch()

5. **EventReader Test**
   - Create reader, verify it starts at correct position
   - Read events, verify cursor advances
   - Test iteration with for...in loop

6. **Buffer Swap Test**
   - Write events, update(), write more, update()
   - Verify proper event ordering

### Manual Testing Steps
1. Compile with `haxe build.hxml`
2. Run with `haxe --run Main`
3. Check for compilation errors
4. Verify event system behavior with test cases

## 6. Rollback Plan

### Revert Individual Files
To revert a specific file to its original state:
1. Copy the original file from git history
2. Restore with `git checkout <file>`

### Full Rollback
If completely rolling back:
1. `git checkout HEAD -- src/haxe/ecs/Event.hx src/haxe/ecs/Events.hx src/haxe/ecs/EventWriter.hx src/haxe/ecs/EventReader.hx`
2. The event system will revert to the previous implementation

### Data Migration
No data migration needed - events are transient by nature and cleared each frame.

## 7. Estimated Effort

| Component | Complexity | Time Estimate |
|-----------|------------|---------------|
| Event.hx updates | Low | 15-20 minutes |
| Events.hx double-buffering | Medium-High | 45-60 minutes |
| EventWriter.hx | Low | 10-15 minutes |
| EventReader.hx | Medium | 20-30 minutes |
| Tests | Medium | 30-45 minutes |
| **Total** | **Medium** | **2-3 hours** |

## 8. Implementation Order

1. Update `Event.hx` - Add supporting classes first
2. Update `Events.hx` - Core double-buffering implementation
3. Update `EventWriter.hx` - Match new Events API
4. Update `EventReader.hx` - Match new Events API with iteration
5. Add tests and verify behavior
