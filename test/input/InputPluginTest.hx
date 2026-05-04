package input;

import bevy.app.App;
import bevy.input.InputPlugin;
import bevy.input.Keyboard;
import bevy.input.Keyboard.KeyboardInput;
import bevy.input.Mouse;
import bevy.input.Mouse.MouseButtonInput;
import bevy.input.Mouse.MouseMotion;

class InputPluginTest {
    static function main():Void {
        var app = new App();
        var plugin = new InputPlugin();
        #if js
        var keyboard = new Keyboard();
        var mouse = new Mouse();
        app.world.insertResource(keyboard);
        app.world.insertResource(mouse);
        app.world.initEvents(KeyboardInput);
        app.world.initEvents(MouseButtonInput);
        app.world.initEvents(MouseMotion);
        #else
        plugin.build(app);
        var keyboard = app.world.getResource(Keyboard);
        var mouse = app.world.getResource(Mouse);
        #end

        var keyReader = app.world.getEvents(KeyboardInput).reader();
        var buttonReader = app.world.getEvents(MouseButtonInput).reader();
        var motionReader = app.world.getEvents(MouseMotion).reader();

        plugin.handleKey(app, keyboard, "KeyA", true);
        plugin.handleMouseButton(app, mouse, 0, true);
        plugin.handleMouseMove(app, mouse, 12, 34);

        assert(keyboard.isPressed("KeyA"), "keyboard state should update");
        assert(mouse.isPressed(0), "mouse button state should update");
        assertEq(12.0, mouse.x, "mouse x");
        assertEq(34.0, mouse.y, "mouse y");

        assertEq(1, keyReader.read().length, "keyboard event");
        assertEq(1, buttonReader.read().length, "mouse button event");
        assertEq(1, motionReader.read().length, "mouse motion event");
        trace("InputPluginTest ok");
    }

    static function assertEq<T>(expected:T, actual:T, label:String):Void {
        if (expected != actual) {
            throw '$label expected $expected, got $actual';
        }
    }

    static function assert(value:Bool, label:String):Void {
        if (!value) {
            throw label;
        }
    }
}
