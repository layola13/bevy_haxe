package haxe.input;

/**
    Gamepad button types based on the Standard Gamepad Layout.
    https://w3c.github.io/gamepad/#dfn-standard-gamepad
*/
enum GamepadButton {
    /// The first button on the face (A on Xbox, X on PlayStation).
    South;
    /// The second button on the face (B on Xbox, O on PlayStation).
    East;
    /// The third button on the face (X on Xbox, Square on PlayStation).
    West;
    /// The fourth button on the face (Y on Xbox, Triangle on PlayStation).
    North;
    /// The first shoulder button (LB on Xbox, L1 on PlayStation).
    LeftTrigger;
    /// The second shoulder button (RB on Xbox, R1 on PlayStation).
    RightTrigger;
    /// The third shoulder button (LT on Xbox, L2 on PlayStation).
    LeftTrigger2;
    /// The fourth shoulder button (RT on Xbox, R2 on PlayStation).
    RightTrigger2;
    /// The select/back button (View on Xbox, Select on PlayStation).
    Select;
    /// The start/menu button (Menu on Xbox, Start on PlayStation).
    Start;
    /// The left stick button (L3 on both).
    LeftStick;
    /// The right stick button (R3 on both).
    RightStick;
    /// Up on the d-pad.
    DPadUp;
    /// Down on the d-pad.
    DPadDown;
    /// Left on the d-pad.
    DPadLeft;
    /// Right on the d-pad.
    DPadRight;
    /// The first button in the center row (PS button on PlayStation).
    Home;
    /// The touchpad button on PlayStation controllers.
    Touchpad;
}

/**
    Gamepad axis types based on the Standard Gamepad Layout.
*/
enum GamepadAxis {
    /// Left stick horizontal axis.
    LeftStickX;
    /// Left stick vertical axis.
    LeftStickY;
    /// Right stick horizontal axis.
    RightStickX;
    /// Right stick vertical axis.
    RightStickY;
}

/**
    Gamepad connection state.
*/
enum GamepadConnectionState {
    Connected;
    Disconnected;
}

/**
    Gamepad connection event.
*/
class GamepadConnectionEvent {
    public var gamepad:Gamepad;
    public var state:GamepadConnectionState;

    public function new(gamepad:Gamepad, state:GamepadConnectionState) {
        this.gamepad = gamepad;
        this.state = state;
    }
}

/**
    Gamepad button changed event.
*/
class GamepadButtonChangedEvent {
    public var gamepad:Gamepad;
    public var button:GamepadButton;
    public var state:ButtonState;
    public var value:Float;

    public function new(
        gamepad:Gamepad,
        button:GamepadButton,
        state:ButtonState,
        value:Float = 0
    ) {
        this.gamepad = gamepad;
        this.button = button;
        this.state = state;
        this.value = value;
    }
}

/**
    Gamepad axis changed event.
*/
class GamepadAxisChangedEvent {
    public var gamepad:Gamepad;
    public var axis:GamepadAxis;
    public var value:Float;

    public function new(gamepad:Gamepad, axis:GamepadAxis, value:Float) {
        this.gamepad = gamepad;
        this.axis = axis;
        this.value = value;
    }
}

/**
    A connected gamepad device.

    Represents the state of a single gamepad controller.
*/
class Gamepad {
    /**
        The unique identifier for this gamepad.
    */
    public var id:String;

    /**
        The index of this gamepad (0-3 typically).
    */
    public var index:Int;

    /**
        The human-readable name of the gamepad.
    */
    public var name:String;

    /**
        Whether the gamepad is currently connected.
    */
    public var connected:Bool;

    /**
        The mapping standard (usually "standard").
    */
    public var mapping:String;

    /**
        Button input state.
    */
    public var buttons:Input<GamepadButton>;

    /**
        Current axis values.
    */
    public var axes:Array<Float>;

    private var _buttonValues:Array<Float>;
    private var _axesCount:Int;
    private var _buttonsCount:Int;

    public function new(id:String, index:Int, name:String = "", mapping:String = "") {
        this.id = id;
        this.index = index;
        this.name = name;
        this.connected = true;
        this.mapping = mapping;

        buttons = new Input();
        _buttonValues = [];
        axes = [0, 0, 0, 0];
        _axesCount = 4;
        _buttonsCount = 17;

        // Initialize button values
        for (i in 0..._buttonsCount) {
            _buttonValues.push(0);
        }
    }

    /**
        Gets the axis value.
        @param axis The axis to query
        @return The axis value from -1.0 to 1.0 (or 0 to 1.0 for triggers)
    */
    public function getAxis(axis:GamepadAxis):Float {
        return switch (axis) {
            case LeftStickX: axes[0];
            case LeftStickY: axes[1];
            case RightStickX: axes[2];
            case RightStickY: axes[3];
        };
    }

    /**
        Sets the axis value directly.
        @param axis The axis to set
        @param value The value to set
    */
    public function setAxis(axis:GamepadAxis, value:Float):Void {
        switch (axis) {
            case LeftStickX: axes[0] = value;
            case LeftStickY: axes[1] = value;
            case RightStickX: axes[2] = value;
            case RightStickY: axes[3] = value;
        }
    }

    /**
        Gets the button value (0.0 to 1.0).
        @param button The button to query
        @return The button value
    */
    public function getButtonValue(button:GamepadButton):Float {
        return _buttonValues[buttonIndex(button)];
    }

    /**
        Sets the button value.
        @param button The button to set
        @param value The value to set (0.0 or 1.0 for digital, 0.0-1.0 for analog)
    */
    public function setButtonValue(button:GamepadButton, value:Float):Void {
        var idx = buttonIndex(button);
        if (idx >= 0 && idx < _buttonsCount) {
            _buttonValues[idx] = value;

            // Update Input state
            if (value > 0.5) {
                buttons.press(button, value);
            } else {
                buttons.release(button);
            }
        }
    }

    /**
        Checks if a button is pressed.
        @param button The button to check
        @return True if pressed
    */
    public inline function buttonPressed(button:GamepadButton):Bool {
        return buttons.pressed(button);
    }

    /**
        Checks if a button was just pressed this frame.
        @param button The button to check
        @return True if just pressed
    */
    public inline function buttonJustPressed(button:GamepadButton):Bool {
        return buttons.justPressed(button);
    }

    /**
        Checks if a button was just released this frame.
        @param button The button to check
        @return True if just released
    */
    public inline function buttonJustReleased(button:GamepadButton):Bool {
        return buttons.justReleased(button);
    }

    /**
        Gets the left stick as a normalized vector.
        @return Object with x and y from -1.0 to 1.0
    */
    public function getLeftStick():{x:Float, y:Float} {
        return {x: axes[0], y: axes[1]};
    }

    /**
        Gets the right stick as a normalized vector.
        @return Object with x and y from -1.0 to 1.0
    */
    public function getRightStick():{x:Float, y:Float} {
        return {x: axes[2], y: axes[3]};
    }

    /**
        Applies deadzone to an axis value.
        @param value The raw axis value
        @param deadzone The deadzone threshold (0.0 to 1.0)
        @return The value with deadzone applied
    */
    public static function applyDeadzone(value:Float, deadzone:Float = 0.1):Float {
        if (Math.abs(value) < deadzone) {
            return 0;
        }
        var sign = value > 0 ? 1.0 : -1.0;
        return sign * ((Math.abs(value) - deadzone) / (1.0 - deadzone));
    }

    /**
        Updates the gamepad state from browser Gamepad API.
        @param browserGamepad The browser's Gamepad object
    */
    public function updateFromBrowser(browserGamepad:js.html.Gamepad):Void {
        // Update axes
        for (i in 0...Math.min(browserGamepad.axes.length, 4)) {
            axes[i] = browserGamepad.axes[i];
        }

        // Update buttons
        for (i in 0...Math.min(browserGamepad.buttons.length, _buttonsCount)) {
            var button = browserGamepad.buttons[i];
            var value:Float = button.value;
            setButtonValue(cast i, value);
        }
    }

    private function buttonIndex(button:GamepadButton):Int {
        return switch (button) {
            case South: 0;
            case East: 1;
            case West: 2;
            case North: 3;
            case LeftTrigger: 4;
            case RightTrigger: 5;
            case LeftTrigger2: 6;
            case RightTrigger2: 7;
            case Select: 8;
            case Start: 9;
            case LeftStick: 10;
            case RightStick: 11;
            case DPadUp: 12;
            case DPadDown: 13;
            case DPadLeft: 14;
            case DPadRight: 15;
            case Home: 16;
            case Touchpad: 17;
        };
    }

    public function toString():String {
        return 'Gamepad($index: $name)';
    }
}

/**
    Gamepad settings for deadzones and sensitivity.
*/
class GamepadSettings {
    /**
        Default deadzone for analog sticks.
    */
    public var defaultLeftStickDeadzone:Float;
    public var defaultRightStickDeadzone:Float;

    /**
        Default deadzone for triggers.
    */
    public var defaultTriggerDeadzone:Float;

    public function new(
        leftStickDeadzone:Float = 0.1,
        rightStickDeadzone:Float = 0.1,
        triggerDeadzone:Float = 0.1
    ) {
        defaultLeftStickDeadzone = leftStickDeadzone;
        defaultRightStickDeadzone = rightStickDeadzone;
        defaultTriggerDeadzone = triggerDeadzone;
    }
}

/**
    Manages all connected gamepads.

    Provides access to gamepads and handles browser gamepad events.
*/
class GamepadManager {
    /**
        Map of gamepad index to Gamepad instance.
    */
    public var gamepads:Map<Int, Gamepad>;

    /**
        Gamepad settings.
    */
    public var settings:GamepadSettings;

    /**
        Events fired when gamepads connect/disconnect.
    */
    public var connectionEvents:Array<GamepadConnectionEvent>;

    /**
        Events fired when button state changes.
    */
    public var buttonEvents:Array<GamepadButtonChangedEvent>;

    /**
        Events fired when axis state changes.
    */
    public var axisEvents:Array<GamepadAxisChangedEvent>;

    /**
        Default deadzone applied to all axes.
    */
    public var defaultDeadzone:Float;

    public function new() {
        gamepads = new Map();
        settings = new GamepadSettings();
        connectionEvents = [];
        buttonEvents = [];
        axisEvents = [];
        defaultDeadzone = 0.15;
    }

    /**
        Gets a gamepad by index.
        @param index The gamepad index
        @return The gamepad or null if not connected
    */
    public inline function getGamepad(index:Int):Null<Gamepad> {
        return gamepads.get(index);
    }

    /**
        Checks if a gamepad is connected.
        @param index The gamepad index
        @return True if connected
    */
    public inline function isGamepadConnected(index:Int):Bool {
        return gamepads.exists(index);
    }

    /**
        Updates all gamepads from browser API.
        Should be called each frame.
    */
    public function update():Void {
        #if js
        var browserGamepads = js.html.GamepadManager.getGamepads();

        for (browserGamepad in browserGamepads) {
            if (browserGamepad != null) {
                var index = browserGamepad.index;
                var gamepad = gamepads.get(index);

                if (gamepad != null) {
                    // Update existing gamepad
                    gamepad.updateFromBrowser(browserGamepad);
                } else {
                    // New gamepad connected
                    addGamepad(browserGamepad);
                }
            }
        }

        // Check for disconnected gamepads
        checkDisconnections(browserGamepads);
        #end
    }

    #if js
    private function addGamepad(browserGamepad:js.html.Gamepad):Void {
        var gamepad = new Gamepad(
            browserGamepad.id,
            browserGamepad.index,
            browserGamepad.id,
            browserGamepad.mapping
        );

        gamepads.set(browserGamepad.index, gamepad);

        var event = new GamepadConnectionEvent(gamepad, GamepadConnectionState.Connected);
        connectionEvents.push(event);
    }

    private function removeGamepad(index:Int):Void {
        var gamepad = gamepads.get(index);
        if (gamepad != null) {
            gamepad.connected = false;
            var event = new GamepadConnectionEvent(gamepad, GamepadConnectionState.Disconnected);
            connectionEvents.push(event);
            gamepads.remove(index);
        }
    }

    private function checkDisconnections(browserGamepads:js.html.GamepadList):Void {
        for (index in gamepads.keys()) {
            var found = false;
            for (browserGamepad in browserGamepads) {
                if (browserGamepad != null && browserGamepad.index == index) {
                    found = true;
                    break;
                }
            }

            if (!found) {
                removeGamepad(index);
            }
        }
    }
    #end

    /**
        Gets an axis value with deadzone applied.
        @param gamepadIndex The gamepad index
        @param axis The axis to query
        @return The axis value with deadzone applied
    */
    public function getAxis(gamepadIndex:Int, axis:GamepadAxis):Float {
        var gamepad = getGamepad(gamepadIndex);
        if (gamepad == null) return 0;
        return applyDeadzone(gamepad.getAxis(axis));
    }

    /**
        Gets the left stick with deadzone applied.
        @param gamepadIndex The gamepad index
        @return The stick vector with deadzone applied
    */
    public function getLeftStick(gamepadIndex:Int):{x:Float, y:Float} {
        var gamepad = getGamepad(gamepadIndex);
        if (gamepad == null) return {x: 0, y: 0};

        return {
            x: applyDeadzone(gamepad.getAxis(LeftStickX)),
            y: applyDeadzone(gamepad.getAxis(LeftStickY))
        };
    }

    /**
        Gets the right stick with deadzone applied.
        @param gamepadIndex The gamepad index
        @return The stick vector with deadzone applied
    */
    public function getRightStick(gamepadIndex:Int):{x:Float, y:Float} {
        var gamepad = getGamepad(gamepadIndex);
        if (gamepad == null) return {x: 0, y: 0};

        return {
            x: applyDeadzone(gamepad.getAxis(RightStickX)),
            y: applyDeadzone(gamepad.getAxis(RightStickY))
        };
    }

    /**
        Checks if a button is pressed.
        @param gamepadIndex The gamepad index
        @param button The button to check
        @return True if pressed
    */
    public function buttonPressed(gamepadIndex:Int, button:GamepadButton):Bool {
        var gamepad = getGamepad(gamepadIndex);
        return gamepad != null && gamepad.buttonPressed(button);
    }

    /**
        Checks if a button was just pressed.
        @param gamepadIndex The gamepad index
        @param button The button to check
        @return True if just pressed
    */
    public function buttonJustPressed(gamepadIndex:Int, button:GamepadButton):Bool {
        var gamepad = getGamepad(gamepadIndex);
        return gamepad != null && gamepad.buttonJustPressed(button);
    }

    /**
        Clears just pressed/released states for all gamepads.
    */
    public function clear():Void {
        for (gamepad in gamepads) {
            gamepad.buttons.clear();
        }
        connectionEvents = [];
        buttonEvents = [];
        axisEvents = [];
    }

    private inline function applyDeadzone(value:Float):Float {
        return Gamepad.applyDeadzone(value, defaultDeadzone);
    }
}
