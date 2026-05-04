package haxe.ecs;

import haxe.ecs.schedule.ScheduleGraph;
import haxe.ecs.schedule.SystemNode;
import haxe.ecs.schedule.SystemSets;
import haxe.ecs.schedule.node.DiGraph;
import haxe.ecs.system.System;
import haxe.ecs.world.World;

/**
 * A collection of systems, stages, and conditions that are run together.
 * 
 * Schedules are the main execution driver in ECS. They contain systems organized
 * into stages, with ordering constraints and conditions defined through SystemSets.
 */
class Schedule {
    public var label:ScheduleLabel;
    public var graph(default, null):ScheduleGraph;
    public var stages:Array<SystemSet>;
    
    private var initialized:Bool = false;
    private var executor:ScheduleExecutor;
    
    /**
     * Creates a new empty Schedule.
     */
    public function new(?label:ScheduleLabel) {
        this.label = label != null ? label : new ScheduleLabel();
        this.graph = new ScheduleGraph();
        this.stages = [];
        this.executor = new SingleThreadedExecutor();
        
        // Initialize default stages
        stages.push(ScheduleStages.First);
        stages.push(ScheduleStages.PreUpdate);
        stages.push(ScheduleStages.Update);
        stages.push(ScheduleStages.PostUpdate);
        stages.push(ScheduleStages.Last);
    }
    
    /**
     * Adds a system to this schedule.
     * @param system The system to add
     * @param set Optional SystemSet to add the system to
     * @param conditions Optional array of conditions that must be met for the system to run
     */
    public function addSystem(system:System, ?set:SystemSet, ?conditions:Array<System -> Bool>):Void {
        var node = new SystemNode(system);
        
        if (set != null) {
            graph.systems.insert(set.intern(), node);
        } else {
            // Default to Update stage
            graph.systems.insert(ScheduleStages.Update.intern(), node);
        }
        
        if (conditions != null) {
            for (cond in conditions) {
                graph.conditions.get(set.intern()).push(cast cond);
            }
        }
        
        initialized = false;
    }
    
    /**
     * Adds multiple systems to this schedule.
     * @param systems Array of systems to add
     * @param set Optional SystemSet to add the systems to
     */
    public function addSystems(systems:Array<System>, ?set:SystemSet):Void {
        for (sys in systems) {
            addSystem(sys, set);
        }
    }
    
    /**
     * Configures system ordering within this schedule.
     * @param before The system that should run first
     * @param after The system that should run second
     */
    public function configureSetOrdering(before:SystemSet, after:SystemSet):Void {
        graph.hierarchy.add_edge(before.intern(), after.intern());
    }
    
    /**
     * Sets a condition that must be met for all systems in a set to run.
     * @param set The system set
     * @param condition The condition function
     */
    public function buildCondition(set:SystemSet, condition:System -> Bool):Void {
        var conditions = graph.conditions.get(set.intern());
        if (conditions == null) {
            conditions = [];
            graph.conditions.set(set.intern(), conditions);
        }
        conditions.push(condition);
    }
    
    /**
     * Initializes the schedule by building the dependency graph.
     * @param world The world to initialize against
     */
    public function initialize(world:World):Void {
        if (initialized) return;
        
        // Build the dependency graph
        graph.initialize(world);
        
        initialized = true;
    }
    
    /**
     * Runs this schedule on the given world.
     * @param world The world to run the schedule on
     */
    public function run(world:World):Void {
        if (!initialized) {
            initialize(world);
        }
        
        executor.execute(this, world);
    }
    
    /**
     * Sets the executor to use for this schedule.
     * @param executor The schedule executor
     */
    public function setExecutor(executor:ScheduleExecutor):Void {
        this.executor = executor;
    }
    
    /**
     * Gets whether this schedule has been initialized.
     */
    public function isInitialized():Bool {
        return initialized;
    }
}

/**
 * Label trait for identifying schedules.
 */
interface ScheduleLabel {
    /**
     * Returns the unique identifier for this schedule label.
     */
    public function getId():String;
}

/**
 * Default implementation of ScheduleLabel using interning.
 */
@:keep
class ScheduleLabel implements ScheduleLabel {
    private static var counter:Int = 0;
    private var id:String;
    private var typeId:Any;
    
    public function new(?id:String) {
        this.id = id != null ? id : 'Schedule_${counter++}';
        this.typeId = Type.typeof(this);
    }
    
    public function getId():String {
        return id;
    }
    
    public function hashCode():Int {
        return id.hashCode();
    }
    
    public function equals(other:Dynamic):Bool {
        if (Std.is(other, ScheduleLabel)) {
            return id == cast(other, ScheduleLabel).getId();
        }
        return false;
    }
}

/**
 * Trait for executors that run schedules.
 */
interface ScheduleExecutor {
    /**
     * Executes the schedule on the world.
     */
    function execute(schedule:Schedule, world:World):Void;
}

/**
 * Single-threaded executor that runs systems sequentially.
 */
class SingleThreadedExecutor implements ScheduleExecutor {
    public function new() {}
    
    public function execute(schedule:Schedule, world:World):Void {
        var graph = schedule.graph;
        
        // Get topologically sorted systems
        var sorted = graph.hierarchy.topological_sort();
        
        for (sysKey in sorted) {
            var sysNode = graph.systems.get(sysKey);
            if (sysNode != null && sysNode.inner != null) {
                // Check conditions
                var conditions = graph.conditions.get(sysKey);
                var shouldRun = true;
                
                if (conditions != null) {
                    for (cond in conditions) {
                        if (!cond(sysNode.inner.system)) {
                            shouldRun = false;
                            break;
                        }
                    }
                }
                
                if (shouldRun) {
                    sysNode.inner.system.run(world);
                }
            }
        }
    }
}

/**
 * Multi-threaded executor for parallel system execution.
 */
class MultiThreadedExecutor implements ScheduleExecutor {
    public function new() {}
    
    public function execute(schedule:Schedule, world:World):Void {
        // Simplified multi-threaded execution
        // In a real implementation, this would use thread pools
        var executor = new SingleThreadedExecutor();
        executor.execute(schedule, world);
    }
}
