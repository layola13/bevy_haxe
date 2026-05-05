package bevy.ecs;

class Entity {
    public var index(default, null):Int;
    public var generation(default, null):Int;

    public inline function new(index:Int, generation:Int) {
        this.index = index;
        this.generation = generation;
    }

    public inline function equals(other:Entity):Bool {
        return other != null && index == other.index && generation == other.generation;
    }

    public inline function key():String {
        return index + ":" + generation;
    }

    public function toString():String {
        return 'Entity($index:$generation)';
    }
}

class EntityLocation {
    public var generation:Int;
    public var alive:Bool;

    public function new(generation:Int, alive:Bool) {
        this.generation = generation;
        this.alive = alive;
    }
}

class EntityRef {
    public var world(default, null):World;
    public var entity(default, null):Entity;

    public function new(world:World, entity:Entity) {
        this.world = world;
        this.entity = entity;
    }

    public inline function id():Entity {
        return entity;
    }

    public inline function isAlive():Bool {
        return world.isAlive(entity);
    }

    public inline function get<T>(cls:Class<T>, ?componentKey:String):Null<T> {
        return world.get(entity, cls, componentKey);
    }

    public inline function contains<T>(cls:Class<T>, ?componentKey:String):Bool {
        return world.has(entity, cls, componentKey);
    }

    public inline function has<T>(cls:Class<T>, ?componentKey:String):Bool {
        return contains(cls, componentKey);
    }
}

class EntityWorldMut extends EntityRef {
    public function new(world:World, entity:Entity) {
        super(world, entity);
    }

    public inline function insert<T>(component:T):EntityWorldMut {
        world.insert(entity, component);
        return this;
    }

    public inline function insertByKey<T>(typeKey:String, component:T):EntityWorldMut {
        world.insertByKey(entity, typeKey, component);
        return this;
    }

    public inline function insertBundle(bundle:Bundle):EntityWorldMut {
        for (component in bundle.toBundle()) {
            world.insert(entity, component);
        }
        return this;
    }

    public inline function remove<T>(cls:Class<T>, ?componentKey:String):Null<T> {
        return world.remove(entity, cls, componentKey);
    }

    public inline function despawn():Bool {
        return world.despawn(entity);
    }
}
