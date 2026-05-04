package;

/**
 * Query Example for Bevy Haxe Engine.
 * 
 * This example demonstrates:
 * - ECS Query system
 * - Component creation and registration
 * - Entity spawning and management
 * - System scheduling
 * 
 * Based on Bevy's ECS (Entity Component System) pattern.
 */

import haxe.prelude.Prelude;
import haxe.app.App;
import haxe.ecs.World;
import haxe.ecs.QueryBuilder;

class Main {
    static function main() {
        trace("=== ECS Query Example ===");
        
        var app = new QueryExampleApp();
        app.run();
        
        trace("Query example completed.");
    }
}

// =============================================================================
// Component Definitions
// =============================================================================

/**
 * Position component - stores entity position in 3D space.
 */
class Transform {
    public var position:Vec3;
    public var rotation:Quat;
    public var scale:Vec3;
    
    public function new(?x:Float = 0, ?y:Float = 0, ?z:Float = 0) {
        position = vec3(x, y, z);
        rotation = quatIdentity();
        scale = vec3(1, 1, 1);
    }
    
    public function toString():String {
        return 'Transform { pos: $position, rot: $rotation, scale: $scale }';
    }
}

/**
 * Velocity component - stores movement direction and speed.
 */
class Velocity {
    public var linear:Vec3;
    public var angular:Vec3;
    
    public function new(?lx:Float = 0, ?ly:Float = 0, ?lz:Float = 0) {
        linear = vec3(lx, ly, lz);
        angular = vec3(0, 0, 0);
    }
    
    public function toString():String {
        return 'Velocity { linear: $linear }';
    }
}

/**
 * Tag component - marks an entity as a player.
 */
class Player {
    public var name:String;
    public var health:Float;
    
    public function new(name:String = "Player") {
        this.name = name;
        this.health = 100.0;
    }
}

/**
 * Tag component - marks an entity as enemy.
 */
class Enemy {
    public var damage:Float;
    
    public function new(damage:Float = 10.0) {
        this.damage = damage;
    }
}

// =============================================================================
// Query Example Application
// =============================================================================

/**
 * Application demonstrating ECS queries and systems.
 */
class QueryExampleApp extends App {
    private var world:World;
    private var frameCount:Int = 0;
    
    public function new() {
        super();
        title = "ECS Query Example - Bevy Haxe";
        width = 1024;
        height = 768;
        
        world = new World();
    }
    
    override function setup() {
        super.setup();
        trace("=== ECS Query System Demo ===");
        
        // Spawn test entities
        spawnPlayer();
        spawnEnemies();
        spawnStaticObjects();
        
        trace('Total entities spawned: ${world.entityCount()}');
    }
    
    /**
     * Spawn a player entity with Transform, Velocity, and Player components.
     */
    function spawnPlayer():Void {
        var entityId = world.spawn();
        
        world.addComponent(entityId, new Transform(0, 1, 0));
        world.addComponent(entityId, new Velocity(0, 0, 5));
        world.addComponent(entityId, new Player("Hero"));
        
        trace('Spawned player entity #$entityId');
    }
    
    /**
     * Spawn multiple enemy entities.
     */
    function spawnEnemies():Void {
        for (i in 0...3) {
            var entityId = world.spawn();
            
            world.addComponent(entityId, new Transform(10 + i * 2, 1, 10 + i * 3));
            world.addComponent(entityId, new Velocity(-1, 0, -2));
            world.addComponent(entityId, new Enemy(15.0 + i * 5));
            
            trace('Spawned enemy entity #$entityId');
        }
    }
    
    /**
     * Spawn static objects (Transform only, no Velocity).
     */
    function spawnStaticObjects():Void {
        for (i in 0...2) {
            var entityId = world.spawn();
            world.addComponent(entityId, new Transform(i * 5, 0, 0));
            trace('Spawned static object entity #$entityId');
        }
    }
    
    override function update(dt:Float) {
        super.update(dt);
        frameCount++;
        
        // Run systems
        moveEntities(dt);
        
        // Demonstrate queries
        if (frameCount % 30 == 0) {
            runQueries();
        }
    }
    
    /**
     * Movement system - moves entities with Transform and Velocity.
     */
    function moveEntities(dt:Float):Void {
        var query = new QueryBuilder(world)
            .with(Transform)
            .with(Velocity);
        
        var entities = query.ids();
        for (entityId in entities) {
            var transform:Transform = world.getComponent(entityId, Transform);
            var velocity:Velocity = world.getComponent(entityId, Velocity);
            
            // Update position based on velocity
            transform.position = transform.position + velocity.linear * dt;
        }
        
        if (frameCount % 60 == 0) {
            trace('Movement: updated ${entities.length} entities');
        }
    }
    
    /**
     * Run various queries to demonstrate the query system.
     */
    function runQueries():Void {
        trace("\n--- Query Results ---");
        
        // Query 1: All entities with Transform
        var allWithTransform = new QueryBuilder(world)
            .with(Transform)
            .ids();
        trace('Entities with Transform: ${allWithTransform.length}');
        
        // Query 2: All entities with Transform AND Velocity (moving entities)
        var movingEntities = new QueryBuilder(world)
            .with(Transform)
            .with(Velocity)
            .ids();
        trace('Moving entities (Transform + Velocity): ${movingEntities.length}');
        
        // Query 3: Players (Transform + Velocity + Player)
        var players = new QueryBuilder(world)
            .with(Transform)
            .with(Velocity)
            .with(Player)
            .ids();
        trace('Players: ${players.length}');
        
        // Query 4: Enemies
        var enemies = new QueryBuilder(world)
            .with(Transform)
            .with(Enemy)
            .ids();
        trace('Enemies: ${enemies.length}');
        
        // Query 5: Static objects (Transform WITHOUT Velocity)
        var staticObjects = new QueryBuilder(world)
            .with(Transform)
            .without(Velocity)
            .ids();
        trace('Static objects (Transform only): ${staticObjects.length}');
        
        // Display component details for players
        for (entityId in players) {
            var transform:Transform = world.getComponent(entityId, Transform);
            var player:Player = world.getComponent(entityId, Player);
            trace('  Player "${player.name}" at ${transform.position}, health: ${player.health}');
        }
        
        // Display enemy details
        for (entityId in enemies) {
            var transform:Transform = world.getComponent(entityId, Transform);
            var enemy:Enemy = world.getComponent(entityId, Enemy);
            trace('  Enemy at ${transform.position}, damage: ${enemy.damage}');
        }
        
        trace("--- End Query Results ---\n");
    }
    
    override function render(dt:Float) {
        super.render(dt);
        // Rendering logic would go here
    }
    
    override function cleanup() {
        super.cleanup();
        trace('Cleanup: processed $frameCount frames');
        trace('Final entity count: ${world.entityCount()}');
    }
}
