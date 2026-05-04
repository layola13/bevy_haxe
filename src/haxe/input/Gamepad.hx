package haxe.input;

import haxe.ds.StringMap;
import haxe.ds.Map;

/**
 * Gamepad button types.
 */
enum GamepadButton {
    Select;
    Start;
    Up;
    Down;
    Left;
    Right;
    L1;
    R1;
    L2;
    R2;
    L3;
    R3;
    A;
    B;
    X;
    Y;
}

/**
 * Gamepad axis types.
 */
enum GamepadAxis {
    LeftStickX;
    LeftStickY;
    RightStickX;
    RightStickY;
    L2Trigger;
    R2Trigger;
}

/**
 * Gamepad connection state.
 */
enum GamepadConnectionState {
    Connected;
    Disconnected;
}

/**
 * A gamepad device.
 */
class Gamepad {
    public var id:String;
    public var index:Int;
    public var name:String;
    public var connected:Bool;
    public var mapping:String;
    
    private var _axes:Array<Float>;
    private var _buttons:Array<Float>;
    
    public function new(id:String, index:Int, name:String = "", mapping:String = "") {
        this.id = id;
        this.index = index;
        this.name = name;
        this.connected = true;
        this.mapping = mapping;
        _axes = [0, 0, 0, 0, 0, 0];
        _buttons = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    }
    
    /**
     * Gets the axis value (-1 to 1 or 0 to 1 for triggers).
     */
    public function getAxis(axis:GamepadAxis):Float {
        return switch (axis) {
            case LeftStickX: _axes[0];
            case LeftStickY: _axes[1];
            case RightStickX: _axes[2];
            case RightStickY: _axes[3];
            case L2Trigger: _axes[4];
            case R2Trigger: _axes[5];
        };
    }
    
    /**
     * Sets the axis value.
     */
    public function setAxis(axis:GamepadAxis, value:Float):Void {
        switch (axis) {
            case LeftStickX: _axes[0] = value;
            case LeftStickY: _axes[1] = value;
            case RightStickX: _axes[2] = value;
            case RightStickY: _axes[3] = value;
            case L2Trigger: _axes[4] = value;
            case R2Trigger: _axes[5] = value;
        }
    }
    
    /**
     * Gets the button value (0 to 1).
     */
    public function getButtonValue(button:GamepadButton):Float {
        return switch (button) {
            case Select: _buttons[8];
            case Start: _buttons[9];
            case Up: _buttons[12];
            case Down: _buttons[13];
            case Left: _buttons[14];
            case Right: _buttons[15];
            case L1: _buttons[4];
            case R1: _buttons[5];
            case L2: _buttons[6];
            case R2: _buttons[7];
            case L3: _buttons[10];
            case R3: _buttons[11];
            case A: _buttons[0];
            case B: _buttons[1];
            case X: _buttons[2];
            case Y: _buttons[3];
        };
    }
    
    /**
     * Sets the button value.
     */
    public function setButtonValue(button:GamepadButton, value:Float):Void {
        switch (button) {
            case Select: _buttons[8] = value;
            case Start: _buttons[9] = value;
            case Up: _buttons[12] = value;
            case Down: _buttons[13] = value;
            case Left: _buttons[14] = value;
            case Right: _buttons[15] = value;
            case L1: _buttons[4] = value;
            case R1: _buttons[5] = value;
            case L2: _buttons[6] = value;
            case R2: _buttons[7] = value;
            case L3: _buttons[10] = value;
            case R3: _buttons[11] = value;
            case A: _buttons[0] = value;
            case B: _buttons[1] = value;
            case X: _buttons[2] = value;
            case Y: _buttons[3] = value;
        }
    }
    
    /**
     * Checks if button is pressed (value > 0.5).
     */
    public function buttonPressed(button:GamepadButton):Bool {
        return getButtonValue(button) > 0.5;
    }
    
    /**
     * Returns all axis values.
     */
    public function getAllAxes():Array<Float> {
        return _axes.copy();
    }
    
    /**
     * Returns all button values.
     */
    public function getAllButtons():Array<Float> {
        return _buttons.copy();
    }
    
    /**
     * Disconnects the gamepad.
     */
    public function disconnect():Void {
        connected = false;
    }
}

/**
 * Gamepad event types.
 */
enum GamepadEventType {
    Connection;
    ButtonChanged;
    AxisChanged;
}

/**
 * Gamepad event.
 */
class GamepadEvent {
    public var type:GamepadEventType;
    public var gamepadIndex:Int;
    
    public function new(type:GamepadEventType, gamepadIndex:Int) {
        this.type = type;
        this.gamepadIndex = gamepadIndex;
    }
}

class GamepadButtonChangedEvent extends GamepadEvent {
    public var button:GamepadButton;
    public var value:Float;
    
    public function new(gamepadIndex:Int, button:GamepadButton, value:Float) {
        super(ButtonChanged, gamepadIndex);
        this.button = button;
        this.value = value;
    }
}

class GamepadConnectionEvent extends GamepadEvent {
    public var connected:Bool;
    public var gamepadId:String;
    
    public function new(gamepadIndex:Int, connected:Bool, gamepadId:String) {
        super(Connection, gamepadIndex);
        this.connected = connected;
        this.gamepadId = gamepadId;
    }
}

/**
 * Gamepad input state manager.
 */
class GamepadInput extends Input<GamepadButton> {
    private var gamepads:StringMap<Gamepad>;
    private var events:Array<GamepadEvent>;
    private var deadzone:Float;
    
    public function new(deadzone:Float = 0.1) {
        super();
        this.deadzone = deadzone;
        gamepads = new StringMap<Gamepad>();
        events = [];
    }
    
    /**
     * Gets a gamepad by index.
     */
    public function getGamepad(index:Int):Gamepad {
        return gamepads.get(Std.string(index));
    }
    
    /**
     * Gets all connected gamepads.
     */
    public function getGamepads():Array<Gamepad> {
        var result:Array<Gamepad> = [];
        for (gamepad in gamepads.iterator()) {
            if (gamepad.connected) {
                result.push(gamepad);
            }
        }
        return result;
    }
    
    /**
     * Adds a gamepad.
     */
    public function addGamepad(gamepad:Gamepad):Void {
        gamepads.set(Std.string(gamepad.index), gamepad);
        events.push(new GamepadConnectionEvent(gamepad.index, true, gamepad.id));
    }
    
    /**
     * Removes a gamepad.
     */
    public function removeGamepad(index:Int):Void {
        var key = Std.string(index);
        var gamepad = gamepads.get(key);
        if (gamepad != null) {
            gamepad.disconnect();
            events.push(new GamepadConnectionEvent(index, false, gamepad.id));
            gamepads.remove(key);
        }
    }
    
    /**
     * Gets pending events.
     */
    public function getEvents():Array<GamepadEvent> {
        var result = events.copy();
        events = [];
        return result;
    }
    
    /**
     * Sets deadzone threshold.
     */
    public function setDeadzone(value:Float):Void {
        deadzone = value;
    }
    
    /**
     * Gets deadzone threshold.
     */
    public function getDeadzone():Float {
        return deadzone;
    }
    
    /**
     * Applies deadzone to a value.
     */
    public function applyDeadzone(value:Float):Float {
        if (value > deadzone || value < -deadzone) {
            if (value > 0) {
                return (value - deadzone) / (1 - deadzone);
            } else {
                return (value + deadzone) / (1 - deadzone);
            }
        }
        return 0;
    }
    
    /**
     * Clears all gamepads and events.
     */
    public function clear():Void {
        super.clear();
        gamepads.clear();
        events = [];
    }
    
    /**
     * Updates gamepads from browser Gamepad API.
     */
    #if js
    public function updateFromBrowser():Void {
        var gamepadsList = js.html.GamepadManager.getGamepads();
        for (i in 0...gamepadsList.length) {
            var browserGamepad = gamepadsList[i];
            if (browserGamepad != null) {
                var key = Std.string(browserGamepad.index);
                var gamepad = gamepads.get(key);
                
                if (gamepad == null) {
                    gamepad = new Gamepad(browserGamepad.id, browserGamepad.index);
                    gamepad.name = browserGamepad.id;
                    gamepad.mapping = browserGamepad.mapping;
                    addGamepad(gamepad);
                }
                
                // Update buttons
                var browserButtons = browserGamepad.buttons;
                for (j in 0...browserButtons.length) {
                    var buttonValue = browserButtons[j].value;
                    
                    // Map button index to GamepadButton enum
                    var button:GamepadButton = switch (j) {
                        case 0: A;
                        case 1: B;
                        case 2: X;
                        case 3: Y;
                        case 4: L1;
                        case 5: R1;
                        case 6: L2;
                        case 7: R2;
                        case 8: Select;
                        case 9: Start;
                        case 10: L3;
                        case 11: R3;
                        case 12: Up;
                        case 13: Down;
                        case 14: Left;
                        case 15: Right;
                        default: A;
                    };
                    
                    gamepad.setButtonValue(button, buttonValue);
                    
                    // Update input state for buttons 0-15
                    if (j < 16) {
                        if (buttonValue > 0.5 && !pressed(button)) {
                            press(button);
                        } else if (buttonValue <= 0.5 && pressed(button)) {
                            release(button);
                        }
                    }
                }
                
                // Update axes
                var browserAxes = browserGamepad.axes;
                if (browserAxes.length >= 4) {
                    gamepad.setAxis(LeftStickX, applyDeadzone(browserAxes[0]));
                    gamepad.setAxis(LeftStickY, applyDeadzone(browserAxes[1]));
                    gamepad.setAxis(RightStickX, applyDeadzone(browserAxes[2]));
                    gamepad.setAxis(RightStickY, applyDeadzone(browserAxes[3]));
                }
                if (browserAxes.length >= 6) {
                    gamepad.setAxis(L2Trigger, browserAxes[4]);
                    gamepad.setAxis(R2Trigger, browserAxes[5]);
                }
            } else {
                // Gamepad disconnected
                var key = Std.string(i);
                if (gamepads.exists(key)) {
                    removeGamepad(i);
                }
            }
        }
    }
    #end
    
    /**
     * Gets the axis value with deadzone applied.
     */
    public function getAxis(gamepadIndex:Int, axis:GamepadAxis):Float {
        var gamepad = getGamepad(gamepadIndex);
        if (gamepad == null) return 0;
        return applyDeadzone(gamepad.getAxis(axis));
    }
    
    /**
     * Gets the left stick as a normalized vector.
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
     * Gets the right stick as a normalized vector.
     */
    public function getRightStick(gamepadIndex:Int):{x:Float, y:Float} {
        var gamepad = getGamepad(gamepadIndex);
        if (gamepad == null) return {x: 0, y: 0};
        return {
            x: applyDeadzone(gamepad.getAxis(RightStickX)),
            y: applyDeadzone(gamepad.getAxis(RightStickY))
        };
    }
}
