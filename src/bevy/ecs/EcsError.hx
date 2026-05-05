package bevy.ecs;

class EcsError extends haxe.Exception {
    public function new(message:String, ?previous:haxe.Exception, ?native:Dynamic) {
        super(message, previous, native);
    }
}

class EntityDoesNotExistError extends EcsError {
    public var entity(default, null):Entity;

    public function new(entity:Entity) {
        this.entity = entity;
        super('Entity does not exist: $entity');
    }
}

class EntityNotAliveError extends EcsError {
    public var entity(default, null):Entity;

    public function new(entity:Entity) {
        this.entity = entity;
        super('Entity is not alive: $entity');
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

class QueryDoesNotMatchError extends QueryEntityError {
    public function new(entity:Entity, label:String) {
        super(entity, '$label.getMany failed for entity $entity');
    }
}

class QuerySingleError extends EcsError {
    public var queryLabel(default, null):String;

    public function new(queryLabel:String, message:String) {
        this.queryLabel = queryLabel;
        super(message);
    }
}

class QuerySingleMissingError extends QuerySingleError {
    public function new(queryLabel:String) {
        super(queryLabel, '$queryLabel did not resolve to exactly one item');
    }
}
