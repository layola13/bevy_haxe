package window;

import bevy.app.App;
import bevy.window.Window;
import bevy.window.WindowPlugin;

class WindowPluginTest {
    static function main():Void {
        var app = new App();
        new WindowPlugin(new Window("Test Window", 320, 240, "test-canvas")).build(app);
        var window = app.world.getResource(Window);
        assert(window != null, "window resource should be inserted");
        assertEq("Test Window", window.title, "title");
        assertEq(320, window.width, "width");
        assertEq(240, window.height, "height");
        trace("WindowPluginTest ok");
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
