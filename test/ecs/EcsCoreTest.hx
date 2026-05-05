package ecs;

using bevy.asset.AssetLoad;

import bevy.app.App;
import bevy.ecs.Commands;
import bevy.ecs.Bundle;
import bevy.ecs.Component;
import bevy.ecs.EcsError.EntityDoesNotExistError;
import bevy.ecs.Entity;
import bevy.ecs.Event;
import bevy.ecs.Events;
import bevy.ecs.EcsError.MissingResourceError;
import bevy.ecs.EcsError.QueryDoesNotMatchError;
import bevy.ecs.EcsError.QuerySingleMissingError;
import bevy.ecs.Resource;
import bevy.ecs.World;
import bevy.ecs.With;
import bevy.ecs.Without;
import bevy.ecs.Added;
import bevy.ecs.Changed;
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
        testFilteredPairQueries();
        testTripleQueries();
        testEntityMixedQueries();
        testInitResource();
        testWorldResourceScopes();
        testQueryEntityAccess();
        testEntityWorldAccess();
        testQueryCountAndStrictGetMany();
        testCommandEntityAccess();
        testTypedEcsErrors();
        trace("EcsCoreTest ok");
    }

    static function testEntityGeneration():Void {
        var world = new World();
        var first = world.spawn();
        assert(world.isAlive(first), "spawned entity should be alive");
        assert(world.despawn(first), "despawn should succeed");
        assert(!world.isAlive(first), "old entity handle should be dead");
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

    static function testTypedEcsErrors():Void {
        var world = new World();
        var entity = world.spawn([new Position(1, 1)]);
        var other = world.spawn([new Velocity(2, 2)]);

        var entityError:EntityDoesNotExistError = null;
        world.despawn(entity);
        try {
            world.entity(entity);
        } catch (error:EntityDoesNotExistError) {
            entityError = error;
        }
        assert(entityError != null, "world.entity should throw EntityDoesNotExistError");
        assertEq(entity.index, entityError.entity.index, "EntityDoesNotExistError should keep the failed entity");

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

        var singleError:QuerySingleMissingError = null;
        try {
            query.single();
        } catch (error:QuerySingleMissingError) {
            singleError = error;
        }
        assert(singleError != null, "Query.single should throw QuerySingleMissingError when cardinality is not one");
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

class MovingBundle implements Bundle {
    public var position:Position;
    public var velocity:Velocity;

    public function new(position:Position, velocity:Velocity) {
        this.position = position;
        this.velocity = velocity;
    }
}

class PlayerTag implements Component {
    public function new() {}
}

class EnemyTag implements Component {
    public function new() {}
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
