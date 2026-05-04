package haxe.prelude;

/**
 * App module prelude.
 * Provides convenient access to application and startup types.
 */
class AppPrelude {
    public function new() {}
}

/**
 * Application configuration.
 */
typedef AppConfig = {
    var ?title:String;
    var ?width:Int;
    var ?height:Int;
    var ?fullscreen:Bool;
    var ?vsync:Bool;
}

/**
 * Startup stage enum.
 */
enum StartupStage {
    PreStartup;
    Startup;
    PostStartup;
}

/**
 * Main loop stage enum.
 */
enum MainLoopStage {
    PreUpdate;
    Update;
    PostUpdate;
    PreRender;
    Render;
    PostRender;
}
