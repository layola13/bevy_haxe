package haxe.input;

import haxe.ds.Map;

/**
    A "press-able" input of type T.

    This type is used as a resource to keep the current state of an input,
    by reacting to events from the input. For a given input value:

    - `pressed()` returns true between a press and a release event.
    - `justPressed()` returns true for one frame after a press event.
    - `justReleased()` returns true for one frame after a release event.

    ## Usage

    ```haxe
    var input = new Input<KeyCode>();
    input.press(KeyCode.Space);
    if (input.pressed(KeyCode.Space)) {
        trace("Space is held!");
    }
    if (input.justPressed(KeyCode.Space)) {
        trace("Space was just pressed!");
    }
    ```
*/
class Input<T> {
    /**
        Map of button state to pressed buttons.
        Maps Pressed -> Set of currently pressed inputs
        Maps Released -> Set of just released inputs
    */
    private var _state:Map<ButtonState, Map<T, Float>>;

    /**
        Set of buttons that were just pressed this frame.
    */
    private var _justPressed:Map<T, Float>;

    /**
        Set of buttons that were just released this frame.
    */
    private var _justReleased:Map<T, Float>;

    public function new() {
        _state = new Map();
        _state.set(ButtonState.Pressed, new Map());
        _state.set(ButtonState.Released, new Map());
        _justPressed = new Map();
        _justReleased = new Map();
    }

    /**
        Registers a press for the given input.
        @param input The input that was pressed
        @param strength The strength of the press (0.0 to 1.0), defaults to 1.0
    */
    public function press(input:T, strength:Float = 1.0):Void {
        var pressed = _state.get(ButtonState.Pressed);
        if (pressed != null && !pressed.exists(input)) {
            pressed.set(input, strength);
            _justPressed.set(input, strength);
        }
    }

    /**
        Releases the given input.
        @param input The input that was released
    */
    public function release(input:T):Void {
        var pressed = _state.get(ButtonState.Pressed);
        if (pressed != null) {
            pressed.remove(input);
        }

        var released = _state.get(ButtonState.Released);
        if (released != null) {
            released.set(input, 0.0);
            _justReleased.set(input, 0.0);
        }
    }

    /**
        Returns true if the input is currently pressed.
        @param input The input to check
    */
    public inline function pressed(input:T):Bool {
        var pressed = _state.get(ButtonState.Pressed);
        return pressed != null && pressed.exists(input);
    }

    /**
        Returns true if the input was just pressed this frame.
        @param input The input to check
    */
    public inline function justPressed(input:T):Bool {
        return _justPressed.exists(input);
    }

    /**
        Returns true if the input was just released this frame.
        @param input The input to check
    */
    public inline function justReleased(input:T):Bool {
        return _justReleased.exists(input);
    }

    /**
        Returns the strength of the input (for analog inputs).
        @param input The input to check
    */
    public function getStrength(input:T):Float {
        var pressed = _state.get(ButtonState.Pressed);
        if (pressed != null) {
            return pressed.get(input);
        }
        return 0.0;
    }

    /**
        Returns all currently pressed inputs.
    */
    public function getPressed():Array<T> {
        var result:Array<T> = [];
        var pressed = _state.get(ButtonState.Pressed);
        if (pressed != null) {
            for (key in pressed.keys()) {
                result.push(key);
            }
        }
        return result;
    }

    /**
        Returns the number of currently pressed inputs.
    */
    public function pressedAmount():Int {
        var pressed = _state.get(ButtonState.Pressed);
        return pressed != null ? pressed.size() : 0;
    }

    /**
        Returns true if any input is currently pressed.
    */
    public function anyPressed():Bool {
        var pressed = _state.get(ButtonState.Pressed);
        return pressed != null && pressed.size() > 0;
    }

    /**
        Returns true if any input was just pressed this frame.
    */
    public function anyJustPressed():Bool {
        return _justPressed.size() > 0;
    }

    /**
        Returns true if any input was just released this frame.
    */
    public function anyJustReleased():Bool {
        return _justReleased.size() > 0;
    }

    /**
        Returns true if the given inputs are all pressed.
        @param inputs Array of inputs to check
    */
    public function allPressed(inputs:Array<T>):Bool {
        for (input in inputs) {
            if (!pressed(input)) return false;
        }
        return true;
    }

    /**
        Returns true if any of the given inputs are pressed.
        @param inputs Array of inputs to check
    */
    public function anyOfPressed(inputs:Array<T>):Bool {
        for (input in inputs) {
            if (pressed(input)) return true;
        }
        return false;
    }

    /**
        Clears the just pressed and just released states.
        Call this at the end of each frame after processing input events.
    */
    public function clear():Void {
        _justPressed = new Map();
        _justReleased = new Map();
        _state.set(ButtonState.Released, new Map());
    }

    /**
        Resets the input state completely.
    */
    public function reset():Void {
        _state.set(ButtonState.Pressed, new Map());
        _state.set(ButtonState.Released, new Map());
        _justPressed = new Map();
        _justReleased = new Map();
    }

    /**
        Resets a specific input.
        @param input The input to reset
    */
    public function resetInput(input:T):Void {
        var pressed = _state.get(ButtonState.Pressed);
        if (pressed != null) {
            pressed.remove(input);
        }
        _justPressed.remove(input);
        _justReleased.remove(input);
    }

    /**
        Clears just pressed state for a specific input.
        @param input The input to clear
    */
    public function clearJustPressed(input:T):Void {
        _justPressed.remove(input);
    }

    /**
        Clears just released state for a specific input.
        @param input The input to clear
    */
    public function clearJustReleased(input:T):Void {
        _justReleased.remove(input);
    }
}

/**
    The current "press" state of an element.
*/
enum ButtonState {
    /**
        The button is pressed.
    */
    Pressed;

    /**
        The button is not pressed.
    */
    Released;
}
