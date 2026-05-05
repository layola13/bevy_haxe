package bevy.ecs;

import bevy.ecs.EcsError.EntityDoesNotExistError;
import bevy.ecs.EcsError.EntityNotAliveError;
import bevy.ecs.EcsError.MissingResourceError;
import bevy.ecs.EcsError.ResourceInitError;
import bevy.ecs.Entity.EntityLocation;
import bevy.ecs.Entity.EntityRef;
import bevy.ecs.Entity.EntityWorldMut;
import bevy.ecs.Query.Query2;
import bevy.ecs.Query.Query3;
import bevy.ecs.Query.QueryItem;
import bevy.ecs.Query.QueryItem2;
import bevy.ecs.Query.QueryItem3;
import bevy.ecs.QueryFilter.QueryFilterKind;
import bevy.ecs.QueryFilter.QueryFilterNode;

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

    public function spawnEmpty():EntityWorldMut {
        return new EntityWorldMut(this, spawn());
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

    public function containsEntity(entity:Entity):Bool {
        return isAlive(entity);
    }

    public function getEntity(entity:Entity):Null<EntityRef> {
        return isAlive(entity) ? new EntityRef(this, entity) : null;
    }

    public function entity(entity:Entity):EntityRef {
        var value = getEntity(entity);
        if (value == null) {
            throw new EntityDoesNotExistError(entity);
        }
        return value;
    }

    public function getEntityMut(entity:Entity):Null<EntityWorldMut> {
        return isAlive(entity) ? new EntityWorldMut(this, entity) : null;
    }

    public function entityMut(entity:Entity):EntityWorldMut {
        var value = getEntityMut(entity);
        if (value == null) {
            throw new EntityDoesNotExistError(entity);
        }
        return value;
    }

    public function insert<T>(entity:Entity, component:T):T {
        return insertByKey(entity, componentStorageKey(component), component);
    }

    public function insertByKey<T>(entity:Entity, typeKey:String, component:T):T {
        assertAlive(entity);
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

    public function remove<T>(entity:Entity, cls:Class<T>, ?typeKey:String):Null<T> {
        assertAlive(entity);
        var resolvedKey = componentLookupKey(cls, typeKey);
        var storage = components.get(entity.index);
        if (storage == null || !storage.exists(resolvedKey)) {
            return null;
        }
        var value:T = cast storage.get(resolvedKey);
        storage.remove(resolvedKey);
        changedComponents.set(componentChangeKey(entity, resolvedKey), changeTick);
        return value;
    }

    public function get<T>(entity:Entity, cls:Class<T>, ?typeKey:String):Null<T> {
        if (!isAlive(entity)) {
            return null;
        }
        var storage = components.get(entity.index);
        if (storage == null) {
            return null;
        }
        return cast storage.get(componentLookupKey(cls, typeKey));
    }

    public function has<T>(entity:Entity, cls:Class<T>, ?typeKey:String):Bool {
        if (!isAlive(entity)) {
            return false;
        }
        var storage = components.get(entity.index);
        return storage != null && storage.exists(componentLookupKey(cls, typeKey));
    }

    public function query<T>(cls:Class<T>, ?componentKey:String):Query<T> {
        var entityData = Type.getClassName(cast cls) == Type.getClassName(Entity);
        return new Query<T>(this, cls, entityData && componentKey == null ? null : componentLookupKey(cls, componentKey));
    }

    public function queryFiltered<T>(cls:Class<T>, filters:Array<bevy.ecs.QueryFilter>, ?componentKey:String):Query<T> {
        return query(cls, componentKey).filterAll(filters);
    }

    public function queryPair<A, B>(a:Class<A>, b:Class<B>, ?aKey:String, ?bKey:String):Query2<A, B> {
        return new Query2<A, B>(this, a, b, queryDataLookupKey(a, aKey), queryDataLookupKey(b, bKey));
    }

    public function queryFilteredPair<A, B>(a:Class<A>, b:Class<B>, filters:Array<bevy.ecs.QueryFilter>, ?aKey:String, ?bKey:String):Query2<A, B> {
        return queryPair(a, b, aKey, bKey).filterAll(filters);
    }

    public function queryTriple<A, B, C>(a:Class<A>, b:Class<B>, c:Class<C>, ?aKey:String, ?bKey:String, ?cKey:String):Query3<A, B, C> {
        return new Query3<A, B, C>(this, a, b, c, queryDataLookupKey(a, aKey), queryDataLookupKey(b, bKey), queryDataLookupKey(c, cKey));
    }

    public function queryFilteredTriple<A, B, C>(a:Class<A>, b:Class<B>, c:Class<C>, filters:Array<bevy.ecs.QueryFilter>, ?aKey:String, ?bKey:String, ?cKey:String):Query3<A, B, C> {
        return queryTriple(a, b, c, aKey, bKey, cKey).filterAll(filters);
    }

    public function queryOne<T>(cls:Class<T>, filters:Array<bevy.ecs.QueryFilter>, ?componentKey:String):Array<QueryItem<T>> {
        var result:Array<QueryItem<T>> = [];
        var entityData = Type.getClassName(cast cls) == Type.getClassName(Entity);
        var typeKey = entityData ? null : componentLookupKey(cls, componentKey);
        for (index => storage in components) {
            var entity = entityForIndex(index);
            if (entity == null || !matchesFilters(entity, storage, filters)) {
                continue;
            }
            if (!entityData && !storage.exists(typeKey)) {
                continue;
            }
            result.push({
                entity: entity,
                component: entityData ? cast entity : cast storage.get(typeKey)
            });
        }
        return result;
    }

    public function queryTwo<A, B>(a:Class<A>, b:Class<B>, filters:Array<bevy.ecs.QueryFilter>, ?aKey:String, ?bKey:String):Array<QueryItem2<A, B>> {
        var result:Array<QueryItem2<A, B>> = [];
        var aEntityData = isEntityClass(a);
        var bEntityData = isEntityClass(b);
        var resolvedAKey = aEntityData ? null : componentLookupKey(a, aKey);
        var resolvedBKey = bEntityData ? null : componentLookupKey(b, bKey);
        for (index => storage in components) {
            var entity = entityForIndex(index);
            if (entity == null || !matchesFilters(entity, storage, filters)) {
                continue;
            }
            if ((!aEntityData && !storage.exists(resolvedAKey)) || (!bEntityData && !storage.exists(resolvedBKey))) {
                continue;
            }
            result.push({
                entity: entity,
                a: aEntityData ? cast entity : cast storage.get(resolvedAKey),
                b: bEntityData ? cast entity : cast storage.get(resolvedBKey)
            });
        }
        return result;
    }

    public function queryThree<A, B, C>(a:Class<A>, b:Class<B>, c:Class<C>, filters:Array<bevy.ecs.QueryFilter>, ?aKey:String, ?bKey:String, ?cKey:String):Array<QueryItem3<A, B, C>> {
        var result:Array<QueryItem3<A, B, C>> = [];
        var aEntityData = isEntityClass(a);
        var bEntityData = isEntityClass(b);
        var cEntityData = isEntityClass(c);
        var resolvedAKey = aEntityData ? null : componentLookupKey(a, aKey);
        var resolvedBKey = bEntityData ? null : componentLookupKey(b, bKey);
        var resolvedCKey = cEntityData ? null : componentLookupKey(c, cKey);
        for (index => storage in components) {
            var entity = entityForIndex(index);
            if (entity == null
                || !matchesFilters(entity, storage, filters)) {
                continue;
            }
            if ((!aEntityData && !storage.exists(resolvedAKey))
                || (!bEntityData && !storage.exists(resolvedBKey))
                || (!cEntityData && !storage.exists(resolvedCKey))) {
                continue;
            }
            result.push({
                entity: entity,
                a: aEntityData ? cast entity : cast storage.get(resolvedAKey),
                b: bEntityData ? cast entity : cast storage.get(resolvedBKey),
                c: cEntityData ? cast entity : cast storage.get(resolvedCKey)
            });
        }
        return result;
    }

    public function insertResource<T>(resource:T):T {
        resources.set(resourceStorageKey(resource), resource);
        return resource;
    }

    public function getResourceOrInsert<T>(resource:T):T {
        var key = resourceStorageKey(resource);
        var existing:T = cast resources.get(key);
        if (existing != null) {
            return existing;
        }
        resources.set(key, resource);
        return resource;
    }

    public function getResourceOrInsertByKey<T>(key:String, resource:T):T {
        var normalized = TypeKey.named(key);
        var existing:T = cast resources.get(normalized);
        if (existing != null) {
            return existing;
        }
        resources.set(normalized, resource);
        return resource;
    }

    public function initResource<T>(cls:Class<T>):T {
        var existing = getResource(cls);
        if (existing != null) {
            return existing;
        }

        var created = createResource(cls);
        insertResource(created);
        return created;
    }

    public function getResourceOrInit<T>(cls:Class<T>):T {
        return initResource(cls);
    }

    public function insertResourceByKey<T>(key:String, resource:T):T {
        resources.set(TypeKey.named(key), resource);
        return resource;
    }

    public function getResource<T>(cls:Class<T>):Null<T> {
        return cast resources.get(TypeKey.ofClass(cls));
    }

    public function getResourceByKey<T>(key:String):Null<T> {
        return cast resources.get(TypeKey.named(key));
    }

    public function removeResource<T>(cls:Class<T>):Null<T> {
        var key = TypeKey.ofClass(cls);
        var value:T = cast resources.get(key);
        resources.remove(key);
        return value;
    }

    public function removeResourceByKey<T>(key:String):Null<T> {
        var normalized = TypeKey.named(key);
        var value:T = cast resources.get(normalized);
        resources.remove(normalized);
        return value;
    }

    public function hasResource<T>(cls:Class<T>):Bool {
        return resources.exists(TypeKey.ofClass(cls));
    }

    public function hasResourceByKey(key:String):Bool {
        return resources.exists(TypeKey.named(key));
    }

    public function containsResource<T>(cls:Class<T>):Bool {
        return hasResource(cls);
    }

    public function containsResourceByKey(key:String):Bool {
        return hasResourceByKey(key);
    }

    public function resourceScope<R:Resource, T>(cls:Class<R>, scope:(World, R) -> T):T {
        var resource = getResource(cls);
        if (resource == null) {
            throw new MissingResourceError(Type.getClassName(cls), "Missing resource for resourceScope");
        }
        return scope(this, resource);
    }

    public function resourceScopeByKey<R, T>(key:String, scope:(World, R) -> T):T {
        var normalized = TypeKey.named(key);
        var resource:R = cast resources.get(normalized);
        if (resource == null) {
            throw new MissingResourceError(normalized, "Missing resource for resourceScopeByKey");
        }
        return scope(this, resource);
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

    public function clearEvents():Void {
        for (store in events) {
            var typed:Events<Dynamic> = cast store;
            typed.clear();
        }
    }

    public function tick():Int {
        return changeTick;
    }

    public function advanceTick():Void {
        changeTick++;
    }

    public function isChanged<T>(entity:Entity, cls:Class<T>, sinceTick:Int, ?componentKey:String):Bool {
        return isChangedByKey(entity, componentLookupKey(cls, componentKey), sinceTick);
    }

    public function isAdded<T>(entity:Entity, cls:Class<T>, sinceTick:Int, ?componentKey:String):Bool {
        return isAddedByKey(entity, componentLookupKey(cls, componentKey), sinceTick);
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

    public function iterEntities():Array<EntityRef> {
        var result:Array<EntityRef> = [];
        for (index in 0...entities.length) {
            var entity = entityForIndex(index);
            if (entity != null) {
                result.push(new EntityRef(this, entity));
            }
        }
        return result;
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

    private function matchesFilters(entity:Entity, storage:Map<String, Dynamic>, filters:Array<bevy.ecs.QueryFilter>):Bool {
        for (filter in filters) {
            if (!matchesFilterNode(entity, storage, filter.node())) {
                return false;
            }
        }
        return true;
    }

    private function matchesFilterNode(entity:Entity, storage:Map<String, Dynamic>, node:QueryFilterNode):Bool {
        return switch node {
            case Single(spec):
                switch spec.kind {
                    case Require:
                        storage.exists(spec.typeKey);
                    case Exclude:
                        !storage.exists(spec.typeKey);
                    case AddedSince(sinceTick):
                        storage.exists(spec.typeKey) && isAddedByKey(entity, spec.typeKey, sinceTick);
                    case ChangedSince(sinceTick):
                        storage.exists(spec.typeKey) && isChangedByKey(entity, spec.typeKey, sinceTick);
                }
            case AllOf(children):
                var matched = true;
                for (child in children) {
                    if (!matchesFilterNode(entity, storage, child)) {
                        matched = false;
                        break;
                    }
                }
                matched;
            case AnyOf(children):
                var matched = false;
                for (child in children) {
                    if (matchesFilterNode(entity, storage, child)) {
                        matched = true;
                        break;
                    }
                }
                matched;
        };
    }

    private function assertAlive(entity:Entity):Void {
        if (!isAlive(entity)) {
            throw new EntityNotAliveError(entity);
        }
    }

    private function componentChangeKey(entity:Entity, typeKey:String):String {
        return entity.key() + ":" + typeKey;
    }

    private function isChangedByKey(entity:Entity, typeKey:String, sinceTick:Int):Bool {
        var value = changedComponents.get(componentChangeKey(entity, typeKey));
        return value != null && value > sinceTick;
    }

    private function isAddedByKey(entity:Entity, typeKey:String, sinceTick:Int):Bool {
        var value = addedComponents.get(componentChangeKey(entity, typeKey));
        return value != null && value > sinceTick;
    }

    private function createResource<T>(cls:Class<T>):T {
        var fromWorld = Reflect.field(cls, "fromWorld");
        if (fromWorld != null) {
            return cast Reflect.callMethod(cls, fromWorld, [this]);
        }

        var createDefault = Reflect.field(cls, "createDefault");
        if (createDefault != null) {
            return cast Reflect.callMethod(cls, createDefault, []);
        }

        throw new ResourceInitError(Type.getClassName(cls));
    }

    private function componentLookupKey<T>(cls:Class<T>, typeKey:Null<String>):String {
        if (typeKey != null && typeKey != "") {
            return TypeKey.named(typeKey);
        }
        return TypeKey.ofClass(cls);
    }

    private function queryDataLookupKey<T>(cls:Class<T>, typeKey:Null<String>):Null<String> {
        return isEntityClass(cls) && (typeKey == null || typeKey == "") ? null : componentLookupKey(cls, typeKey);
    }

    private function isEntityClass<T>(cls:Class<T>):Bool {
        return Type.getClassName(cast cls) == Type.getClassName(Entity);
    }

    private function componentStorageKey(component:Dynamic):String {
        var explicit = Reflect.field(component, "componentKey");
        if (Std.isOfType(explicit, String) && explicit != null && explicit != "") {
            return TypeKey.named(cast explicit);
        }
        return TypeKey.ofInstance(component);
    }

    private function resourceStorageKey(resource:Dynamic):String {
        var explicit = Reflect.field(resource, "resourceKey");
        if (Std.isOfType(explicit, String) && explicit != null && explicit != "") {
            return TypeKey.named(cast explicit);
        }
        return TypeKey.ofInstance(resource);
    }
}
