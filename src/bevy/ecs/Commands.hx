package bevy.ecs;

typedef CommandOp = World->Void;

class Commands {
    private var world:World;
    private var queue:Array<CommandOp>;

    public function new(world:World) {
        this.world = world;
        queue = [];
    }

    public function spawn(?bundle:Array<Dynamic>):Entity {
        var entity = world.spawn();
        if (bundle != null) {
            for (component in bundle) {
                insert(entity, component);
            }
        }
        return entity;
    }

    public function spawnBundle(bundle:Bundle):Entity {
        return spawn(bundle.toBundle());
    }

    public function insert<T>(entity:Entity, component:T):Commands {
        queue.push(function(world) {
            world.insert(entity, component);
        });
        return this;
    }

    public function remove<T>(entity:Entity, cls:Class<T>):Commands {
        queue.push(function(world) {
            world.remove(entity, cls);
        });
        return this;
    }

    public function despawn(entity:Entity):Commands {
        queue.push(function(world) {
            world.despawn(entity);
        });
        return this;
    }

    public function insertResource<T>(resource:T):Commands {
        queue.push(function(world) {
            world.insertResource(resource);
        });
        return this;
    }

    public function sendEvent<T>(event:T):Commands {
        queue.push(function(world) {
            world.sendEvent(event);
        });
        return this;
    }

    public function apply():Void {
        var pending = queue;
        queue = [];
        for (op in pending) {
            op(world);
        }
        world.advanceTick();
    }

    public function len():Int {
        return queue.length;
    }
}
