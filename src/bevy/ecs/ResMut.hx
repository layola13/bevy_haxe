package bevy.ecs;

import bevy.ecs.EcsError.MissingResourceError;

class ResMut<T> {
    public var value(default, null):T;

    public function new(value:T) {
        if (value == null) {
            throw new MissingResourceError("unknown", "Missing mutable resource");
        }
        this.value = value;
    }
}
