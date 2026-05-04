package app;

import bevy.app.App;
import bevy.app.PluginsState;
import bevy.app.MainSchedule;
import bevy.app.ScheduleRunnerPlugin;
import bevy.async.AsyncRuntime;
import bevy.async.Future;
import bevy.ecs.Resource;

class AppRunTest {
    static function main():Void {
        testInterpRun();
        testStartupOnce();
        testPluginLifecycle();
        testSetRunner();
        testScheduleRunnerPlugin();
        trace("AppRunTest ok");
    }

    static function testInterpRun():Void {
        var app = new App();
        app.world.insertResource(new RunTrace());
        app.addSystem(MainSchedule.Startup, function(world) {
            world.getResource(RunTrace).push("startup");
            return null;
        });
        app.addSystem(MainSchedule.First, function(world) {
            world.getResource(RunTrace).push("first");
            return null;
        });
        app.addSystem(MainSchedule.Update, function(world) {
            world.getResource(RunTrace).push("update");
            world.sendEvent(new RunEvent("frame"));
            return null;
        });
        app.addSystem(MainSchedule.Last, function(world) {
            world.getResource(RunTrace).push("last");
            return null;
        });

        var done = false;
        app.run().handle(function(_) {
            done = true;
        }, function(error) throw error);
        AsyncRuntime.flush();

        assert(done, "run should resolve on interp");
        assert(app.started, "startup should mark app started");
        assert(!app.running, "app should stop after interp frame");
        assertEq(1, app.frameCount, "run should advance one frame on interp");
        assertEq("startup,first,update,last", app.world.getResource(RunTrace).join(","), "schedule order");
        assertEq(2, app.world.tick(), "world tick should advance once");
        assertEq(0, app.world.getEvents(RunEvent).len(), "events should clear after frame");
    }

    static function testStartupOnce():Void {
        var app = new App();
        app.world.insertResource(new StartupCounter());
        app.addSystem(MainSchedule.Startup, function(world) {
            world.getResource(StartupCounter).value++;
            return null;
        });
        app.addSystem(MainSchedule.Update, function(world) {
            return Future.resolved(null);
        });

        var firstDone = false;
        app.run().handle(function(_) firstDone = true, function(error) throw error);
        AsyncRuntime.flush();
        var secondDone = false;
        app.run().handle(function(_) secondDone = true, function(error) throw error);
        AsyncRuntime.flush();

        assert(firstDone, "first run should resolve");
        assert(secondDone, "second run should resolve");
        assertEq(1, app.world.getResource(StartupCounter).value, "startup should only run once");
        assertEq(2, app.frameCount, "second run should execute another frame");
    }

    static function testPluginLifecycle():Void {
        var app = new App();
        var plugin = new LifecyclePlugin();
        app.addPlugin(plugin);

        assertEq(Ready, app.pluginsState(), "plugin should become ready");

        var done = false;
        app.run().handle(function(_) {
            done = true;
        }, function(error) throw error);
        AsyncRuntime.flush();

        assert(done, "run should resolve with ready plugin");
        assert(plugin.finishCalled, "plugin finish should run before execution");
        assert(plugin.cleanupCalled, "plugin cleanup should run before execution");
        assertEq(Cleaned, app.pluginsState(), "plugin lifecycle should be cleaned");
    }

    static function testSetRunner():Void {
        var app = new App();
        app.addSystem(MainSchedule.Update, function(world) {
            world.insertResource(new RunnerCounter());
            return null;
        });
        app.setRunner(function(target:App) {
            return target.startup().next(function(_) {
                return target.update().next(function(_) {
                    return target.update();
                });
            });
        });

        var done = false;
        app.run().handle(function(_) {
            done = true;
        }, function(error) throw error);
        AsyncRuntime.flush();

        assert(done, "custom runner should resolve");
        assertEq(2, app.frameCount, "custom runner should be used");
    }

    static function testScheduleRunnerPlugin():Void {
        var app = new App();
        app.world.insertResource(new RunnerCounter());
        app.addPlugin(ScheduleRunnerPlugin.runOnce());
        app.addSystem(MainSchedule.Update, function(world) {
            world.getResource(RunnerCounter).value++;
            return null;
        });

        var done = false;
        app.run().handle(function(_) {
            done = true;
        }, function(error) throw error);
        AsyncRuntime.flush();

        assert(done, "schedule runner plugin should resolve");
        assertEq(1, app.world.getResource(RunnerCounter).value, "schedule runner plugin should drive one frame");
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

class RunTrace implements Resource {
    public var values:Array<String>;

    public function new() {
        values = [];
    }

    public function push(value:String):Void {
        values.push(value);
    }

    public function join(separator:String):String {
        return values.join(separator);
    }
}

class StartupCounter implements Resource {
    public var value:Int = 0;

    public function new() {}
}

class RunnerCounter implements Resource {
    public var value:Int = 0;

    public function new() {}
}

class RunEvent {
    public var value:String;

    public function new(value:String) {
        this.value = value;
    }
}

class LifecyclePlugin implements bevy.app.Plugin {
    public var finishCalled:Bool = false;
    public var cleanupCalled:Bool = false;

    public function new() {}

    public function build(app:App):Void {}

    public function ready(app:App):Bool {
        return true;
    }

    public function finish(app:App):Void {
        finishCalled = true;
    }

    public function cleanup(app:App):Void {
        cleanupCalled = true;
    }
}
