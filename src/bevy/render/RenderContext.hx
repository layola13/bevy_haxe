package bevy.render;

import bevy.ecs.Resource;
import bevy.window.Window;

class RenderContext implements Resource {
    public var backend(default, null):String;
    public var clearR:Float;
    public var clearG:Float;
    public var clearB:Float;
    public var clearA:Float;
    public var initialized(default, null):Bool;
    #if js
    public var gl(default, null):Null<js.html.webgl.RenderingContext>;
    #else
    public var gl(default, null):Dynamic;
    #end

    public function new(?backend:String) {
        this.backend = backend != null ? backend : "WebGL2";
        clearR = 0;
        clearG = 0;
        clearB = 0;
        clearA = 1;
        initialized = false;
        gl = null;
    }

    public function initialize(window:Window):Bool {
        #if js
        if (window.canvas == null) {
            return false;
        }
        gl = cast window.canvas.getContext("webgl2");
        if (gl == null) {
            gl = cast window.canvas.getContext("webgl");
            backend = "WebGL";
        }
        initialized = gl != null;
        applyClearColor();
        return initialized;
        #else
        initialized = true;
        return true;
        #end
    }

    public function setClearColor(r:Float, g:Float, b:Float, a:Float):Void {
        clearR = r;
        clearG = g;
        clearB = b;
        clearA = a;
        applyClearColor();
    }

    public function clear():Void {
        #if js
        if (gl != null) {
            gl.clear(js.html.webgl.RenderingContext.COLOR_BUFFER_BIT | js.html.webgl.RenderingContext.DEPTH_BUFFER_BIT);
        }
        #end
    }

    private function applyClearColor():Void {
        #if js
        if (gl != null) {
            gl.clearColor(clearR, clearG, clearB, clearA);
        }
        #end
    }
}
