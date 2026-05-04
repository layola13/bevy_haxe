package haxe.ecs.schedule;

/**
 * SystemSets contains the system sets for a schedule.
 */
class SystemSets {
    private var sets:Map<InternedSystemSet, SystemSetData>;
    private var initialized:Bool;
    
    public function new() {
        sets = new Map();
        initialized = false;
    }
    
    /**
     * Inserts a system into a set.
     */
    public function insert(set:InternedSystemSet, system:SystemNode):Void {
        var data = sets.get(set);
        if (data == null) {
            data = new SystemSetData(set);
            sets.set(set, data);
        }
        data.systems.push(system);
    }
    
    /**
     * Gets a system set by its interned label.
     */
    public function get(set:InternedSystemSet):Null<SystemSetData> {
        return sets.get(set);
    }
    
    /**
     * Gets all system sets.
     */
    public function getAll():Map<InternedSystemSet, SystemSetData> {
        return sets;
    }
    
    /**
     * Gets the number of sets.
     */
    public function length():Int {
        return Lambda.count(sets);
    }
    
    /**
     * Checks if empty.
     */
    public function isEmpty():Bool {
        return length() == 0;
    }
    
    /**
     * Initializes all systems in all sets.
     */
    public function initialize(world:World):Void {
        for (data in sets) {
            for (node in data.systems) {
                if (node.inner != null) {
                    node.inner.system.initialize(world);
                }
            }
        }
        initialized = true;
    }
    
    /**
     * Checks if initialized.
     */
    public function isInitialized():Bool {
        return initialized;
    }
    
    /**
     * Iterator for sets.
     */
    public function iterator():Iterator<InternedSystemSet> {
        return sets.keys();
    }
}

/**
 * Data for a system set.
 */
class SystemSetData {
    public var set:InternedSystemSet;
    public var systems:Array<SystemNode>;
    public var conditions:Array<System -> Bool>;
    public var hierarchy:Null<HierarchyInfo>;
    
    public function new(set:InternedSystemSet) {
        this.set = set;
        this.systems = [];
        this.conditions = [];
    }
}

/**
 * Information about a node in the hierarchy.
 */
class HierarchyInfo {
    public var parent:Null<InternedSystemSet>;
    public var children:Array<InternedSystemSet>;
    
    public function new(?parent:InternedSystemSet) {
        this.parent = parent;
        this.children = [];
    }
}
