package bevy.input;

import bevy.ecs.Event;
import bevy.ecs.Resource;

class MouseButtonInput implements Event {
    public var button:Int;
    public var pressed:Bool;

    public function new(button:Int, pressed:Bool) {
        this.button = button;
        this.pressed = pressed;
    }
}

class MouseMotion implements Event {
    public var x:Float;
    public var y:Float;

    public function new(x:Float, y:Float) {
        this.x = x;
        this.y = y;
    }
}

class Mouse implements Resource {
    public var x(default, null):Float = 0;
    public var y(default, null):Float = 0;
    private var pressed:Map<Int, Bool>;

    public function new() {
        pressed = new Map();
    }

    public function move(x:Float, y:Float):Void {
        this.x = x;
        this.y = y;
    }

    public function press(button:Int):Void {
        pressed.set(button, true);
    }

    public function release(button:Int):Void {
        pressed.remove(button);
    }

    public function isPressed(button:Int):Bool {
        return pressed.exists(button);
    }
}
