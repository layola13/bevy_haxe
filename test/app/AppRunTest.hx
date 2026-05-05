package app;

import bevy.app.App;
import bevy.app.AppError;
import bevy.app.AppError.AppErrorKind;
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
        testInitResource();
        testPluginGroup();
        testAddPluginsComposition();
        testAddPluginsMacroVarargs();
        testPluginAddedIntrospection();
        testPluginUniquenessTypedError();
        testPluginGroupTypedErrors();
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

    static function testInitResource():Void {
        var app = new App();
        app.initResource(AppInitResource);
        assertEq(1, app.world.getResource(AppInitResource).value, "app.initResource should initialize default resource");
        app.initResource(AppInitResource);
        assertEq(1, app.world.getResource(AppInitResource).value, "app.initResource should not overwrite existing resource");
    }

    static function testPluginGroup():Void {
        var app = new App();
        app.world.insertResource(new RunTrace());
        app.addPluginGroup(new OrderedPlugins());

        var trace = app.world.getResource(RunTrace);
        assertEq("alpha,gamma", trace.join(","), "plugin group should respect ordering and disable removed plugin");

        var builder = bevy.app.PluginGroup.PluginGroupBuilder.start(bevy.app.PluginGroup.NoopPluginGroup)
            .add(new AlphaPlugin())
            .add(new BetaPlugin());
        assert(builder.contains(AlphaPlugin), "builder should track plugin type presence");
        assert(builder.enabled(BetaPlugin), "plugin should start enabled");
        builder.disable(BetaPlugin).enable(BetaPlugin);
        assert(builder.tryAdd(new BetaPlugin()) == false, "builder should reject duplicate plugin type in tryAdd");

        var replaced = builder.trySet(new BetaPlugin());
        assert(replaced, "builder should replace an existing plugin via trySet");
        assert(builder.tryAddBeforeOverwrite(AlphaPlugin, new GammaPlugin()), "builder should support before-overwrite insertion");
        assert(builder.tryAddAfterOverwrite(GammaPlugin, new AlphaPlugin()), "builder should support after-overwrite insertion");

        var groupedApp = new App();
        groupedApp.world.insertResource(new RunTrace());
        groupedApp.addPluginGroup(
            bevy.app.PluginGroup.PluginGroupBuilder.start(bevy.app.PluginGroup.NoopPluginGroup)
                .add(new AlphaPlugin())
                .addAfter(AlphaPlugin, new GammaPlugin())
                .addBefore(GammaPlugin, new BetaPlugin())
                .disable(BetaPlugin)
        );
        assertEq("alpha,gamma", groupedApp.world.getResource(RunTrace).join(","), "builder-backed plugin group should finish in configured order");
    }

    static function testAddPluginsComposition():Void {
        var singleApp = new App();
        singleApp.world.insertResource(new RunTrace());
        singleApp.addPlugins(new AlphaPlugin());
        assertEq("alpha", singleApp.world.getResource(RunTrace).join(","), "addPlugins should accept a single Plugin");

        var builderApp = new App();
        builderApp.world.insertResource(new RunTrace());
        builderApp.addPlugins(
            bevy.app.PluginGroup.PluginGroupBuilder.start(bevy.app.PluginGroup.NoopPluginGroup)
                .add(new AlphaPlugin())
                .addAfter(AlphaPlugin, new GammaPlugin())
                .disable(GammaPlugin)
        );
        assertEq("alpha", builderApp.world.getResource(RunTrace).join(","), "addPlugins should accept a PluginGroupBuilder");

        var nestedApp = new App();
        nestedApp.world.insertResource(new RunTrace());
        var nestedItems:Array<bevy.app.Plugins> = [];
        nestedItems.push(new AlphaPlugin());
        nestedItems.push(
            bevy.app.PluginGroup.PluginGroupBuilder.start(bevy.app.PluginGroup.NoopPluginGroup)
                .add(new GammaPlugin())
        );
        var innerItems:Array<bevy.app.Plugins> = [];
        innerItems.push(
            bevy.app.PluginGroup.PluginGroupBuilder.start(bevy.app.PluginGroup.NoopPluginGroup)
                .add(new DeltaPlugin())
        );
        nestedItems.push(innerItems);
        var nested:bevy.app.Plugins = nestedItems;
        nestedApp.addPlugins(nested);
        assertEq("alpha,gamma,delta", nestedApp.world.getResource(RunTrace).join(","), "addPlugins should compose plugins, groups, builders, and nested arrays");
    }

    static function testAddPluginsMacroVarargs():Void {
        var app = new App();
        app.world.insertResource(new RunTrace());
        app.addPlugins(bevy.app.PluginsDsl.of(
            new AlphaPlugin(),
            [
                bevy.app.PluginGroup.PluginGroupBuilder.start(bevy.app.PluginGroup.NoopPluginGroup)
                    .add(new GammaPlugin())
            ],
            new DeltaPlugin()
        ));
        assertEq("alpha,gamma,delta", app.world.getResource(RunTrace).join(","), "Plugins.of should accept varargs and nested arrays");
    }

    static function testPluginAddedIntrospection():Void {
        var app = new App();
        app.world.insertResource(new RunTrace());
        assert(!app.isPluginAdded(AlphaPlugin), "isPluginAdded should be false before registration");
        app.addPlugin(new AlphaPlugin());
        assert(app.isPluginAdded(AlphaPlugin), "isPluginAdded should track registered plugin types");
    }

    static function testPluginUniquenessTypedError():Void {
        var app = new App();
        app.world.insertResource(new RunTrace());
        app.addPlugin(new AlphaPlugin());

        var typedError:AppError = null;
        try {
            app.addPlugin(new AlphaPlugin());
        } catch (error:AppError) {
            typedError = error;
        }

        assert(typedError != null, "duplicate unique plugin registration should throw AppError");
        switch typedError.kind {
            case PluginAlreadyAdded(pluginName):
                assert(pluginName != null && pluginName != "", "duplicate-plugin typed error should preserve plugin name");
            default:
                throw "unexpected plugin uniqueness typed error kind";
        }
    }

    static function testPluginGroupTypedErrors():Void {
        testPluginGroupMissingTargetError();
        testPluginGroupAddFailedError();
    }

    static function testPluginGroupMissingTargetError():Void {
        var typedError:AppError = null;
        try {
            bevy.app.PluginGroup.PluginGroupBuilder.start(bevy.app.PluginGroup.NoopPluginGroup)
                .add(new AlphaPlugin())
                .addBefore(BetaPlugin, new GammaPlugin());
        } catch (error:AppError) {
            typedError = error;
        }

        assert(typedError != null, "missing target plugin should throw typed plugin-group error");
        switch typedError.kind {
            case PluginGroupPluginMissing(groupName, pluginTypeKey):
                assert(groupName != null && groupName != "", "missing-target plugin-group error should keep group name");
                assert(pluginTypeKey != null && pluginTypeKey != "", "missing-target plugin-group error should keep type key");
            default:
                throw "unexpected plugin-group missing-target typed error kind";
        }
    }

    static function testPluginGroupAddFailedError():Void {
        var app = new App();
        app.world.insertResource(new RunTrace());

        var typedError:AppError = null;
        try {
            app.addPlugin(new AlphaPlugin());
            app.addPluginGroup(
                bevy.app.PluginGroup.PluginGroupBuilder.start(bevy.app.PluginGroup.NoopPluginGroup)
                    .add(new AlphaPlugin())
            );
        } catch (error:AppError) {
            typedError = error;
        }

        assert(typedError != null, "plugin-group finish failure should throw typed plugin-group error");
        switch typedError.kind {
            case PluginGroupAddFailed(groupName, pluginName, cause):
                assert(groupName != null && groupName != "", "group-add-failed error should keep group name");
                assert(pluginName != null && pluginName != "", "group-add-failed error should keep plugin name");
                assert(cause != null, "group-add-failed error should preserve nested cause");
            default:
                throw "unexpected plugin-group add-failed typed error kind";
        }
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
    public var value:Int;

    public function new(?value:Int) {
        this.value = value != null ? value : 0;
    }
}

class RunnerCounter implements Resource {
    public var value:Int;

    public function new(?value:Int) {
        this.value = value != null ? value : 0;
    }
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
    public var marker(default, null):String;

    public function new(?marker:String) {
        this.marker = marker != null ? marker : "lifecycle";
    }

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

class AppInitResource implements Resource {
    public static var created:Int = 0;
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }

    public static function createDefault():AppInitResource {
        created++;
        return new AppInitResource(created);
    }
}

class OrderedPlugins implements bevy.app.PluginGroup {
    public var marker(default, null):String;

    public function new(?marker:String) {
        this.marker = marker != null ? marker : "ordered";
    }

    public function build():bevy.app.PluginGroup.PluginGroupBuilder {
        return bevy.app.PluginGroup.PluginGroupBuilder.start(OrderedPlugins)
            .add(new AlphaPlugin())
            .add(new BetaPlugin())
            .addAfter(AlphaPlugin, new GammaPlugin())
            .disable(BetaPlugin);
    }
}

class AlphaPlugin implements bevy.app.Plugin {
    public var marker(default, null):String;

    public function new(?marker:String) {
        this.marker = marker != null ? marker : "alpha";
    }

    public function build(app:App):Void {
        app.world.getResource(RunTrace).push("alpha");
    }
}

class BetaPlugin implements bevy.app.Plugin {
    public var marker(default, null):String;

    public function new(?marker:String) {
        this.marker = marker != null ? marker : "beta";
    }

    public function build(app:App):Void {
        app.world.getResource(RunTrace).push("beta");
    }
}

class GammaPlugin implements bevy.app.Plugin {
    public var marker(default, null):String;

    public function new(?marker:String) {
        this.marker = marker != null ? marker : "gamma";
    }

    public function build(app:App):Void {
        app.world.getResource(RunTrace).push("gamma");
    }
}

class DeltaPlugin implements bevy.app.Plugin {
    public var marker(default, null):String;

    public function new(?marker:String) {
        this.marker = marker != null ? marker : "delta";
    }

    public function build(app:App):Void {
        app.world.getResource(RunTrace).push("delta");
    }
}
