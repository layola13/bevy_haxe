package haxe.ecs;

/**
 * Interface for query filters that can restrict which entities are included in query results.
 * 
 * Query filters determine which entities should be included or excluded from query results
 * based on their component composition. Common filters include:
 * - With<T>: Entity must have component T
 * - Without<T>: Entity must NOT have component T
 * - Or<Filters>: Entity matches if ANY filter in the Or passes
 * 
 * Example usage:
 * ```haxe
 * // Query entities with Position but without Player tag
 * var query = world.query([Position], [Without(Player)]);
 * ```
 */
interface QueryFilter {
    /**
     * Check if this filter is archetypal (can use archetype-level optimization).
     * Archetypal filters can skip entire archetypes if they don't match.
     */
    var isArchetypal(get, never):Bool;
    
    /**
     * Get the set of component type IDs required by this filter
     */
    function getRequiredTypes():Array<Int>;
    
    /**
     * Check if an entity matches this filter
     * @param components The entity's component map
     * @return true if the entity matches this filter
     */
    function matches(components:Map<Int, Dynamic>):Bool;
}

/**
 * Base class for filter states that need to cache type information
 */
class QueryFilterBase implements QueryFilter {
    public var isArchetypal(get, never):Bool;
    
    private inline function get_isArchetypal():Bool return true;
    
    public function getRequiredTypes():Array<Int> return [];
    
    public function matches(components:Map<Int, Dynamic>):Bool return true;
}

/**
 * Filter that requires entities to have a specific component type.
 * 
 * This is an archetypal filter that can be optimized at the archetype level.
 */
@:generic
class With<T:Component> extends QueryFilterBase {
    private var typeId:Int;
    
    public function new(?cls:Class<T>) {
        super();
        if (cls != null) {
            this.typeId = ComponentType.get(cls);
        }
    }
    
    public override function getRequiredTypes():Array<Int> {
        return [typeId];
    }
    
    public override function matches(components:Map<Int, Dynamic>):Bool {
        return components.exists(typeId);
    }
    
    /**
     * Create a With filter
     */
    public static inline function create<T:Component>(cls:Class<T>):With<T> {
        return new With<T>(cls);
    }
}

/**
 * Filter that requires entities to NOT have a specific component type.
 * 
 * This is an archetypal filter that can be optimized at the archetype level.
 */
@:generic
class Without<T:Component> extends QueryFilterBase {
    private var typeId:Int;
    
    public function new(?cls:Class<T>) {
        super();
        if (cls != null) {
            this.typeId = ComponentType.get(cls);
        }
    }
    
    public override function getRequiredTypes():Array<Int> {
        return [typeId];
    }
    
    public override function matches(components:Map<Int, Dynamic>):Bool {
        return !components.exists(typeId);
    }
    
    /**
     * Create a Without filter
     */
    public static inline function create<T:Component>(cls:Class<T>):Without<T> {
        return new Without<T>(cls);
    }
}

/**
 * Logical OR filter - entity matches if ANY of the inner filters match.
 * 
 * This is NOT an archetypal filter because OR conditions require checking
 * each entity individually.
 */
class Or<T:QueryFilter> extends QueryFilterBase {
    private var filters:Array<T>;
    
    public function new(filters:Array<T>) {
        super();
        this.filters = filters;
    }
    
    public override var isArchetypal(get, never):Bool;
    private inline function get_isArchetypal():Bool return false;
    
    public override function getRequiredTypes():Array<Int> {
        var types:Array<Int> = [];
        for (filter in filters) {
            for (typeId in filter.getRequiredTypes()) {
                if (!types.contains(typeId)) {
                    types.push(typeId);
                }
            }
        }
        return types;
    }
    
    public override function matches(components:Map<Int, Dynamic>):Bool {
        for (filter in filters) {
            if (filter.matches(components)) return true;
        }
        return false;
    }
    
    /**
     * Create an Or filter from multiple filters
     */
    @:generic
    public static function create<T1:QueryFilter, T2:QueryFilter>(f1:T1, f2:T2):Or<QueryFilter> {
        return new Or<QueryFilter>([f1, f2]);
    }
    
    @:generic
    public static function create3<T1:QueryFilter, T2:QueryFilter, T3:QueryFilter>(f1:T1, f2:T2, f3:T3):Or<QueryFilter> {
        return new Or<QueryFilter>([f1, f2, f3]);
    }
    
    @:generic
    public static function create4<T1:QueryFilter, T2:QueryFilter, T3:QueryFilter, T4:QueryFilter>(f1:T1, f2:T2, f3:T3, f4:T4):Or<QueryFilter> {
        return new Or<QueryFilter>([f1, f2, f3, f4]);
    }
}

/**
 * Helper class for building filter combinations programmatically
 */
class QueryFilterBuilder {
    private var filters:Array<QueryFilter> = [];
    
    public function new() {}
    
    /**
     * Add a With filter
     */
    @:generic
    public function with<T:Component>(cls:Class<T>):QueryFilterBuilder {
        filters.push(new With<T>(cls));
        return this;
    }
    
    /**
     * Add a Without filter
     */
    @:generic
    public function without<T:Component>(cls:Class<T>):QueryFilterBuilder {
        filters.push(new Without<T>(cls));
        return this;
    }
    
    /**
     * Add a custom filter
     */
    public function add(filter:QueryFilter):QueryFilterBuilder {
        filters.push(filter);
        return this;
    }
    
    /**
     * Build the final filter (And of all filters)
     */
    public function build():QueryFilter {
        if (filters.length == 0) {
            return new EmptyFilter();
        }
        if (filters.length == 1) {
            return filters[0];
        }
        return new AndFilter(filters.copy());
    }
    
    /**
     * Get all raw filters
     */
    public function getFilters():Array<QueryFilter> {
        return filters.copy();
    }
}

/**
 * Empty filter that matches all entities
 */
class EmptyFilter extends QueryFilterBase {
    public function new() super();
}

/**
 * AND filter - entity matches if ALL of the inner filters match
 */
class AndFilter extends QueryFilterBase {
    private var filters:Array<QueryFilter>;
    
    public function new(filters:Array<QueryFilter>) {
        super();
        this.filters = filters;
    }
    
    public override function matches(components:Map<Int, Dynamic>):Bool {
        for (filter in filters) {
            if (!filter.matches(components)) return false;
        }
        return true;
    }
}
