package haxe.input;

import haxe.ds.Map;

/**
    Physical key code based on W3C UI Events Code values.
    https://www.w3.org/TR/2017/CR-uievents-code-20170601/

    These codes represent the physical location of keys on the keyboard,
    regardless of the current keyboard layout or input language.
*/
enum KeyCode {
    // ===== 0x0X: Miscellaneous =====

    /// The backtick (`) key.
    Backquote;
    /// The backslash (\) key.
    Backslash;
    /// The backspace (←) key.
    Backspace;
    /// The bracket ([) key.
    BracketLeft;
    /// The bracket (]) key.
    BracketRight;
    /// The comma (,) key.
    Comma;
    /// The delete (Del) key.
    Delete;
    /// The end (End) key.
    End;
    /// The enter (↵) key.
    Enter;
    /// The equal (=) key.
    Equal;
    /// The escape (Esc) key.
    Escape;
    /// The home (Home) key.
    Home;
    /// The minus (-) key.
    Minus;

    // ===== 0x1X: Numbers =====

    /// The 0 key.
    Digit0;
    /// The 1 key.
    Digit1;
    /// The 2 key.
    Digit2;
    /// The 3 key.
    Digit3;
    /// The 4 key.
    Digit4;
    /// The 5 key.
    Digit5;
    /// The 6 key.
    Digit6;
    /// The 7 key.
    Digit7;
    /// The 8 key.
    Digit8;
    /// The 9 key.
    Digit9;

    // ===== 0x2X: Letters =====

    /// The A key.
    KeyA;
    /// The B key.
    KeyB;
    /// The C key.
    KeyC;
    /// The D key.
    KeyD;
    /// The E key.
    KeyE;
    /// The F key.
    KeyF;
    /// The G key.
    KeyG;
    /// The H key.
    KeyH;
    /// The I key.
    KeyI;
    /// The J key.
    KeyJ;
    /// The K key.
    KeyK;
    /// The L key.
    KeyL;
    /// The M key.
    KeyM;
    /// The N key.
    KeyN;
    /// The O key.
    KeyO;
    /// The P key.
    KeyP;
    /// The Q key.
    KeyQ;
    /// The R key.
    KeyR;
    /// The S key.
    KeyS;
    /// The T key.
    KeyT;
    /// The U key.
    KeyU;
    /// The V key.
    KeyV;
    /// The W key.
    KeyW;
    /// The X key.
    KeyX;
    /// The Y key.
    KeyY;
    /// The Z key.
    KeyZ;

    // ===== 0x3X =====

    /// The caps lock (Caps) key.
    CapsLock;

    // ===== 0x4X: Modifiers =====

    /// The alt (Alt) key on the left.
    AltLeft;
    /// The alt (Alt) key on the right.
    AltRight;
    /// The control (Ctrl) key on the left.
    ControlLeft;
    /// The control (Ctrl) key on the right.
    ControlRight;
    /// The shift (Shift) key on the left.
    ShiftLeft;
    /// The shift (Shift) key on the right.
    ShiftRight;
    /// The meta (Meta) key on the left (Command on Mac, Windows on PC).
    MetaLeft;
    /// The meta (Meta) key on the right.
    MetaRight;

    // ===== 0x5X: Misc. =====

    /// The insert (Ins) key.
    Insert;

    // ===== 0x6X =====

    /// The page down (PageDown) key.
    PageDown;
    /// The page up (PageUp) key.
    PageUp;
    /// The pause (Pause) key.
    Pause;
    /// The print screen (PrintScreen) key.
    PrintScreen;
    /// The scroll lock (ScrollLock) key.
    ScrollLock;
    /// The semicolon (;) key.
    Semicolon;
    /// The single quote/double quote (') key.
    Apostrophe;
    /// The slash (/) key.
    Slash;
    /// The tab (⇥) key.
    Tab;
    /// The grave accent (`) key.
    BackquoteAlt;

    // ===== 0x7X =====

    /// The left arrow (←) key.
    ArrowLeft;
    /// The right arrow (→) key.
    ArrowRight;
    /// The up arrow (↑) key.
    ArrowUp;
    /// The down arrow (↓) key.
    ArrowDown;

    // ===== 0x8X: Function =====

    /// The F1 key.
    F1;
    /// The F2 key.
    F2;
    /// The F3 key.
    F3;
    /// The F4 key.
    F4;
    /// The F5 key.
    F5;
    /// The F6 key.
    F6;
    /// The F7 key.
    F7;
    /// The F8 key.
    F8;
    /// The F9 key.
    F9;
    /// The F10 key.
    F10;
    /// The F11 key.
    F11;
    /// The F12 key.
    F12;
    /// The F13 key.
    F13;
    /// The F14 key.
    F14;
    /// The F15 key.
    F15;
    /// The F16 key.
    F16;
    /// The F17 key.
    F17;
    /// The F18 key.
    F18;
    /// The F19 key.
    F19;
    /// The F20 key.
    F20;

    // ===== 0x9X =====

    /// The num lock (NumLock) key.
    NumLock;

    // ===== 0xAX: Numpad =====

    /// The numpad 0 key.
    Numpad0;
    /// The numpad 1 key.
    Numpad1;
    /// The numpad 2 key.
    Numpad2;
    /// The numpad 3 key.
    Numpad3;
    /// The numpad 4 key.
    Numpad4;
    /// The numpad 5 key.
    Numpad5;
    /// The numpad 6 key.
    Numpad6;
    /// The numpad 7 key.
    Numpad7;
    /// The numpad 8 key.
    Numpad8;
    /// The numpad 9 key.
    Numpad9;
    /// The numpad add (+) key.
    NumpadAdd;
    /// The numpad decimal (.) key.
    NumpadDecimal;
    /// The numpad divide (/) key.
    NumpadDivide;
    /// The numpad enter (=) key.
    NumpadEnter;
    /// The numpad equal (=) key.
    NumpadEqual;
    /// The numpad multiply (*) key.
    NumpadMultiply;
    /// The numpad subtract (-) key.
    NumpadSubtract;

    // ===== Space =====

    /// The space (␣) key.
    Space;
}

/**
    Logical key representing the text that would be typed.

    Unlike KeyCode which represents the physical key location,
    Key represents the meaning/character that would be typed.
*/
enum Key {
    /// A character key.
    Character(char:String);
    /// The backspace key.
    Backspace;
    /// The enter/return key.
    Enter;
    /// The tab key.
    Tab;
    /// The escape key.
    Escape;
    /// An arrow key.
    Arrow(ArrowDirection);
    /// The shift modifier.
    Shift;
    /// The control modifier.
    Control;
    /// The alt modifier.
    Alt;
    /// The meta (Command/Windows) modifier.
    Meta;
    /// An unknown key.
    Unknown;
}

/**
    Arrow key directions.
*/
enum ArrowDirection {
    Left;
    Right;
    Up;
    Down;
}

/**
    Keyboard input state manager.

    Manages keyboard input state and handles browser keyboard events.
*/
class Keyboard extends Input<KeyCode> {
    /**
        Currently pressed keys.
    */
    public var pressedKeys(get, never):Array<KeyCode>;

    private var _textInput:String = "";

    public function new() {
        super();
    }

    private inline function get_pressedKeys():Array<KeyCode> {
        return getPressed();
    }

    /**
        Returns true if any key is currently pressed.
    */
    public inline function anyKey():Bool {
        return anyPressed();
    }

    /**
        Returns true if any key was just pressed this frame.
    */
    public inline function anyKeyJustPressed():Bool {
        return anyJustPressed();
    }

    /**
        Checks if the Shift key is pressed.
    */
    public inline function shiftPressed():Bool {
        return pressed(ShiftLeft) || pressed(ShiftRight);
    }

    /**
        Checks if the Control key is pressed.
    */
    public inline function ctrlPressed():Bool {
        return pressed(ControlLeft) || pressed(ControlRight);
    }

    /**
        Checks if the Alt key is pressed.
    */
    public inline function altPressed():Bool {
        return pressed(AltLeft) || pressed(AltRight);
    }

    /**
        Checks if the Meta (Command/Windows) key is pressed.
    */
    public inline function metaPressed():Bool {
        return pressed(MetaLeft) || pressed(MetaRight);
    }

    /**
        Gets text input since last call to clearTextInput.
    */
    public function getTextInput():String {
        var result = _textInput;
        _textInput = "";
        return result;
    }

    /**
        Clears accumulated text input.
    */
    public function clearTextInput():Void {
        _textInput = "";
    }

    #if js
    private function handleKeyDown(event:js.html.KeyboardEvent):Void {
        event.preventDefault();

        var keyCode = domToKeyCode(event.code);
        press(keyCode);

        // Handle text input for printable characters
        if (event.key.length == 1 && !event.ctrlKey && !event.metaKey) {
            _textInput += event.key;
        }
    }

    private function handleKeyUp(event:js.html.KeyboardEvent):Void {
        var keyCode = domToKeyCode(event.code);
        release(keyCode);
    }

    private function handleBlur(event:js.html.Event):Void {
        // Release all keys when focus is lost
        reset();
    }

    private function domToKeyCode(code:String):KeyCode {
        return switch (code) {
            case "Backquote": Backquote;
            case "Backslash": Backslash;
            case "Backspace": Backspace;
            case "BracketLeft": BracketLeft;
            case "BracketRight": BracketRight;
            case "Comma": Comma;
            case "Delete": Delete;
            case "End": End;
            case "Enter": Enter;
            case "Equal": Equal;
            case "Escape": Escape;
            case "Home": Home;
            case "Minus": Minus;
            case "Digit0": Digit0;
            case "Digit1": Digit1;
            case "Digit2": Digit2;
            case "Digit3": Digit3;
            case "Digit4": Digit4;
            case "Digit5": Digit5;
            case "Digit6": Digit6;
            case "Digit7": Digit7;
            case "Digit8": Digit8;
            case "Digit9": Digit9;
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
            case "CapsLock": CapsLock;
            case "AltLeft": AltLeft;
            case "AltRight": AltRight;
            case "ControlLeft": ControlLeft;
            case "ControlRight": ControlRight;
            case "ShiftLeft": ShiftLeft;
            case "ShiftRight": ShiftRight;
            case "MetaLeft": MetaLeft;
            case "MetaRight": MetaRight;
            case "Insert": Insert;
            case "PageDown": PageDown;
            case "PageUp": PageUp;
            case "Pause": Pause;
            case "PrintScreen": PrintScreen;
            case "ScrollLock": ScrollLock;
            case "Semicolon": Semicolon;
            case "Apostrophe": Apostrophe;
            case "Slash": Slash;
            case "Tab": Tab;
            case "ArrowLeft": ArrowLeft;
            case "ArrowRight": ArrowRight;
            case "ArrowUp": ArrowUp;
            case "ArrowDown": ArrowDown;
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
            case "F13": F13;
            case "F14": F14;
            case "F15": F15;
            case "F16": F16;
            case "F17": F17;
            case "F18": F18;
            case "F19": F19;
            case "F20": F20;
            case "NumLock": NumLock;
            case "Numpad0": Numpad0;
            case "Numpad1": Numpad1;
            case "Numpad2": Numpad2;
            case "Numpad3": Numpad3;
            case "Numpad4": Numpad4;
            case "Numpad5": Numpad5;
            case "Numpad6": Numpad6;
            case "Numpad7": Numpad7;
            case "Numpad8": Numpad8;
            case "Numpad9": Numpad9;
            case "NumpadAdd": NumpadAdd;
            case "NumpadDecimal": NumpadDecimal;
            case "NumpadDivide": NumpadDivide;
            case "NumpadEnter": NumpadEnter;
            case "NumpadEqual": NumpadEqual;
            case "NumpadMultiply": NumpadMultiply;
            case "NumpadSubtract": NumpadSubtract;
            case "Space": Space;
            default: Space;
        };
    }

    /**
        Register keyboard event listeners on an element.
    */
    public function registerListeners(element:js.html.Element):Void {
        element.addEventListener("keydown", handleKeyDown);
        element.addEventListener("keyup", handleKeyUp);
        element.addEventListener("blur", handleBlur);
    }

    /**
        Unregister keyboard event listeners.
    */
    public function unregisterListeners(element:js.html.Element):Void {
        element.removeEventListener("keydown", handleKeyDown);
        element.removeEventListener("keyup", handleKeyUp);
        element.removeEventListener("blur", handleBlur);
    }
    #end
}
