package bevy.ecs;

class Option<T> {
    public var value(default, null):Null<T>;

    public function new(value:Null<T>) {
        this.value = value;
    }

    public static function some<T>(value:T):Option<T> {
        return new Option<T>(value);
    }

    public static function none<T>():Option<T> {
        return new Option<T>(null);
    }

    public function isSome():Bool {
        return value != null;
    }

    public function isNone():Bool {
        return value == null;
    }

    public function unwrapOrNull():Null<T> {
        return value;
    }

    public function toString():String {
        return isSome() ? 'Option.Some($value)' : "Option.None";
    }
}
