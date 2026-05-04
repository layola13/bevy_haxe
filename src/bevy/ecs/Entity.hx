package bevy.ecs;

class Entity {
    public var index(default, null):Int;
    public var generation(default, null):Int;

    public inline function new(index:Int, generation:Int) {
        this.index = index;
        this.generation = generation;
    }

    public inline function equals(other:Entity):Bool {
        return other != null && index == other.index && generation == other.generation;
    }

    public inline function key():String {
        return index + ":" + generation;
    }

    public function toString():String {
        return 'Entity($index:$generation)';
    }
}

class EntityLocation {
    public var generation:Int;
    public var alive:Bool;

    public function new(generation:Int, alive:Bool) {
        this.generation = generation;
        this.alive = alive;
    }
}
