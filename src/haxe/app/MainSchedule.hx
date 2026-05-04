package haxe.app;

import haxe.ecs.schedule.Schedule;
import haxe.ecs.schedule.ScheduleLabel;
import haxe.ecs.schedule.InternedScheduleLabel;
import haxe.ecs.system.System;
import haxe.ecs.world.World;

/**
    Schedule labels for the main application schedule.
    
    These represent the standard Bevy schedules that are run
    each tick of the application.
    
    ## Default Order
    
    On the first run:
    - StateTransition (if state plugin enabled)
    - PreStartup
    - Startup
    - PostStartup
    
    Then each frame:
    - First
    - PreUpdate
    - StateTransition (if state plugin enabled)
    - RunFixedMainLoop (may run FixedMain zero or more times)
    - Update
    - SpawnScene
    - PostUpdate
    - Last
**/
class MainScheduleOrder {
    /**
        The list of startup schedule labels in order.
    **/
    public var startup_labels:Array<InternedScheduleLabel>;
    
    /**
        The list of main schedule labels in order.
    **/
    public var main_labels:Array<InternedScheduleLabel>;
    
    public function new() {
        startup_labels = [];
        main_labels = [];
    }
    
    /**
        Adds a schedule before another in the startup schedules.
    **/
    public function insert_startup_before(before:InternedScheduleLabel, schedule:InternedScheduleLabel):Void {
        var index = Lambda.indexOf(startup_labels, before);
        if (index < 0) index = startup_labels.length;
        startup_labels.insert(index, schedule);
    }
    
    /**
        Adds a schedule after another in the startup schedules.
    **/
    public function insert_startup_after(after:InternedScheduleLabel, schedule:InternedScheduleLabel):Void {
        var index = Lambda.indexOf(startup_labels, after);
        if (index < 0) index = 0;
        else index++;
        startup_labels.insert(index, schedule);
    }
    
    /**
        Adds a schedule before another in the main schedules.
    **/
    public function insert_main_before(before:InternedScheduleLabel, schedule:InternedScheduleLabel):Void {
        var index = Lambda.indexOf(main_labels, before);
        if (index < 0) index = main_labels.length;
        main_labels.insert(index, schedule);
    }
    
    /**
        Adds a schedule after another in the main schedules.
    **/
    public function insert_main_after(after:InternedScheduleLabel, schedule:InternedScheduleLabel):Void {
        var index = Lambda.indexOf(main_labels, after);
        if (index < 0) index = 0;
        else index++;
        main_labels.insert(index, schedule);
    }
}

/**
    The main schedule that contains the app logic evaluated each tick.
    
    See the module documentation for the default schedule order.
**/
@:keep
class Main implements ScheduleLabel {
    public function new() {}
    
    /**
        Returns the type ID for this schedule label.
    **/
    public function getTypeId():Any return Main;
    
    /**
        Returns the display name.
    **/
    public function name():String return 'Main';
}

/**
    Pre-update schedule - runs before the main update.
    
    ## Example

    ```haxe
    app.addSystem(PreUpdate, processInput);
    ```
**/
@:keep
class PreUpdate implements ScheduleLabel {
    public function new() {}
    public function getTypeId():Any return PreUpdate;
    public function name():String return 'PreUpdate';
}

/**
    Main update schedule - runs once per frame.
    
    This is the default location for game logic systems.
    
    ## Example

    ```haxe
    app.addSystem(Update, moveEntities);
    ```
**/
@:keep
class Update implements ScheduleLabel {
    public function new() {}
    public function getTypeId():Any return Update;
    public function name():String return 'Update';
}

/**
    Post-update schedule - runs after the main update.
    
    ## Example

    ```haxe
    app.addSystem(PostUpdate, syncTransforms);
    ```
**/
@:keep
class PostUpdate implements ScheduleLabel {
    public function new() {}
    public function getTypeId():Any return PostUpdate;
    public function name():String return 'PostUpdate';
}

/**
    First schedule - runs at the start of each frame.
    
    Good for systems that need to run before other systems.
    
    ## Example

    ```haxe
    app.addSystem(First, cameraController);
    ```
**/
@:keep
class First implements ScheduleLabel {
    public function new() {}
    public function getTypeId():Any return First;
    public function name():String return 'First';
}

/**
    Last schedule - runs at the end of each frame.
    
    Good for cleanup systems or systems that need to run after all others.
    
    ## Example

    ```haxe
    app.addSystem(Last, cleanupEntities);
    ```
**/
@:keep
class Last implements ScheduleLabel {
    public function new() {}
    public function getTypeId():Any return Last;
    public function name():String return 'Last';
}

/**
    Pre-startup schedule - runs once before startup.
    
    Use this for systems that need to run before plugins are fully initialized.
    
    ## Example

    ```haxe
    app.addSystem(PreStartup, registerComponents);
    ```
**/
@:keep
class PreStartup implements ScheduleLabel {
    public function new() {}
    public function getTypeId():Any return PreStartup;
    public function name():String return 'PreStartup';
}

/**
    Startup schedule - runs once when the app starts.
    
    Use this for systems that should run once during initialization.
    
    ## Example

    ```haxe
    app.addSystem(Startup, spawnInitialEntities);
    ```
**/
@:keep
class Startup implements ScheduleLabel {
    public function new() {}
    public function getTypeId():Any return Startup;
    public function name():String return 'Startup';
}

/**
    Post-startup schedule - runs once after startup.
    
    ## Example

    ```haxe
    app.addSystem(PostStartup, initCamera);
    ```
**/
@:keep
class PostStartup implements ScheduleLabel {
    public function new() {}
    public function getTypeId():Any return PostStartup;
    public function name():String return 'PostStartup';
}

/**
    Fixed update schedule - runs at a fixed rate.
    
    Use this for physics, networking, or other logic that should
    run at a consistent rate regardless of frame rate.
    
    ## Example

    ```haxe
    app.addSystem(FixedUpdate, physicsSystem);
    ```
**/
@:keep
class FixedUpdate implements ScheduleLabel {
    public function new() {}
    public function getTypeId():Any return FixedUpdate;
    public function name():String return 'FixedUpdate';
}

/**
    Fixed pre-update schedule - runs before fixed update.
**/
@:keep
class FixedPreUpdate implements ScheduleLabel {
    public function new() {}
    public function getTypeId():Any return FixedPreUpdate;
    public function name():String return 'FixedPreUpdate';
}

/**
    Fixed post-update schedule - runs after fixed update.
**/
@:keep
class FixedPostUpdate implements ScheduleLabel {
    public function new() {}
    public function getTypeId():Any return FixedPostUpdate;
    public function name():String return 'FixedPostUpdate';
}

/**
    Fixed first schedule - runs first in fixed update.
**/
@:keep
class FixedFirst implements ScheduleLabel {
    public function new() {}
    public function getTypeId():Any return FixedFirst;
    public function name():String return 'FixedFirst';
}

/**
    Fixed last schedule - runs last in fixed update.
**/
@:keep
class FixedLast implements ScheduleLabel {
    public function new() {}
    public function getTypeId():Any return FixedLast;
    public function name():String return 'FixedLast';
}

/**
    Run fixed main loop schedule.
**/
@:keep
class RunFixedMainLoop implements ScheduleLabel {
    public function new() {}
    public function getTypeId():Any return RunFixedMainLoop;
    public function name():String return 'RunFixedMainLoop';
}

/**
    State transition schedule - runs for state changes.
    
    This is typically inserted automatically when using the state plugin.
**/
@:keep
class StateTransition implements ScheduleLabel {
    public function new() {}
    public function getTypeId():Any return StateTransition;
    public function name():String return 'StateTransition';
}

/**
    Spawn scene schedule - runs for scene spawning.
**/
@:keep
class SpawnScene implements ScheduleLabel {
    public function new() {}
    public function getTypeId():Any return SpawnScene;
    public function name():String return 'SpawnScene';
}

/**
    Pre-render schedule - runs before rendering.
**/
@:keep
class PreRender implements ScheduleLabel {
    public function new() {}
    public function getTypeId():Any return PreRender;
    public function name():String return 'PreRender';
}

/**
    Render schedule - runs during rendering.
**/
@:keep
class Render implements ScheduleLabel {
    public function new() {}
    public function getTypeId():Any return Render;
    public function name():String return 'Render';
}

/**
    Post-render schedule - runs after rendering.
**/
@:keep
class PostRender implements ScheduleLabel {
    public function new() {}
    public function getTypeId():Any return PostRender;
    public function name():String return 'PostRender';
}

/**
    Default schedule order for startup schedules.
**/
class StartupScheduleOrder {
    public static inline var DEFAULT:Array<Class<Dynamic>> = [
        PreStartup,
        Startup,
        PostStartup
    ];
}

/**
    Default schedule order for main schedules.
**/
class MainScheduleOrderDefaults {
    public static inline var DEFAULT:Array<Class<Dynamic>> = [
        First,
        PreUpdate,
        Update,
        PostUpdate,
        Last
    ];
}
