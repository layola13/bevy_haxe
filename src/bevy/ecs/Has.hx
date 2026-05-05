package bevy.ecs;

class Has<T> {
    public var value(default, null):Bool;

    public function new(value:Bool) {
        this.value = value;
    }

    public function isPresent():Bool {
        return value;
    }

    public function toString():String {
        return value ? "Has(true)" : "Has(false)";
    }
}
