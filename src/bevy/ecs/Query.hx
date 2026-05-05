package bevy.ecs;

import bevy.ecs.EcsError.QueryDoesNotMatchError;
import bevy.ecs.EcsError.QueryEntityNotSpawnedError;
import bevy.ecs.EcsError.EntityDoesNotExistError;
import bevy.ecs.EcsError.QuerySingleMultipleEntitiesError;
import bevy.ecs.EcsError.QuerySingleNoEntitiesError;
import bevy.ecs.Added;
import bevy.ecs.Changed;
import bevy.ecs.With;
import bevy.ecs.Without;

typedef QueryItem<T> = {
    var entity:Entity;
    var component:T;
}

typedef QueryItem2<A, B> = {
    var entity:Entity;
    var a:A;
    var b:B;
}

typedef QueryItem3<A, B, C> = {
    var entity:Entity;
    var a:A;
    var b:B;
    var c:C;
}

class Query<T, F:bevy.ecs.QueryFilter = bevy.ecs.QueryFilter> {
    private var world:World;
    private var componentClass:Class<T>;
    private var componentKey:Null<String>;
    private var filters:Array<bevy.ecs.QueryFilter>;

    public function new(world:World, componentClass:Class<T>, componentKey:Null<String>) {
        this.world = world;
        this.componentClass = componentClass;
        this.componentKey = componentKey;
        filters = [];
    }

    public function filter(value:bevy.ecs.QueryFilter):Query<T, F> {
        filters.push(value);
        return this;
    }

    public function filterAll(values:Array<bevy.ecs.QueryFilter>):Query<T, F> {
        for (value in values) {
            filter(value);
        }
        return this;
    }

    public function with<C>(cls:Class<C>, ?filterKey:String):Query<T, F> {
        return filter(With.of(cls, filterKey));
    }

    public function without<C>(cls:Class<C>, ?filterKey:String):Query<T, F> {
        return filter(Without.of(cls, filterKey));
    }

    public function added<C>(cls:Class<C>, sinceTick:Int, ?filterKey:String):Query<T, F> {
        return filter(Added.of(cls, sinceTick, filterKey));
    }

    public function changed<C>(cls:Class<C>, sinceTick:Int, ?filterKey:String):Query<T, F> {
        return filter(Changed.of(cls, sinceTick, filterKey));
    }

    public function toArray():Array<QueryItem<T>> {
        return world.queryOne(componentClass, filters, componentKey);
    }

    public function iter():Array<QueryItem<T>> {
        return toArray();
    }

    public function isEmpty():Bool {
        return toArray().length == 0;
    }

    public function count():Int {
        return toArray().length;
    }

    public function contains(entity:Entity):Bool {
        return get(entity) != null;
    }

    public function get(entity:Entity):Null<QueryItem<T>> {
        if (!world.isAlive(entity)) {
            return null;
        }

        var entityData = Type.getClassName(cast componentClass) == Type.getClassName(Entity);
        if (!entityData && world.get(entity, componentClass, componentKey) == null) {
            return null;
        }

        var items = world.queryOne(componentClass, filters, componentKey);
        for (item in items) {
            if (item.entity.equals(entity)) {
                return item;
            }
        }
        return null;
    }

    public function iterMany(entities:Array<Entity>):Array<QueryItem<T>> {
        var result:Array<QueryItem<T>> = [];
        if (entities == null) {
            return result;
        }
        for (entity in entities) {
            var item = get(entity);
            if (item != null) {
                result.push(item);
            }
        }
        return result;
    }

    public function getMany(entities:Array<Entity>):Array<QueryItem<T>> {
        var result:Array<QueryItem<T>> = [];
        if (entities == null) {
            return result;
        }
        for (entity in entities) {
            try {
                world.entity(entity);
            } catch (error:EntityDoesNotExistError) {
                throw new QueryEntityNotSpawnedError(entity, "Query", error);
            }
            var item = get(entity);
            if (item == null) {
                throw new QueryDoesNotMatchError(entity, "Query");
            }
            result.push(item);
        }
        return result;
    }

    public function getSingle():Null<QueryItem<T>> {
        var items = toArray();
        if (items.length == 1) {
            return items[0];
        }
        return null;
    }

    public function singleOrNull():Null<QueryItem<T>> {
        return getSingle();
    }

    public function single():QueryItem<T> {
        var items = toArray();
        if (items.length == 0) {
            throw new QuerySingleNoEntitiesError("Query");
        }
        if (items.length > 1) {
            throw new QuerySingleMultipleEntitiesError("Query");
        }
        return items[0];
    }
}

class Query2<A, B, F:bevy.ecs.QueryFilter = bevy.ecs.QueryFilter> {
    private var world:World;
    private var aClass:Class<A>;
    private var bClass:Class<B>;
    private var aKey:Null<String>;
    private var bKey:Null<String>;
    private var filters:Array<bevy.ecs.QueryFilter>;

    public function new(world:World, aClass:Class<A>, bClass:Class<B>, aKey:Null<String>, bKey:Null<String>) {
        this.world = world;
        this.aClass = aClass;
        this.bClass = bClass;
        this.aKey = aKey;
        this.bKey = bKey;
        filters = [];
    }

    public function filter(value:bevy.ecs.QueryFilter):Query2<A, B, F> {
        filters.push(value);
        return this;
    }

    public function filterAll(values:Array<bevy.ecs.QueryFilter>):Query2<A, B, F> {
        for (value in values) {
            filter(value);
        }
        return this;
    }

    public function with<C>(cls:Class<C>, ?filterKey:String):Query2<A, B, F> {
        return filter(With.of(cls, filterKey));
    }

    public function without<C>(cls:Class<C>, ?filterKey:String):Query2<A, B, F> {
        return filter(Without.of(cls, filterKey));
    }

    public function added<C>(cls:Class<C>, sinceTick:Int, ?filterKey:String):Query2<A, B, F> {
        return filter(Added.of(cls, sinceTick, filterKey));
    }

    public function changed<C>(cls:Class<C>, sinceTick:Int, ?filterKey:String):Query2<A, B, F> {
        return filter(Changed.of(cls, sinceTick, filterKey));
    }

    public function toArray():Array<QueryItem2<A, B>> {
        return world.queryTwo(aClass, bClass, filters, aKey, bKey);
    }

    public function iter():Array<QueryItem2<A, B>> {
        return toArray();
    }

    public function isEmpty():Bool {
        return toArray().length == 0;
    }

    public function count():Int {
        return toArray().length;
    }

    public function contains(entity:Entity):Bool {
        return get(entity) != null;
    }

    public function get(entity:Entity):Null<QueryItem2<A, B>> {
        if (!world.isAlive(entity)) {
            return null;
        }

        var aEntityData = isEntityClass(aClass);
        var bEntityData = isEntityClass(bClass);
        var a = aEntityData ? cast entity : world.get(entity, aClass, aKey);
        var b = bEntityData ? cast entity : world.get(entity, bClass, bKey);
        if (a == null || b == null) {
            return null;
        }

        var items = world.queryTwo(aClass, bClass, filters, aKey, bKey);
        for (item in items) {
            if (item.entity.equals(entity)) {
                return item;
            }
        }
        return null;
    }

    public function iterMany(entities:Array<Entity>):Array<QueryItem2<A, B>> {
        var result:Array<QueryItem2<A, B>> = [];
        if (entities == null) {
            return result;
        }
        for (entity in entities) {
            var item = get(entity);
            if (item != null) {
                result.push(item);
            }
        }
        return result;
    }

    public function getMany(entities:Array<Entity>):Array<QueryItem2<A, B>> {
        var result:Array<QueryItem2<A, B>> = [];
        if (entities == null) {
            return result;
        }
        for (entity in entities) {
            try {
                world.entity(entity);
            } catch (error:EntityDoesNotExistError) {
                throw new QueryEntityNotSpawnedError(entity, "Query2", error);
            }
            var item = get(entity);
            if (item == null) {
                throw new QueryDoesNotMatchError(entity, "Query2");
            }
            result.push(item);
        }
        return result;
    }

    public function getSingle():Null<QueryItem2<A, B>> {
        var items = toArray();
        if (items.length == 1) {
            return items[0];
        }
        return null;
    }

    public function singleOrNull():Null<QueryItem2<A, B>> {
        return getSingle();
    }

    public function single():QueryItem2<A, B> {
        var items = toArray();
        if (items.length == 0) {
            throw new QuerySingleNoEntitiesError("Query2");
        }
        if (items.length > 1) {
            throw new QuerySingleMultipleEntitiesError("Query2");
        }
        return items[0];
    }

    private inline function isEntityClass<T>(cls:Class<T>):Bool {
        return Type.getClassName(cast cls) == Type.getClassName(Entity);
    }
}

class Query3<A, B, C, F:bevy.ecs.QueryFilter = bevy.ecs.QueryFilter> {
    private var world:World;
    private var aClass:Class<A>;
    private var bClass:Class<B>;
    private var cClass:Class<C>;
    private var aKey:Null<String>;
    private var bKey:Null<String>;
    private var cKey:Null<String>;
    private var filters:Array<bevy.ecs.QueryFilter>;

    public function new(world:World, aClass:Class<A>, bClass:Class<B>, cClass:Class<C>, aKey:Null<String>, bKey:Null<String>, cKey:Null<String>) {
        this.world = world;
        this.aClass = aClass;
        this.bClass = bClass;
        this.cClass = cClass;
        this.aKey = aKey;
        this.bKey = bKey;
        this.cKey = cKey;
        filters = [];
    }

    public function filter(value:bevy.ecs.QueryFilter):Query3<A, B, C, F> {
        filters.push(value);
        return this;
    }

    public function filterAll(values:Array<bevy.ecs.QueryFilter>):Query3<A, B, C, F> {
        for (value in values) {
            filter(value);
        }
        return this;
    }

    public function with<D>(cls:Class<D>, ?filterKey:String):Query3<A, B, C, F> {
        return filter(With.of(cls, filterKey));
    }

    public function without<D>(cls:Class<D>, ?filterKey:String):Query3<A, B, C, F> {
        return filter(Without.of(cls, filterKey));
    }

    public function added<D>(cls:Class<D>, sinceTick:Int, ?filterKey:String):Query3<A, B, C, F> {
        return filter(Added.of(cls, sinceTick, filterKey));
    }

    public function changed<D>(cls:Class<D>, sinceTick:Int, ?filterKey:String):Query3<A, B, C, F> {
        return filter(Changed.of(cls, sinceTick, filterKey));
    }

    public function toArray():Array<QueryItem3<A, B, C>> {
        return world.queryThree(aClass, bClass, cClass, filters, aKey, bKey, cKey);
    }

    public function iter():Array<QueryItem3<A, B, C>> {
        return toArray();
    }

    public function isEmpty():Bool {
        return toArray().length == 0;
    }

    public function count():Int {
        return toArray().length;
    }

    public function contains(entity:Entity):Bool {
        return get(entity) != null;
    }

    public function get(entity:Entity):Null<QueryItem3<A, B, C>> {
        if (!world.isAlive(entity)) {
            return null;
        }

        var aEntityData = isEntityClass(aClass);
        var bEntityData = isEntityClass(bClass);
        var cEntityData = isEntityClass(cClass);
        var a = aEntityData ? cast entity : world.get(entity, aClass, aKey);
        var b = bEntityData ? cast entity : world.get(entity, bClass, bKey);
        var c = cEntityData ? cast entity : world.get(entity, cClass, cKey);
        if (a == null || b == null || c == null) {
            return null;
        }

        var items = world.queryThree(aClass, bClass, cClass, filters, aKey, bKey, cKey);
        for (item in items) {
            if (item.entity.equals(entity)) {
                return item;
            }
        }
        return null;
    }

    public function iterMany(entities:Array<Entity>):Array<QueryItem3<A, B, C>> {
        var result:Array<QueryItem3<A, B, C>> = [];
        if (entities == null) {
            return result;
        }
        for (entity in entities) {
            var item = get(entity);
            if (item != null) {
                result.push(item);
            }
        }
        return result;
    }

    public function getMany(entities:Array<Entity>):Array<QueryItem3<A, B, C>> {
        var result:Array<QueryItem3<A, B, C>> = [];
        if (entities == null) {
            return result;
        }
        for (entity in entities) {
            try {
                world.entity(entity);
            } catch (error:EntityDoesNotExistError) {
                throw new QueryEntityNotSpawnedError(entity, "Query3", error);
            }
            var item = get(entity);
            if (item == null) {
                throw new QueryDoesNotMatchError(entity, "Query3");
            }
            result.push(item);
        }
        return result;
    }

    public function getSingle():Null<QueryItem3<A, B, C>> {
        var items = toArray();
        if (items.length == 1) {
            return items[0];
        }
        return null;
    }

    public function singleOrNull():Null<QueryItem3<A, B, C>> {
        return getSingle();
    }

    public function single():QueryItem3<A, B, C> {
        var items = toArray();
        if (items.length == 0) {
            throw new QuerySingleNoEntitiesError("Query3");
        }
        if (items.length > 1) {
            throw new QuerySingleMultipleEntitiesError("Query3");
        }
        return items[0];
    }

    private inline function isEntityClass<T>(cls:Class<T>):Bool {
        return Type.getClassName(cast cls) == Type.getClassName(Entity);
    }
}

@:allow(bevy.macro.SystemMacro)
class QueryTuple<T, F:bevy.ecs.QueryFilter = bevy.ecs.QueryFilter> extends Query<T, F> {
    private var worldRef:World;
    private var itemClasses:Array<Class<Any>>;
    private var itemKeys:Array<Null<String>>;
    private var tupleFilters:Array<bevy.ecs.QueryFilter>;
    private var tupleFactory:Array<Any>->T;

    public function new(world:World, tupleClass:Class<T>, tupleFactory:Array<Any>->T, itemClasses:Array<Class<Any>>, itemKeys:Array<Null<String>>, filters:Array<bevy.ecs.QueryFilter>) {
        super(world, tupleClass, null);
        this.worldRef = world;
        this.tupleFactory = tupleFactory;
        this.itemClasses = itemClasses;
        this.itemKeys = itemKeys;
        this.tupleFilters = filters != null ? filters.copy() : [];
    }

    override public function filter(value:bevy.ecs.QueryFilter):Query<T, F> {
        tupleFilters.push(value);
        return this;
    }

    override public function filterAll(values:Array<bevy.ecs.QueryFilter>):Query<T, F> {
        for (value in values) {
            tupleFilters.push(value);
        }
        return this;
    }

    override public function with<C>(cls:Class<C>, ?filterKey:String):Query<T, F> {
        tupleFilters.push(With.of(cls, filterKey));
        return this;
    }

    override public function without<C>(cls:Class<C>, ?filterKey:String):Query<T, F> {
        tupleFilters.push(Without.of(cls, filterKey));
        return this;
    }

    override public function added<C>(cls:Class<C>, sinceTick:Int, ?filterKey:String):Query<T, F> {
        tupleFilters.push(Added.of(cls, sinceTick, filterKey));
        return this;
    }

    override public function changed<C>(cls:Class<C>, sinceTick:Int, ?filterKey:String):Query<T, F> {
        tupleFilters.push(Changed.of(cls, sinceTick, filterKey));
        return this;
    }

    override public function toArray():Array<QueryItem<T>> {
        var raw = worldRef.queryTuple(itemClasses, tupleFilters, itemKeys);
        var result:Array<QueryItem<T>> = [];
        for (item in raw) {
            result.push({
                entity: item.entity,
                component: tupleFactory(item.components)
            });
        }
        return result;
    }

    override public function iter():Array<QueryItem<T>> {
        return toArray();
    }

    override public function get(entity:Entity):Null<QueryItem<T>> {
        if (!worldRef.isAlive(entity)) {
            return null;
        }

        var items = toArray();
        for (item in items) {
            if (item.entity.equals(entity)) {
                return item;
            }
        }
        return null;
    }

    override public function iterMany(entities:Array<Entity>):Array<QueryItem<T>> {
        var result:Array<QueryItem<T>> = [];
        if (entities == null) {
            return result;
        }
        for (entity in entities) {
            var item = get(entity);
            if (item != null) {
                result.push(item);
            }
        }
        return result;
    }

    override public function getMany(entities:Array<Entity>):Array<QueryItem<T>> {
        var result:Array<QueryItem<T>> = [];
        if (entities == null) {
            return result;
        }
        for (entity in entities) {
            try {
                worldRef.entity(entity);
            } catch (error:EntityDoesNotExistError) {
                throw new QueryEntityNotSpawnedError(entity, "Query", error);
            }
            var item = get(entity);
            if (item == null) {
                throw new QueryDoesNotMatchError(entity, "Query");
            }
            result.push(item);
        }
        return result;
    }

    override public function getSingle():Null<QueryItem<T>> {
        var items = toArray();
        if (items.length == 1) {
            return items[0];
        }
        return null;
    }

    override public function singleOrNull():Null<QueryItem<T>> {
        return getSingle();
    }

    override public function single():QueryItem<T> {
        var items = toArray();
        if (items.length == 0) {
            throw new QuerySingleNoEntitiesError("Query");
        }
        if (items.length > 1) {
            throw new QuerySingleMultipleEntitiesError("Query");
        }
        return items[0];
    }
}
