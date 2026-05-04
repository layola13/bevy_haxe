package haxe.ecs;

abstract Entity(Int) {
    public inline function new(id:Int) this = id;

    public var id(get, never):Int;
    private inline function get_id():Int return this;

    public static var NULL(get, never):Entity;
    private static inline function get_NULL():Entity return new Entity(0);

    @:op(A == B) public static function eq(a:Entity, b:Entity):Bool return (a:Int) == (b:Int);
    @:op(A != B) public static function ne(a:Entity, b:Entity):Bool return (a:Int) != (b:Int);
    @:op(A < B) public static function lt(a:Entity, b:Entity):Bool return (a:Int) < (b:Int);

    public inline function isValid():Bool return this != 0;

    public function toString():String return 'Entity($id)';

    @:from public static inline function fromInt(v:Int):Entity return new Entity(v);
    @:to public inline function toInt():Int return this;
}

class EntityLocation {
    public var archetypeIndex:Int;
    public var indexInArchetype:Int;

    public inline function new(archetypeIndex:Int, indexInArchetype:Int) {
        this.archetypeIndex = archetypeIndex;
        this.indexInArchetype = indexInArchetype;
    }
}

/**
    Entity Mut - mutable access to entity components.
**/
class EntityMut {
    public var world:World;
    public var entity:Entity;

    public inline function new(world:World, entity:Entity) {
        this.world = world;
        this.entity = entity;
    }

    public inline function get<T:Component>(cls:Class<T>):T return world.get(entity, cls);

    public inline function insert<T:Component>(component:T):EntityMut {
        world.insert(entity, component);
        return this;
    }

    public inline function remove<T:Component>(cls:Class<T>):EntityMut {
        world.remove(entity, cls);
        return this;
    }

    public inline function despawn():Void world.despawn(entity);
}

/**
    Entity Ref - immutable access to entity components.
**/
class EntityRef {
    public var world:World;
    public var entity:Entity;

    public inline function new(world:World, entity:Entity) {
        this.world = world;
        this.entity = entity;
    }

    public inline function get<T:Component>(cls:Class<T>):T return world.get(entity, cls);
    public inline function contains<T:Component>(cls:Class<T>):Bool return world.has(entity, cls);
}
