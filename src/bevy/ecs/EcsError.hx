package bevy.ecs;

enum EntityNotSpawnedKind {
    Invalid(currentGeneration:Null<Int>);
    ValidButNotSpawned;
}

enum SpawnErrorKind {
    Invalid(currentGeneration:Null<Int>);
    AlreadySpawned;
}

enum QuerySingleKind {
    NoEntities;
    MultipleEntities;
}

enum TypeKeyErrorKind {
    AnonymousClass;
    ValueWithoutClass;
    EmptyName;
}

enum QueryFilterErrorKind {
    OrRequiresChildren;
}


class EcsError extends haxe.Exception {
    public function new(message:String, ?previous:haxe.Exception, ?native:Dynamic) {
        super(message, previous, native);
    }
}

class InvalidEntityError extends EcsError {
    public var entity(default, null):Entity;
    public var currentGeneration(default, null):Null<Int>;

    public function new(entity:Entity, currentGeneration:Null<Int>) {
        this.entity = entity;
        this.currentGeneration = currentGeneration;
        super(currentGeneration != null
            ? 'Invalid entity id: $entity (current generation: $currentGeneration)'
            : 'Invalid entity id: $entity');
    }
}

class EntityValidButNotSpawnedError extends EcsError {
    public var entity(default, null):Entity;

    public function new(entity:Entity) {
        this.entity = entity;
        super('Entity is valid but not spawned: $entity');
    }
}

class EntityNotSpawnedError extends EcsError {
    public var entity(default, null):Entity;
    public var kind(default, null):EntityNotSpawnedKind;

    public function new(entity:Entity, kind:EntityNotSpawnedKind) {
        this.entity = entity;
        this.kind = kind;
        super(switch kind {
            case Invalid(currentGeneration):
                currentGeneration != null
                    ? 'Entity despawned or invalid: $entity (current generation: $currentGeneration)'
                    : 'Entity despawned or invalid: $entity';
            case ValidButNotSpawned:
                'Entity not yet spawned: $entity';
        });
    }
}

class EntityDoesNotExistError extends EntityNotSpawnedError {
    public function new(entity:Entity, ?kind:EntityNotSpawnedKind) {
        super(entity, kind != null ? kind : ValidButNotSpawned);
    }
}

class EntityNotAliveError extends EntityNotSpawnedError {
    public function new(entity:Entity, ?kind:EntityNotSpawnedKind) {
        super(entity, kind != null ? kind : ValidButNotSpawned);
    }
}

class SpawnError extends EcsError {
    public var entity(default, null):Entity;
    public var kind(default, null):SpawnErrorKind;

    public function new(entity:Entity, kind:SpawnErrorKind) {
        this.entity = entity;
        this.kind = kind;
        super(switch kind {
            case Invalid(currentGeneration):
                currentGeneration != null
                    ? 'Cannot spawn at invalid entity id: $entity (current generation: $currentGeneration)'
                    : 'Cannot spawn at invalid entity id: $entity';
            case AlreadySpawned:
                'Cannot spawn at already spawned entity: $entity';
        });
    }
}

class EntityAlreadySpawnedError extends SpawnError {
    public function new(entity:Entity) {
        super(entity, AlreadySpawned);
    }
}

class MissingResourceError extends EcsError {
    public var resourceKey(default, null):String;

    public function new(resourceKey:String, ?context:String) {
        this.resourceKey = resourceKey;
        super(context != null ? '$context: $resourceKey' : 'Missing resource: $resourceKey');
    }
}

class ResourceInitError extends EcsError {
    public var resourceKey(default, null):String;

    public function new(resourceKey:String) {
        this.resourceKey = resourceKey;
        super('Resource cannot be initialized automatically: $resourceKey');
    }
}

class QueryEntityError extends EcsError {
    public var entity(default, null):Entity;

    public function new(entity:Entity, message:String) {
        this.entity = entity;
        super(message);
    }
}

class QueryEntityNotSpawnedError extends QueryEntityError {
    public var notSpawnedError(default, null):EntityNotSpawnedError;
    public var kind(get, never):EntityNotSpawnedKind;

    public function new(entity:Entity, label:String, notSpawnedError:EntityNotSpawnedError) {
        this.notSpawnedError = notSpawnedError;
        super(entity, '$label.getMany failed because entity is not spawned: $entity');
    }

    private function get_kind():EntityNotSpawnedKind {
        return notSpawnedError.kind;
    }
}

class QueryDoesNotMatchError extends QueryEntityError {
    public function new(entity:Entity, label:String) {
        super(entity, '$label.getMany failed for entity $entity');
    }
}

class DuplicateEntityError extends EcsError {
    public var entity(default, null):Entity;
    public var firstIndex(default, null):Int;
    public var duplicateIndex(default, null):Int;

    public function new(entity:Entity, firstIndex:Int, duplicateIndex:Int) {
        this.entity = entity;
        this.firstIndex = firstIndex;
        this.duplicateIndex = duplicateIndex;
        super('Duplicate entity $entity at indices $firstIndex and $duplicateIndex');
    }
}

class QuerySingleError extends EcsError {
    public var queryLabel(default, null):String;
    public var kind(default, null):QuerySingleKind;

    public function new(queryLabel:String, kind:QuerySingleKind, message:String) {
        this.queryLabel = queryLabel;
        this.kind = kind;
        super(message);
    }
}

class QuerySingleMissingError extends QuerySingleError {
    public function new(queryLabel:String, kind:QuerySingleKind) {
        super(queryLabel, kind, switch kind {
            case NoEntities:
                'No entities fit $queryLabel';
            case MultipleEntities:
                'Multiple entities fit $queryLabel';
        });
    }
}

class QuerySingleNoEntitiesError extends QuerySingleMissingError {
    public function new(queryLabel:String) {
        super(queryLabel, NoEntities);
    }
}

class QuerySingleMultipleEntitiesError extends QuerySingleMissingError {
    public function new(queryLabel:String) {
        super(queryLabel, MultipleEntities);
    }
}

class TypeKeyError extends EcsError {
    public var kind(default, null):TypeKeyErrorKind;

    public function new(kind:TypeKeyErrorKind, ?detail:String) {
        this.kind = kind;
        super(switch kind {
            case AnonymousClass:
                "Cannot derive a TypeKey for an anonymous class";
            case ValueWithoutClass:
                "Cannot derive a TypeKey for a value without a class";
            case EmptyName:
                detail != null ? detail : "TypeKey name must not be empty";
        });
    }
}

class QueryFilterError extends EcsError {
    public var kind(default, null):QueryFilterErrorKind;

    public function new(kind:QueryFilterErrorKind, ?detail:String) {
        this.kind = kind;
        super(switch kind {
            case OrRequiresChildren:
                detail != null ? detail : "Or filter requires at least one child filter";
        });
    }
}
