package haxe.ecs;

/**
 * Change detection types for tracking component/resource mutations.
 * 
 * These types wrap values and track when they were last changed,
 * enabling systems to detect modifications made by other systems.
 */

/**
 * The minimum number of world tick increments between tick scans.
 * 
 * Change ticks can only be scanned when systems aren't running.
 * (518,400,000 = 1000 ticks per frame * 144 frames per second * 3600 seconds per hour)
 */
final CHECK_TICK_THRESHOLD:Int = 518400000;

/**
 * The maximum change tick difference that won't overflow before the next scan.
 * Changes stop being detected once they become this old.
 */
final MAX_CHANGE_AGE:Int = 0xFFFFFFFF - (2 * CHECK_TICK_THRESHOLD - 1);

/**
 * A value that tracks when a system ran relative to other systems.
 * This is used to power change detection.
 * 
 * A system that hasn't been run yet has a Tick of 0.
 */
abstract Tick(Int) {
    /** Maximum relative age for a change tick */
    public static var MAX(default, never):Tick = new Tick(MAX_CHANGE_AGE);
    
    public inline function new(tick:Int) {
        this = tick;
    }
    
    /**
     * Gets the value of this tick.
     */
    public inline function get():Int {
        return this;
    }
    
    /**
     * Sets the value of this tick.
     */
    public inline function set(value:Int):Void {
        this = value;
    }
    
    /**
     * Returns true if this tick occurred since the last run.
     * Handles wraparound correctly.
     */
    public function isNewerThan(lastRun:Tick, thisRun:Tick):Bool {
        // Handle wraparound using difference comparison
        var selfTick = this;
        var lastTick = lastRun.get();
        var currentTick = thisRun.get();
        
        // Calculate age considering wraparound
        var age = currentTick - selfTick;
        var lastAge = currentTick - lastTick;
        
        // If age is smaller than lastAge, tick is newer
        return age < lastAge;
    }
    
    /**
     * Checks if this tick is older than another tick.
     */
    public function isOlderThan(other:Tick):Bool {
        return this < other.get();
    }
    
    /**
     * Returns the ticks since this tick.
     */
    public function ticksSince(currentTick:Tick):Int {
        return currentTick.get() - this;
    }
    
    @:op(A == B)
    static inline function eq(a:Tick, b:Tick):Bool {
        return a.get() == b.get();
    }
    
    @:op(A != B)
    static inline function ne(a:Tick, b:Tick):Bool {
        return a.get() != b.get();
    }
    
    @:op(A < B)
    static inline function lt(a:Tick, b:Tick):Bool {
        return a.get() < b.get();
    }
    
    @:op(A <= B)
    static inline function lte(a:Tick, b:Tick):Bool {
        return a.get() <= b.get();
    }
    
    @:op(A > B)
    static inline function gt(a:Tick, b:Tick):Bool {
        return a.get() > b.get();
    }
    
    @:op(A >= B)
    static inline function gte(a:Tick, b:Tick):Bool {
        return a.get() >= b.get();
    }
}

/**
 * Ticks for a component, tracking when it was added and changed.
 */
class ComponentTicks {
    /** When the component was added */
    public var added:Tick;
    
    /** When the component was last changed */
    public var changed:Tick;
    
    public function new(added:Tick, changed:Tick) {
        this.added = added;
        this.changed = changed;
    }
    
    /**
     * Creates a new instance with the same tick for added and changed.
     */
    public static function newWithTick(tick:Tick):ComponentTicks {
        return new ComponentTicks(tick, tick);
    }
    
    /**
     * Returns true if the component was added since the last run.
     */
    public function isAddedSince(lastRun:Tick, thisRun:Tick):Bool {
        return added.isNewerThan(lastRun, thisRun);
    }
    
    /**
     * Returns true if the component was added or changed since the last run.
     */
    public function isChangedSince(lastRun:Tick, thisRun:Tick):Bool {
        return changed.isNewerThan(lastRun, thisRun);
    }
}

/**
 * Mutable ticks for a component with change tracking.
 */
class ComponentTicksMut extends ComponentTicks {
    /** The entity/system that last changed this component */
    public var changedBy:String;
    
    /** Last tick when the system accessing this ran */
    public var lastRun:Tick;
    
    /** Current tick */
    public var thisRun:Tick;
    
    public function new(added:Tick, changed:Tick, ?changedBy:String, ?lastRun:Tick, ?thisRun:Tick) {
        super(added, changed);
        this.changedBy = changedBy != null ? changedBy : "";
        this.lastRun = lastRun != null ? lastRun : new Tick(0);
        this.thisRun = thisRun != null ? thisRun : new Tick(0);
    }
    
    /**
     * Sets the changed tick to the current run.
     */
    public inline function setChanged():Void {
        changed = thisRun;
    }
}

/**
 * Reference to a value that can detect changes.
 * 
 * Ref<T> provides read-only access to a value while tracking
 * when it was last changed. This enables change detection in systems.
 * 
 * # Usage
 * ```haxe
 * function system(query:Query<Ref<MyComponent>>) {
 *     for (ref in query) {
 *         if (ref.isChanged()) {
 *             trace('Component changed!');
 *         }
 *         trace('Value: ${ref.value}');
 *     }
 * }
 * ```
 */
class Ref<T> {
    /** The wrapped value */
    public var value:T;
    
    /** Ticks for change detection */
    public var ticks:ComponentTicks;
    
    /** Last tick when the system accessing this ran */
    public var lastRun:Tick;
    
    /** Current tick */
    public var thisRun:Tick;
    
    /**
     * Creates a new Ref.
     */
    public function new(value:T, ticks:ComponentTicks, lastRun:Tick, thisRun:Tick) {
        this.value = value;
        this.ticks = ticks;
        this.lastRun = lastRun;
        this.thisRun = thisRun;
    }
    
    /**
     * Returns true if this value was added after the system last ran.
     */
    public inline function isAdded():Bool {
        return ticks.isAddedSince(lastRun, thisRun);
    }
    
    /**
     * Returns true if this value was added or changed since the system last ran.
     */
    public inline function isChanged():Bool {
        return ticks.isChangedSince(lastRun, thisRun);
    }
    
    /**
     * Returns true if this value was added after the other tick.
     */
    public inline function isAddedAfter(other:Tick):Bool {
        return ticks.added.isNewerThan(other, thisRun);
    }
    
    /**
     * Returns true if this value was added or changed after the other tick.
     */
    public inline function isChangedAfter(other:Tick):Bool {
        return ticks.changed.isNewerThan(other, thisRun);
    }
    
    /**
     * Gets the change tick of the wrapped value.
     */
    public inline function getChangeTick():Tick {
        return ticks.changed;
    }
    
    /**
     * Gets the added tick of the wrapped value.
     */
    public inline function getAddedTick():Tick {
        return ticks.added;
    }
    
    /**
     * Creates a new Ref with a reborrowed lifetime.
     */
    public function reborrow():Ref<T> {
        return new Ref<T>(value, ticks, thisRun, thisRun);
    }
    
    /**
     * Maps the value to a different type without triggering change detection.
     */
    public function map<U>(f:T->U):Ref<U> {
        return new Ref<U>(f(value), ticks, lastRun, thisRun);
    }
}

/**
 * Mutable reference to a value that can detect and propagate changes.
 * 
 * Mut<T> provides mutable access to a value, and automatically
 * updates the change tick when dereferenced mutably.
 * 
 * # Usage
 * ```haxe
 * function system(mut query:Query<Mut<MyComponent>>) {
 *     for (comp in query) {
 *         comp.value.x += 1;  // Automatically marks as changed
 *     }
 * }
 * ```
 */
class Mut<T> extends Ref<T> {
    /** Mutable version of ticks */
    public var mutableTicks:ComponentTicksMut;
    
    /**
     * Creates a new Mut.
     */
    public function new(value:T, ticks:ComponentTicksMut, lastRun:Tick, thisRun:Tick) {
        super(value, ticks, lastRun, thisRun);
        this.mutableTicks = ticks;
    }
    
    /**
     * Sets the change tick to mark the value as changed.
     */
    public inline function setChanged():Void {
        mutableTicks.setChanged();
    }
    
    /**
     * Creates a new Mut with a reborrowed lifetime.
     */
    public function reborrow():Mut<T> {
        var newTicks = new ComponentTicksMut(
            mutableTicks.added,
            thisRun,  // Update changed to this run
            mutableTicks.changedBy,
            lastRun,
            thisRun
        );
        return new Mut<T>(value, newTicks, lastRun, thisRun);
    }
    
    /**
     * Maps the value to a different type without triggering change detection.
     */
    public function mapUnchanged<U>(f:T->U):Mut<U> {
        var newTicks = new ComponentTicksMut(
            mutableTicks.added,
            mutableTicks.changed,
            mutableTicks.changedBy,
            lastRun,
            thisRun
        );
        return new Mut<U>(f(value), newTicks, lastRun, thisRun);
    }
    
    /**
     * Maps the value to a different type and marks as changed.
     */
    public function map<U>(f:T->U):Mut<U> {
        var newTicks = new ComponentTicksMut(
            mutableTicks.added,
            thisRun,  // Mark as changed
            mutableTicks.changedBy,
            lastRun,
            thisRun
        );
        return new Mut<U>(f(value), newTicks, lastRun, thisRun);
    }
    
    /**
     * Gets the last system tick that accessed this value.
     */
    public inline function getLastRunTick():Tick {
        return mutableTicks.lastRun;
    }
    
    /**
     * Gets the current system tick.
     */
    public inline function getThisRunTick():Tick {
        return mutableTicks.thisRun;
    }
}

/**
 * Trait-like interface for types that can detect changes.
 */
interface DetectChanges {
    /**
     * Returns true if this value was added after the system last ran.
     */
    function isAdded():Bool;
    
    /**
     * Returns true if this value was added or changed since the system last ran.
     */
    function isChanged():Bool;
    
    /**
     * Returns true if this value was added after the other tick.
     */
    function isAddedAfter(other:Tick):Bool;
    
    /**
     * Returns true if this value was added or changed after the other tick.
     */
    function isChangedAfter(other:Tick):Bool;
}

/**
 * Trait-like interface for types that can detect and propagate changes.
 */
interface DetectChangesMut extends DetectChanges {
    /**
     * Marks the value as changed.
     */
    function setChanged():Void;
}

/**
 * Extension methods for DetectChanges types.
 */
class DetectChangesExtension {
    /**
     * Returns true if the value was just added (not changed before).
     */
    public static function isJustAdded<T:DetectChanges>(value:T):Bool {
        return value.isAdded() && !value.isChanged();
    }
    
    /**
     * Filters an array to only changed items.
     */
    public static function filterChanged<T:{value:Dynamic, isChanged:Void->Bool}>(items:Array<T>):Array<T> {
        return items.filter(item -> item.isChanged());
    }
}
