package haxe.input;

/**
 * Physical key code based on W3C UI Events Code values.
 * https://www.w3.org/TR/2017/CR-uievents-code-20170601/
 */
enum KeyCode {
    // Miscellaneous
    Escape;
    Space;
    Apostrophe;
    Comma;
    Minus;
    Period;
    Slash;
    Backquote;
    BracketLeft;
    Backslash;
    BracketRight;
    Semicolon;
    Equal;
    Digit0;
    Digit1;
    Digit2;
    Digit3;
    Digit4;
    Digit5;
    Digit6;
    Digit7;
    Digit8;
    Digit9;
    CapsLock;
    
    // Letter keys
    KeyA;
    KeyB;
    KeyC;
    KeyD;
    KeyE;
    KeyF;
    KeyG;
    KeyH;
    KeyI;
    KeyJ;
    KeyK;
    KeyL;
    KeyM;
    KeyN;
    KeyO;
    KeyP;
    KeyQ;
    KeyR;
    KeyS;
    KeyT;
    KeyU;
    KeyV;
    KeyW;
    KeyX;
    KeyY;
    KeyZ;
    
    // Function keys
    Tab;
    Enter;
    ShiftLeft;
    ShiftRight;
    ControlLeft;
    ControlRight;
    AltLeft;
    AltRight;
    Backspace;
    Insert;
    Home;
    Delete;
    End;
    PageUp;
    PageDown;
    ArrowUp;
    ArrowDown;
    ArrowLeft;
    ArrowRight;
    
    // Function row
    F1;
    F2;
    F3;
    F4;
    F5;
    F6;
    F7;
    F8;
    F9;
    F10;
    F11;
    F12;
    F13;
    F14;
    F15;
    F16;
    F17;
    F18;
    F19;
    F20;
    PrintScreen;
    ScrollLock;
    Pause;
    
    // Numpad
    NumLock;
    Numpad0;
    Numpad1;
    Numpad2;
    Numpad3;
    Numpad4;
    Numpad5;
    Numpad6;
    Numpad7;
    Numpad8;
    Numpad9;
    NumpadDecimal;
    NumpadAdd;
    NumpadSubtract;
    NumpadMultiply;
    NumpadDivide;
    NumpadEnter;
    NumpadEqual;
    NumpadParenLeft;
    NumpadParenRight;
}

/**
 * Logical key representation.
 */
enum Key {
    // Control characters
    Backspace;
    Tab;
    Enter;
    Shift;
    Control;
    Alt;
    CapsLock;
    NumLock;
    ScrollLock;
    Escape;
    
    // Whitespace
    Space;
    
    // Navigation
    Insert;
    Delete;
    Home;
    End;
    PageUp;
    PageDown;
    Left;
    Up;
    Right;
    Down;
    
    // Function keys
    Fn;
    F1;
    F2;
    F3;
    F4;
    F5;
    F6;
    F7;
    F8;
    F9;
    F10;
    F11;
    F12;
    PrintScreen;
    Pause;
    
    // Other
    Unknown;
}

/**
 * Keyboard input event.
 */
class KeyboardInput {
    public var keyCode:KeyCode;
    public var key:Key;
    public var state:ButtonState;
    public var scanCode:Int;
    
    public function new(keyCode:KeyCode, key:Key, state:ButtonState, scanCode:Int = 0) {
        this.keyCode = keyCode;
        this.key = key;
        this.state = state;
        this.scanCode = scanCode;
    }
}

/**
 * Keyboard input state manager.
 */
class Keyboard extends Input<KeyCode> {
    public var focusLost:Bool;
    
    public function new() {
        super();
        focusLost = false;
    }
    
    /**
     * Mark keyboard focus as lost.
     */
    public function setFocusLost():Void {
        focusLost = true;
    }
    
    /**
     * Mark keyboard focus as gained.
     */
    public function setFocusGained():Void {
        focusLost = false;
    }
    
    /**
     * Release all keys (call when focus is lost).
     */
    public function releaseAll():Void {
        for (button in getPressed()) {
            release(button);
        }
        setFocusLost();
    }
    
    /**
     * Clear focus lost state (call when focus is gained).
     */
    public function clearFocusLost():Void {
        setFocusGained();
    }
    
    /**
     * Get the logical key from a key code.
     */
    public static function keyFromKeyCode(code:KeyCode):Key {
        return switch (code) {
            case Backspace: Backspace;
            case Tab: Tab;
            case Enter: Enter;
            case ShiftLeft, ShiftRight: Shift;
            case ControlLeft, ControlRight: Control;
            case AltLeft, AltRight: Alt;
            case CapsLock: CapsLock;
            case NumLock: NumLock;
            case ScrollLock: ScrollLock;
            case Escape: Escape;
            case Space: Space;
            case Insert: Insert;
            case Delete: Delete;
            case Home: Home;
            case End: End;
            case PageUp: PageUp;
            case PageDown: PageDown;
            case ArrowLeft: Left;
            case ArrowUp: Up;
            case ArrowRight: Right;
            case ArrowDown: Down;
            case F1: F1;
            case F2: F2;
            case F3: F3;
            case F4: F4;
            case F5: F5;
            case F6: F6;
            case F7: F7;
            case F8: F8;
            case F9: F9;
            case F10: F10;
            case F11: F11;
            case F12: F12;
            case PrintScreen: PrintScreen;
            case Pause: Pause;
            default: Unknown;
        };
    }
}

// Web platform keyboard event handling
#if js
class KeyboardInputHandler {
    private var keyboard:Keyboard;
    private var onKeyPress:KeyCode->Void;
    private var onKeyRelease:KeyCode->Void;
    
    public function new(keyboard:Keyboard,
                        onKeyPress:KeyCode->Void,
                        onKeyRelease:KeyCode->Void) {
        this.keyboard = keyboard;
        this.onKeyPress = onKeyPress;
        this.onKeyRelease = onKeyRelease;
    }
    
    public function handleKeyDown(event:js.html.KeyboardEvent):Void {
        event.preventDefault();
        var code = domToKeyCode(event.code);
        keyboard.press(code);
        if (onKeyPress != null) {
            onKeyPress(code);
        }
    }
    
    public function handleKeyUp(event:js.html.KeyboardEvent):Void {
        event.preventDefault();
        var code = domToKeyCode(event.code);
        keyboard.release(code);
        if (onKeyRelease != null) {
            onKeyRelease(code);
        }
    }
    
    public function handleBlur(event:js.html.Event):Void {
        keyboard.releaseAll();
    }
    
    public function handleFocus(event:js.html.FocusEvent):Void {
        keyboard.clearFocusLost();
    }
    
    private function domToKeyCode(code:String):KeyCode {
        return switch (code) {
            case "Space": Space;
            case "Escape": Escape;
            case "Digit0" | "Numpad0": Digit0;
            case "Digit1" | "Numpad1": Digit1;
            case "Digit2" | "Numpad2": Digit2;
            case "Digit3" | "Numpad3": Digit3;
            case "Digit4" | "Numpad4": Digit4;
            case "Digit5" | "Numpad5": Digit5;
            case "Digit6" | "Numpad6": Digit6;
            case "Digit7" | "Numpad7": Digit7;
            case "Digit8" | "Numpad8": Digit8;
            case "Digit9" | "Numpad9": Digit9;
            case "KeyA": KeyA;
            case "KeyB": KeyB;
            case "KeyC": KeyC;
            case "KeyD": KeyD;
            case "KeyE": KeyE;
            case "KeyF": KeyF;
            case "KeyG": KeyG;
            case "KeyH": KeyH;
            case "KeyI": KeyI;
            case "KeyJ": KeyJ;
            case "KeyK": KeyK;
            case "KeyL": KeyL;
            case "KeyM": KeyM;
            case "KeyN": KeyN;
            case "KeyO": KeyO;
            case "KeyP": KeyP;
            case "KeyQ": KeyQ;
            case "KeyR": KeyR;
            case "KeyS": KeyS;
            case "KeyT": KeyT;
            case "KeyU": KeyU;
            case "KeyV": KeyV;
            case "KeyW": KeyW;
            case "KeyX": KeyX;
            case "KeyY": KeyY;
            case "KeyZ": KeyZ;
            case "Enter": Enter;
            case "Tab": Tab;
            case "Backspace": Backspace;
            case "ShiftLeft" | "ShiftRight": ShiftLeft;
            case "ControlLeft" | "ControlRight": ControlLeft;
            case "AltLeft" | "AltRight": AltLeft;
            case "ArrowUp": ArrowUp;
            case "ArrowDown": ArrowDown;
            case "ArrowLeft": ArrowLeft;
            case "ArrowRight": ArrowRight;
            case "F1": F1;
            case "F2": F2;
            case "F3": F3;
            case "F4": F4;
            case "F5": F5;
            case "F6": F6;
            case "F7": F7;
            case "F8": F8;
            case "F9": F9;
            case "F10": F10;
            case "F11": F11;
            case "F12": F12;
            default: Space;
        };
    }
    
    public function registerListeners(element:js.html.Element):Void {
        element.addEventListener("keydown", handleKeyDown);
        element.addEventListener("keyup", handleKeyUp);
        element.addEventListener("blur", handleBlur);
    }
    
    public function unregisterListeners(element:js.html.Element):Void {
        element.removeEventListener("keydown", handleKeyDown);
        element.removeEventListener("keyup", handleKeyUp);
        element.removeEventListener("blur", handleBlur);
    }
}
#end
