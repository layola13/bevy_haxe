package haxe.ecs;

/**
 * Base World class for entity-component system
 * Provides basic entity spawning and component management
 */
class World {
    private var nextEntityId:Int = 1;
    private var entities:Map<Int, Map<Int, Dynamic>> = new Map();
    private var removedComponents:Map<Int, Set<Int>> = new Map();
    private var changedComponents:Map<Int, Set<Int>> = new Map();
    private var entitiesToRemove:Array<Int> = [];
    
    public function new() {}
    
    /**
     * Spawn a new entity and return its ID
     */
    public function spawn():Entity {
        var id = nextEntityId++;
        entities.set(id, new Map());
        return new Entity(id);
    }
    
    /**
     * Despawn an entity and all its components
     */
    public function despawn(entity:Entity):Void {
        entities.remove(entity.id);
        entitiesToRemove.push(entity.id);
    }
    
    /**
     * Add a component to an entity
     */
    public function add<T:Component>(entity:Entity, component:T):T {
        var entityComponents = entities.get(entity.id);
        if (entityComponents == null) {
            entityComponents = new Map();
            entities.set(entity.id, entityComponents);
        }
        var typeId = ComponentType.get(Type.getClass(component));
        entityComponents.set(typeId, component);
        return component;
    }
    
    /**
     * Get a component from an entity
     */
    public function get<T:Component>(entity:Entity, cls:Class<T>):T {
        var entityComponents = entities.get(entity.id);
        if (entityComponents == null) return null;
        var typeId = ComponentType.get(cls);
        return entityComponents.get(typeId);
    }
    
    /**
     * Remove a component from an entity
     */
    public function remove<T:Component>(entity:Entity, cls:Class<T>):Void {
        var entityComponents = entities.get(entity.id);
        if (entityComponents == null) return;
        var typeId = ComponentType.get(cls);
        entityComponents.remove(typeId);
    }
    
    /**
     * Check if entity has a component
     */
    public function has<T:Component>(entity:Entity, cls:Class<T>):Bool {
        var entityComponents = entities.get(entity.id);
        if (entityComponents == null) return false;
        var typeId = ComponentType.get(cls);
        return entityComponents.exists(typeId);
    }
    
    /**
     * Query entities with specific components
     */
    public function query<T1:Component>(cls1:Class<T1>):Array<EntityWith<T1>> {
        var result:Array<EntityWith<T1>> = [];
        for (id => components in entities) {
            var typeId1 = ComponentType.get(cls1);
            if (components.exists(typeId1)) {
                var entity = new Entity(id);
                result.push(new EntityWith(entity, components.get(typeId1)));
            }
        }
        return result;
    }
    
    public function query2<T1:Component, T2:Component>(cls1:Class<T1>, cls2:Class<T2>):Array<EntityWith2<T1, T2>> {
        var result:Array<EntityWith2<T1, T2>> = [];
        for (id => components in entities) {
            var typeId1 = ComponentType.get(cls1);
            var typeId2 = ComponentType.get(cls2);
            if (components.exists(typeId1) && components.exists(typeId2)) {
                var entity = new Entity(id);
                result.push(new EntityWith2(entity, components.get(typeId1), components.get(typeId2)));
            }
        }
        return result;
    }
    
    public function query3<T1:Component, T2:Component, T3:Component>(
        cls1:Class<T1>, cls2:Class<T2>, cls3:Class<T3>
    ):Array<EntityWith3<T1, T2, T3>> {
        var result:Array<EntityWith3<T1, T2, T3>> = [];
        for (id => components in entities) {
            var typeId1 = ComponentType.get(cls1);
            var typeId2 = ComponentType.get(cls2);
            var typeId3 = ComponentType.get(cls3);
            if (components.exists(typeId1) && components.exists(typeId2) && components.exists(typeId3)) {
                var entity = new Entity(id);
                result.push(new EntityWith3(entity, components.get(typeId1), components.get(typeId2), components.get(typeId3)));
            }
        }
        return result;
    }
    
    /**
     * Get all entities with a specific component type
     */
    public function entitiesWith<T:Component>(cls:Class<T>):Array<Int> {
        var result:Array<Int> = [];
        var typeId = ComponentType.get(cls);
        for (id => components in entities) {
            if (components.exists(typeId)) {
                result.push(id);
            }
        }
        return result;
    }
    
    /**
     * Mark a component as changed for an entity
     */
    public function markChanged(entity:Entity, cls:Class<Dynamic>):Void {
        var typeId = ComponentType.get(cls);
        if (!changedComponents.exists(entity.id)) {
            changedComponents.set(entity.id, new Set());
        }
        changedComponents.get(entity.id).add(typeId);
    }
    
    /**
     * Check if a component was changed this frame
     */
    public function isChanged(entity:Entity, cls:Class<Dynamic>):Bool {
        var entityChanges = changedComponents.get(entity.id);
        if (entityChanges == null) return false;
        return entityChanges.exists(ComponentType.get(cls));
    }
    
    /**
     * Clear change tracking at end of frame
     */
    public function clearChangeTracking():Void {
        changedComponents.clear();
    }
    
    /**
     * Process removed entities
     */
    public function processRemovals():Void {
        for (id in entitiesToRemove) {
            removedComponents.remove(id);
            changedComponents.remove(id);
        }
        entitiesToRemove = [];
    }
}

/**
 * Entity with single component wrapper
 */
class EntityWith<T:Component> {
    public var entity:Entity;
    public var c1:T;
    
    public inline function new(entity:Entity, c1:T) {
        this.entity = entity;
        this.c1 = c1;
    }
}

/**
 * Entity with two components wrapper
 */
class EntityWith2<T1:Component, T2:Component> {
    public var entity:Entity;
    public var c1:T1;
    public var c2:T2;
    
    public inline function new(entity:Entity, c1:T1, c2:T2) {
        this.entity = entity;
        this.c1 = c1;
        this.c2 = c2;
    }
}

/**
 * Entity with three components wrapper
 */
class EntityWith3<T1:Component, T2:Component, T3:Component> {
    public var entity:Entity;
    public var c1:T1;
    public var c2:T2;
    public var c3:T3;
    
    public inline function new(entity:Entity, c1:T1, c2:T2, c3:T3) {
        this.entity = entity;
        this.c1 = c1;
        this.c2 = c2;
        this.c3 = c3;
    }
}

/**
 * Simple Set implementation for change tracking
 */
@:generic
class Set<T> {
    private var data:Map<T, Bool> = new Map();
    
    public inline function add(item:T):Void {
        data.set(item, true);
    }
    
    public inline function exists(item:T):Bool {
        return data.exists(item);
    }
    
    public inline function remove(item:T):Void {
        data.remove(item);
    }
    
    public inline function clear():Void {
        data.clear();
    }
    
    public inline function iterator():Iterator<T> {
        return data.keys();
    }
}
