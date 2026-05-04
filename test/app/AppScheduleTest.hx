package app;

import bevy.app.App;
import bevy.app.MainSchedule;
import bevy.app.SystemClass;
import bevy.app.SystemRegistry;
import bevy.async.AsyncClass;
import bevy.async.AsyncRuntime;
import bevy.async.Future;
import bevy.ecs.Commands;
import bevy.ecs.Component;
import bevy.ecs.Event;
import bevy.ecs.Events.EventReader;
import bevy.ecs.Events.EventWriter;
import bevy.ecs.Query.Query2;
import bevy.ecs.Res;
import bevy.ecs.ResMut;
import bevy.ecs.Resource;
import bevy.ecs.World;

class AppScheduleTest {
    static function main():Void {
        var app = new App();
        app.world.insertResource(new Counter());
        app.world.spawn([new AppPosition(1), new AppVelocity(2)]);
        app.world.initEvents(AppSignal);
        app.addRegisteredSystems(MainSchedule.Update);

        var done = false;
        app.update().handle(function(_) {
            done = true;
        }, function(error) throw error);
        AsyncRuntime.flush();

        assert(done, "update future should resolve");
        assertEq(8, app.world.getResource(Counter).value, "sync and async systems should run in order");
        assertEq("sync", app.world.getResource(CommandFlag).value, "sync command should apply");
        assertEq(9, app.world.getResource(AsyncCommandFlag).value, "async command should apply after await");
        assertEq(8, app.world.getResource(ReadBack).value, "Res param should read resource");
        assertEq(3, app.world.getResource(QueryTotal).value, "Query2 param should read components");
        assertEq("received", app.world.getResource(EventStatus).value, "events should flow through systems");
        trace("AppScheduleTest ok");
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

class EventStatus implements Resource {
    public var value:String;
    public function new(value:String) {
        this.value = value;
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

class AppSignal implements Event {
    public var value:String;
    public function new(value:String) {
        this.value = value;
    }
}

class CounterSystems implements SystemClass implements AsyncClass {
    @:system("Update")
    public static function addOne(counter:ResMut<Counter>):Void {
        counter.value.value += 1;
    }

    @:async
    @:system("Update")
    public static function addAsync(counter:ResMut<Counter>) {
        var value = @await Future.resolved(7);
        counter.value.value += value;
    }

    @:system("Update")
    public static function commandFlag(commands:Commands):Void {
        commands.insertResource(new CommandFlag("sync"));
    }

    @:async
    @:system("Update")
    public static function asyncCommand(commands:Commands) {
        var value = @await Future.resolved(9);
        commands.insertResource(new AsyncCommandFlag(value));
    }

    @:system("Update")
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
