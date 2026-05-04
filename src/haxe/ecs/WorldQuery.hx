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
 * Component set for matching checks
 */
abstract ComponentSet(haxe.ds.Map<Int, Bool>) from haxe.ds.Map<Int, Bool> {
    public inline function new() {
        this = new haxe.ds.Map<Int, Bool>();
    }

    public inline function add(id: Int): Void {
        this.set(id, true);
    }

    public inline function contains(id: Int): Bool {
        return this.exists(id);
    }
}
