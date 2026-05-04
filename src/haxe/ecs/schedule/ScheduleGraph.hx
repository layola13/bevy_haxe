package haxe.ecs.schedule;

import haxe.ecs.system.System;
import haxe.ecs.system.FilteredAccessSet;
import haxe.ecs.schedule.node.DiGraph;
import haxe.ecs.world.World;

/**
 * Graph structure for scheduling systems.
 * 
 * Contains the dependency hierarchy and systems organized into sets.
 */
class ScheduleGraph {
    /** Hierarchy graph for set ordering */
    public var hierarchy:DiGraph;
    
    /** Dependency graph for system execution order */
    public var dependency:DiGraph;
    
    /** Systems organized by set */
    public var systems:Map<InternedSystemSet, SystemNode>;
    
    /** Conditions for each system set */
    public var conditions:Map<InternedSystemSet, Array<System -> Bool>>;
    
    /** Sets with conditions */
    public var setWithConditions:Array<InternedSystemSet>;
    
    /** Whether the graph has been initialized */
    public var initialized(default, null):Bool;
    
    public function new() {
        hierarchy = new DiGraph();
        dependency = new DiGraph();
        systems = new Map();
        conditions = new Map();
        setWithConditions = [];
        initialized = false;
    }
    
    /**
     * Initializes the schedule graph.
     * @param world The world to initialize against
     */
    public function initialize(world:World):Void {
        // Build topologically sorted order
        hierarchy.build();
        dependency.build();
        initialized = true;
    }
    
    /**
     * Gets the topological order of sets.
     */
    public function getSetOrder():Array<InternedSystemSet> {
        return hierarchy.topological_sort();
    }
    
    /**
     * Gets systems in a specific set.
     */
    public function getSystemsInSet(set:InternedSystemSet):Array<SystemNode> {
        var result = [];
        var node = systems.get(set);
        if (node != null) {
            result.push(node);
        }
        return result;
    }
    
    /**
     * Adds a condition to a system set.
     */
    public function addCondition(set:InternedSystemSet, condition:System -> Bool):Void {
        var existing = conditions.get(set);
        if (existing == null) {
            existing = [];
            conditions.set(set, existing);
        }
        existing.push(condition);
        
        if (!setWithConditions.contains(set)) {
            setWithConditions.push(set);
        }
    }
}

/**
 * System node containing a system and its access information.
 */
class SystemNode {
    public var inner:Null<SystemWithAccess>;
    
    public function new(system:System) {
        this.inner = new SystemWithAccess(system);
    }
}

/**
 * System with access information.
 */
class SystemWithAccess {
    public var system:System;
    public var access:FilteredAccessSet;
    
    public function new(system:System) {
        this.system = system;
        this.access = new FilteredAccessSet();
    }
}

/**
 * Set of filtered access patterns.
 */
class FilteredAccessSet {
    private var accesses:Array<FilteredAccess>;
    
    public function new() {
        accesses = [];
    }
    
    public function add(access:FilteredAccess):Void {
        accesses.push(access);
    }
    
    /**
     * Checks if this access set conflicts with another.
     */
    public function conflicts(other:FilteredAccessSet):Bool {
        for (a in accesses) {
            for (b in other.accesses) {
                if (a.conflicts(b)) return true;
            }
        }
        return false;
    }
}
