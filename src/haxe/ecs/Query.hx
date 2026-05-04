package haxe.ecs;

/**
 * Query builder for more flexible entity queries
 */
class QueryBuilder {
    private var world:World;
    private var withTypes:Array<Int> = new Array();
    private var withoutTypes:Array<Int> = new Array();
    
    public function new(world:World) {
        this.world = world;
    }
    
    /**
     * Require entity to have this component type
     */
    public function with<T:Component>(cls:Class<T>):QueryBuilder {
        withTypes.push(ComponentType.get(cls));
        return this;
    }
    
    /**
     * Require entity to NOT have this component type
     */
    public function without<T:Component>(cls:Class<T>):QueryBuilder {
        withoutTypes.push(ComponentType.get(cls));
        return this;
    }
    
    /**
     * Execute query and return matching entity IDs
     */
    public function ids():Array<Int> {
        var result:Array<Int> = [];
        for (id => components in world["entities"]) {
            var matches = true;
            
            // Check required components
            for (typeId in withTypes) {
                if (!components.exists(typeId)) {
                    matches = false;
                    break;
                }
            }
            
            // Check excluded components
            if (matches) {
                for (typeId in withoutTypes) {
                    if (components.exists(typeId)) {
                        matches = false;
                        break;
                    }
                }
            }
            
            if (matches) {
                result.push(id);
            }
        }
        return result;
    }
    
    /**
     * Execute query and return entity-entityIdMap tuples
     */
    public function entityMap<T:Component>(cls:Class<T>):Map<Int, T> {
        var result:Map<Int, T> = new Map();
        var typeId = ComponentType.get(cls);
        for (id in ids()) {
            var components:Map<Int, Dynamic> = world["entities"].get(id);
            if (components.exists(typeId)) {
                result.set(id, components.get(typeId));
            }
        }
        return result;
    }
    
    public function entityMap2<T1:Component, T2:Component>(cls1:Class<T1>, cls2:Class<T2>):Map<Int, {c1:T1, c2:T2}> {
        var result:Map<Int, {c1:T1, c2:T2}> = new Map();
        var typeId1 = ComponentType.get(cls1);
        var typeId2 = ComponentType.get(cls2);
        for (id in ids()) {
            var components:Map<Int, Dynamic> = world["entities"].get(id);
            if (components.exists(typeId1) && components.exists(typeId2)) {
                result.set(id, {c1: components.get(typeId1), c2: components.get(typeId2)});
            }
        }
        return result;
    }
}
