package haxe.ecs;

/**
 * Sparse set storage for components.
 * Provides O(1) random access and efficient iteration.
 * 
 * Uses a sparse array for entity->index mapping and a dense array for actual component storage.
 */
class SparseSet<T> {
    /** Sparse array: entityId -> dense index (or -1 if not present) */
    private var sparse:Map<EntityId, Int>;
    
    /** Dense array: stores actual entity ids */
    private var dense:Array<EntityId>;
    
    /** Dense array: stores component values */
    private var data:Array<T>;
    
    /** Number of entities currently stored */
    private var count:Int;

    public inline function new() {
        sparse = new Map();
        dense = [];
        data = [];
        count = 0;
    }

    /**
     * Returns the number of components stored
     */
    public inline function length():Int {
        return count;
    }

    /**
     * Returns true if no components are stored
     */
    public inline function isEmpty():Bool {
        return count == 0;
    }

    /**
     * Checks if a component exists for the given entity
     */
    public inline function contains(entity:Entity):Bool {
        return containsId(entity.id);
    }

    /**
     * Checks if a component exists for the given entity id
     */
    public inline function containsId(entityId:EntityId):Bool {
        final index = sparse.get(entityId);
        return index != null && index >= 0 && index < count;
    }

    /**
     * Gets the component for the given entity
     */
    public inline function get(entity:Entity):Null<T> {
        return getId(entity.id);
    }

    /**
     * Gets the component for the given entity id
     */
    public inline function getId(entityId:EntityId):Null<T> {
        final index = sparse.get(entityId);
        if (index == null || index < 0 || index >= count) {
            return null;
        }
        return data[index];
    }

    /**
     * Gets a mutable reference to the component for the given entity
     */
    public inline function getMut(entity:Entity):Null<T> {
        return getId(entity.id);
    }

    /**
     * Inserts a component for the given entity
     */
    public function insert(entity:Entity, value:T):Void {
        insertId(entity.id, value);
    }

    /**
     * Inserts a component for the given entity id
     */
    public function insertId(entityId:EntityId, value:T):Void {
        final existing = sparse.get(entityId);
        
        if (existing != null && existing >= 0 && existing < count) {
            // Update existing
            data[existing] = value;
            return;
        }
        
        // Insert new
        sparse.set(entityId, count);
        dense.push(entityId);
        data.push(value);
        count++;
    }

    /**
     * Removes the component for the given entity
     */
    public function remove(entity:Entity):Void {
        removeId(entity.id);
    }

    /**
     * Removes the component for the given entity id
     * Uses swap-remove for O(1) removal
     */
    public function removeId(entityId:EntityId):Void {
        final index = sparse.get(entityId);
        if (index == null || index < 0 || index >= count) {
            return;
        }
        
        // Swap-remove the last element with the removed element
        final lastIndex = count - 1;
        final lastEntityId = dense[lastIndex];
        
        if (index != lastIndex) {
            // Swap the data
            data[index] = data[lastIndex];
            dense[index] = lastEntityId;
            sparse.set(lastEntityId, index);
        }
        
        // Clear the sparse entry for the removed entity
        sparse.set(entityId, -1);
        
        // Remove last elements
        data.pop();
        dense.pop();
        count--;
    }

    /**
     * Clears all components from this storage
     */
    public function clear():Void {
        sparse = new Map();
        dense = [];
        data = [];
        count = 0;
    }

    /**
     * Gets the entity id at the given index in the dense array
     */
    public inline function getEntityIdAt(index:Int):EntityId {
        return dense[index];
    }

    /**
     * Gets the component at the given index in the dense array
     */
    public inline function getDataAt(index:Int):T {
        return data[index];
    }

    /**
     * Gets the sparse index for an entity
     */
    public inline function getSparseIndex(entityId:EntityId):Int {
        final index = sparse.get(entityId);
        return if (index == null) -1 else index;
    }

    /**
     * Iterates over all (entity, component) pairs
     */
    public function iterator():Iterator<EntityComponentPair<T>> {
        return new SparseSetIterator(this);
    }

    /**
     * Returns all entity ids in this storage
     */
    public function entityIds():Array<EntityId> {
        return dense.copy();
    }

    /**
     * Returns all components in this storage
     */
    public function components():Array<T> {
        return data.copy();
    }
}

/**
 * Iterator for iterating over sparse set entries
 */
class EntityComponentPair<T> {
    public final entityId:EntityId;
    public final component:T;

    public inline function new(entityId:EntityId, component:T) {
        this.entityId = entityId;
        this.component = component;
    }
}

class SparseSetIterator<T> {
    private var storage:SparseSet<T>;
    private var index:Int = 0;

    public inline function new(storage:SparseSet<T>) {
        this.storage = storage;
    }

    public inline function hasNext():Bool {
        return index < storage.length();
    }

    public inline function next():EntityComponentPair<T> {
        final entityId = storage.getEntityIdAt(index);
        final component = storage.getDataAt(index);
        index++;
        return new EntityComponentPair(entityId, component);
    }
}

/**
 * Collection of all sparse sets for component storage
 */
class SparseSets {
    private var storages:Map<ComponentId, Any>;

    public inline function new() {
        storages = new Map();
    }

    /**
     * Gets or creates a sparse set for the given component type
     */
    public function getOrInsert<T>(componentId:ComponentId):SparseSet<T> {
        var storage:Any = storages.get(componentId);
        if (storage == null) {
            storage = new SparseSet<T>();
            storages.set(componentId, storage);
        }
        return cast storage;
    }

    /**
     * Gets a sparse set for the given component type
     */
    public inline function get<T>(componentId:ComponentId):Null<SparseSet<T>> {
        final storage:Any = storages.get(componentId);
        return if (storage != null) cast storage else null;
    }

    /**
     * Removes a sparse set
     */
    public inline function remove(componentId:ComponentId):Void {
        storages.remove(componentId);
    }

    /**
     * Returns the number of component types stored
     */
    public inline function size():Int {
        return storages.count();
    }
}

/**
 * Type alias for component id
 */
typedef ComponentId = UInt;
