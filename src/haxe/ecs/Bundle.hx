package haxe.ecs;

/**
    Bundle interface for inserting/removing multiple components at once.

    A Bundle represents a static set of component types that can be
    spawned or inserted onto an entity together. This enables batch
    operations on groups of related components.

    Bundles are especially useful for:
    - Defining entity templates (e.g., "Player", "Enemy", "Projectile")
    - Spawning entities with multiple components in one call
    - Inserting/removing groups of related components

    ## Manual Implementation

    You can implement Bundle manually for any class:

    ```haxe
    class TransformBundle implements Bundle {
        public var position:Vec3;
        public var rotation:Quat;
        public var scale:Vec3;

        public function new() {
            position = Vec3.ZERO;
            rotation = Quat.IDENTITY;
            scale = new Vec3(1, 1, 1);
        }
    }
    ```

    ## Tuple Bundles

    Anonymous bundles can be created using Array<Dynamic> or special tuple types:

    ```haxe
    // Spawn with multiple components
    world.spawnBundle([
        new Position(0, 0, 0),
        new Velocity(1, 0, 0),
        new Renderable("player.png")
    ]);
    ```

    Note: In Haxe, tuples are typically implemented using Array<Dynamic> or
    custom Tuple1-Tuple16 types due to language limitations.
**/
interface Bundle {
    /**
        Returns an array of all component types in this bundle.
        Used by the ECS to determine which storages to access.
    **/
    function getComponentTypes():Array<ComponentId>;

    /**
        Returns the number of components in this bundle.
    **/
    function componentCount():Int;
}

/**
    A tuple-style bundle for exactly 1 component.
**/
class Bundle1<T:Component> implements Bundle {
    public var c1:T;

    public inline function new(c1:T) {
        this.c1 = c1;
    }

    public function getComponentTypes():Array<ComponentId> {
        return [ComponentId.forType(Type.getClass(c1))];
    }

    public function componentCount():Int return 1;
}

/**
    A tuple-style bundle for exactly 2 components.
**/
class Bundle2<T1:Component, T2:Component> implements Bundle {
    public var c1:T1;
    public var c2:T2;

    public inline function new(c1:T1, c2:T2) {
        this.c1 = c1;
        this.c2 = c2;
    }

    public function getComponentTypes():Array<ComponentId> {
        return [
            ComponentId.forType(Type.getClass(c1)),
            ComponentId.forType(Type.getClass(c2))
        ];
    }

    public function componentCount():Int return 2;
}

/**
    A tuple-style bundle for exactly 3 components.
**/
class Bundle3<T1:Component, T2:Component, T3:Component> implements Bundle {
    public var c1:T1;
    public var c2:T2;
    public var c3:T3;

    public inline function new(c1:T1, c2:T2, c3:T3) {
        this.c1 = c1;
        this.c2 = c2;
        this.c3 = c3;
    }

    public function getComponentTypes():Array<ComponentId> {
        return [
            ComponentId.forType(Type.getClass(c1)),
            ComponentId.forType(Type.getClass(c2)),
            ComponentId.forType(Type.getClass(c3))
        ];
    }

    public function componentCount():Int return 3;
}

/**
    Type-safe bundle creation helper.
    Provides a fluent API for building entity bundles.
**/
class BundleBuilder {
    private var components:Array<Component>;

    public inline function new() {
        components = [];
    }

    public inline function with<T:Component>(component:T):BundleBuilder {
        components.push(component);
        return this;
    }

    public inline function build():Dynamic {
        return components;
    }

    public inline function componentCount():Int {
        return components.length;
    }
}
