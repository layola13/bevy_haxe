package bevy.ecs;

import bevy.ecs.Entity.EntityLocation;
import bevy.ecs.Query.Query2;
import bevy.ecs.Query.QueryItem;
import bevy.ecs.Query.QueryItem2;

class World {
    private var entities:Array<EntityLocation>;
    private var freeIndices:Array<Int>;
    private var components:Map<Int, Map<String, Dynamic>>;
    private var resources:Map<String, Dynamic>;
    private var events:Map<String, Dynamic>;
    private var changeTick:Int;
    private var changedComponents:Map<String, Int>;
    private var addedComponents:Map<String, Int>;

    public function new() {
        entities = [];
        freeIndices = [];
        components = new Map();
        resources = new Map();
        events = new Map();
        changeTick = 1;
        changedComponents = new Map();
        addedComponents = new Map();
    }

    public function spawn(?bundle:Array<Dynamic>):Entity {
        var index:Int;
        var generation:Int;
        if (freeIndices.length > 0) {
            index = freeIndices.pop();
            var location = entities[index];
            location.alive = true;
            generation = location.generation;
        } else {
            index = entities.length;
            generation = 1;
            entities.push(new EntityLocation(generation, true));
        }

        var entity = new Entity(index, generation);
        components.set(index, new Map());
        if (bundle != null) {
            for (component in bundle) {
                insert(entity, component);
            }
        }
        return entity;
    }

    public function spawnBundle(bundle:Bundle):Entity {
        return spawn(bundle.toBundle());
    }

    public function despawn(entity:Entity):Bool {
        if (!isAlive(entity)) {
            return false;
        }
        var location = entities[entity.index];
        location.alive = false;
        location.generation++;
        components.remove(entity.index);
        freeIndices.push(entity.index);
        return true;
    }

    public function isAlive(entity:Entity):Bool {
        if (entity == null || entity.index < 0 || entity.index >= entities.length) {
            return false;
        }
        var location = entities[entity.index];
        return location.alive && location.generation == entity.generation;
    }

    public function insert<T>(entity:Entity, component:T):T {
        assertAlive(entity);
        var typeKey = TypeKey.ofInstance(component);
        var storage = components.get(entity.index);
        if (storage == null) {
            storage = new Map();
            components.set(entity.index, storage);
        }
        var changeKey = componentChangeKey(entity, typeKey);
        if (!storage.exists(typeKey)) {
            addedComponents.set(changeKey, changeTick);
        }
        storage.set(typeKey, component);
        changedComponents.set(changeKey, changeTick);
        return component;
    }

    public function remove<T>(entity:Entity, cls:Class<T>):Null<T> {
        assertAlive(entity);
        var typeKey = TypeKey.ofClass(cls);
        var storage = components.get(entity.index);
        if (storage == null || !storage.exists(typeKey)) {
            return null;
        }
        var value:T = cast storage.get(typeKey);
        storage.remove(typeKey);
        changedComponents.set(componentChangeKey(entity, typeKey), changeTick);
        return value;
    }

    public function get<T>(entity:Entity, cls:Class<T>):Null<T> {
        if (!isAlive(entity)) {
            return null;
        }
        var storage = components.get(entity.index);
        if (storage == null) {
            return null;
        }
        return cast storage.get(TypeKey.ofClass(cls));
    }

    public function has<T>(entity:Entity, cls:Class<T>):Bool {
        if (!isAlive(entity)) {
            return false;
        }
        var storage = components.get(entity.index);
        return storage != null && storage.exists(TypeKey.ofClass(cls));
    }

    public function query<T>(cls:Class<T>):Query<T> {
        return new Query<T>(this, cls);
    }

    public function queryPair<A, B>(a:Class<A>, b:Class<B>):Query2<A, B> {
        return new Query2<A, B>(this, a, b);
    }

    public function queryOne<T>(cls:Class<T>, withFilters:Array<String>, withoutFilters:Array<String>):Array<QueryItem<T>> {
        var result:Array<QueryItem<T>> = [];
        var typeKey = TypeKey.ofClass(cls);
        for (index => storage in components) {
            var entity = entityForIndex(index);
            if (entity == null || !storage.exists(typeKey) || !matchesFilters(storage, withFilters, withoutFilters)) {
                continue;
            }
            result.push({entity: entity, component: cast storage.get(typeKey)});
        }
        return result;
    }

    public function queryTwo<A, B>(a:Class<A>, b:Class<B>, withFilters:Array<String>, withoutFilters:Array<String>):Array<QueryItem2<A, B>> {
        var result:Array<QueryItem2<A, B>> = [];
        var aKey = TypeKey.ofClass(a);
        var bKey = TypeKey.ofClass(b);
        for (index => storage in components) {
            var entity = entityForIndex(index);
            if (entity == null || !storage.exists(aKey) || !storage.exists(bKey) || !matchesFilters(storage, withFilters, withoutFilters)) {
                continue;
            }
            result.push({
                entity: entity,
                a: cast storage.get(aKey),
                b: cast storage.get(bKey)
            });
        }
        return result;
    }

    public function insertResource<T>(resource:T):T {
        resources.set(TypeKey.ofInstance(resource), resource);
        return resource;
    }

    public function getResource<T>(cls:Class<T>):Null<T> {
        return cast resources.get(TypeKey.ofClass(cls));
    }

    public function removeResource<T>(cls:Class<T>):Null<T> {
        var key = TypeKey.ofClass(cls);
        var value:T = cast resources.get(key);
        resources.remove(key);
        return value;
    }

    public function initEvents<T>(cls:Class<T>):Events<T> {
        var key = TypeKey.ofClass(cls);
        var existing = events.get(key);
        if (existing != null) {
            return cast existing;
        }
        var created = new Events<T>();
        events.set(key, created);
        return created;
    }

    public function getEvents<T>(cls:Class<T>):Events<T> {
        return initEvents(cls);
    }

    public function sendEvent<T>(event:T):Void {
        initEvents(Type.getClass(event)).send(event);
    }

    public function tick():Int {
        return changeTick;
    }

    public function advanceTick():Void {
        changeTick++;
    }

    public function isChanged<T>(entity:Entity, cls:Class<T>, sinceTick:Int):Bool {
        var value = changedComponents.get(componentChangeKey(entity, TypeKey.ofClass(cls)));
        return value != null && value > sinceTick;
    }

    public function isAdded<T>(entity:Entity, cls:Class<T>, sinceTick:Int):Bool {
        var value = addedComponents.get(componentChangeKey(entity, TypeKey.ofClass(cls)));
        return value != null && value > sinceTick;
    }

    public function commands():Commands {
        return new Commands(this);
    }

    public function entityCount():Int {
        var count = 0;
        for (location in entities) {
            if (location.alive) {
                count++;
            }
        }
        return count;
    }

    private function entityForIndex(index:Int):Null<Entity> {
        if (index < 0 || index >= entities.length) {
            return null;
        }
        var location = entities[index];
        if (!location.alive) {
            return null;
        }
        return new Entity(index, location.generation);
    }

    private function matchesFilters(storage:Map<String, Dynamic>, withFilters:Array<String>, withoutFilters:Array<String>):Bool {
        for (key in withFilters) {
            if (!storage.exists(key)) {
                return false;
            }
        }
        for (key in withoutFilters) {
            if (storage.exists(key)) {
                return false;
            }
        }
        return true;
    }

    private function assertAlive(entity:Entity):Void {
        if (!isAlive(entity)) {
            throw 'Entity is not alive: $entity';
        }
    }

    private function componentChangeKey(entity:Entity, typeKey:String):String {
        return entity.key() + ":" + typeKey;
    }
}
