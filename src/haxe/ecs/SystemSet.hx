package haxe.ecs;

import haxe.ecs.schedule.ScheduleGraph;

/**
 * A SystemSet is a labeled group of systems that can be configured together.
 * 
 * SystemSets allow you to:
 * - Group related systems together
 * - Define ordering constraints between groups
 * - Apply conditions to all systems in the group
 * - Configure how systems in the set are executed
 */
interface SystemSet {
    /**
     * Returns the interned label for this system set.
     */
    public function intern():InternedSystemSet;
    
    /**
     * Returns the display name of this system set.
     */
    public function name():String;
    
    /**
     * Returns default system sets for a system.
     */
    // public function defaultSystemSets():Array<InternedSystemSet>;
}

/**
 * A strongly-typed system set label.
 * 
 * Use `#[derive(SystemSet)]` to create custom system set types.
 */
interface SystemSetLabel {
    /**
     * Returns the unique type ID for this system set.
     */
    public function getTypeId():Any;
}

/**
 * Interned system set for fast comparisons.
 */
@:keep
class InternedSystemSet {
    public var id(default, null):Int;
    public var typeId(default, null):Any;
    public var name:String;
    
    private static var counter:Int = 0;
    private static var cache:Map<Int, InternedSystemSet> = new Map();
    
    private function new(id:Int, typeId:Any, name:String) {
        this.id = id;
        this.typeId = typeId;
        this.name = name;
    }
    
    /**
     * Creates an interned system set from a label.
     */
    public static function fromLabel<T:SystemSetLabel>(label:T):InternedSystemSet {
        var typeId = label.getTypeId();
        var hash = Std.hashCode(cast typeId);
        
        var existing = cache.get(hash);
        if (existing != null) {
            return existing;
        }
        
        var interned = new InternedSystemSet(counter++, typeId, Type.getClassName(Type.getClass(label)));
        cache.set(hash, interned);
        return interned;
    }
    
    public function hashCode():Int {
        return id;
    }
    
    public function equals(other:Dynamic):Bool {
        if (Std.is(other, InternedSystemSet)) {
            return id == cast(other, InternedSystemSet).id;
        }
        return false;
    }
    
    public function toString():String {
        return 'SystemSet($name)';
    }
}

/**
 * Common system sets that are built into Bevy.
 */
class SystemSets {
    /** Base set for all systems */
    public static var BaseSystemSet(default, never):InternedSystemSet = 
        InternedSystemSet.fromLabel(Base.label);
    
    /** Systems that run in the update stage */
    public static var UpdateSystemSet(default, never):InternedSystemSet = 
        InternedSystemSet.fromLabel(Update.label);
}

/**
 * Base system set label.
 */
@:keep
class Base implements SystemSetLabel {
    public static var label(default, never):Base = new Base();
    
    private function new() {}
    
    public function getTypeId():Any {
        return Type.typeof(this);
    }
}

/**
 * Update system set label.
 */
@:keep  
class Update implements SystemSetLabel {
    public static var label(default, never):Update = new Update();
    
    private function new() {}
    
    public function getTypeId():Any {
        return Type.typeof(this);
    }
}

/**
 * Defines scheduling configuration for a system set.
 */
class SystemSetConfig {
    public var set:InternedSystemSet;
    public var conditions:Array<System -> Bool>;
    public var shouldRun:MaybeInit<Bool>;
    
    public function new(set:InternedSystemSet) {
        this.set = set;
        this.conditions = [];
        this.shouldRun = MaybeInit.NotInitialized;
    }
    
    /**
     * Adds a condition that all systems in this set must pass.
     */
    public function before(c:Condition):SystemSetConfig {
        conditions.push(c.run);
        return this;
    }
    
    /**
     * Specifies this set should run after another set.
     */
    public function runsAfter(other:InternedSystemSet):SystemSetConfig {
        return this;
    }
    
    /**
     * Specifies this set should run before another set.
     */
    public function runsBefore(other:InternedSystemSet):SystemSetConfig {
        return this;
    }
}

/**
 * A condition that can be evaluated for system execution.
 */
interface Condition {
    /**
     * The function that evaluates this condition.
     */
    public var run(get, never):System -> Bool;
    
    /**
     * Whether this condition depends on system state.
     */
    public var dependsOn(get, never):Bool;
}

/**
 * Condition that wraps a simple boolean function.
 */
class SimpleCondition implements Condition {
    private var fn:() -> Bool;
    
    public function new(fn:() -> Bool) {
        this.fn = fn;
    }
    
    public function get_run():System -> Bool {
        var f = fn;
        return function(sys:System):Bool {
            return f();
        }
    }
    
    public function get_dependsOn():Bool {
        return false;
    }
}

/**
 * Condition that checks resource state.
 */
class ResourceCondition<T:Resource> implements Condition {
    private var exists:Bool;
    
    public function new(exists:Bool = true) {
        this.exists = exists;
    }
    
    public function get_run():System -> Bool {
        var checkExists = exists;
        return function(sys:System):Bool {
            // Simplified - would need World access in real implementation
            return checkExists;
        }
    }
    
    public function get_dependsOn():Bool {
        return true;
    }
}

/**
 * MaybeInit type for optional initialization state.
 */
enum MaybeInit<T> {
    NotInitialized;
    Initializing;
    Initialized(value:T);
}
