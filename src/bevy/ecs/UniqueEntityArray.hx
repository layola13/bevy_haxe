package bevy.ecs;

import bevy.ecs.EcsError.DuplicateEntityError;

class UniqueEntityArray {
    private var entities:Array<Entity>;

    public function new(values:Array<Entity>) {
        entities = values != null ? values.copy() : [];
        validateUnique(entities);
    }

    public static function from(values:Array<Entity>):UniqueEntityArray {
        return new UniqueEntityArray(values);
    }

    public function toArray():Array<Entity> {
        return entities.copy();
    }

    public var length(get, never):Int;

    private function get_length():Int {
        return entities.length;
    }

    private static function validateUnique(values:Array<Entity>):Void {
        var seen:Map<String, Int> = new Map();
        for (i in 0...values.length) {
            var entity = values[i];
            var key = entity != null ? entity.key() : "null";
            var previous = seen.get(key);
            if (previous != null) {
                throw new DuplicateEntityError(entity, previous, i);
            }
            seen.set(key, i);
        }
    }
}
