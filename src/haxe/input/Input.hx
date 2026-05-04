package haxe.input;

/**
 * The current "press" state of an element.
 */
enum ButtonState {
    Pressed;
    Released;
}

extension ButtonState {
    public inline function isPressed():Bool {
        return this == Pressed;
    }
}
