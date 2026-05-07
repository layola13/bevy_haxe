package ecs;

using bevy.asset.AssetLoad;

import bevy.app.App;
import bevy.ecs.Commands;
import bevy.ecs.Bundle;
import bevy.ecs.Component;
import bevy.ecs.EcsError.EntityDoesNotExistError;
import bevy.ecs.EcsError.EntityNotSpawnedError;
import bevy.ecs.EcsError.EntityNotSpawnedKind;
import bevy.ecs.EcsError.DuplicateEntityError;
import bevy.ecs.EcsError.InvalidEntityError;
import bevy.ecs.Entity;
import bevy.ecs.Event;
import bevy.ecs.Events;
import bevy.ecs.EcsError.MissingResourceError;
import bevy.ecs.EcsError.QueryDoesNotMatchError;
import bevy.ecs.EcsError.QueryEntityNotSpawnedError;
import bevy.ecs.EcsError.QuerySingleKind;
import bevy.ecs.EcsError.QuerySingleMultipleEntitiesError;
import bevy.ecs.EcsError.QuerySingleMissingError;
import bevy.ecs.EcsError.QuerySingleNoEntitiesError;
import bevy.ecs.EcsError.QueryFilterError;
import bevy.ecs.EcsError.QueryFilterErrorKind;
import bevy.ecs.EcsError.SpawnError;
import bevy.ecs.EcsError.SpawnErrorKind;
import bevy.ecs.EcsError.TypeKeyError;
import bevy.ecs.EcsError.TypeKeyErrorKind;
import bevy.ecs.Resource;
import bevy.ecs.UniqueEntityArray;
import bevy.ecs.World;
import bevy.ecs.With;
import bevy.ecs.Without;
import bevy.ecs.Added;
import bevy.ecs.Changed;
import bevy.ecs.Spawned;
import bevy.ecs.SpawnDetails;
import bevy.ecs.Has;
import bevy.ecs.Option;
import bevy.ecs.Ref;
import bevy.ecs.Mut;
import bevy.ecs.QueryDataKey;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.AnyOf;
import bevy.ecs.All;
import bevy.ecs.Or;
import bevy.asset.Asset;
import bevy.asset.AssetLoader;
import bevy.asset.AssetPlugin;
import bevy.asset.AssetServer;
import bevy.asset.Assets;
import bevy.asset.Handle;
import bevy.async.AsyncRuntime;
import bevy.async.Future;

typedef PositionVelocityAnyOf = AnyOf<Position, Velocity>;
typedef EntityMutHealthAnyOf = AnyOf<Entity, Mut<Health>>;
typedef HasOptionHealthAnyOf = AnyOf<Has<Health>, Option<Health>>;

class EcsCoreTest {
    static function main():Void {
        testEntityGeneration();
        testComponentsAndQueries();
        testResources();
        testEvents();
        testCommands();
        testBundles();
        testChangeTicks();
        testGenericHandleComponents();
        testDedicatedQueryFilters();
        testSpawnedQueryFilter();
        testSpawnDetailsQueryData();
        testHasQueryData();
        testOptionQueryData();
        testAnyOfQueryData();
        testRefMutQueryData();
        testFilteredPairQueries();
        testTripleQueries();
        testEntityMixedQueries();
        testInitResource();
        testWorldResourceScopes();
        testQueryEntityAccess();
        testEntityWorldAccess();
        testQueryCountAndStrictGetMany();
        testQueryUniqueEntityAccess();
        testQueryIterCombinations();
        testCommandEntityAccess();
        testCommandGetEntitySemantics();
        testDeferredSpawnSemantics();
        testSpawnBatchSemantics();
        testReservedEntityAccessSemantics();
        testTypedEcsErrors();
        testTypeKeyTypedErrors();
        testQueryFilterTypedErrors();
        trace("EcsCoreTest ok");
    }

    static function testEntityGeneration():Void {
        var world = new World();
        var first = world.spawn();
        assert(world.isAlive(first), "spawned entity should be alive");
        assert(world.containsEntity(first), "spawned entity id should be valid");
        assert(world.despawn(first), "despawn should succeed");
        assert(!world.isAlive(first), "old entity handle should be dead");
        assert(!world.containsEntity(first), "despawned entity id should become stale");
        var second = world.spawn();
        assert(first.index == second.index, "freed entity index should be reused");
        assert(first.generation != second.generation, "generation should change on reuse");
    }

    static function testComponentsAndQueries():Void {
        var world = new World();
        var player = world.spawn([new Position(1, 2), new Velocity(3, 4), new PlayerTag()]);
        var enemy = world.spawn([new Position(5, 6), new EnemyTag()]);

        assertEq(2, world.query(Position).toArray().length, "position query");
        assertEq(1, world.queryPair(Position, Velocity).toArray().length, "pair query");
        assertEq(1, world.query(Position).with(PlayerTag).toArray().length, "with filter");
        assertEq(1, world.query(Position).without(Velocity).toArray().length, "without filter");
        assert(!world.query(Velocity).isEmpty(), "query should report non-empty results");
        assertEq(player.index, world.query(Velocity).single().entity.index, "single query should return only match");

        var pos = world.get(player, Position);
        assertEq(1, pos.x, "get component");
        assert(world.remove(enemy, EnemyTag) != null, "remove component");
        assert(!world.has(enemy, EnemyTag), "removed component should be absent");
    }

    static function testResources():Void {
        var world = new World();
        world.insertResource(new TimeResource(0.5));
        assertEq(0.5, world.getResource(TimeResource).delta, "resource get");
        assert(world.removeResource(TimeResource) != null, "resource remove");
        assert(world.getResource(TimeResource) == null, "resource absent after remove");
    }

    static function testEvents():Void {
        var world = new World();
        var events = world.initEvents(DamageEvent);
        var reader = events.reader();
        world.sendEvent(new DamageEvent(7));
        var seen = reader.read();
        assertEq(1, seen.length, "event reader count");
        assertEq(7, seen[0].amount, "event value");
    }

    static function testCommands():Void {
        var world = new World();
        var entity = world.spawn();
        var commands = world.commands();
        commands.insert(entity, new Position(10, 20));
        assert(!world.has(entity, Position), "commands are deferred");
        commands.apply();
        assert(world.has(entity, Position), "commands apply insert");

        commands.despawn(entity);
        commands.apply();
        assert(!world.isAlive(entity), "commands apply despawn");
    }

    static function testBundles():Void {
        var world = new World();
        var entity = world.spawnBundle(new MovingBundle(new Position(2, 3), new Velocity(4, 5)));
        assert(world.has(entity, Position), "bundle should insert position");
        assert(world.has(entity, Velocity), "bundle should insert velocity");

        var commands = world.commands();
        var deferred = commands.spawnBundle(new MovingBundle(new Position(8, 9), new Velocity(1, 1)));
        assert(!world.has(deferred, Position), "command bundle insert is deferred");
        commands.apply();
        assert(world.has(deferred, Position), "command bundle insert applies");
    }

    static function testChangeTicks():Void {
        var world = new World();
        var entity = world.spawn([new Position(0, 0)]);
        var tick = world.tick();
        assert(!world.isAdded(entity, Position, tick), "same tick is not after sinceTick");
        world.advanceTick();
        var before = world.tick();
        world.insert(entity, new Position(1, 1));
        assert(world.isChanged(entity, Position, before - 1), "changed component tracked");
    }

    static function testGenericHandleComponents():Void {
        var app = new App();
        app.addPlugin(new AssetPlugin(function(path) return Future.resolved(path)));
        app.initAsset(TestAssetA);
        app.initAsset(TestAssetB);
        app.registerAssetLoader(AssetLoader.create(TestAssetA, ["a"], function(path) {
            return Future.resolved(new TestAssetA(path));
        }));
        app.registerAssetLoader(AssetLoader.create(TestAssetB, ["b"], function(path) {
            return Future.resolved(new TestAssetB(path));
        }));

        var server:AssetServer = app.world.getResource(AssetServer);
        var aHandle:Handle<TestAssetA> = server.load("first.a");
        var bHandle:Handle<TestAssetB> = server.load("second.b");
        AsyncRuntime.flush();

        var both = app.world.spawn([aHandle, bHandle]);
        var onlyA = app.world.spawn([aHandle]);
        assert(app.world.has(both, Handle, aHandle.componentKey), "world should store first typed handle component");
        assert(app.world.has(both, Handle, bHandle.componentKey), "world should store second typed handle component");

        var readA:Handle<TestAssetA> = app.world.get(both, Handle, aHandle.componentKey);
        var readB:Handle<TestAssetB> = app.world.get(both, Handle, bHandle.componentKey);
        assert(readA != null && readA.equals(aHandle), "typed handle A should round-trip");
        assert(readB != null && readB.equals(bHandle), "typed handle B should round-trip");

        var aMatches = app.world.query(Handle, aHandle.componentKey).toArray();
        var bMatches = app.world.query(Handle, bHandle.componentKey).toArray();
        var onlyAMatches = app.world.query(Handle, aHandle.componentKey).without(Handle, bHandle.componentKey).toArray();
        var bothMatches = app.world.query(Handle, aHandle.componentKey).with(Handle, bHandle.componentKey).toArray();
        assertEq(2, aMatches.length, "query should find both first typed handle carriers");
        assertEq(1, bMatches.length, "query should find only second typed handle");
        assertEq(1, onlyAMatches.length, "without filter should exclude entities with the second typed handle");
        assertEq(1, bothMatches.length, "with filter should match entity carrying both typed handles");
        assertEq(aHandle.id, cast(aMatches[0].component, Handle<Dynamic>).id, "query A should return first handle");
        assertEq(bHandle.id, cast(bMatches[0].component, Handle<Dynamic>).id, "query B should return second handle");
        assertEq(onlyA.index, onlyAMatches[0].entity.index, "typed filter should keep single-handle entity");
    }

    static function testDedicatedQueryFilters():Void {
        var world = new World();
        var sinceSpawn = world.tick() - 1;
        var player = world.spawn([new Position(1, 1), new PlayerTag()]);
        var enemy = world.spawn([new Position(2, 2), new Velocity(3, 3)]);

        var withPlayer = world.queryFiltered(Position, [With.of(PlayerTag)]).toArray();
        var withoutVelocity = world.queryFiltered(Position, [Without.of(Velocity)]).toArray();
        var addedPlayer = world.queryFiltered(Position, [Added.of(PlayerTag, sinceSpawn)]).toArray();
        var allPlayerAdded = world.queryFiltered(Position, [All.of([With.of(PlayerTag), Added.of(PlayerTag, sinceSpawn)])]).toArray();
        var playerOrVelocity = world.queryFiltered(Position, [Or.of([With.of(PlayerTag), With.of(Velocity)])]).toArray();
        assertEq(1, withPlayer.length, "With<T> filter should match tagged entity");
        assertEq(player.index, withPlayer[0].entity.index, "With<T> should keep player entity");
        assertEq(1, withoutVelocity.length, "Without<T> filter should exclude velocity entity");
        assertEq(player.index, withoutVelocity[0].entity.index, "Without<T> should keep player entity");
        assertEq(1, addedPlayer.length, "Added<T> filter should detect spawn-time inserts");
        assertEq(player.index, addedPlayer[0].entity.index, "Added<T> should keep newly added tag");
        assertEq(1, allPlayerAdded.length, "All filter should require all child filters");
        assertEq(player.index, allPlayerAdded[0].entity.index, "All filter should keep player entity");
        assertEq(2, playerOrVelocity.length, "Or filter should match either child filter");

        world.advanceTick();
        var beforeChange = world.tick();
        world.insert(enemy, new Position(9, 9));
        var changedPosition = world.queryFiltered(Position, [Changed.of(Position, beforeChange - 1)]).toArray();
        var playerOrChanged = world.queryFiltered(Position, [Or.of([With.of(PlayerTag), Changed.of(Position, beforeChange - 1)])]).toArray();
        assertEq(1, changedPosition.length, "Changed<T> filter should detect updated component");
        assertEq(enemy.index, changedPosition[0].entity.index, "Changed<T> should keep changed entity");
        assertEq(2, playerOrChanged.length, "Or filter should compose change and presence filters");
    }

    static function testSpawnedQueryFilter():Void {
        var world = new World();
        var initial = world.spawn([new Position(1, 1), new PlayerTag()]);

        var firstSeen = world.queryFiltered(Position, [Spawned.of(0)]).toArray();
        assertEq(1, firstSeen.length, "Spawned filter should include entities spawned before first query run");
        assertEq(initial.index, firstSeen[0].entity.index, "Spawned filter should keep the initially spawned entity");

        world.advanceTick();
        var afterInitialSince = world.tick() - 1;
        assertEq(0, world.queryFiltered(Position, [Spawned.of(afterInitialSince)]).count(), "Spawned filter should stop matching old spawns after the caller advances its last-run tick");

        var commands = world.commands();
        var deferred = commands.spawn([new Position(2, 2)]);
        assert(world.containsEntity(deferred), "deferred spawned entity id should be reserved before apply");
        assert(!world.isAlive(deferred), "deferred spawned entity should not be alive before command apply");
        assertEq(0, world.queryFiltered(Position, [Spawned.of(afterInitialSince)]).count(), "Spawned filter should not see deferred command spawns before apply");

        commands.apply();
        var afterApply = world.queryFiltered(Position, [Spawned.of(afterInitialSince)]).toArray();
        assertEq(1, afterApply.length, "Spawned filter should see command spawns after deferred apply");
        assertEq(deferred.index, afterApply[0].entity.index, "Spawned filter should keep the newly materialized command entity");
    }

    static function testSpawnDetailsQueryData():Void {
        var world = new World();
        var initial = world.spawn([new Position(1, 1)]);

        var direct = world.query(SpawnDetails).single();
        assert(direct.component.isSpawned(), "SpawnDetails should report first-run spawned state for direct query data");
        assertEq(world.tick(), direct.component.spawnTick(), "SpawnDetails should expose the entity spawn tick");
        assert(direct.component.spawnedBy() != null && direct.component.spawnedBy().length > 0, "SpawnDetails should expose a non-empty spawn source");

        var pair = world.queryPair(Entity, SpawnDetails).single();
        assertEq(initial.index, pair.a.index, "Query2<Entity, SpawnDetails> should keep Entity query data");
        assert(pair.b.isSpawnedAfter(0), "SpawnDetails.isSpawnedAfter should compare against an explicit tick");

        world.advanceTick();
        var afterInitialSince = world.tick() - 1;
        var staleDetails = world.queryPair(Entity, SpawnDetails, null, null, afterInitialSince).single();
        assert(!staleDetails.b.isSpawned(), "SpawnDetails should stop reporting old spawns after last-run advances");

        var commands = world.commands();
        var deferred = commands.spawn([new Position(2, 2)]);
        commands.apply();

        var deferredDetails = world.queryPair(Entity, SpawnDetails, null, null, afterInitialSince).get(deferred);
        assert(deferredDetails != null, "Query2<Entity, SpawnDetails>.get should resolve a newly applied command spawn");
        assert(deferredDetails.b.isSpawned(), "SpawnDetails should report command-spawned entities after deferred apply");
        assert(deferredDetails.b.spawnedBy() != null && deferredDetails.b.spawnedBy().length > 0, "SpawnDetails should preserve command spawn source captured at queue time");
        assertEq(deferred.index, deferredDetails.a.index, "SpawnDetails query should preserve the requested entity");
    }

    static function testHasQueryData():Void {
        var world = new World();
        var player = world.spawn([new Position(1, 1), new PlayerTag("tracked")]);
        var untagged = world.spawn([new Position(2, 2)]);
        var tagOnly = world.spawn([new PlayerTag("only-tag")]);

        var hasPlayerTag = world.query(Has, bevy.ecs.TypeKey.ofClass(PlayerTag));
        assertEq(3, hasPlayerTag.count(), "Query<Has<T>> should match all spawned entities, not only entities with T");
        assert(hasPlayerTag.get(player).component.value, "Query<Has<T>> should report true when the entity has T");
        assert(!hasPlayerTag.get(untagged).component.value, "Query<Has<T>> should report false when the entity lacks T");
        assert(hasPlayerTag.get(tagOnly).component.isPresent(), "Has<T>.isPresent should mirror the stored presence bit");

        var positioned = world.queryPair(Position, Has, null, bevy.ecs.TypeKey.ofClass(PlayerTag));
        assertEq(2, positioned.count(), "Query2<Component, Has<T>> should still be constrained by real component data");
        assert(positioned.get(player).b.value, "Query2<Component, Has<T>> should return true for matching component presence");
        assert(!positioned.get(untagged).b.value, "Query2<Component, Has<T>>.get should not reject absent T");

        var triple = world.queryTriple(Entity, Position, Has, null, null, bevy.ecs.TypeKey.ofClass(PlayerTag));
        assertEq(2, triple.count(), "Query3<Entity, Component, Has<T>> should support Has<T> in synthetic data slots");
        assertEq(player.index, triple.get(player).a.index, "Query3<Entity, Component, Has<T>> should preserve Entity query data");
        assert(!triple.get(untagged).c.value, "Query3<Entity, Component, Has<T>> should preserve false Has<T> values");

        var handleAKey = bevy.ecs.TypeKey.ofParameterizedClass(Handle, [cast TestAssetA]);
        var handleBKey = bevy.ecs.TypeKey.ofParameterizedClass(Handle, [cast TestAssetB]);
        var bothHandles = world.spawn([new Position(3, 3), new Handle<TestAssetA>(10, handleAKey), new Handle<TestAssetB>(20, handleBKey)]);
        var onlyHandleA = world.spawn([new Position(4, 4), new Handle<TestAssetA>(11, handleAKey)]);
        var handlePresence = world.queryPair(Handle, Has, handleAKey, handleBKey);
        assertEq(2, handlePresence.count(), "Query2<Handle<A>, Has<Handle<B>>> should use parameterized component keys");
        assert(handlePresence.get(bothHandles).b.value, "Has<Handle<B>> should report true for the entity carrying the parameterized B handle");
        assert(!handlePresence.get(onlyHandleA).b.value, "Has<Handle<B>> should report false for an entity carrying only Handle<A>");
    }

    static function testOptionQueryData():Void {
        var world = new World();
        var player = world.spawn([new Position(1, 1), new PlayerTag("optional")]);
        var untagged = world.spawn([new Position(2, 2)]);
        var velocityOnly = world.spawn([new Velocity(3, 3)]);

        var optionalPlayerTag = world.query(Option, bevy.ecs.TypeKey.ofClass(PlayerTag));
        assertEq(3, optionalPlayerTag.count(), "Query<Option<T>> should match all spawned entities, not only entities with T");
        assert(optionalPlayerTag.get(player).component.isSome(), "Query<Option<T>> should return Some when T is present");
        assertEq("optional", optionalPlayerTag.get(player).component.value.marker, "Query<Option<T>> should preserve the component value");
        assert(optionalPlayerTag.get(untagged).component.isNone(), "Query<Option<T>> should return None when T is absent");
        assert(optionalPlayerTag.get(velocityOnly).component.unwrapOrNull() == null, "Option<T>.unwrapOrNull should expose null for None");

        var positioned = world.queryPair(Position, Option, null, bevy.ecs.TypeKey.ofClass(PlayerTag));
        assertEq(2, positioned.count(), "Query2<Component, Option<T>> should still be constrained by real component data");
        assert(positioned.get(player).b.isSome(), "Query2<Component, Option<T>> should return Some for matching component presence");
        assert(positioned.get(untagged).b.isNone(), "Query2<Component, Option<T>>.get should not reject absent T");

        var triple = world.queryTriple(Entity, Position, Option, null, null, bevy.ecs.TypeKey.ofClass(PlayerTag));
        assertEq(2, triple.count(), "Query3<Entity, Component, Option<T>> should support Option<T> in synthetic data slots");
        assertEq(player.index, triple.get(player).a.index, "Query3<Entity, Component, Option<T>> should preserve Entity query data");
        assert(triple.get(untagged).c.isNone(), "Query3<Entity, Component, Option<T>> should preserve None values");

        var handleAKey = bevy.ecs.TypeKey.ofParameterizedClass(Handle, [cast TestAssetA]);
        var handleBKey = bevy.ecs.TypeKey.ofParameterizedClass(Handle, [cast TestAssetB]);
        var bothHandles = world.spawn([new Handle<TestAssetA>(30, handleAKey), new Handle<TestAssetB>(40, handleBKey)]);
        var onlyHandleA = world.spawn([new Handle<TestAssetA>(31, handleAKey)]);
        var handlePresence = world.queryPair(Handle, Option, handleAKey, handleBKey);
        assertEq(2, handlePresence.count(), "Query2<Handle<A>, Option<Handle<B>>> should use parameterized component keys");
        assertEq(40, handlePresence.get(bothHandles).b.value.id, "Option<Handle<B>> should return the parameterized B handle when present");
        assert(handlePresence.get(onlyHandleA).b.isNone(), "Option<Handle<B>> should return None for an entity carrying only Handle<A>");
    }

    static function testAnyOfQueryData():Void {
        var world = new World();
        var onlyPosition = world.spawn([new Position(5, 50)]);
        var onlyVelocity = world.spawn([new Velocity(7, 70)]);
        var both = world.spawn([new Position(11, 110), new Velocity(13, 130)]);
        var neither = world.spawn([new PlayerTag()]);

        var encodedAnyKey = QueryDataKey.encodeAnyOfKeys([
            bevy.ecs.TypeKey.ofClass(Position),
            bevy.ecs.TypeKey.ofClass(Velocity)
        ]);

        var topLevelAny = new bevy.ecs.Query.QueryAnyOf<PositionVelocityAnyOf, bevy.ecs.QueryFilter>(
            world,
            PositionVelocityAnyOf,
            function(raw:Array<Any>) return new PositionVelocityAnyOf(cast raw[0], cast raw[1]),
            [cast Position, cast Velocity],
            [null, null],
            [],
            0
        );
        assertEq(3, topLevelAny.count(), "Query<AnyOf<...>> should match entities with at least one branch component");

        var onlyPositionItem = topLevelAny.get(onlyPosition);
        assert(onlyPositionItem != null, "AnyOf query should resolve entity with first branch only");
        assert(onlyPositionItem.component._0.isSome(), "AnyOf first branch should be Some when Position exists");
        assertEq(5, onlyPositionItem.component._0.value.x, "AnyOf should preserve first branch component payload");
        assert(onlyPositionItem.component._1.isNone(), "AnyOf second branch should be None when Velocity is absent");

        var onlyVelocityItem = topLevelAny.get(onlyVelocity);
        assert(onlyVelocityItem != null, "AnyOf query should resolve entity with second branch only");
        assert(onlyVelocityItem.component._0.isNone(), "AnyOf first branch should be None when Position is absent");
        assert(onlyVelocityItem.component._1.isSome(), "AnyOf second branch should be Some when Velocity exists");
        assertEq(7, onlyVelocityItem.component._1.value.x, "AnyOf should preserve second branch component payload");

        var bothItem = topLevelAny.get(both);
        assert(bothItem != null, "AnyOf query should resolve entity with both branches");
        assert(bothItem.component._0.isSome() && bothItem.component._1.isSome(), "AnyOf should expose Some in both branches when both components exist");
        assert(topLevelAny.get(neither) == null, "AnyOf query should reject entities with no branch components");

        var keyedPair = world.queryPair(PositionVelocityAnyOf, Position, encodedAnyKey, null);
        assertEq(2, keyedPair.count(), "Query2<AnyOf<...>, Position> should support AnyOf nested query data");
        assert(keyedPair.get(onlyPosition) != null, "Query2 nested AnyOf should resolve entity with first branch");
        assert(keyedPair.get(both) != null, "Query2 nested AnyOf should resolve entity with both branches");
        assert(keyedPair.get(onlyVelocity) == null, "Query2 nested AnyOf should still require second non-synthetic query component");

        var tripleAny = world.queryTriple(Entity, PositionVelocityAnyOf, Position, null, encodedAnyKey, null);
        assertEq(2, tripleAny.count(), "Query3<..., AnyOf<...>, Position> should support AnyOf synthetic data slots");
        var tripleBoth = tripleAny.get(both);
        assert(tripleBoth != null, "Query3 nested AnyOf should resolve matching entity");
        assertEq(both.index, tripleBoth.a.index, "Query3 nested AnyOf should preserve Entity query data");
        assert(tripleBoth.b._0.isSome() && tripleBoth.b._1.isSome(), "Query3 nested AnyOf should preserve branch Option values");

        var tracked = world.spawn([new Health(21), new PlayerTag("tracked")]);
        var untracked = world.spawn([new PlayerTag("plain")]);
        var entityMutAny = new bevy.ecs.Query.QueryAnyOf<EntityMutHealthAnyOf, bevy.ecs.QueryFilter>(
            world,
            EntityMutHealthAnyOf,
            function(raw:Array<Any>) return new EntityMutHealthAnyOf(cast raw[0], cast raw[1]),
            [cast Entity, cast Mut],
            [
                QueryDataKey.anyOfEntityItem(),
                QueryDataKey.anyOfMutItem(bevy.ecs.TypeKey.ofClass(Health))
            ],
            [],
            0
        );
        assertEq(6, entityMutAny.count(), "AnyOf<Entity, Mut<T>> should match all spawned entities");

        var trackedAny = entityMutAny.get(tracked);
        assert(trackedAny != null, "AnyOf<Entity, Mut<T>> should resolve entity carrying T");
        assert(trackedAny.component._0.isSome(), "AnyOf<Entity, Mut<T>> should expose Entity branch as Some");
        assertEq(tracked.index, trackedAny.component._0.value.index, "AnyOf<Entity, Mut<T>> should preserve entity id");
        assert(trackedAny.component._1.isSome(), "AnyOf<Entity, Mut<T>> should expose Mut<T> branch as Some when T exists");
        trackedAny.component._1.value.value.value = 34;
        trackedAny.component._1.value.setChanged();
        assertEq(34, world.get(tracked, Health).value, "AnyOf<Entity, Mut<T>> should persist Mut<T> world writes");

        var untrackedAny = entityMutAny.get(untracked);
        assert(untrackedAny != null, "AnyOf<Entity, Mut<T>> should resolve entity without T because Entity branch matches");
        assert(untrackedAny.component._0.isSome(), "Entity branch should stay Some on entities without T");
        assert(untrackedAny.component._1.isNone(), "Mut<T> branch should be None when T is absent");

        var hasOptionAny = new bevy.ecs.Query.QueryAnyOf<HasOptionHealthAnyOf, bevy.ecs.QueryFilter>(
            world,
            HasOptionHealthAnyOf,
            function(raw:Array<Any>) return new HasOptionHealthAnyOf(cast raw[0], cast raw[1]),
            [cast Has, cast Option],
            [
                QueryDataKey.anyOfHasItem(bevy.ecs.TypeKey.ofClass(Health)),
                QueryDataKey.anyOfOptionItem(bevy.ecs.TypeKey.ofClass(Health))
            ],
            [],
            0
        );
        assertEq(6, hasOptionAny.count(), "AnyOf<Has<T>, Option<T>> should match all spawned entities");

        var trackedHasOption = hasOptionAny.get(tracked);
        assert(trackedHasOption != null, "AnyOf<Has<T>, Option<T>> should resolve entity carrying T");
        assert(trackedHasOption.component._0.isSome() && trackedHasOption.component._0.value.value, "Has<T> branch should be Some(true) when T exists");
        assert(trackedHasOption.component._1.isSome() && trackedHasOption.component._1.value.isSome(), "Option<T> branch should be Some(Some(T)) when T exists");

        var untrackedHasOption = hasOptionAny.get(untracked);
        assert(untrackedHasOption != null, "AnyOf<Has<T>, Option<T>> should resolve entity without T");
        assert(untrackedHasOption.component._0.isSome() && !untrackedHasOption.component._0.value.value, "Has<T> branch should be Some(false) when T is absent");
        assert(untrackedHasOption.component._1.isSome() && untrackedHasOption.component._1.value.isNone(), "Option<T> branch should be Some(None) when T is absent");
    }

    static function testRefMutQueryData():Void {
        var world = new World();
        var tracked = world.spawn([new Position(10, 20), new Velocity(1, 2)]);
        var velocityOnly = world.spawn([new Velocity(3, 4)]);

        var initialRef = world.query(Ref, bevy.ecs.TypeKey.ofClass(Position));
        assertEq(1, initialRef.count(), "Query<Ref<T>> should require the queried component");
        var trackedRef = initialRef.get(tracked);
        assert(trackedRef != null, "Query<Ref<T>> should resolve matching entity");
        assertEq(10, trackedRef.component.value.x, "Ref<T> should expose the typed component");
        assert(trackedRef.component.isAdded(), "Ref<T>.isAdded should include spawn-time insertion on first observation window");
        assert(trackedRef.component.isChanged(), "Ref<T>.isChanged should include spawn-time insertion on first observation window");
        assertEq(world.tick(), trackedRef.component.added(), "Ref<T>.added should expose component added tick");
        assertEq(world.tick(), trackedRef.component.lastChanged(), "Ref<T>.lastChanged should expose component changed tick");
        assert(trackedRef.component.thisRunTick() >= trackedRef.component.lastRunTick(), "Ref<T> should expose run tick bounds");

        assert(initialRef.get(velocityOnly) == null, "Query<Ref<T>> should not match entities without T");

        world.advanceTick();
        var afterInitialSince = world.tick() - 1;
        var staleRef = world.queryFiltered(Ref, [With.of(Position)], bevy.ecs.TypeKey.ofClass(Position), afterInitialSince).get(tracked);
        assert(staleRef != null, "Query<Ref<T>, With<T>> should still resolve matching entities");
        assert(!staleRef.component.isAdded(), "Ref<T>.isAdded should be false once the caller advances last-run tick");
        assert(!staleRef.component.isChanged(), "Ref<T>.isChanged should be false when there was no change after last-run");

        world.insert(tracked, new Position(40, 50));
        var changedRef = world.queryFiltered(Ref, [With.of(Position)], bevy.ecs.TypeKey.ofClass(Position), afterInitialSince).get(tracked);
        assert(changedRef != null, "Query<Ref<T>> should keep matching after replacing T");
        assert(!changedRef.component.isAdded(), "Replacing an existing component should not flip Ref<T>.isAdded back to true");
        assert(changedRef.component.isChanged(), "Replacing an existing component should set Ref<T>.isChanged");
        assertEq(40, changedRef.component.value.x, "Ref<T> should expose updated component value");

        var pair = world.queryPair(Position, Ref, null, bevy.ecs.TypeKey.ofClass(Velocity));
        assertEq(1, pair.count(), "Query2<Component, Ref<T>> should require the base component and Ref target");
        var pairItem = pair.get(tracked);
        assert(pairItem != null, "Query2<Component, Ref<T>> should resolve matching entity");
        assertEq(1, pairItem.b.value.x, "Ref<T> inside Query2 should preserve queried component value");

        var mutQuery = world.query(Mut, bevy.ecs.TypeKey.ofClass(Position));
        var mutItem = mutQuery.get(tracked);
        assert(mutItem != null, "Query<Mut<T>> should resolve matching entity");
        assert(mutItem.component.isChangedAfter(afterInitialSince), "Mut<T> should expose changed-after metadata before explicit mark");

        world.advanceTick();
        var afterMutAdvance = world.tick() - 1;
        var staleMut = world.queryFiltered(Mut, [With.of(Position)], bevy.ecs.TypeKey.ofClass(Position), afterMutAdvance).get(tracked);
        assert(staleMut != null, "Query<Mut<T>> should still resolve matching entity after advancing caller tick");
        assert(!staleMut.component.isChanged(), "Mut<T>.isChanged should be false when no change happened since last-run");
        staleMut.component.value.x = 77;
        staleMut.component.setChanged();
        assert(staleMut.component.isChanged(), "Mut<T>.setChanged should flip changed state for current run");
        assertEq(staleMut.component.thisRunTick(), staleMut.component.lastChanged(), "Mut<T>.setChanged should update lastChanged to this-run tick");
        assertEq(77, world.get(tracked, Position).x, "Mut<T> should update the underlying world component value");
        assert(world.isChanged(tracked, Position, afterMutAdvance), "Mut<T>.setChanged should persist change-tick update to World");

        var triple = world.queryTriple(Entity, Position, Mut, null, null, bevy.ecs.TypeKey.ofClass(Velocity));
        var tripleItem = triple.get(tracked);
        assert(tripleItem != null, "Query3<Entity, Component, Mut<T>> should support Mut<T> synthetic data");
        assertEq(tracked.index, tripleItem.a.index, "Query3 mixed Entity/Mut should preserve Entity data slot");
        assertEq(1, tripleItem.c.value.x, "Mut<T> inside Query3 should preserve queried component value");
    }

    static function testFilteredPairQueries():Void {
        var world = new World();
        var player = world.spawn([new Position(1, 1), new Velocity(2, 2), new PlayerTag()]);
        world.spawn([new Position(3, 3), new Velocity(4, 4)]);

        var filtered = world.queryFilteredPair(Position, Velocity, [With.of(PlayerTag)]).toArray();
        assertEq(1, filtered.length, "queryFilteredPair should honor typed filters");
        assertEq(player.index, filtered[0].entity.index, "queryFilteredPair should keep matching entity");
    }

    static function testTripleQueries():Void {
        var world = new World();
        var player = world.spawn([new Position(1, 1), new Velocity(2, 2), new EnemyTag(), new PlayerTag()]);
        world.spawn([new Position(3, 3), new Velocity(4, 4), new EnemyTag()]);

        var triples = world.queryTriple(Position, Velocity, EnemyTag).toArray();
        var filtered = world.queryFilteredTriple(Position, Velocity, EnemyTag, [With.of(PlayerTag)]).toArray();
        assertEq(2, triples.length, "queryTriple should return all matching entities");
        assertEq(1, filtered.length, "queryFilteredTriple should honor typed filters");
        assertEq(player.index, filtered[0].entity.index, "queryFilteredTriple should keep matching entity");
    }

    static function testEntityMixedQueries():Void {
        var world = new World();
        var player = world.spawn([new Position(2, 3), new Velocity(4, 5), new PlayerTag()]);
        world.spawn([new Position(8, 9)]);

        var pair = world.queryPair(Entity, Position).with(PlayerTag);
        var pairItem = pair.single();
        assertEq(player.index, cast(pairItem.a, Entity).index, "Query2<Entity, T> should expose entity as the first data slot");
        assertEq(2, pairItem.b.x, "Query2<Entity, T> should still expose typed component data");

        var triple = world.queryTriple(Entity, Position, Velocity).with(PlayerTag);
        var tripleItem = triple.single();
        assertEq(player.index, cast(tripleItem.a, Entity).index, "Query3<Entity, A, B> should expose entity as the first data slot");
        assertEq(3, tripleItem.b.y, "Query3<Entity, A, B> should keep the second typed component");
        assertEq(4, tripleItem.c.x, "Query3<Entity, A, B> should keep the third typed component");
    }

    static function testInitResource():Void {
        var world = new World();
        var first = world.initResource(InitCounterResource);
        var second = world.getResourceOrInit(InitCounterResource);
        assert(first == second, "initResource should reuse existing resource");
        assertEq(1, first.value, "createDefault should run once");

        world.insertResource(new SeedValue(4));
        var derived = world.initResource(DerivedResource);
        assertEq(8, derived.value, "fromWorld should derive from existing world resources");
        assert(world.getResource(DerivedResource) == derived, "derived resource should be stored");
    }

    static function testWorldResourceScopes():Void {
        var world = new World();
        var first = world.getResourceOrInsert(new TimeResource(0.25));
        var second = world.getResourceOrInsert(new TimeResource(1.0));
        assert(first == second, "getResourceOrInsert should keep the first resource");
        assertEq(0.25, second.delta, "getResourceOrInsert should not overwrite existing resource");
        assert(world.containsResource(TimeResource), "containsResource should mirror hasResource");

        var scoped = world.resourceScope(TimeResource, function(scopeWorld, time) {
            time.delta += 0.5;
            return scopeWorld.entityCount();
        });
        assertEq(0, scoped, "resourceScope should expose the world alongside the resource");
        assertEq(0.75, world.getResource(TimeResource).delta, "resourceScope should allow mutable resource updates");
    }

    static function testQueryEntityAccess():Void {
        var world = new World();
        var player = world.spawn([new Position(4, 5), new PlayerTag()]);
        var enemy = world.spawn([new Position(7, 8)]);

        var entityQuery = world.query(Entity).with(PlayerTag);
        assert(entityQuery.contains(player), "Query<Entity, _> should match filtered entity");
        assert(!entityQuery.contains(enemy), "Query<Entity, _> should honor filters");
        var playerEntity = entityQuery.single();
        assertEq(player.index, playerEntity.entity.index, "Query<Entity, _>.single should return the matching entity");
        assertEq(player.index, cast(playerEntity.component, Entity).index, "Query<Entity, _> item component should be the entity");

        var positionQuery = world.query(Position);
        var fetched = positionQuery.get(player);
        assert(fetched != null, "Query.get should resolve matching entity");
        assertEq(4, fetched.component.x, "Query.get should return typed component data");
        assert(positionQuery.contains(enemy), "Query.contains should report matching entity");
        assertEq(2, positionQuery.getMany([player, enemy]).length, "Query.getMany should keep all matching entities");
    }

    static function testEntityWorldAccess():Void {
        var world = new World();
        var entity = world.spawn([new Position(1, 2)]);
        assert(world.containsEntity(entity), "containsEntity should report spawned entities");

        var view = world.getEntity(entity);
        assert(view != null, "getEntity should return a view for live entities");
        assert(view.contains(Position), "EntityRef.contains should see inserted components");
        assertEq(1, view.get(Position).x, "EntityRef.get should read typed data");

        world.entityMut(entity).insert(new Velocity(3, 4));
        assert(world.entity(entity).contains(Velocity), "entityMut.insert should mutate the entity");

        var built = world.spawnEmpty().insert(new PlayerTag()).insert(new Position(9, 10)).id();
        assert(world.entity(built).contains(PlayerTag), "spawnEmpty should return a mutable entity view");
        assertEq(2, world.iterEntities().length, "iterEntities should expose all live entities");
    }

    static function testQueryCountAndStrictGetMany():Void {
        var world = new World();
        var first = world.spawn([new Position(1, 1)]);
        var second = world.spawn([new Position(2, 2)]);
        var other = world.spawn([new Velocity(5, 5)]);

        var query = world.query(Position);
        assertEq(2, query.count(), "Query.count should match entity count");
        assertEq(2, query.iterMany([first, second, other]).length, "iterMany should skip non-matching entities");
        assertEq(2, query.getMany([first, second]).length, "getMany should preserve input order for matching entities");

        var threw = false;
        try {
            query.getMany([first, other]);
        } catch (_:Dynamic) {
            threw = true;
        }
        assert(threw, "getMany should fail when any entity does not satisfy the query");
    }

    static function testQueryUniqueEntityAccess():Void {
        var world = new World();
        var first = world.spawn([new Position(1, 1), new Velocity(10, 10)]);
        var second = world.spawn([new Position(2, 2), new Velocity(20, 20)]);
        var other = world.spawn([new Velocity(30, 30)]);

        var unique = UniqueEntityArray.from([second, first]);
        var query = world.query(Position);
        var items = query.getManyUnique(unique);
        assertEq(2, items.length, "Query.getManyUnique should return all unique matching entities");
        assertEq(second.index, items[0].entity.index, "Query.getManyUnique should preserve input order");
        assertEq(first.index, items[1].entity.index, "Query.getManyUnique should preserve second input order");

        var iterItems = query.iterManyUnique(UniqueEntityArray.from([other, first, second]));
        assertEq(2, iterItems.length, "Query.iterManyUnique should skip non-matching unique entities");

        var pairItems = world.queryPair(Position, Velocity).getManyUnique(UniqueEntityArray.from([first, second]));
        assertEq(2, pairItems.length, "Query2.getManyUnique should support unique entity arrays");
        assertEq(20, pairItems[1].b.x, "Query2.getManyUnique should preserve tuple data");

        var tripleItems = world.queryTriple(Entity, Position, Velocity).getManyUnique(UniqueEntityArray.from([second, first]));
        assertEq(2, tripleItems.length, "Query3.getManyUnique should support mixed entity/component data");
        assertEq(second.index, tripleItems[0].a.index, "Query3.getManyUnique should keep Entity query data");

        var duplicateError:DuplicateEntityError = null;
        try {
            UniqueEntityArray.from([first, second, first]);
        } catch (error:DuplicateEntityError) {
            duplicateError = error;
        }
        assert(duplicateError != null, "UniqueEntityArray should reject duplicate entities");
        assertEq(first.index, duplicateError.entity.index, "DuplicateEntityError should keep duplicate entity");
        assertEq(0, duplicateError.firstIndex, "DuplicateEntityError should keep first index");
        assertEq(2, duplicateError.duplicateIndex, "DuplicateEntityError should keep duplicate index");
    }

    static function testQueryIterCombinations():Void {
        var world = new World();
        var first = world.spawn([new Position(1, 1), new Velocity(10, 10)]);
        var second = world.spawn([new Position(2, 2), new Velocity(20, 20)]);
        var third = world.spawn([new Position(3, 3), new Velocity(30, 30)]);
        world.spawn([new Velocity(40, 40)]);

        var pairs = world.query(Position).iterCombinations(2);
        assertEq(3, pairs.length, "Query.iterCombinations(2) should return n choose 2 matching pairs");
        var pairKeys:Map<String, Bool> = new Map();
        for (pair in pairs) {
            assert(pair[0].entity.index != pair[1].entity.index, "Query.iterCombinations pairs must not repeat an entity");
            pairKeys.set(combinationKey([pair[0].entity, pair[1].entity]), true);
        }
        assert(pairKeys.exists(combinationKey([first, second])), "Query.iterCombinations should include first/second pair");
        assert(pairKeys.exists(combinationKey([first, third])), "Query.iterCombinations should include first/third pair");
        assert(pairKeys.exists(combinationKey([second, third])), "Query.iterCombinations should include second/third pair");

        var triples = world.query(Position).iterCombinations(3);
        assertEq(1, triples.length, "Query.iterCombinations(3) should return one triple for three matching entities");
        assertEq(combinationKey([first, second, third]), combinationKey([for (item in triples[0]) item.entity]), "Query.iterCombinations(3) should include all matching entities once");
        assertEq(0, world.query(Position).iterCombinations(4).length, "Query.iterCombinations should be empty when K exceeds match count");

        var query2Pairs = world.queryPair(Position, Velocity).iterCombinations(2);
        assertEq(3, query2Pairs.length, "Query2.iterCombinations should work on multi-component query data");
        var velocityPairTotals = [for (pair in query2Pairs) pair[0].b.x + pair[1].b.x];
        velocityPairTotals.sort(Reflect.compare);
        assertEq("30,40,50", velocityPairTotals.join(","), "Query2.iterCombinations should preserve item data");

        var query3Triples = world.queryTriple(Entity, Position, Velocity).iterCombinations(3);
        assertEq(1, query3Triples.length, "Query3.iterCombinations should work with mixed Entity data");
        assertEq(combinationKey([first, second, third]), combinationKey([for (item in query3Triples[0]) item.a]), "Query3.iterCombinations should preserve Entity query field");
    }

    static function testCommandEntityAccess():Void {
        var world = new World();
        var entity = world.spawn();
        var commands = world.commands();

        commands.entity(entity).insert(new Position(8, 9)).insert(new Velocity(1, 2));
        var deferred = commands.spawnEmpty().insert(new PlayerTag()).id();
        assert(!world.has(entity, Position), "entity commands should remain deferred until apply");
        commands.apply();

        assert(world.entity(entity).contains(Position), "entity commands should apply to existing entities");
        assert(world.entity(entity).contains(Velocity), "entity commands should chain inserts");
        assert(world.entity(deferred).contains(PlayerTag), "spawnEmpty entity commands should apply to new entities");
    }

    static function testCommandGetEntitySemantics():Void {
        var world = new World();
        var commands = world.commands();

        var reserved = world.reserveEntity();
        var spawned = world.spawn([new Position(3, 4)]);
        var stale = world.spawn();
        world.despawn(stale);

        var reservedCommands = commands.getEntity(reserved);
        reservedCommands.insert(new PlayerTag());
        assertEq(reserved.index, reservedCommands.id().index, "Commands.getEntity should accept valid reserved entities");

        var spawnedCommands = commands.getSpawnedEntity(spawned);
        spawnedCommands.insert(new Velocity(1, 2));
        assertEq(spawned.index, spawnedCommands.id().index, "Commands.getSpawnedEntity should accept spawned entities");

        var reservedNotSpawnedError:EntityNotSpawnedError = null;
        try {
            commands.getSpawnedEntity(reserved);
        } catch (error:EntityNotSpawnedError) {
            reservedNotSpawnedError = error;
        }
        assert(reservedNotSpawnedError != null, "Commands.getSpawnedEntity should reject reserved entities");
        assertEntityNotSpawnedKindValidButNotSpawned(reservedNotSpawnedError.kind, "reserved entity should report ValidButNotSpawned kind");

        var staleNotSpawnedError:EntityNotSpawnedError = null;
        try {
            commands.getSpawnedEntity(stale);
        } catch (error:EntityNotSpawnedError) {
            staleNotSpawnedError = error;
        }
        assert(staleNotSpawnedError != null, "Commands.getSpawnedEntity should reject stale entities");
        assertEntityNotSpawnedKindInvalid(staleNotSpawnedError.kind, "stale entity should report Invalid kind");

        var invalidEntityError:InvalidEntityError = null;
        try {
            commands.getEntity(stale);
        } catch (error:InvalidEntityError) {
            invalidEntityError = error;
        }
        assert(invalidEntityError != null, "Commands.getEntity should reject stale entities");
    }

    static function testDeferredSpawnSemantics():Void {
        var world = new World();
        var commands = world.commands();

        var deferred = commands.spawn([new Position(11, 12)]);
        assert(world.containsEntity(deferred), "reserved id should be valid before apply");
        assert(!world.isAlive(deferred), "reserved id should not be spawned before apply");
        assert(world.getEntity(deferred) == null, "reserved id should not be visible through getEntity before apply");
        assertEq(0, world.query(Position).count(), "reserved spawn should be invisible to queries before apply");

        commands.apply();
        assert(world.isAlive(deferred), "reserved id should become spawned after apply");
        assert(world.entity(deferred).contains(Position), "deferred spawn should materialize components on apply");
        assertEq(1, world.query(Position).count(), "deferred spawn should become query-visible after apply");
    }

    static function testSpawnBatchSemantics():Void {
        var world = new World();

        var direct = world.spawnBatch([
            new MovingBundle(new Position(1, 1), new Velocity(1, 0)),
            new MovingBundle(new Position(2, 2), new Velocity(0, 1))
        ]);
        assertEq(2, direct.length, "world.spawnBatch should return all spawned entities");
        assertEq(2, world.query(Position).count(), "world.spawnBatch should immediately spawn all bundles");
        assertEq(direct[0].index + 1, direct[1].index, "world.spawnBatch should preserve reservation order");
        assertEq(1, world.get(direct[0], Position).x, "world.spawnBatch should keep first bundle data on first entity");
        assertEq(2, world.get(direct[1], Position).x, "world.spawnBatch should keep second bundle data on second entity");
        var directDetails = world.queryPair(Entity, SpawnDetails).get(direct[0]);
        assert(directDetails != null && directDetails.b.spawnedBy() != null && directDetails.b.spawnedBy().length > 0, "world.spawnBatch should record spawn source metadata");

        var commands = world.commands();
        var deferred = commands.spawnBatch([
            new MovingBundle(new Position(3, 3), new Velocity(1, 1)),
            new MovingBundle(new Position(4, 4), new Velocity(2, 2))
        ]);
        assertEq(2, deferred.length, "commands.spawnBatch should return reserved entities");
        assert(world.containsEntity(deferred[0]) && world.containsEntity(deferred[1]), "commands.spawnBatch should reserve valid ids");
        assert(!world.isAlive(deferred[0]) && !world.isAlive(deferred[1]), "commands.spawnBatch ids should be unspawned before apply");
        assertEq(2, world.query(Position).count(), "commands.spawnBatch should stay deferred before apply");

        commands.apply();
        assert(world.isAlive(deferred[0]) && world.isAlive(deferred[1]), "commands.spawnBatch ids should spawn after apply");
        assertEq(4, world.query(Position).count(), "commands.spawnBatch should materialize all bundles after apply");
        assertEq(2, deferred[0].index, "commands.spawnBatch should preserve first reserved index");
        assertEq(3, deferred[1].index, "commands.spawnBatch should preserve second reserved index");
        assertEq(3, world.get(deferred[0], Position).x, "commands.spawnBatch should keep first deferred bundle data on first entity");
        assertEq(4, world.get(deferred[1], Position).x, "commands.spawnBatch should keep second deferred bundle data on second entity");
        var deferredDetails = world.queryPair(Entity, SpawnDetails).get(deferred[0]);
        assert(deferredDetails != null && deferredDetails.b.spawnedBy() != null && deferredDetails.b.spawnedBy().length > 0, "commands.spawnBatch should preserve spawn source metadata from queue time");
    }

    static function testReservedEntityAccessSemantics():Void {
        var world = new World();
        var reserved = world.reserveEntity();
        assert(world.containsEntity(reserved), "reserveEntity should return a valid entity id");
        assert(!world.isAlive(reserved), "reserveEntity id should not be alive until spawned");
        assert(world.getEntity(reserved) == null, "getEntity should hide reserved-unspawned ids");
        assert(world.getEntityMut(reserved) == null, "getEntityMut should hide reserved-unspawned ids");

        var commands = world.commands();
        var deferred = commands.spawn();
        assert(world.containsEntity(deferred), "commands.spawn should reserve a valid id before apply");
        assert(!world.isAlive(deferred), "commands.spawn id should stay unspawned before apply");
        assert(world.getEntity(deferred) == null, "commands.spawn id should not be exposed by getEntity before apply");
        assert(world.getEntityMut(deferred) == null, "commands.spawn id should not be exposed by getEntityMut before apply");

        commands.apply();
        assert(world.isAlive(deferred), "commands.spawn id should become alive after apply");
        assert(world.getEntity(deferred) != null, "getEntity should expose id after deferred spawn apply");
        assert(world.getEntityMut(deferred) != null, "getEntityMut should expose id after deferred spawn apply");
    }

    static function testTypedEcsErrors():Void {
        var world = new World();
        var entity = world.spawn([new Position(1, 1)]);
        var other = world.spawn([new Velocity(2, 2)]);
        var reserved = world.reserveEntity();

        var entityError:EntityDoesNotExistError = null;
        world.despawn(entity);
        try {
            world.entity(entity);
        } catch (error:EntityDoesNotExistError) {
            entityError = error;
        }
        assert(entityError != null, "world.entity should throw EntityDoesNotExistError");
        assertEq(entity.index, entityError.entity.index, "EntityDoesNotExistError should keep the failed entity");
        assertEntityNotSpawnedKindInvalid(entityError.kind, "despawned entity should report Invalid kind");

        var reservedError:EntityDoesNotExistError = null;
        try {
            world.entity(reserved);
        } catch (error:EntityDoesNotExistError) {
            reservedError = error;
        }
        assert(reservedError != null, "world.entity should reject reserved-unspawned entity");
        assertEntityNotSpawnedKindValidButNotSpawned(reservedError.kind, "reserved entity should report ValidButNotSpawned kind");

        var invalidSpawnError:SpawnError = null;
        try {
            world.spawnReserved(entity);
        } catch (error:SpawnError) {
            invalidSpawnError = error;
        }
        assert(invalidSpawnError != null, "spawnReserved should reject stale entity ids");
        assertSpawnErrorKindInvalid(invalidSpawnError.kind, "spawnReserved on stale entity should report Invalid kind");

        var alive = world.spawn();
        var alreadySpawnedError:SpawnError = null;
        try {
            world.spawnReserved(alive);
        } catch (error:SpawnError) {
            alreadySpawnedError = error;
        }
        assert(alreadySpawnedError != null, "spawnReserved should reject already spawned ids");
        assertSpawnErrorKindAlreadySpawned(alreadySpawnedError.kind, "spawnReserved on live entity should report AlreadySpawned kind");

        var resourceError:MissingResourceError = null;
        try {
            world.resourceScope(TimeResource, function(_, _) return 0);
        } catch (error:MissingResourceError) {
            resourceError = error;
        }
        assert(resourceError != null, "resourceScope should throw MissingResourceError");

        var query = world.query(Position);
        var mismatchError:QueryDoesNotMatchError = null;
        try {
            query.getMany([other]);
        } catch (error:QueryDoesNotMatchError) {
            mismatchError = error;
        }
        assert(mismatchError != null, "Query.getMany should throw QueryDoesNotMatchError");
        assertEq(other.index, mismatchError.entity.index, "QueryDoesNotMatchError should keep the failed entity");

        var staleWorld = new World();
        var stale = staleWorld.spawn([new Position(5, 5)]);
        staleWorld.despawn(stale);
        var staleQuery = staleWorld.query(Position);
        var notSpawnedQueryError:QueryEntityNotSpawnedError = null;
        try {
            staleQuery.getMany([stale]);
        } catch (error:QueryEntityNotSpawnedError) {
            notSpawnedQueryError = error;
        }
        assert(notSpawnedQueryError != null, "Query.getMany should distinguish stale/unspawned entities from query mismatches");
        assertEq(stale.index, notSpawnedQueryError.entity.index, "QueryEntityNotSpawnedError should keep the failed entity");
        assertEntityNotSpawnedKindInvalid(notSpawnedQueryError.kind, "QueryEntityNotSpawnedError should preserve invalid/stale kind");

        var singleError:QuerySingleNoEntitiesError = null;
        try {
            query.single();
        } catch (error:QuerySingleNoEntitiesError) {
            singleError = error;
        }
        assert(singleError != null, "Query.single should distinguish the no-entities case");
        assertEq(QuerySingleKind.NoEntities, singleError.kind, "Query.single no-entities error should preserve kind");

        var manyWorld = new World();
        manyWorld.spawn([new Position(1, 1)]);
        manyWorld.spawn([new Position(2, 2)]);
        var manyQuery = manyWorld.query(Position);
        var multipleError:QuerySingleMultipleEntitiesError = null;
        try {
            manyQuery.single();
        } catch (error:QuerySingleMultipleEntitiesError) {
            multipleError = error;
        }
        assert(multipleError != null, "Query.single should distinguish the multiple-entities case");
        assertEq(QuerySingleKind.MultipleEntities, multipleError.kind, "Query.single multiple-entities error should preserve kind");
    }

    static function testTypeKeyTypedErrors():Void {
        var emptyNameError:TypeKeyError = null;
        try {
            bevy.ecs.TypeKey.named("");
        } catch (error:TypeKeyError) {
            emptyNameError = error;
        }
        assert(emptyNameError != null, "TypeKey.named should throw typed error for empty names");
        assertEq(TypeKeyErrorKind.EmptyName, emptyNameError.kind, "TypeKey.named should preserve EmptyName kind");

        var noClassValueError:TypeKeyError = null;
        try {
            bevy.ecs.TypeKey.ofInstance(1);
        } catch (error:TypeKeyError) {
            noClassValueError = error;
        }
        assert(noClassValueError != null, "TypeKey.ofInstance should throw typed error for classless values");
        assertEq(TypeKeyErrorKind.ValueWithoutClass, noClassValueError.kind, "TypeKey.ofInstance should preserve ValueWithoutClass kind");
    }

    static function testQueryFilterTypedErrors():Void {
        var orError:QueryFilterError = null;
        try {
            Or.of([]);
        } catch (error:QueryFilterError) {
            orError = error;
        }
        assert(orError != null, "Or.of([]) should throw typed query-filter error");
        assertEq(QueryFilterErrorKind.OrRequiresChildren, orError.kind, "Or.of([]) should preserve OrRequiresChildren kind");
    }


    static function assertEq<T>(expected:T, actual:T, label:String):Void {
        if (expected != actual) {
            throw '$label expected $expected, got $actual';
        }
    }

    static function assert(value:Bool, label:String):Void {
        if (!value) {
            throw label;
        }
    }

    static function combinationKey(entities:Array<Entity>):String {
        var keys = [for (entity in entities) entity.key()];
        keys.sort(Reflect.compare);
        return keys.join("|");
    }

    static function assertEntityNotSpawnedKindInvalid(kind:EntityNotSpawnedKind, label:String):Void {
        switch kind {
            case Invalid(_):
            case ValidButNotSpawned:
                throw label;
        }
    }

    static function assertEntityNotSpawnedKindValidButNotSpawned(kind:EntityNotSpawnedKind, label:String):Void {
        switch kind {
            case ValidButNotSpawned:
            case Invalid(_):
                throw label;
        }
    }

    static function assertSpawnErrorKindInvalid(kind:SpawnErrorKind, label:String):Void {
        switch kind {
            case Invalid(_):
            case AlreadySpawned:
                throw label;
        }
    }

    static function assertSpawnErrorKindAlreadySpawned(kind:SpawnErrorKind, label:String):Void {
        switch kind {
            case AlreadySpawned:
            case Invalid(_):
                throw label;
        }
    }
}

class Position implements Component {
    public var x:Int;
    public var y:Int;

    public function new(x:Int, y:Int) {
        this.x = x;
        this.y = y;
    }
}

class Velocity implements Component {
    public var x:Int;
    public var y:Int;

    public function new(x:Int, y:Int) {
        this.x = x;
        this.y = y;
    }
}

class Health implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class MovingBundle implements Bundle {
    public var position:Position;
    public var velocity:Velocity;

    public function new(position:Position, velocity:Velocity) {
        this.position = position;
        this.velocity = velocity;
    }
}

class PlayerTag implements Component {
    public var marker(default, null):String;

    public function new(?marker:String) {
        this.marker = marker != null ? marker : "player";
    }
}

class EnemyTag implements Component {
    public var marker(default, null):String;

    public function new(?marker:String) {
        this.marker = marker != null ? marker : "enemy";
    }
}

class TimeResource implements Resource {
    public var delta:Float;

    public function new(delta:Float) {
        this.delta = delta;
    }
}

class DamageEvent implements Event {
    public var amount:Int;

    public function new(amount:Int) {
        this.amount = amount;
    }
}

class InitCounterResource implements Resource {
    public static var created:Int = 0;
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }

    public static function createDefault():InitCounterResource {
        created++;
        return new InitCounterResource(created);
    }
}

class SeedValue implements Resource {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class DerivedResource implements Resource {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }

    public static function fromWorld(world:World):DerivedResource {
        var seed = world.getResource(SeedValue);
        return new DerivedResource(seed.value * 2);
    }
}

class TestAssetA implements Asset {
    public var value:String;

    public function new(value:String) {
        this.value = value;
    }
}

class TestAssetB implements Asset {
    public var value:String;

    public function new(value:String) {
        this.value = value;
    }
}
