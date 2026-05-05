package bevy.ecs;

import bevy.ecs.EcsError.EntityDoesNotExistError;
import bevy.ecs.EcsError.EntityNotSpawnedError;
import bevy.ecs.EcsError.EntityNotSpawnedKind;
import bevy.ecs.EcsError.InvalidEntityError;

typedef CommandOp = World->Void;

class Commands {
    private var world:World;
    private var queue:Array<CommandOp>;

    public function new(world:World) {
        this.world = world;
        queue = [];
    }

    public function spawn(?bundle:Array<Dynamic>):Entity {
        var entity = world.reserveEntity();
        var deferredBundle = bundle != null ? bundle.copy() : null;
        queue.push(function(world) {
            world.spawnReserved(entity, deferredBundle);
        });
        return entity;
    }

    public function spawnBundle(bundle:Bundle):Entity {
        return spawn(bundle.toBundle());
    }

    public function spawnEmpty():EntityCommands {
        return new EntityCommands(this, spawn());
    }

    public function spawnBatch(bundles:Array<Bundle>):Array<Entity> {
        var result:Array<Entity> = [];
        if (bundles == null || bundles.length == 0) {
            return result;
        }
        var reserved = world.reserveEntities(bundles.length);
        for (i in 0...bundles.length) {
            var entity = reserved[i];
            var deferredBundle = bundles[i];
            result.push(entity);
            queue.push(function(world) {
                world.spawnReserved(entity, deferredBundle.toBundle());
            });
        }
        return result;
    }

    public function entity(entity:Entity):EntityCommands {
        return new EntityCommands(this, entity);
    }

    public function getEntity(entity:Entity):EntityCommands {
        if (!world.containsEntity(entity)) {
            throw new InvalidEntityError(entity, currentGenerationForInvalidEntity(entity));
        }
        return new EntityCommands(this, entity);
    }

    public function getSpawnedEntity(entity:Entity):EntityCommands {
        if (world.isAlive(entity)) {
            return new EntityCommands(this, entity);
        }

        var kind = entityNotSpawnedKind(entity);
        throw new EntityNotSpawnedError(entity, kind);
    }

    public function insert<T>(entity:Entity, component:T):Commands {
        queue.push(function(world) {
            world.insert(entity, component);
        });
        return this;
    }

    public function insertByKey<T>(entity:Entity, typeKey:String, component:T):Commands {
        queue.push(function(world) {
            world.insertByKey(entity, typeKey, component);
        });
        return this;
    }

    public function insertBundle(entity:Entity, bundle:Bundle):Commands {
        for (component in bundle.toBundle()) {
            insert(entity, component);
        }
        return this;
    }

    public function remove<T>(entity:Entity, cls:Class<T>, ?componentKey:String):Commands {
        queue.push(function(world) {
            world.remove(entity, cls, componentKey);
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

    public function removeResource<T>(cls:Class<T>):Commands {
        queue.push(function(world) {
            world.removeResource(cls);
        });
        return this;
    }

    public function removeResourceByKey(key:String):Commands {
        queue.push(function(world) {
            world.removeResourceByKey(key);
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

    private function entityNotSpawnedKind(entity:Entity):EntityNotSpawnedKind {
        try {
            world.entity(entity);
            return EntityNotSpawnedKind.ValidButNotSpawned;
        } catch (error:EntityDoesNotExistError) {
            return error.kind;
        }
    }

    private function currentGenerationForInvalidEntity(entity:Entity):Null<Int> {
        return switch entityNotSpawnedKind(entity) {
            case Invalid(currentGeneration):
                currentGeneration;
            case ValidButNotSpawned:
                null;
        };
    }
}

class EntityCommands {
    public var commands(default, null):Commands;
    public var entity(default, null):Entity;

    public function new(commands:Commands, entity:Entity) {
        this.commands = commands;
        this.entity = entity;
    }

    public inline function id():Entity {
        return entity;
    }

    public inline function insert<T>(component:T):EntityCommands {
        commands.insert(entity, component);
        return this;
    }

    public inline function insertByKey<T>(typeKey:String, component:T):EntityCommands {
        commands.insertByKey(entity, typeKey, component);
        return this;
    }

    public inline function insertBundle(bundle:Bundle):EntityCommands {
        commands.insertBundle(entity, bundle);
        return this;
    }

    public inline function remove<T>(cls:Class<T>, ?componentKey:String):EntityCommands {
        commands.remove(entity, cls, componentKey);
        return this;
    }

    public inline function despawn():Commands {
        return commands.despawn(entity);
    }
}
