package bevy.input;

import bevy.ecs.Event;
import bevy.ecs.Resource;

class KeyboardInput implements Event {
    public var code:String;
    public var pressed:Bool;

    public function new(code:String, pressed:Bool) {
        this.code = code;
        this.pressed = pressed;
    }
}

class Keyboard implements Resource {
    private var pressed:Map<String, Bool>;

    public function new() {
        pressed = new Map();
    }

    public function press(code:String):Void {
        pressed.set(code, true);
    }

    public function release(code:String):Void {
        pressed.remove(code);
    }

    public function isPressed(code:String):Bool {
        return pressed.exists(code);
    }
}
