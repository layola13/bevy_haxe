package haxe.ecs;

/**
 * Iterator over query results.
 * Provides a way to iterate over entity query results with their components.
 * 
 * Supports iteration with automatic cleanup via dispose() method.
 */
class QueryIter {
    private var world:World;
    private var entities:Array<Int>;
    private var currentIndex:Int = 0;
    private var typeIds:Array<Int>;
    private var filters:QueryFilterState;
    
    /**
     * Internal constructor - use World.query() instead
     */
    private function new(world:World, typeIds:Array<Int>, ?filters:QueryFilterState) {
        this.world = world;
        this.typeIds = typeIds;
        this.filters = filters != null ? filters : new QueryFilterState();
        this.entities = [];
        this.currentIndex = 0;
    }
    
    /**
     * Set up the entities list by scanning the world
     */
    private function setup():Void {
        entities = [];
        var entityMap:Map<Int, Map<Int, Dynamic>> = cast world.entities;
        
        for (entityId in entityMap.keys()) {
            var components = entityMap.get(entityId);
            if (components == null) continue;
            
            if (matchesFilters(components)) {
                entities.push(entityId);
            }
        }
    }
    
    /**
     * Check if entity matches all filter conditions
     */
    private function matchesFilters(components:Map<Int, Dynamic>):Bool {
        // Check With filters
        for (withType in filters.withTypes) {
            if (!components.exists(withType)) return false;
        }
        
        // Check Without filters
        for (withoutType in filters.withoutTypes) {
            if (components.exists(withoutType)) return false;
        }
        
        return true;
    }
    
    /**
     * Get the number of matching entities
     */
    public var length(get, never):Int;
    private function get_length():Int {
        if (entities.length == 0) setup();
        return entities.length;
    }
    
    /**
     * Check if there are more elements to iterate
     */
    public function hasNext():Bool {
        if (entities.length == 0) setup();
        return currentIndex < entities.length;
    }
    
    /**
     * Get the next entity ID without fetching components
     */
    public function nextEntity():Null<Int> {
        if (entities.length == 0) setup();
        if (currentIndex >= entities.length) return null;
        return entities[currentIndex++];
    }
    
    /**
     * Reset the iterator to the beginning
     */
    public function reset():Void {
        currentIndex = 0;
    }
    
    /**
     * Clean up iterator resources
     */
    public function dispose():Void {
        entities = [];
        currentIndex = 0;
    }
    
    /**
     * Get an iterator over entity IDs
     */
    public function entityIterator():Iterator<Int> {
        if (entities.length == 0) setup();
        reset();
        return entities.iterator();
    }
    
    /**
     * Get the current entity ID
     */
    public function currentEntity():Null<Int> {
        if (currentIndex == 0 || entities.length == 0) return null;
        return entities[currentIndex - 1];
    }
    
    /**
     * Get the current index
     */
    public var index(get, never):Int;
    private function get_index():Int return currentIndex;
}

/**
 * State holder for query filters
 */
class QueryFilterState {
    public var withTypes:Array<Int> = [];
    public var withoutTypes:Array<Int> = [];
    
    public function new() {}
    
    public function addWith(typeId:Int):Void {
        withTypes.push(typeId);
    }
    
    public function addWithout(typeId:Int):Void {
        withoutTypes.push(typeId);
    }
}

/**
 * Generic iterator for Query<T> results
 */
@:generic
class QueryIter1<T0:Component> extends QueryIter {
    private var componentClass0:Class<T0>;
    
    private function new(world:World, componentClass0:Class<T0>, ?filters:QueryFilterState) {
        super(world, [ComponentType.get(componentClass0)], filters);
        this.componentClass0 = componentClass0;
    }
    
    /**
     * Get the next result as a QueryResult1
     */
    public function nextResult():Null<QueryResult1<T0>> {
        var entityId = nextEntity();
        if (entityId == null) return null;
        
        var entity = new Entity(entityId);
        var entityMap:Map<Int, Map<Int, Dynamic>> = cast world.entities;
        var components = entityMap.get(entityId);
        
        var c0:T0 = components != null ? components.get(typeIds[0]) : null;
        
        return new QueryResult1(entity, c0);
    }
    
    /**
     * Collect all results as an array
     */
    public function collect():Array<QueryResult1<T0>> {
        var results:Array<QueryResult1<T0>> = [];
        for (result in this) {
            results.push(result);
        }
        return results;
    }
    
    /**
     * Iterator interface
     */
    public function iterator():Iterator<QueryResult1<T0>> {
        if (entities.length == 0) setup();
        reset();
        return this;
    }
    
    public function hasNext():Bool return super.hasNext();
    public function next():QueryResult1<T0> return nextResult();
}

/**
 * Generic iterator for Query<T0, T1> results
 */
@:generic
class QueryIter2<T0:Component, T1:Component> extends QueryIter {
    private var componentClass0:Class<T0>;
    private var componentClass1:Class<T1>;
    
    private function new(world:World, componentClass0:Class<T0>, componentClass1:Class<T1>, ?filters:QueryFilterState) {
        super(world, [ComponentType.get(componentClass0), ComponentType.get(componentClass1)], filters);
        this.componentClass0 = componentClass0;
        this.componentClass1 = componentClass1;
    }
    
    /**
     * Get the next result as a QueryResult2
     */
    public function nextResult():Null<QueryResult2<T0, T1>> {
        var entityId = nextEntity();
        if (entityId == null) return null;
        
        var entity = new Entity(entityId);
        var entityMap:Map<Int, Map<Int, Dynamic>> = cast world.entities;
        var components = entityMap.get(entityId);
        
        var c0:T0 = components != null ? components.get(typeIds[0]) : null;
        var c1:T1 = components != null ? components.get(typeIds[1]) : null;
        
        return new QueryResult2(entity, c0, c1);
    }
    
    /**
     * Collect all results as an array
     */
    public function collect():Array<QueryResult2<T0, T1>> {
        var results:Array<QueryResult2<T0, T1>> = [];
        for (result in this) {
            results.push(result);
        }
        return results;
    }
    
    /**
     * Iterator interface
     */
    public function iterator():Iterator<QueryResult2<T0, T1>> {
        if (entities.length == 0) setup();
        reset();
        return this;
    }
    
    public function hasNext():Bool return super.hasNext();
    public function next():QueryResult2<T0, T1> return nextResult();
}

/**
 * Generic iterator for Query<T0, T1, T2> results
 */
@:generic
class QueryIter3<T0:Component, T1:Component, T2:Component> extends QueryIter {
    private var componentClass0:Class<T0>;
    private var componentClass1:Class<T1>;
    private var componentClass2:Class<T2>;
    
    private function new(world:World, componentClass0:Class<T0>, componentClass1:Class<T1>, componentClass2:Class<T2>, ?filters:QueryFilterState) {
        super(world, [ComponentType.get(componentClass0), ComponentType.get(componentClass1), ComponentType.get(componentClass2)], filters);
        this.componentClass0 = componentClass0;
        this.componentClass1 = componentClass1;
        this.componentClass2 = componentClass2;
    }
    
    /**
     * Get the next result as a QueryResult3
     */
    public function nextResult():Null<QueryResult3<T0, T1, T2>> {
        var entityId = nextEntity();
        if (entityId == null) return null;
        
        var entity = new Entity(entityId);
        var entityMap:Map<Int, Map<Int, Dynamic>> = cast world.entities;
        var components = entityMap.get(entityId);
        
        var c0:T0 = components != null ? components.get(typeIds[0]) : null;
        var c1:T1 = components != null ? components.get(typeIds[1]) : null;
        var c2:T2 = components != null ? components.get(typeIds[2]) : null;
        
        return new QueryResult3(entity, c0, c1, c2);
    }
    
    /**
     * Collect all results as an array
     */
    public function collect():Array<QueryResult3<T0, T1, T2>> {
        var results:Array<QueryResult3<T0, T1, T2>> = [];
        for (result in this) {
            results.push(result);
        }
        return results;
    }
    
    /**
     * Iterator interface
     */
    public function iterator():Iterator<QueryResult3<T0, T1, T2>> {
        if (entities.length == 0) setup();
        reset();
        return this;
    }
    
    public function hasNext():Bool return super.hasNext();
    public function next():QueryResult3<T0, T1, T2> return nextResult();
}

/**
 * Generic iterator for Query<T0, T1, T2, T3> results
 */
@:generic
class QueryIter4<T0:Component, T1:Component, T2:Component, T3:Component> extends QueryIter {
    private var componentClass0:Class<T0>;
    private var componentClass1:Class<T1>;
    private var componentClass2:Class<T2>;
    private var componentClass3:Class<T3>;
    
    private function new(world:World, componentClass0:Class<T0>, componentClass1:Class<T1>, componentClass2:Class<T2>, componentClass3:Class<T3>, ?filters:QueryFilterState) {
        super(world, [ComponentType.get(componentClass0), ComponentType.get(componentClass1), ComponentType.get(componentClass2), ComponentType.get(componentClass3)], filters);
        this.componentClass0 = componentClass0;
        this.componentClass1 = componentClass1;
        this.componentClass2 = componentClass2;
        this.componentClass3 = componentClass3;
    }
    
    /**
     * Get the next result as a QueryResult4
     */
    public function nextResult():Null<QueryResult4<T0, T1, T2, T3>> {
        var entityId = nextEntity();
        if (entityId == null) return null;
        
        var entity = new Entity(entityId);
        var entityMap:Map<Int, Map<Int, Dynamic>> = cast world.entities;
        var components = entityMap.get(entityId);
        
        var c0:T0 = components != null ? components.get(typeIds[0]) : null;
        var c1:T1 = components != null ? components.get(typeIds[1]) : null;
        var c2:T2 = components != null ? components.get(typeIds[2]) : null;
        var c3:T3 = components != null ? components.get(typeIds[3]) : null;
        
        return new QueryResult4(entity, c0, c1, c2, c3);
    }
    
    /**
     * Collect all results as an array
     */
    public function collect():Array<QueryResult4<T0, T1, T2, T3>> {
        var results:Array<QueryResult4<T0, T1, T2, T3>> = [];
        for (result in this) {
            results.push(result);
        }
        return results;
    }
    
    /**
     * Iterator interface
     */
    public function iterator():Iterator<QueryResult4<T0, T1, T2, T3>> {
        if (entities.length == 0) setup();
        reset();
        return this;
    }
    
    public function hasNext():Bool return super.hasNext();
    public function next():QueryResult4<T0, T1, T2, T3> return nextResult();
}
