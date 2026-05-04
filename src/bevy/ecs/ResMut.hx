package bevy.ecs;

class ResMut<T> {
    public var value(default, null):T;

    public function new(value:T) {
        if (value == null) {
            throw "Missing mutable resource";
        }
        this.value = value;
    }
}
