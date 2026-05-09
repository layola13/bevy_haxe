package haxe.app;

import haxe.ds.Map;
import haxe.app.AppError;
import haxe.app.AppError.AppErrorKind;
import haxe.app.Plugins;

/**
    System function type.
**/
typedef System = Void->Void;

/**
    System with App context.
**/
typedef AppSystem = App->Void;

/**
    App is the primary API for writing applications.

    It automates the setup of a standard lifecycle and provides
    interface glue for plugins.

    ## Example

    ```haxe
    class MyPlugin extends LifecyclePlugin {
        public override function build(app:App) {
            app.addSystem(() -> trace("Hello"));
        }
    }

    App.new()
        .addPlugin(new MyPlugin())
        .run();
    ```
**/
class App {
    /**
        Registered plugins.
    **/
    var plugins:Map<String, Plugin>;

    /**
        Registered systems by schedule.
    **/
    var systems:Map<Schedule, Array<System>>;

    /**
        Plugin registration order.
    **/
    var pluginOrder:Array<String>;

    /**
        Current schedule.
    **/
    var currentSchedule:Schedule;

    /**
        Creates a new App instance.
    **/
    public function new() {
        plugins = new Map();
        systems = new Map();
        pluginOrder = [];
        currentSchedule = Update;

        // Add default plugins
        addPluginInternal(new TaskPoolPlugin());
        addPluginInternal(new ScheduleRunnerPlugin());
    }

    /**
        Adds a plugin to the App.

        The plugin's `build` method is called immediately.
        Returns `this` for chainable API.
    **/
    public function addPlugin<T:Plugin>(plugin:T):App {
        addPluginInternal(plugin);
        return this;
    }

    /**
        Internal method to add plugin without returning App.
    **/
    function addPluginInternal<T:Plugin>(plugin:T):Void {
        if (plugin.isUnique && plugins.exists(plugin.name)) {
            throw new AppError(AppErrorKind.PluginAlreadyAdded(plugin.name));
        }
        plugins.set(plugin.name, plugin);
        pluginOrder.push(plugin.name);
        plugin.build(this);
    }

    /**
        Directly adds a plugin (used by PluginGroup).
    **/
    function addPluginDirectly<T:Plugin>(plugin:T):Void {
        addPluginInternal(plugin);
    }

    /**
        Adds a plugin group to the App.

        Returns `this` for chainable API.
    **/
    public function addPluginGroup<T:PluginGroup>(group:T):App {
        return group.build().finish(this);
    }

    public function addPlugins(values:Plugins):App {
        values.addToApp(this);
        return this;
    }

    /**
        Adds a system to the current schedule.

        Returns `this` for chainable API.
    **/
    public function addSystem(system:System):App {
        if (!systems.exists(currentSchedule)) {
            systems.set(currentSchedule, []);
        }
        systems.get(currentSchedule).push(system);
        return this;
    }

    /**
        Adds a system with App context to the current schedule.

        Returns `this` for chainable API.
    **/
    public function addSystemWithApp(system:AppSystem):App {
        if (!systems.exists(currentSchedule)) {
            systems.set(currentSchedule, []);
        }
        systems.get(currentSchedule).push(() -> system(this));
        return this;
    }

    /**
        Sets the current schedule for subsequent `addSystem` calls.

        Returns `this` for chainable API.
    **/
    public function setSchedule(schedule:Schedule):App {
        currentSchedule = schedule;
        return this;
    }

    /**
        Finishes the app setup.

        Called internally before running.
    **/
    function finish():Void {
        for (name in pluginOrder) {
            var plugin = plugins.get(name);
            plugin.finish(this);
        }
    }

    /**
        Checks if all plugins are ready.
    **/
    function arePluginsReady():Bool {
        for (name in pluginOrder) {
            var plugin = plugins.get(name);
            if (!plugin.ready(this)) {
                return false;
            }
        }
        return true;
    }

    /**
        Runs the App.

        This function should be called at the end of the program.
    **/
    public function run():Void {
        // Wait for all plugins to be ready
        while (!arePluginsReady()) {
            // Could implement async waiting here
        }

        // Finish setup
        finish();

        // Run the schedule runner
        var scheduleRunner:ScheduleRunnerPlugin = cast plugins.get('bevy_app.ScheduleRunnerPlugin');
        if (scheduleRunner != null) {
            scheduleRunner.run();
        }
    }

    /**
        Updates the App once (for embedded use).
    **/
    public function update():Void {
        for (name in pluginOrder) {
            var plugin = plugins.get(name);
            plugin.ready(this);
        }
    }
}

/**
    Schedule labels for system execution order.
**/
enum Schedule {
    /**
        First schedule - runs once at startup.
    **/
    First;

    /**
        Pre-update schedule - runs before each update.
    **/
    PreUpdate;

    /**
        Main update schedule - default location for game logic.
    **/
    Update;

    /**
        Post-update schedule - runs after each update.
    **/
    PostUpdate;

    /**
        Last schedule - runs once at end.
    **/
    Last;
}

/**
    Default plugin for task pool setup.
**/
class TaskPoolPlugin extends LifecyclePlugin {
    public function new() {
        super('bevy_app.TaskPoolPlugin');
    }

    public override function build(app:App):Void {
        // Task pool setup would go here
    }
}

/**
    Default plugin for schedule running.
**/
class ScheduleRunnerPlugin extends LifecyclePlugin {
    public function new() {
        super('bevy_app.ScheduleRunnerPlugin');
    }

    public override function build(app:App):Void {
        // Schedule runner setup would go here
    }

    /**
        Runs the main loop.
    **/
    public function run():Void {
        // Default implementation - just run update once
        // In a real app, this would be a game loop
    }
}
