package render;

import bevy.app.App;
import bevy.render.RenderContext;
import bevy.render.RenderPlugin;
import bevy.render.ShaderSource;
import bevy.render.TriangleMesh;
import bevy.window.Window;
import bevy.window.WindowPlugin;

class RenderContextTest {
    static function main():Void {
        var app = new App();
        new WindowPlugin(new Window("Render Test", 128, 64)).build(app);
        var context = new RenderContext();
        context.setClearColor(0.1, 0.2, 0.3, 1.0);
        new RenderPlugin(context).build(app);

        var stored = app.world.getResource(RenderContext);
        assert(stored != null, "render context resource should be inserted");
        assert(stored.initialized, "interp render context should initialize");
        assertEq(0.1, stored.clearR, "clear r");
        assertEq(0.2, stored.clearG, "clear g");
        assertEq(0.3, stored.clearB, "clear b");
        assert(stored.createProgram(ShaderSource.basicColor()), "shader program API should succeed");
        var triangle = TriangleMesh.triangle();
        assertEq(9, triangle.positions.length, "triangle positions");
        assert(stored.uploadTriangle(triangle), "triangle upload");
        assert(stored.drawTriangle(), "triangle draw");
        trace("RenderContextTest ok");
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
