package bevy.ecs;

import bevy.ecs.EcsError.MissingResourceError;

class Res<T> {
    public var value(default, null):T;

    public function new(value:T) {
        if (value == null) {
            throw new MissingResourceError("unknown", "Missing resource");
        }
        this.value = value;
    }
}
