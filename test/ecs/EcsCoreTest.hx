package ecs;

import bevy.ecs.Commands;
import bevy.ecs.Bundle;
import bevy.ecs.Component;
import bevy.ecs.Event;
import bevy.ecs.Events;
import bevy.ecs.Resource;
import bevy.ecs.World;

class EcsCoreTest {
    static function main():Void {
        testEntityGeneration();
        testComponentsAndQueries();
        testResources();
        testEvents();
        testCommands();
        testBundles();
        testChangeTicks();
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
