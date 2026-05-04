package bevy.app;

import bevy.async.Future;
import bevy.asset.AssetApp;
import bevy.asset.AssetLoaderRegistration;
import bevy.ecs.World;
import bevy.app.Plugin.PluginTools;
import bevy.app.PluginsState;
import bevy.app.SystemRegistry.SystemRunner;

typedef AppRunner = App->Future<Dynamic>;

class App {
    public var world(default, null):World;
    public var started(default, null):Bool;
    public var running(default, null):Bool;
    public var frameCount(default, null):Int;

    private var schedules:Map<String, Schedule>;
    private var plugins:Array<Plugin>;
    private var lifecycleState:PluginsState;
    private var runner:AppRunner;
    private var startupFuture:Null<Future<Dynamic>>;
    private var runFuture:Null<Future<Dynamic>>;
    private var exitRequest:Null<AppExit>;

    public function new() {
        world = new World();
        started = false;
        running = false;
        frameCount = 0;
        schedules = new Map();
        plugins = [];
        lifecycleState = Adding;
        runner = runOnce;
        startupFuture = null;
        runFuture = null;
        exitRequest = null;

        initSchedule(MainSchedule.First);
        initSchedule(MainSchedule.Startup);
        initSchedule(MainSchedule.PreUpdate);
        initSchedule(MainSchedule.Update);
        initSchedule(MainSchedule.PostUpdate);
        initSchedule(MainSchedule.Last);
    }

    public function addPlugin(plugin:Plugin):App {
        assertPluginUnique(plugin);
        lifecycleState = Adding;
        plugin.build(this);
        plugins.push(plugin);
        return this;
    }

    public function addPlugins(values:Array<Plugin>):App {
        for (plugin in values) {
            addPlugin(plugin);
        }
        return this;
    }

    public function pluginsState():PluginsState {
        switch lifecycleState {
            case Finished | Cleaned:
                return lifecycleState;
            case Adding | Ready:
        }

        for (plugin in plugins) {
            if (!PluginTools.isReady(plugin, this)) {
                lifecycleState = Adding;
                return lifecycleState;
            }
        }

        lifecycleState = Ready;
        return lifecycleState;
    }

    public function finish():App {
        if (lifecycleState == Finished || lifecycleState == Cleaned) {
            return this;
        }
        for (plugin in plugins) {
            PluginTools.finish(plugin, this);
        }
        lifecycleState = Finished;
        return this;
    }

    public function cleanup():App {
        if (lifecycleState == Cleaned) {
            return this;
        }
        if (lifecycleState == Adding || lifecycleState == Ready) {
            finish();
        }
        for (plugin in plugins) {
            PluginTools.cleanup(plugin, this);
        }
        lifecycleState = Cleaned;
        return this;
    }

    public function setRunner(value:AppRunner):App {
        runner = value;
        return this;
    }

    public function addSystem(schedule:String, run:SystemRunner, ?name:String):App {
        initSchedule(schedule).addSystem(run, name);
        return this;
    }

    public function addRegisteredSystems(?schedule:String):App {
        if (schedule == null) {
            for (descriptor in SystemRegistry.all()) {
                initSchedule(descriptor.schedule).addDescriptor(descriptor);
            }
        } else {
            for (descriptor in SystemRegistry.bySchedule(schedule)) {
                initSchedule(schedule).addDescriptor(descriptor);
            }
        }
        return this;
    }

    public function initAsset<T>(assetClass:Class<T>):App {
        return AssetApp.initAsset(this, assetClass);
    }

    public function registerAssetLoader(loader:AssetLoaderRegistration):App {
        return AssetApp.registerAssetLoader(this, loader);
    }

    public function runSchedule(schedule:String):Future<Dynamic> {
        return initSchedule(schedule).run(world);
    }

    public function update():Future<Dynamic> {
        return runSequence([
            MainSchedule.First,
            MainSchedule.PreUpdate,
            MainSchedule.Update,
            MainSchedule.PostUpdate,
            MainSchedule.Last
        ], 0).map(function(result) {
            frameCount++;
            world.advanceTick();
            world.clearEvents();
            return result;
        });
    }

    public function startup():Future<Dynamic> {
        if (started) {
            return Future.resolved(null);
        }
        if (startupFuture != null) {
            return startupFuture;
        }
        startupFuture = Future.create(function(resolve, reject) {
            runSchedule(MainSchedule.Startup).handle(function(result) {
                started = true;
                startupFuture = null;
                resolve(result);
            }, function(error) {
                startupFuture = null;
                reject(error);
            });
        });
        return startupFuture;
    }

    public function run():Future<Dynamic> {
        if (running && runFuture != null) {
            return runFuture;
        }

        var state = pluginsState();
        if (state == Adding) {
            return Future.rejected("App.run() called while plugins are still adding");
        }
        if (state == Ready) {
            finish();
            cleanup();
        }

        running = true;
        runFuture = Future.create(function(resolve, reject) {
            try {
                runner(this).handle(function(result) {
                    running = false;
                    runFuture = null;
                    resolve(result);
                }, function(error) {
                    running = false;
                    runFuture = null;
                    reject(error);
                });
            } catch (error:Dynamic) {
                running = false;
                runFuture = null;
                reject(error);
            }
        });
        return runFuture;
    }

    public function requestExit(?code:Int):App {
        exitRequest = new AppExit(code != null ? code : 0);
        return this;
    }

    public function shouldExit():Null<AppExit> {
        return exitRequest;
    }

    public function clearExit():App {
        exitRequest = null;
        return this;
    }

    public function stop():Void {
        requestExit();
    }

    private function initSchedule(label:String):Schedule {
        var schedule = schedules.get(label);
        if (schedule == null) {
            schedule = new Schedule(label);
            schedules.set(label, schedule);
        }
        return schedule;
    }

    private function runSequence(labels:Array<String>, index:Int):Future<Dynamic> {
        if (index >= labels.length) {
            return Future.resolved(null);
        }
        return runSchedule(labels[index]).next(function(_) {
            return runSequence(labels, index + 1);
        });
    }

    private function assertPluginUnique(plugin:Plugin):Void {
        if (!PluginTools.isUnique(plugin)) {
            return;
        }

        var name = PluginTools.name(plugin);
        for (existing in plugins) {
            if (PluginTools.isUnique(existing) && PluginTools.name(existing) == name) {
                throw 'Plugin already added: $name';
            }
        }
    }

    private static function runOnce(app:App):Future<Dynamic> {
        return app.startup().next(function(_) {
            return app.update();
        });
    }
}
