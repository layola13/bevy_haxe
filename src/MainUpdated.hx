package;

/**
 * Bevy Haxe Engine - Main Entry Point
 * 
 * This is the primary entry point for Bevy Haxe applications.
 * Use this module to initialize and run the application.
 */

import haxe.prelude.Prelude;
import haxe.app.App;
import haxe.app.Plugin;

class Main {
    /**
     * Application configuration
     */
    static var config:AppConfig = {
        title: "Bevy Haxe Application",
        width: 1280,
        height: 720,
        vsync: true
    };

    /**
     * Main entry point.
     */
    static function main() {
        #if debug
        trace("=== Bevy Haxe Engine ===");
        trace("Starting in debug mode...");
        #end
        
        // Create and run the application
        run();
    }

    /**
     * Create and run the App instance.
     */
    public static function run():Void {
        var app = new App();
        
        // Configure window
        app.title = config.title;
        app.width = config.width;
        app.height = config.height;
        
        // Add default plugins
        app.addPlugin(new haxe.app.LifecyclePlugin("core"));
        
        #if debug
        trace('App initialized: ${app.title}');
        trace('Resolution: ${app.width}x${app.height}');
        #end
        
        // Run the application
        app.run();
        
        #if debug
        trace("Application closed.");
        #end
    }

    /**
     * Quick start with custom setup and update functions.
     */
    public static function quickStart(?setup:Void->Void, ?update:Float->Void):Void {
        var app = new App();
        
        if (setup != null) {
            app.onSetup = setup;
        }
        
        if (update != null) {
            app.onUpdate = update;
        }
        
        app.run();
    }
}

/**
 * Application configuration type.
 */
typedef AppConfig = {
    ?title:String,
    ?width:Int,
    ?height:Int,
    ?fullscreen:Bool,
    ?vsync:Bool,
    ?targetFps:Int
}
