package bevy.ecs;

class Res<T> {
    public var value(default, null):T;

    public function new(value:T) {
        if (value == null) {
            throw "Missing resource";
        }
        this.value = value;
    }
}
