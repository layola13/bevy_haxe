package app;

import bevy.app.App;
import bevy.app.MainSchedule;
import bevy.app.SystemConfig.SystemConfigBuilder;
import bevy.app.SystemConfig.SystemSetConfigBuilder;
import bevy.app.SystemClass;
import bevy.app.SystemRegistry;
import bevy.async.AsyncClass;
import bevy.async.AsyncRuntime;
import bevy.async.Future;
import bevy.ecs.All;
import bevy.ecs.Added;
import bevy.ecs.Changed;
import bevy.ecs.Commands;
import bevy.ecs.Component;
import bevy.ecs.Event;
import bevy.ecs.Events.EventReader;
import bevy.ecs.Events.EventWriter;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.Query.Query2;
import bevy.ecs.Query.Query3;
import bevy.ecs.Res;
import bevy.ecs.ResMut;
import bevy.ecs.Resource;
import bevy.ecs.With;
import bevy.ecs.Without;
import bevy.ecs.World;

class AppScheduleTest {
    static function main():Void {
        testRegisteredSystemOrdering();
        testRunIfConditions();
        testSetOrderingAndConditions();
        testRuntimeBuilders();

        var app = new App();
        app.world.insertResource(new Counter());
        app.world.insertResource(new ChangeStep(0));
        app.world.spawn([new AppPosition(1), new AppVelocity(2), new AppTag()]);
        app.world.spawn([new AppPosition(5)]);
        app.world.initEvents(AppSignal);
        app.addRegisteredSystems(MainSchedule.Update);

        var firstDone = false;
        app.update().handle(function(_) {
            firstDone = true;
        }, function(error) throw error);
        AsyncRuntime.flush();

        var secondDone = false;
        app.update().handle(function(_) {
            secondDone = true;
        }, function(error) throw error);
        AsyncRuntime.flush();

        assert(firstDone, "first update future should resolve");
        assert(secondDone, "second update future should resolve");
        assertEq(16, app.world.getResource(Counter).value, "sync and async systems should run in order across two updates");
        assertEq("sync", app.world.getResource(CommandFlag).value, "sync command should apply");
        assertEq(9, app.world.getResource(AsyncValue).value, "async system should persist awaited value");
        assertEq(9, app.world.getResource(AsyncCommandFlag).value, "sync command should apply async result");
        assertEq(16, app.world.getResource(ReadBack).value, "Res param should read resource");
        assertEq(3, app.world.getResource(QueryTotal).value, "Query2 param should read components");
        assertEq(1, app.world.getResource(QueryPairFilterCount).value, "Query2<DataA, DataB, Filter> param should respect filter type");
        assertEq(1, app.world.getResource(QueryEntityPairCount).value, "Query2<Entity, Data> param should inject mixed entity/component queries");
        assertEq(3, app.world.getResource(QueryTripleTotal).value, "Query3 param should read three-component tuples");
        assertEq(1, app.world.getResource(QueryTripleFilterCount).value, "Query3<DataA, DataB, DataC, Filter> param should respect filter type");
        assertEq(1, app.world.getResource(QueryEntityTripleCount).value, "Query3<Entity, DataA, DataB> param should inject mixed entity/component queries");
        assertEq(1, app.world.getResource(FilterCount).value, "Query<Data, Filter> param should respect filter type");
        assertEq(1, app.world.getResource(TaggedEntityCount).value, "Query<Entity, Filter> param should inject entity-only queries");
        assertEq(2, app.world.getResource(OrFilterCount).value, "Query<Data, Or<...>> param should compose filters");
        assertEq(1, app.world.getResource(AddedCountFirst).value, "Query<Data, Added<T>> param should see first-run additions");
        assertEq(0, app.world.getResource(AddedCountSecond).value, "Query<Data, Added<T>> param should stop matching after first run");
        assertEq(2, app.world.getResource(ChangedCountFirst).value, "Changed<T> should include startup inserts on first run");
        assertEq(1, app.world.getResource(ChangedCountSecond).value, "Changed<T> should match data mutated after last run");
        assertEq("received", app.world.getResource(EventStatus).value, "events should flow through systems");
        trace("AppScheduleTest ok");
    }

    static function testRegisteredSystemOrdering():Void {
        var app = new App();
        app.world.insertResource(new OrderTrace());
        app.addRegisteredSystems(MainSchedule.PostUpdate);

        var done = false;
        app.runSchedule(MainSchedule.PostUpdate).handle(function(_) {
            done = true;
        }, function(error) throw error);
        AsyncRuntime.flush();

        assert(done, "ordered schedule should resolve");
        assertEq("first,middle,last", app.world.getResource(OrderTrace).values.join(","), "before/after metadata should reorder registered systems");
    }

    static function testRunIfConditions():Void {
        var app = new App();
        app.world.insertResource(new RunIfTrace());
        app.world.insertResource(new RunIfState(true, false));
        app.world.spawn([new AppPosition(3), new AppTag()]);
        app.addRegisteredSystems(MainSchedule.First);

        var done = false;
        app.runSchedule(MainSchedule.First).handle(function(_) {
            done = true;
        }, function(error) throw error);
        AsyncRuntime.flush();

        assert(done, "run_if schedule should resolve");
        assertEq("sync,query", app.world.getResource(RunIfTrace).values.join(","), "run_if should gate systems by sync, async, and query-backed conditions");
    }

    static function testSetOrderingAndConditions():Void {
        var app = new App();
        app.world.insertResource(new SetTrace());
        app.world.insertResource(new SetGate(true, false));
        app.addRegisteredSystems(MainSchedule.Last);

        var firstDone = false;
        app.runSchedule(MainSchedule.Last).handle(function(_) {
            firstDone = true;
        }, function(error) throw error);
        AsyncRuntime.flush();

        assert(firstDone, "set-based schedule should resolve");
        assertEq("alpha", app.world.getResource(SetTrace).values.join(","), "set run_if should block disabled set and set ordering should keep alpha first");

        app.world.getResource(SetGate).betaEnabled = true;
        app.world.insertResource(new SetTrace());

        var secondDone = false;
        app.runSchedule(MainSchedule.Last).handle(function(_) {
            secondDone = true;
        }, function(error) throw error);
        AsyncRuntime.flush();

        assert(secondDone, "set-based schedule second pass should resolve");
        assertEq("alpha,beta", app.world.getResource(SetTrace).values.join(","), "set before/after and setRunIf should control grouped systems");
    }

    static function testRuntimeBuilders():Void {
        var app = new App();
        app.world.insertResource(new BuilderTrace());
        app.world.insertResource(new BuilderGate(true, false));

        app.configureSet(MainSchedule.Startup, SystemSetConfigBuilder.named("builder_alpha"));
        app.configureSet(MainSchedule.Startup, SystemSetConfigBuilder.named("builder_beta").after("builder_alpha").runIf(function(world) {
            return world.getResource(BuilderGate).betaEnabled;
        }));

        app.addSystemConfig(MainSchedule.Startup, SystemConfigBuilder.named("builder.first", function(world) {
            world.getResource(BuilderTrace).push("first");
            return null;
        }).inSet("builder_alpha"));

        app.addSystemConfig(MainSchedule.Startup, SystemConfigBuilder.named("builder.second", function(world) {
            world.getResource(BuilderTrace).push("second");
            return null;
        }).inSet("builder_beta"));

        app.addSystemConfig(MainSchedule.Startup, SystemConfigBuilder.named("builder.third", function(world) {
            world.getResource(BuilderTrace).push("third");
            return null;
        }).after("builder.first"));

        var done = false;
        app.runSchedule(MainSchedule.Startup).handle(function(_) {
            done = true;
        }, function(error) throw error);
        AsyncRuntime.flush();

        assert(done, "runtime builder schedule should resolve");
        assertEq("first,third", app.world.getResource(BuilderTrace).values.join(","), "runtime system/set builders should enforce ordering and conditions");
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

class Counter implements Resource {
    public var value:Int = 0;
    public function new() {}
}

class CommandFlag implements Resource {
    public var value:String;
    public function new(value:String) {
        this.value = value;
    }
}

class AsyncCommandFlag implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AsyncValue implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AsyncCounterDelta implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class ReadBack implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTotal implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryPairFilterCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryEntityPairCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleTotal implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleFilterCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryEntityTripleCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class FilterCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class TaggedEntityCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class OrFilterCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AddedCountFirst implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AddedCountSecond implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class ChangedCountFirst implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class ChangedCountSecond implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class EventStatus implements Resource {
    public var value:String;
    public function new(value:String) {
        this.value = value;
    }
}

class OrderTrace implements Resource {
    public var values:Array<String>;

    public function new() {
        values = [];
    }

    public function push(value:String):Void {
        values.push(value);
    }
}

class RunIfTrace implements Resource {
    public var values:Array<String>;

    public function new() {
        values = [];
    }

    public function push(value:String):Void {
        values.push(value);
    }
}

class RunIfState implements Resource {
    public var syncEnabled:Bool;
    public var asyncEnabled:Bool;

    public function new(syncEnabled:Bool, asyncEnabled:Bool) {
        this.syncEnabled = syncEnabled;
        this.asyncEnabled = asyncEnabled;
    }
}

class SetTrace implements Resource {
    public var values:Array<String>;

    public function new() {
        values = [];
    }

    public function push(value:String):Void {
        values.push(value);
    }
}

class SetGate implements Resource {
    public var alphaEnabled:Bool;
    public var betaEnabled:Bool;

    public function new(alphaEnabled:Bool, betaEnabled:Bool) {
        this.alphaEnabled = alphaEnabled;
        this.betaEnabled = betaEnabled;
    }
}

class BuilderTrace implements Resource {
    public var values:Array<String>;

    public function new() {
        values = [];
    }

    public function push(value:String):Void {
        values.push(value);
    }
}

class BuilderGate implements Resource {
    public var alphaEnabled:Bool;
    public var betaEnabled:Bool;

    public function new(alphaEnabled:Bool, betaEnabled:Bool) {
        this.alphaEnabled = alphaEnabled;
        this.betaEnabled = betaEnabled;
    }
}

class AppPosition implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AppVelocity implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AppTag implements Component {
    public function new() {}
}

class AppSignal implements Event {
    public var value:String;
    public function new(value:String) {
        this.value = value;
    }
}

class ChangeStep implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class CounterSystems implements SystemClass implements AsyncClass {
    @:system("Last")
    @:inSet("alpha")
    @:setRunIf("app.CounterSetConditions.allowAlpha")
    public static function setAlpha(trace:ResMut<SetTrace>):Void {
        trace.value.push("alpha");
    }

    @:system("Last")
    @:inSet("beta")
    @:setAfter("alpha")
    @:setRunIf("app.CounterSetConditions.allowBeta")
    public static function setBeta(trace:ResMut<SetTrace>):Void {
        trace.value.push("beta");
    }

    @:system("First")
    @:runIf("app.CounterConditions.allowSync")
    public static function gatedSync(trace:ResMut<RunIfTrace>):Void {
        trace.value.push("sync");
    }

    @:system("First")
    @:runIf("app.CounterConditions.allowAsync")
    public static function gatedAsync(trace:ResMut<RunIfTrace>):Void {
        trace.value.push("async");
    }

    @:system("First")
    @:runIf("app.CounterConditions.hasTaggedPosition")
    public static function gatedQuery(trace:ResMut<RunIfTrace>):Void {
        trace.value.push("query");
    }

    @:system("PostUpdate")
    @:before("app.CounterSystems.orderedMiddle")
    public static function orderedFirst(trace:ResMut<OrderTrace>):Void {
        trace.value.push("first");
    }

    @:system("PostUpdate")
    @:after("app.CounterSystems.orderedFirst")
    @:before("app.CounterSystems.orderedLast")
    public static function orderedMiddle(trace:ResMut<OrderTrace>):Void {
        trace.value.push("middle");
    }

    @:system("PostUpdate")
    @:after("app.CounterSystems.orderedMiddle")
    public static function orderedLast(trace:ResMut<OrderTrace>):Void {
        trace.value.push("last");
    }

    @:system("Update")
    public static function addOne(counter:ResMut<Counter>):Void {
        counter.value.value += 1;
    }

    @:async
    @:system("Update")
    public static function addAsync(world:World) {
        var value = @await Future.resolved(7);
        world.insertResource(new AsyncCounterDelta(value));
    }

    @:system("Update")
    public static function commandFlag(commands:Commands):Void {
        commands.insertResource(new CommandFlag("sync"));
    }

    @:async
    @:system("Update")
    public static function asyncValue(world:World) {
        var value = @await Future.resolved(9);
        world.insertResource(new AsyncValue(value));
    }

    @:system("Update")
    public static function storeAsyncValue(value:Res<AsyncValue>, commands:Commands):Void {
        if (value != null) {
            commands.insertResource(new AsyncCommandFlag(value.value.value));
        }
    }

    @:system("Update")
    @:after("app.CounterSystems.applyAsyncCounterDelta")
    public static function readBack(counter:Res<Counter>, commands:Commands):Void {
        commands.insertResource(new ReadBack(counter.value.value));
    }

    @:system("Update")
    public static function querySystem(query:Query2<AppPosition, AppVelocity>, commands:Commands):Void {
        var total = 0;
        for (item in query.toArray()) {
            total += item.a.value + item.b.value;
        }
        commands.insertResource(new QueryTotal(total));
    }

    @:system("Update")
    public static function filteredPairQuerySystem(query:Query2<AppPosition, AppVelocity, With<AppTag>>, commands:Commands):Void {
        commands.insertResource(new QueryPairFilterCount(query.toArray().length));
    }

    @:system("Update")
    public static function entityPairQuerySystem(query:Query2<bevy.ecs.Entity, AppPosition, With<AppTag>>, commands:Commands):Void {
        var count = 0;
        for (item in query.toArray()) {
            if (item.entity.index == item.a.index && item.b.value > 0) {
                count++;
            }
        }
        commands.insertResource(new QueryEntityPairCount(count));
    }

    @:system("Update")
    public static function tripleQuerySystem(query:Query3<AppPosition, AppVelocity, AppTag>, commands:Commands):Void {
        commands.insertResource(new QueryTripleTotal(query.toArray().length * 3));
    }

    @:system("Update")
    public static function filteredTripleQuerySystem(query:Query3<AppPosition, AppVelocity, AppTag, With<AppTag>>, commands:Commands):Void {
        commands.insertResource(new QueryTripleFilterCount(query.toArray().length));
    }

    @:system("Update")
    public static function entityTripleQuerySystem(query:Query3<bevy.ecs.Entity, AppPosition, AppVelocity, With<AppTag>>, commands:Commands):Void {
        var count = 0;
        for (item in query.toArray()) {
            if (item.entity.index == item.a.index && item.b.value > 0 && item.c.value > 0) {
                count++;
            }
        }
        commands.insertResource(new QueryEntityTripleCount(count));
    }

    @:system("Update")
    public static function filteredQuerySystem(query:Query<AppPosition, All<With<AppTag>>>, commands:Commands):Void {
        commands.insertResource(new FilterCount(query.toArray().length));
    }

    @:system("Update")
    public static function taggedEntitySystem(query:Query<bevy.ecs.Entity, With<AppTag>>, commands:Commands):Void {
        commands.insertResource(new TaggedEntityCount(query.toArray().length));
    }

    @:system("Update")
    public static function orFilteredQuerySystem(query:Query<AppPosition, Or<With<AppTag>, Without<AppVelocity>>>, commands:Commands):Void {
        commands.insertResource(new OrFilterCount(query.toArray().length));
    }

    @:system("Update")
    public static function addedQuerySystem(query:Query<AppPosition, Added<AppTag>>, step:Res<ChangeStep>, commands:Commands):Void {
        var count = query.toArray().length;
        if (step.value.value == 0) {
            commands.insertResource(new AddedCountFirst(count));
        } else {
            commands.insertResource(new AddedCountSecond(count));
        }
    }

    @:system("Update")
    public static function mutateTrackedPosition(world:World):Void {
        var step = world.getResource(ChangeStep);
        if (step.value == 0) {
            step.value = 1;
            return;
        }
        var target = world.query(AppPosition).with(AppTag).getSingle();
        if (target != null) {
            world.insert(target.entity, new AppPosition(target.component.value + 10));
        }
        step.value = 2;
    }

    @:system("Update")
    public static function changedQuerySystem(query:Query<AppPosition, Changed<AppPosition>>, step:Res<ChangeStep>, commands:Commands):Void {
        var count = query.toArray().length;
        if (step.value.value <= 1) {
            commands.insertResource(new ChangedCountFirst(count));
        } else {
            commands.insertResource(new ChangedCountSecond(count));
        }
    }

    @:system("Update")
    @:after("app.CounterSystems.addAsync")
    @:before("app.CounterSystems.readBack")
    public static function applyAsyncCounterDelta(counter:ResMut<Counter>, delta:Res<AsyncCounterDelta>, commands:Commands):Void {
        counter.value.value += delta.value.value;
        commands.removeResource(AsyncCounterDelta);
    }

    @:system("Update")
    public static function sendEvent(writer:EventWriter<AppSignal>):Void {
        writer.send(new AppSignal("received"));
    }

    @:system("Update")
    public static function readEvent(reader:EventReader<AppSignal>, commands:Commands):Void {
        for (event in reader.read()) {
            commands.insertResource(new EventStatus(event.value));
        }
    }
}

class CounterConditions {
    public static function allowSync(state:Res<RunIfState>):Bool {
        return state.value.syncEnabled;
    }

    public static function allowAsync(state:Res<RunIfState>):Future<Bool> {
        return Future.resolved(state.value.asyncEnabled);
    }

    public static function hasTaggedPosition(query:Query<AppPosition, With<AppTag>>):Bool {
        return !query.isEmpty();
    }
}

class CounterSetConditions {
    public static function allowAlpha(gate:Res<SetGate>):Bool {
        return gate.value.alphaEnabled;
    }

    public static function allowBeta(gate:Res<SetGate>):Bool {
        return gate.value.betaEnabled;
    }
}
