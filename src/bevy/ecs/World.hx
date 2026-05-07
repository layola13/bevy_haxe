package bevy.ecs;

import bevy.ecs.EcsError.EntityDoesNotExistError;
import bevy.ecs.EcsError.EntityNotAliveError;
import bevy.ecs.EcsError.EntityAlreadySpawnedError;
import bevy.ecs.EcsError.EntityNotSpawnedKind;
import bevy.ecs.EcsError.MissingResourceError;
import bevy.ecs.EcsError.ResourceInitError;
import bevy.ecs.EcsError.SpawnError;
import bevy.ecs.EcsError.SpawnErrorKind;
import bevy.ecs.EcsError.TypeKeyError;
import bevy.ecs.EcsError.TypeKeyErrorKind;
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

    public function reserveEntity():Entity {
        var index:Int;
        var generation:Int;
        if (freeIndices.length > 0) {
            index = freeIndices.pop();
            var location = entities[index];
            generation = location.generation;
            location.alive = false;
            location.spawnTick = 0;
            location.spawnedBy = null;
        } else {
            index = entities.length;
            generation = 1;
            entities.push(new EntityLocation(generation, false));
        }
        return new Entity(index, generation);
    }

    public function reserveEntities(count:Int):Array<Entity> {
        var result:Array<Entity> = [];
        if (count <= 0) {
            return result;
        }
        for (_ in 0...count) {
            result.push(reserveEntity());
        }
        return result;
    }

    public function spawn(?bundle:Array<Dynamic>):Entity {
        return spawnReserved(reserveEntity(), bundle);
    }

    public function spawnReserved(entity:Entity, ?bundle:Array<Dynamic>, ?spawnedBy:String):Entity {
        var location = entityLocation(entity);
        if (location == null || location.generation != entity.generation) {
            throw new SpawnError(entity, SpawnErrorKind.Invalid(currentGenerationForEntity(entity)));
        }
        if (location.alive) {
            throw new EntityAlreadySpawnedError(entity);
        }

        location.alive = true;
        location.spawnTick = changeTick;
        location.spawnedBy = spawnedBy != null ? spawnedBy : captureSpawnedBy();
        var storage = components.get(entity.index);
        if (storage == null) {
            storage = new Map();
            components.set(entity.index, storage);
        }
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

    public function spawnBatch(bundles:Array<Bundle>):Array<Entity> {
        var result:Array<Entity> = [];
        if (bundles == null || bundles.length == 0) {
            return result;
        }
        var reserved = reserveEntities(bundles.length);
        for (i in 0...bundles.length) {
            result.push(spawnReserved(reserved[i], bundles[i].toBundle()));
        }
        return result;
    }

    public function spawnEmpty():EntityWorldMut {
        return new EntityWorldMut(this, spawn());
    }

    public function despawn(entity:Entity):Bool {
        var location = entityLocation(entity);
        if (location == null || location.generation != entity.generation) {
            return false;
        }
        if (location.alive) {
            components.remove(entity.index);
        }
        location.alive = false;
        location.spawnTick = 0;
        location.spawnedBy = null;
        location.generation++;
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
        if (entity == null) {
            return false;
        }
        var location = entityLocation(entity);
        return location != null && location.generation == entity.generation;
    }

    public function getEntity(entity:Entity):Null<EntityRef> {
        return isAlive(entity) ? new EntityRef(this, entity) : null;
    }

    public function entity(entity:Entity):EntityRef {
        var value = getEntity(entity);
        if (value == null) {
            throw new EntityDoesNotExistError(entity, entityNotSpawnedKind(entity));
        }
        return value;
    }

    public function getEntityMut(entity:Entity):Null<EntityWorldMut> {
        return isAlive(entity) ? new EntityWorldMut(this, entity) : null;
    }

    public function entityMut(entity:Entity):EntityWorldMut {
        var value = getEntityMut(entity);
        if (value == null) {
            throw new EntityDoesNotExistError(entity, entityNotSpawnedKind(entity));
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

    @:allow(bevy.ecs.Query)
    private function hasByKey(entity:Entity, typeKey:Null<String>):Bool {
        if (!isAlive(entity) || typeKey == null) {
            return false;
        }
        var storage = components.get(entity.index);
        return storage != null && storage.exists(TypeKey.named(typeKey));
    }

    public function query<T>(cls:Class<T>, ?componentKey:String):Query<T> {
        return new Query<T>(this, cls, queryDataLookupKey(cls, componentKey));
    }

    public function queryFiltered<T>(cls:Class<T>, filters:Array<bevy.ecs.QueryFilter>, ?componentKey:String, lastRunTick:Int = 0):Query<T> {
        return new Query<T>(this, cls, queryDataLookupKey(cls, componentKey), lastRunTick).filterAll(filters);
    }

    public function queryPair<A, B>(a:Class<A>, b:Class<B>, ?aKey:String, ?bKey:String, lastRunTick:Int = 0):Query2<A, B> {
        return new Query2<A, B>(this, a, b, queryDataLookupKey(a, aKey), queryDataLookupKey(b, bKey), lastRunTick);
    }

    public function queryFilteredPair<A, B>(a:Class<A>, b:Class<B>, filters:Array<bevy.ecs.QueryFilter>, ?aKey:String, ?bKey:String, lastRunTick:Int = 0):Query2<A, B> {
        return queryPair(a, b, aKey, bKey, lastRunTick).filterAll(filters);
    }

    public function queryTriple<A, B, C>(a:Class<A>, b:Class<B>, c:Class<C>, ?aKey:String, ?bKey:String, ?cKey:String, lastRunTick:Int = 0):Query3<A, B, C> {
        return new Query3<A, B, C>(this, a, b, c, queryDataLookupKey(a, aKey), queryDataLookupKey(b, bKey), queryDataLookupKey(c, cKey), lastRunTick);
    }

    public function queryFilteredTriple<A, B, C>(a:Class<A>, b:Class<B>, c:Class<C>, filters:Array<bevy.ecs.QueryFilter>, ?aKey:String, ?bKey:String, ?cKey:String, lastRunTick:Int = 0):Query3<A, B, C> {
        return queryTriple(a, b, c, aKey, bKey, cKey, lastRunTick).filterAll(filters);
    }

    public function queryOne<T>(cls:Class<T>, filters:Array<bevy.ecs.QueryFilter>, ?componentKey:String, lastRunTick:Int = 0):Array<QueryItem<T>> {
        var result:Array<QueryItem<T>> = [];
        var entityData = isEntityClass(cls);
        var spawnDetailsData = isSpawnDetailsClass(cls);
        var hasData = isHasClass(cls);
        var optionData = isOptionClass(cls);
        var refData = isRefClass(cls);
        var mutData = isMutClass(cls);
        var syntheticData = entityData || spawnDetailsData || hasData || optionData || refData || mutData;
        var typeKey = syntheticData ? componentKey : componentLookupKey(cls, componentKey);
        for (index => storage in components) {
            var entity = entityForIndex(index);
            if (entity == null || !matchesFilters(entity, storage, filters)) {
                continue;
            }
            if (!syntheticData && !storage.exists(typeKey)) {
                continue;
            }
            if ((refData || mutData) && (typeKey == null || !storage.exists(typeKey))) {
                continue;
            }
            result.push({
                entity: entity,
                component: entityData ? cast entity : spawnDetailsData ? cast spawnDetails(entity, lastRunTick) : hasData ? cast hasQueryData(storage, typeKey) : optionData ? cast optionQueryData(storage, typeKey) : refData ? cast refQueryData(entity, storage, typeKey, lastRunTick) : mutData ? cast mutQueryData(entity, storage, typeKey, lastRunTick) : cast storage.get(typeKey)
            });
        }
        return result;
    }

    public function queryTwo<A, B>(a:Class<A>, b:Class<B>, filters:Array<bevy.ecs.QueryFilter>, ?aKey:String, ?bKey:String, lastRunTick:Int = 0):Array<QueryItem2<A, B>> {
        var result:Array<QueryItem2<A, B>> = [];
        var aEntityData = isEntityClass(a);
        var bEntityData = isEntityClass(b);
        var aSpawnDetailsData = isSpawnDetailsClass(a);
        var bSpawnDetailsData = isSpawnDetailsClass(b);
        var aHasData = isHasClass(a);
        var bHasData = isHasClass(b);
        var aOptionData = isOptionClass(a);
        var bOptionData = isOptionClass(b);
        var aRefData = isRefClass(a);
        var bRefData = isRefClass(b);
        var aMutData = isMutClass(a);
        var bMutData = isMutClass(b);
        var aAnyOfKeys = parseAnyOfQueryDataKey(aKey);
        var bAnyOfKeys = parseAnyOfQueryDataKey(bKey);
        var aAnyOfData = aAnyOfKeys != null;
        var bAnyOfData = bAnyOfKeys != null;
        var aSyntheticData = aEntityData || aSpawnDetailsData || aHasData || aOptionData || aRefData || aMutData;
        var bSyntheticData = bEntityData || bSpawnDetailsData || bHasData || bOptionData || bRefData || bMutData;
        var aRuntimeSyntheticData = aSyntheticData || aAnyOfData;
        var bRuntimeSyntheticData = bSyntheticData || bAnyOfData;
        var resolvedAKey = aSyntheticData ? aKey : componentLookupKey(a, aKey);
        var resolvedBKey = bSyntheticData ? bKey : componentLookupKey(b, bKey);
        for (index => storage in components) {
            var entity = entityForIndex(index);
            if (entity == null || !matchesFilters(entity, storage, filters)) {
                continue;
            }
            if ((!aRuntimeSyntheticData && !storage.exists(resolvedAKey)) || (!bRuntimeSyntheticData && !storage.exists(resolvedBKey))) {
                continue;
            }
            if ((aRefData || aMutData) && (resolvedAKey == null || !storage.exists(resolvedAKey))) {
                continue;
            }
            if ((bRefData || bMutData) && (resolvedBKey == null || !storage.exists(resolvedBKey))) {
                continue;
            }
            if (aAnyOfData && !anyOfMatches(storage, aAnyOfKeys)) {
                continue;
            }
            if (bAnyOfData && !anyOfMatches(storage, bAnyOfKeys)) {
                continue;
            }
            result.push({
                entity: entity,
                a: aEntityData ? cast entity : aSpawnDetailsData ? cast spawnDetails(entity, lastRunTick) : aHasData ? cast hasQueryData(storage, resolvedAKey) : aOptionData ? cast optionQueryData(storage, resolvedAKey) : aRefData ? cast refQueryData(entity, storage, resolvedAKey, lastRunTick) : aMutData ? cast mutQueryData(entity, storage, resolvedAKey, lastRunTick) : aAnyOfData ? cast anyOfQueryData(cast a, entity, storage, aAnyOfKeys, lastRunTick) : cast storage.get(resolvedAKey),
                b: bEntityData ? cast entity : bSpawnDetailsData ? cast spawnDetails(entity, lastRunTick) : bHasData ? cast hasQueryData(storage, resolvedBKey) : bOptionData ? cast optionQueryData(storage, resolvedBKey) : bRefData ? cast refQueryData(entity, storage, resolvedBKey, lastRunTick) : bMutData ? cast mutQueryData(entity, storage, resolvedBKey, lastRunTick) : bAnyOfData ? cast anyOfQueryData(cast b, entity, storage, bAnyOfKeys, lastRunTick) : cast storage.get(resolvedBKey)
            });
        }
        return result;
    }

    public function queryThree<A, B, C>(a:Class<A>, b:Class<B>, c:Class<C>, filters:Array<bevy.ecs.QueryFilter>, ?aKey:String, ?bKey:String, ?cKey:String, lastRunTick:Int = 0):Array<QueryItem3<A, B, C>> {
        var result:Array<QueryItem3<A, B, C>> = [];
        var aEntityData = isEntityClass(a);
        var bEntityData = isEntityClass(b);
        var cEntityData = isEntityClass(c);
        var aSpawnDetailsData = isSpawnDetailsClass(a);
        var bSpawnDetailsData = isSpawnDetailsClass(b);
        var cSpawnDetailsData = isSpawnDetailsClass(c);
        var aHasData = isHasClass(a);
        var bHasData = isHasClass(b);
        var cHasData = isHasClass(c);
        var aOptionData = isOptionClass(a);
        var bOptionData = isOptionClass(b);
        var cOptionData = isOptionClass(c);
        var aRefData = isRefClass(a);
        var bRefData = isRefClass(b);
        var cRefData = isRefClass(c);
        var aMutData = isMutClass(a);
        var bMutData = isMutClass(b);
        var cMutData = isMutClass(c);
        var aAnyOfKeys = parseAnyOfQueryDataKey(aKey);
        var bAnyOfKeys = parseAnyOfQueryDataKey(bKey);
        var cAnyOfKeys = parseAnyOfQueryDataKey(cKey);
        var aAnyOfData = aAnyOfKeys != null;
        var bAnyOfData = bAnyOfKeys != null;
        var cAnyOfData = cAnyOfKeys != null;
        var aSyntheticData = aEntityData || aSpawnDetailsData || aHasData || aOptionData || aRefData || aMutData;
        var bSyntheticData = bEntityData || bSpawnDetailsData || bHasData || bOptionData || bRefData || bMutData;
        var cSyntheticData = cEntityData || cSpawnDetailsData || cHasData || cOptionData || cRefData || cMutData;
        var aRuntimeSyntheticData = aSyntheticData || aAnyOfData;
        var bRuntimeSyntheticData = bSyntheticData || bAnyOfData;
        var cRuntimeSyntheticData = cSyntheticData || cAnyOfData;
        var resolvedAKey = aSyntheticData ? aKey : componentLookupKey(a, aKey);
        var resolvedBKey = bSyntheticData ? bKey : componentLookupKey(b, bKey);
        var resolvedCKey = cSyntheticData ? cKey : componentLookupKey(c, cKey);
        for (index => storage in components) {
            var entity = entityForIndex(index);
            if (entity == null
                || !matchesFilters(entity, storage, filters)) {
                continue;
            }
            if ((!aRuntimeSyntheticData && !storage.exists(resolvedAKey))
                || (!bRuntimeSyntheticData && !storage.exists(resolvedBKey))
                || (!cRuntimeSyntheticData && !storage.exists(resolvedCKey))) {
                continue;
            }
            if ((aRefData || aMutData) && (resolvedAKey == null || !storage.exists(resolvedAKey))) {
                continue;
            }
            if ((bRefData || bMutData) && (resolvedBKey == null || !storage.exists(resolvedBKey))) {
                continue;
            }
            if ((cRefData || cMutData) && (resolvedCKey == null || !storage.exists(resolvedCKey))) {
                continue;
            }
            if (aAnyOfData && !anyOfMatches(storage, aAnyOfKeys)) {
                continue;
            }
            if (bAnyOfData && !anyOfMatches(storage, bAnyOfKeys)) {
                continue;
            }
            if (cAnyOfData && !anyOfMatches(storage, cAnyOfKeys)) {
                continue;
            }
            result.push({
                entity: entity,
                a: aEntityData ? cast entity : aSpawnDetailsData ? cast spawnDetails(entity, lastRunTick) : aHasData ? cast hasQueryData(storage, resolvedAKey) : aOptionData ? cast optionQueryData(storage, resolvedAKey) : aRefData ? cast refQueryData(entity, storage, resolvedAKey, lastRunTick) : aMutData ? cast mutQueryData(entity, storage, resolvedAKey, lastRunTick) : aAnyOfData ? cast anyOfQueryData(cast a, entity, storage, aAnyOfKeys, lastRunTick) : cast storage.get(resolvedAKey),
                b: bEntityData ? cast entity : bSpawnDetailsData ? cast spawnDetails(entity, lastRunTick) : bHasData ? cast hasQueryData(storage, resolvedBKey) : bOptionData ? cast optionQueryData(storage, resolvedBKey) : bRefData ? cast refQueryData(entity, storage, resolvedBKey, lastRunTick) : bMutData ? cast mutQueryData(entity, storage, resolvedBKey, lastRunTick) : bAnyOfData ? cast anyOfQueryData(cast b, entity, storage, bAnyOfKeys, lastRunTick) : cast storage.get(resolvedBKey),
                c: cEntityData ? cast entity : cSpawnDetailsData ? cast spawnDetails(entity, lastRunTick) : cHasData ? cast hasQueryData(storage, resolvedCKey) : cOptionData ? cast optionQueryData(storage, resolvedCKey) : cRefData ? cast refQueryData(entity, storage, resolvedCKey, lastRunTick) : cMutData ? cast mutQueryData(entity, storage, resolvedCKey, lastRunTick) : cAnyOfData ? cast anyOfQueryData(cast c, entity, storage, cAnyOfKeys, lastRunTick) : cast storage.get(resolvedCKey)
            });
        }
        return result;
    }

    @:allow(bevy.ecs.Query)
    private function queryTuple(items:Array<Class<Any>>, filters:Array<bevy.ecs.QueryFilter>, ?itemKeys:Array<Null<String>>, lastRunTick:Int = 0):Array<{entity:Entity, components:Array<Any>}> {
        var result:Array<{entity:Entity, components:Array<Any>}> = [];
        if (items == null || items.length == 0) {
            return result;
        }

        var syntheticData:Array<Bool> = [];
        var spawnDetailsData:Array<Bool> = [];
        var hasData:Array<Bool> = [];
        var optionData:Array<Bool> = [];
        var refData:Array<Bool> = [];
        var mutData:Array<Bool> = [];
        var anyOfData:Array<Bool> = [];
        var anyOfKeys:Array<Null<Array<String>>> = [];
        var resolvedKeys:Array<Null<String>> = [];
        for (i in 0...items.length) {
            var cls = items[i];
            var isSyntheticData = isSyntheticQueryDataClass(cast cls);
            var isSpawnDetailsData = isSpawnDetailsClass(cast cls);
            var isHasData = isHasClass(cast cls);
            var isOptionData = isOptionClass(cast cls);
            var isRefData = isRefClass(cast cls);
            var isMutData = isMutClass(cast cls);
            var explicitKey = itemKeys != null && i < itemKeys.length ? itemKeys[i] : null;
            var itemAnyOfKeys = parseAnyOfQueryDataKey(explicitKey);
            var isAnyOfData = itemAnyOfKeys != null;
            syntheticData.push(isSyntheticData);
            spawnDetailsData.push(isSpawnDetailsData);
            hasData.push(isHasData);
            optionData.push(isOptionData);
            refData.push(isRefData);
            mutData.push(isMutData);
            anyOfData.push(isAnyOfData);
            anyOfKeys.push(itemAnyOfKeys);
            if (isSyntheticData || isAnyOfData) {
                resolvedKeys.push(isHasData || isOptionData || isRefData || isMutData ? explicitKey : null);
                continue;
            }
            resolvedKeys.push(componentLookupKey(cast cls, explicitKey));
        }

        for (index => storage in components) {
            var entity = entityForIndex(index);
            if (entity == null || !matchesFilters(entity, storage, filters)) {
                continue;
            }

            var values:Array<Any> = [];
            var matched = true;
            for (i in 0...items.length) {
                if (anyOfData[i]) {
                    var nestedAnyOfKeys = anyOfKeys[i];
                    if (!anyOfMatches(storage, nestedAnyOfKeys)) {
                        matched = false;
                        break;
                    }
                    values.push(anyOfQueryData(cast items[i], entity, storage, nestedAnyOfKeys, lastRunTick));
                    continue;
                }
                if (syntheticData[i]) {
                    var key = resolvedKeys[i];
                    if ((refData[i] || mutData[i]) && (key == null || !storage.exists(key))) {
                        matched = false;
                        break;
                    }
                    values.push(spawnDetailsData[i] ? spawnDetails(entity, lastRunTick) : hasData[i] ? hasQueryData(storage, key) : optionData[i] ? optionQueryData(storage, key) : refData[i] ? refQueryData(entity, storage, key, lastRunTick) : mutData[i] ? mutQueryData(entity, storage, key, lastRunTick) : entity);
                    continue;
                }

                var key = resolvedKeys[i];
                if (!storage.exists(key)) {
                    matched = false;
                    break;
                }
                values.push(storage.get(key));
            }

            if (!matched) {
                continue;
            }

            result.push({
                entity: entity,
                components: values
            });
        }

        return result;
    }

    @:allow(bevy.ecs.Query)
    private function queryAnyOf(items:Array<Class<Any>>, filters:Array<bevy.ecs.QueryFilter>, ?itemKeys:Array<Null<String>>, lastRunTick:Int = 0):Array<{entity:Entity, components:Array<Any>}> {
        var result:Array<{entity:Entity, components:Array<Any>}> = [];
        if (items == null || items.length == 0) {
            return result;
        }

        for (index => storage in components) {
            var entity = entityForIndex(index);
            if (entity == null || !matchesFilters(entity, storage, filters)) {
                continue;
            }

            var values:Array<Any> = [];
            var matched = false;
            for (i in 0...items.length) {
                var explicitKey = itemKeys != null && i < itemKeys.length ? itemKeys[i] : null;
                var item = anyOfBranchQueryData(cast items[i], explicitKey, entity, storage, lastRunTick);
                var present = item.present;
                if (present) {
                    matched = true;
                }
                values.push(new Option<Any>(present ? cast item.value : null));
            }

            if (!matched) {
                continue;
            }

            result.push({
                entity: entity,
                components: values
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

    private function entityLocation(entity:Entity):Null<EntityLocation> {
        if (entity == null || entity.index < 0 || entity.index >= entities.length) {
            return null;
        }
        return entities[entity.index];
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
                    case SpawnedSince(sinceTick):
                        isSpawnedSince(entity, sinceTick);
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
            throw new EntityNotAliveError(entity, entityNotSpawnedKind(entity));
        }
    }

    private function entityNotSpawnedKind(entity:Entity):EntityNotSpawnedKind {
        var location = entityLocation(entity);
        if (location == null || location.generation != entity.generation) {
            return EntityNotSpawnedKind.Invalid(currentGenerationForEntity(entity));
        }
        return EntityNotSpawnedKind.ValidButNotSpawned;
    }

    private function currentGenerationForEntity(entity:Entity):Null<Int> {
        if (entity == null || entity.index < 0 || entity.index >= entities.length) {
            return null;
        }
        return entities[entity.index].generation;
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

    private function isSpawnedSince(entity:Entity, sinceTick:Int):Bool {
        var location = entityLocation(entity);
        return location != null
            && location.alive
            && location.generation == entity.generation
            && location.spawnTick > sinceTick;
    }

    @:allow(bevy.ecs.Query)
    private function spawnDetails(entity:Entity, lastRunTick:Int):Null<SpawnDetails> {
        var location = entityLocation(entity);
        if (location == null || !location.alive || location.generation != entity.generation) {
            return null;
        }
        return new SpawnDetails(location.spawnTick, lastRunTick, changeTick, location.spawnedBy);
    }

    private function hasQueryData(storage:Map<String, Dynamic>, typeKey:Null<String>):Has<Any> {
        return new Has<Any>(typeKey != null && storage.exists(typeKey));
    }

    private function optionQueryData(storage:Map<String, Dynamic>, typeKey:Null<String>):Option<Any> {
        return new Option<Any>(typeKey != null && storage.exists(typeKey) ? cast storage.get(typeKey) : null);
    }

    private function anyOfMatches(storage:Map<String, Dynamic>, keys:Null<Array<String>>):Bool {
        if (keys == null || keys.length == 0) {
            return false;
        }
        for (key in keys) {
            var decodeKey = decodeAnyOfBranchKey(key);
            if (anyOfBranchMatches(decodeKey, storage)) {
                return true;
            }
        }
        return false;
    }

    private function anyOfQueryData(cls:Class<Any>, entity:Entity, storage:Map<String, Dynamic>, keys:Null<Array<String>>, lastRunTick:Int):Any {
        var values:Array<Any> = [];
        if (keys != null) {
            for (key in keys) {
                var branch = anyOfBranchQueryDataByKey(key, entity, storage, lastRunTick);
                values.push(new Option<Any>(branch.present ? cast branch.value : null));
            }
        }
        return Type.createInstance(cls, values);
    }

    private inline function decodeAnyOfBranchKey(rawKey:Null<String>):Null<String> {
        if (rawKey == null || rawKey == "") {
            return null;
        }
        var key = rawKey;
        if (!StringTools.startsWith(key, QueryDataKey.ANY_OF_ITEM_COMPONENT_PREFIX)
            && !StringTools.startsWith(key, QueryDataKey.ANY_OF_ITEM_HAS_PREFIX)
            && !StringTools.startsWith(key, QueryDataKey.ANY_OF_ITEM_OPTION_PREFIX)
            && !StringTools.startsWith(key, QueryDataKey.ANY_OF_ITEM_REF_PREFIX)
            && !StringTools.startsWith(key, QueryDataKey.ANY_OF_ITEM_MUT_PREFIX)
            && key != QueryDataKey.ANY_OF_ITEM_ENTITY
            && key != QueryDataKey.ANY_OF_ITEM_SPAWN_DETAILS) {
            key = QueryDataKey.ANY_OF_ITEM_COMPONENT_PREFIX + key;
        }
        return key;
    }

    private inline function anyOfInnerKey(rawKey:String, prefix:String):String {
        return rawKey.substr(prefix.length);
    }

    private function anyOfBranchMatches(rawKey:Null<String>, storage:Map<String, Dynamic>):Bool {
        if (rawKey == null || rawKey == "") {
            return false;
        }
        var key = rawKey;
        if (StringTools.startsWith(key, QueryDataKey.ANY_OF_ITEM_COMPONENT_PREFIX)) {
            var componentKey = anyOfInnerKey(key, QueryDataKey.ANY_OF_ITEM_COMPONENT_PREFIX);
            return componentKey != "" && storage.exists(componentKey);
        }
        if (StringTools.startsWith(key, QueryDataKey.ANY_OF_ITEM_HAS_PREFIX)) {
            return true;
        }
        if (StringTools.startsWith(key, QueryDataKey.ANY_OF_ITEM_OPTION_PREFIX)) {
            return true;
        }
        if (StringTools.startsWith(key, QueryDataKey.ANY_OF_ITEM_REF_PREFIX) || StringTools.startsWith(key, QueryDataKey.ANY_OF_ITEM_MUT_PREFIX)) {
            var refMutKey = StringTools.startsWith(key, QueryDataKey.ANY_OF_ITEM_REF_PREFIX)
                ? anyOfInnerKey(key, QueryDataKey.ANY_OF_ITEM_REF_PREFIX)
                : anyOfInnerKey(key, QueryDataKey.ANY_OF_ITEM_MUT_PREFIX);
            return refMutKey != "" && storage.exists(refMutKey);
        }
        if (key == QueryDataKey.ANY_OF_ITEM_ENTITY || key == QueryDataKey.ANY_OF_ITEM_SPAWN_DETAILS) {
            return true;
        }
        return false;
    }

    private function anyOfBranchQueryDataByKey(rawKey:Null<String>, entity:Entity, storage:Map<String, Dynamic>, lastRunTick:Int):{present:Bool, value:Any} {
        var keyForDecode = decodeAnyOfBranchKey(rawKey);
        if (keyForDecode == null || keyForDecode == "") {
            return {present: false, value: null};
        }

        if (StringTools.startsWith(keyForDecode, QueryDataKey.ANY_OF_ITEM_COMPONENT_PREFIX)) {
            var componentKey = anyOfInnerKey(keyForDecode, QueryDataKey.ANY_OF_ITEM_COMPONENT_PREFIX);
            var present = componentKey != "" && storage.exists(componentKey);
            return {present: present, value: present ? cast storage.get(componentKey) : null};
        }

        if (StringTools.startsWith(keyForDecode, QueryDataKey.ANY_OF_ITEM_HAS_PREFIX)) {
            var hasKey = anyOfInnerKey(keyForDecode, QueryDataKey.ANY_OF_ITEM_HAS_PREFIX);
            return {present: true, value: hasQueryData(storage, hasKey)};
        }

        if (StringTools.startsWith(keyForDecode, QueryDataKey.ANY_OF_ITEM_OPTION_PREFIX)) {
            var optionKey = anyOfInnerKey(keyForDecode, QueryDataKey.ANY_OF_ITEM_OPTION_PREFIX);
            return {present: true, value: optionQueryData(storage, optionKey)};
        }

        if (StringTools.startsWith(keyForDecode, QueryDataKey.ANY_OF_ITEM_REF_PREFIX)) {
            var refKey = anyOfInnerKey(keyForDecode, QueryDataKey.ANY_OF_ITEM_REF_PREFIX);
            if (refKey == "" || !storage.exists(refKey)) {
                return {present: false, value: null};
            }
            return {present: true, value: refQueryData(entity, storage, refKey, lastRunTick)};
        }

        if (StringTools.startsWith(keyForDecode, QueryDataKey.ANY_OF_ITEM_MUT_PREFIX)) {
            var mutKey = anyOfInnerKey(keyForDecode, QueryDataKey.ANY_OF_ITEM_MUT_PREFIX);
            if (mutKey == "" || !storage.exists(mutKey)) {
                return {present: false, value: null};
            }
            return {present: true, value: mutQueryData(entity, storage, mutKey, lastRunTick)};
        }

        if (keyForDecode == QueryDataKey.ANY_OF_ITEM_ENTITY) {
            return {present: true, value: entity};
        }

        if (keyForDecode == QueryDataKey.ANY_OF_ITEM_SPAWN_DETAILS) {
            var details = spawnDetails(entity, lastRunTick);
            return {present: details != null, value: details};
        }

        return {present: false, value: null};
    }

    private function anyOfBranchQueryData(
        cls:Class<Any>,
        rawKey:Null<String>,
        entity:Entity,
        storage:Map<String, Dynamic>,
        lastRunTick:Int
    ):{present:Bool, value:Any} {
        var keyForDecode = rawKey;
        if (keyForDecode == null || keyForDecode == "") {
            keyForDecode = anyOfDefaultBranchKey(cls);
            if (keyForDecode == null || keyForDecode == "") {
                return {present: false, value: null};
            }
        }
        return anyOfBranchQueryDataByKey(keyForDecode, entity, storage, lastRunTick);
    }

    private function anyOfDefaultBranchKey(cls:Class<Any>):Null<String> {
        var clsName = Type.getClassName(cast cls);
        if (clsName == null || clsName == "") {
            return null;
        }
        if (clsName == "bevy.ecs.Entity") {
            return QueryDataKey.ANY_OF_ITEM_ENTITY;
        }
        if (clsName == "bevy.ecs.SpawnDetails") {
            return QueryDataKey.ANY_OF_ITEM_SPAWN_DETAILS;
        }
        if (clsName == "bevy.ecs.Has" || clsName == "bevy.ecs.Option" || clsName == "bevy.ecs.Ref" || clsName == "bevy.ecs.Mut") {
            return null;
        }
        return QueryDataKey.ANY_OF_ITEM_COMPONENT_PREFIX + componentLookupKey(cast cls, null);
    }

    private function parseAnyOfQueryDataKey(typeKey:Null<String>):Null<Array<String>> {
        return QueryDataKey.parseAnyOfKeys(typeKey);
    }

    private function refQueryData(entity:Entity, storage:Map<String, Dynamic>, typeKey:Null<String>, lastRunTick:Int):Ref<Any> {
        var key = typeKey;
        if (key == null || key == "") {
            throw new TypeKeyError(TypeKeyErrorKind.EmptyName);
        }
        key = TypeKey.named(key);
        var value:Any = cast storage.get(key);
        var changeKey = componentChangeKey(entity, key);
        var addedTick = addedComponents.get(changeKey);
        var changedTick = changedComponents.get(changeKey);
        return new Ref<Any>(value, addedTick != null ? addedTick : 0, changedTick != null ? changedTick : 0, lastRunTick, changeTick);
    }

    private function mutQueryData(entity:Entity, storage:Map<String, Dynamic>, typeKey:Null<String>, lastRunTick:Int):Mut<Any> {
        var key = typeKey;
        if (key == null || key == "") {
            throw new TypeKeyError(TypeKeyErrorKind.EmptyName);
        }
        key = TypeKey.named(key);
        var value:Any = cast storage.get(key);
        var changeKey = componentChangeKey(entity, key);
        var addedTick = addedComponents.get(changeKey);
        var changedTick = changedComponents.get(changeKey);
        return new Mut<Any>(value, addedTick != null ? addedTick : 0, changedTick != null ? changedTick : 0, lastRunTick, changeTick, function() {
            changedComponents.set(changeKey, changeTick);
        });
    }

    @:allow(bevy.ecs.Commands)
    private static function captureSpawnedBy():String {
        var stack = haxe.CallStack.callStack();
        for (item in stack) {
            var value = Std.string(item);
            if (value.indexOf("captureSpawnedBy") >= 0
                || value.indexOf("bevy.ecs.World.spawn") >= 0
                || value.indexOf("bevy.ecs.Commands.spawn") >= 0
                || value.indexOf("bevy.ecs.Commands.apply") >= 0) {
                continue;
            }
            return value;
        }
        return Std.string(stack);
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
        if (isEntityClass(cls) || isSpawnDetailsClass(cls)) {
            return typeKey == null || typeKey == "" ? null : componentLookupKey(cls, typeKey);
        }
        if (isHasClass(cls)) {
            return typeKey == null || typeKey == "" ? null : TypeKey.named(typeKey);
        }
        if (isOptionClass(cls)) {
            return typeKey == null || typeKey == "" ? null : TypeKey.named(typeKey);
        }
        return componentLookupKey(cls, typeKey);
    }

    private function isEntityClass<T>(cls:Class<T>):Bool {
        return Type.getClassName(cast cls) == Type.getClassName(Entity);
    }

    private function isSpawnDetailsClass<T>(cls:Class<T>):Bool {
        return Type.getClassName(cast cls) == Type.getClassName(SpawnDetails);
    }

    private function isHasClass<T>(cls:Class<T>):Bool {
        return Type.getClassName(cast cls) == Type.getClassName(Has);
    }

    private function isOptionClass<T>(cls:Class<T>):Bool {
        return Type.getClassName(cast cls) == Type.getClassName(Option);
    }

    private function isRefClass<T>(cls:Class<T>):Bool {
        return Type.getClassName(cast cls) == Type.getClassName(Ref);
    }

    private function isMutClass<T>(cls:Class<T>):Bool {
        return Type.getClassName(cast cls) == Type.getClassName(Mut);
    }

    private function isSyntheticQueryDataClass<T>(cls:Class<T>):Bool {
        return isEntityClass(cls) || isSpawnDetailsClass(cls) || isHasClass(cls) || isOptionClass(cls) || isRefClass(cls) || isMutClass(cls);
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
