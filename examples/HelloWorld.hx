package;

import Main;

/**
 * HelloWorld example for Bevy Haxe.
 * 
 * Demonstrates:
 * - Basic prelude imports
 * - Vector and math operations
 * - Simple application setup
 * - Entity creation
 */
class HelloWorld extends App {
    private var entityCount:Int = 0;

    public function new() {
        super();
        title = "Hello World - Bevy Haxe";
        width = 800;
        height = 600;
    }

    override function setup() {
        super.setup();
        trace("=== Hello World Example ===");

        // Create some entities
        var player = entity(1);
        var enemy = entity(2);
        entityCount = 2;

        trace('Created entities: player=#${player.id}, enemy=#${enemy.id}');
    }

    override function update(dt:Float) {
        super.update(dt);

        // Demonstrate math prelude
        var pos:Vec3 = vec3(10, 20, 30);
        var velocity:Vec3 = vec3(1, 2, 3) * dt;

        pos = pos + velocity;

        if (entityCount % 60 == 0) {
            trace('Player position: $pos');
            trace('Delta time: ${dt}s');
        }
    }

    override function render(dt:Float) {
        super.render(dt);
        // Rendering logic would go here
    }
}

/**
 * Entry point.
 */
class Main {
    static function main() {
        trace("Starting Hello World example...");

        // Use quick start for simple demos
        Main.quickStart(
            () -> {
                trace("Setup complete!");
                var pos = vec3(0, 0, 0);
                var rot = quatIdentity();
                trace('Initial position: $pos');
                trace('Initial rotation: $rot');
            },
            (dt) -> {
                // Simple update loop
            }
        );

        // Or use the full App class
        new HelloWorld().run();

        trace("Example completed!");
    }

    /**
     * Helper function to demonstrate vector operations.
     */
    static function demonstrateVectors() {
        // Vec2 operations
        var v2a = vec2(1, 2);
        var v2b = vec2(3, 4);
        var v2sum = v2a + v2b;
        trace('Vec2 sum: $v2sum');

        // Vec3 operations
        var v3a = vec3(1, 2, 3);
        var v3b = vec3(4, 5, 6);
        var v3diff = v3a - v3b;
        var dot = v3a.dot(v3b);
        trace('Vec3 difference: $v3diff');
        trace('Vec3 dot product: $dot');

        // Vec4 operations
        var v4 = vec4(1, 2, 3, 4);
        var normalized = v4.normalize();
        trace('Vec4 normalized: $normalized');

        // Matrix operations
        var m = mat4();
        var trans = translation(10, 0, 0);
        trace('Translation matrix created');
    }

    /**
     * Helper function to demonstrate quaternion rotations.
     */
    static function demonstrateQuaternions() {
        var q1 = quat(0, 0, 0, 1);  // Identity
        var q2 = quatIdentity();

        var axis = vec3(0, 1, 0);
        var rotation = quat.fromAxisAngle(axis, Math.PI / 4);  // 45 degrees

        trace('Quaternion rotation: $rotation');

        // Combine rotations
        var combined = q1 * rotation;
        trace('Combined rotation: $combined');
    }
}
