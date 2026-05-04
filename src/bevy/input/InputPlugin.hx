package bevy.input;

import bevy.app.App;
import bevy.input.Keyboard.KeyboardInput;
import bevy.input.Mouse.MouseButtonInput;
import bevy.input.Mouse.MouseMotion;
import bevy.window.Window;

class InputPlugin {
    public function new() {}

    public function build(app:App):Void {
        var keyboard = new Keyboard();
        var mouse = new Mouse();
        app.world.insertResource(keyboard);
        app.world.insertResource(mouse);
        app.world.initEvents(KeyboardInput);
        app.world.initEvents(MouseButtonInput);
        app.world.initEvents(MouseMotion);
        #if js
        bindDom(app, keyboard, mouse);
        #end
    }

    public function handleKey(app:App, keyboard:Keyboard, code:String, pressed:Bool):Void {
        if (pressed) {
            keyboard.press(code);
        } else {
            keyboard.release(code);
        }
        app.world.sendEvent(new KeyboardInput(code, pressed));
    }

    public function handleMouseButton(app:App, mouse:Mouse, button:Int, pressed:Bool):Void {
        if (pressed) {
            mouse.press(button);
        } else {
            mouse.release(button);
        }
        app.world.sendEvent(new MouseButtonInput(button, pressed));
    }

    public function handleMouseMove(app:App, mouse:Mouse, x:Float, y:Float):Void {
        mouse.move(x, y);
        app.world.sendEvent(new MouseMotion(x, y));
    }

    #if js
    private function bindDom(app:App, keyboard:Keyboard, mouse:Mouse):Void {
        var target:js.html.EventTarget = js.Browser.window;
        var window = app.world.getResource(Window);
        if (window != null && window.canvas != null) {
            target = window.canvas;
        }
        target.addEventListener("keydown", function(event:js.html.KeyboardEvent) {
            handleKey(app, keyboard, event.code, true);
        });
        target.addEventListener("keyup", function(event:js.html.KeyboardEvent) {
            handleKey(app, keyboard, event.code, false);
        });
        target.addEventListener("mousedown", function(event:js.html.MouseEvent) {
            handleMouseButton(app, mouse, event.button, true);
        });
        target.addEventListener("mouseup", function(event:js.html.MouseEvent) {
            handleMouseButton(app, mouse, event.button, false);
        });
        target.addEventListener("mousemove", function(event:js.html.MouseEvent) {
            handleMouseMove(app, mouse, event.clientX, event.clientY);
        });
    }
    #end
}
