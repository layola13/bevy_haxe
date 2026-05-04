package haxe.ecs;

/**
 * Interface for types that can be queried from a World.
 * Implementors should implement either QueryData or QueryFilter.
 */
interface WorldQuery<T:WorldQuery<Dynamic>> {
    /**
     * State type for caching query data
     */
    var state(get, never): QueryState;

    /**
     * Whether this query is read-only (no mutable access)
     */
    var isReadOnly(get, never): Bool;

    /**
     * Initialize the query state for this type
     */
    function initState(world: World): Void;

    /**
     * Update archetype information for this query
     */
    function updateArchetypes(): Void;

    /**
     * Check if a set of components matches this query's filters
     */
    function matchesComponentSet(set: ComponentSet): Bool;

    /**
     * Fetch the component data for an entity
     */
    function fetch(entity: Entity, tableRow: TableRow): Null<T>;

    /**
     * Update component access information
     */
    function updateComponentAccess(access: FilteredAccess): Void;

    /**
     * Shrink a longer lifetime reference to a shorter one
     */
    function shrink(item: T): T;
}

/**
 * Base interface for query data (components to fetch)
 */
interface QueryData<T> extends WorldQuery<T> {
    /**
     * Read-only version of this query data
     */
    var readOnly(get, never): QueryData<Dynamic>;

    /**
     * Get the item type for iteration
     */
    var itemType(get, never): Class<T>;
}

/**
 * Base interface for query filters (conditions)
 */
interface QueryFilter extends WorldQuery<QueryFilter> {
    /**
     * Whether this filter is archetypal (can use archetype-level filtering)
     */
    var isArchetypal(get, never): Bool;
}

/**
 * Component set for matching checks
 */
abstract ComponentSet(Set<Int>) {
    public inline function new(set: Set<Int>) {
        this = set;
    }

    public inline function contains(id: Int): Bool {
        return this.contains(id);
    }
}
