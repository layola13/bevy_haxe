package;

/**
 * Hello World Example for Bevy Haxe Engine.
 * 
 * This example demonstrates:
 * - Basic prelude imports
 * - Vector and math operations
 * - Entity creation
 * - Simple application lifecycle
 */

import haxe.prelude.Prelude;
import haxe.app.App;

class Main {
    static function main() {
        trace("=== Hello World Example ===");
        
        // Create the application
        var app = new HelloWorldApp();
        app.run();
        
        trace("Example completed.");
    }
}

/**
 * Simple Hello World application.
 */
class HelloWorldApp extends App {
    private var frameCount:Int = 0;
    private var startTime:Float;
    
    public function new() {
        super();
        title = "Hello World - Bevy Haxe";
        width = 800;
        height = 600;
        startTime = 0;
    }
    
    override function setup() {
        super.setup();
        trace("Setup complete!");
        
        // Create some test entities
        var player = entity(1);
        var enemy = entity(2);
        var npc = entity(3);
        
        trace('Created entities: player=#${player.id}, enemy=#${enemy.id}, npc=#${npc.id}');
        
        // Demonstrate math prelude
        var pos = vec3(10, 20, 30);
        var velocity = vec3(1, 2, 3);
        trace('Initial position: $pos');
        trace('Initial velocity: $velocity');
    }
    
    override function update(dt:Float) {
        super.update(dt);
        frameCount++;
        
        // Demonstrate vector operations
        var pos = vec3(frameCount, frameCount * 0.5, 0);
        var scaled = pos * 2.0;
        var added = pos + vec3(1, 1, 1);
        
        // Log every 60 frames
        if (frameCount % 60 == 0) {
            trace('Frame $frameCount: pos=$pos, scaled=$scaled, added=$added');
            trace('Delta time: ${dt}s');
        }
        
        // Demonstrate quaternion
        if (frameCount == 1) {
            var identity = quatIdentity();
            var rotation = quat(0, 0, 0, 1);
            trace('Identity quaternion: $identity');
            trace('Rotation quaternion: $rotation');
        }
    }
    
    override function render(dt:Float) {
        super.render(dt);
        // Rendering would happen here
        if (frameCount % 120 == 0) {
            trace("Rendering frame...");
        }
    }
    
    override function cleanup() {
        super.cleanup();
        trace('Cleanup: processed $frameCount frames');
    }
}
