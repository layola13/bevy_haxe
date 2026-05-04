package haxe.utils;

/**
 * Entity identifier used in ECS (Entity-Component-System) pattern.
 * Entities are represented by unique indices.
 */
@:structInit
class Entity {
    /**
     * Unique identifier for this entity
     */
    public var id(default, null):UInt;
    
    /**
     * Generation counter for this entity ID
     */
    public var generation(default, null):UInt;
    
    public inline function new(id:UInt = 0, generation:UInt = 0) {
        this.id = id;
        this.generation = generation;
    }
    
    /**
     * Creates an invalid/null entity
     */
    public static var INVALID(get, never):Entity;
    private static inline function get_INVALID():Entity return new Entity(0, 0);
    
    /**
     * Check if this entity is valid (non-zero ID)
     */
    public var isValid(get, never):Bool;
    private inline function get_isValid():Bool return id != 0;
    
    /**
     * Convert to string representation
     */
    public function toString():String {
        return 'Entity($id, gen: $generation)';
    }
    
    @:op(A == B)
    public static function equals(a:Entity, b:Entity):Bool {
        return a.id == b.id && a.generation == b.generation;
    }
    
    @:op(A != B)
    public static function notEquals(a:Entity, b:Entity):Bool {
        return a.id != b.id || a.generation != b.generation;
    }
    
    public function hashCode():Int {
        return Std.int(id) ^ Std.int(generation);
    }
}

/**
 * A hash map specialized for Entity keys.
 * Uses Entity ID and generation for efficient lookups.
 * 
 * Equivalent to Rust's `bevy_utils::EntityHashMap`.
 */
@:generic
class EntityHashMap<V> {
    private var data:Map<Int, V>;
    private var entityData:Map<UInt, EntityEntry<V>>;
    
    private static inline var ENTITY_MASK:Int = 0xFFFFFFFF;
    
    private static function entityKey(entity:Entity):Int {
        return Std.int(entity.id ^ (entity.generation << 16));
    }
    
    public inline function new() {
        data = new Map();
        entityData = new Map();
    }
    
    /**
     * Insert a value for the given entity.
     * @param entity The entity key
     * @param value The value to store
     * @return The previous value if one existed
     */
    public inline function set(entity:Entity, value:V):Null<V> {
        var key = entityKey(entity);
        var old:V = data.get(key);
        data.set(key, value);
        entityData.set(entity.id, new EntityEntry(entity, value));
        return old;
    }
    
    /**
     * Get a value for the given entity.
     * @param entity The entity key
     * @return The value if found, null otherwise
     */
    public inline function get(entity:Entity):Null<V> {
        return data.get(entityKey(entity));
    }
    
    /**
     * Check if the map contains a value for the given entity.
     */
    public inline function exists(entity:Entity):Bool {
        return data.exists(entityKey(entity));
    }
    
    /**
     * Remove the value for the given entity.
     * @param entity The entity key
     * @return The removed value if one existed
     */
    public inline function remove(entity:Entity):Null<V> {
        var key = entityKey(entity);
        entityData.remove(entity.id);
        return data.remove(key);
    }
    
    /**
     * Get the number of entries in the map.
     */
    public var length(get, never):Int;
    private inline function get_length():Int return data.count();
    
    /**
     * Clear all entries from the map.
     */
    public inline function clear():Void {
        data.clear();
        entityData.clear();
    }
    
    /**
     * Get all entities in the map.
     */
    public inline function keys():Iterator<Entity> {
        var keys = data.keys();
        return {
            hasNext: keys.hasNext,
            next: function():Entity {
                var id:Int = keys.next();
                var generation:UInt = (id >> 16) & 0xFFFF;
                return new Entity(id & 0xFFFF, generation);
            }
        };
    }
    
    /**
     * Get all values in the map.
     */
    public inline function iterator():Iterator<V> {
        return data.iterator();
    }
    
    /**
     * Get key-value pairs.
     */
    public inline function keyValueIterator():KeyValueIterator<Entity, V> {
        var kvIter = data.keyValueIterator();
        return {
            hasNext: kvIter.hasNext,
            next: function():KeyValue<Entity, V> {
                var kv = kvIter.next();
                var id:Int = kv.key;
                var generation:UInt = (id >> 16) & 0xFFFF;
                return {key: new Entity(id & 0xFFFF, generation), value: kv.value};
            }
        };
    }
    
    /**
     * Check if the map is empty.
     */
    public var isEmpty(get, never):Bool;
    private inline function get_isEmpty():Bool return data.isEmpty();
    
    /**
     * Get or insert a value using a factory function.
     */
    public inline function getOrInsertWith(entity:Entity, factory:Void->V):V {
        var key = entityKey(entity);
        if (data.exists(key)) {
            return data.get(key);
        }
        var value = factory();
        data.set(key, value);
        entityData.set(entity.id, new EntityEntry(entity, value));
        return value;
    }
}

/**
 * Internal entry for entity tracking
 */
@:structInit
private class EntityEntry<V> {
    public var entity:Entity;
    public var value:V;
    
    public inline function new(entity:Entity, value:V) {
        this.entity = entity;
        this.value = value;
    }
}

/**
 * Specialized Entity hash set
 */
@:generic
class EntityHashSet {
    private var data:Map<Int, Entity>;
    
    private static inline function entityKey(entity:Entity):Int {
        return Std.int(entity.id ^ (entity.generation << 16));
    }
    
    public inline function new() {
        data = new Map();
    }
    
    public inline function insert(entity:Entity):Bool {
        var key = entityKey(entity);
        if (data.exists(key)) return false;
        data.set(key, entity);
        return true;
    }
    
    public inline function contains(entity:Entity):Bool {
        return data.exists(entityKey(entity));
    }
    
    public inline function remove(entity:Entity):Bool {
        return data.remove(entityKey(entity));
    }
    
    public inline function clear():Void {
        data.clear();
    }
    
    public var length(get, never):Int;
    private inline function get_length():Int return data.count();
    
    public inline function iterator():Iterator<Entity> {
        return data.iterator();
    }
}
