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
    public var lastProgram(default, null):Null<js.html.webgl.Program>;
    public var lastBuffer(default, null):Null<js.html.webgl.Buffer>;
    #else
    public var gl(default, null):Dynamic;
    public var lastProgram(default, null):Dynamic;
    public var lastBuffer(default, null):Dynamic;
    #end
    public var lastVertexCount(default, null):Int;

    public function new(?backend:String) {
        this.backend = backend != null ? backend : "WebGL2";
        clearR = 0;
        clearG = 0;
        clearB = 0;
        clearA = 1;
        initialized = false;
        gl = null;
        lastProgram = null;
        lastBuffer = null;
        lastVertexCount = 0;
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

    public function createProgram(source:ShaderSource):Bool {
        #if js
        if (gl == null) {
            return false;
        }
        var vertex = gl.createShader(js.html.webgl.RenderingContext.VERTEX_SHADER);
        var fragment = gl.createShader(js.html.webgl.RenderingContext.FRAGMENT_SHADER);
        if (vertex == null || fragment == null) {
            return false;
        }
        gl.shaderSource(vertex, source.vertex);
        gl.compileShader(vertex);
        gl.shaderSource(fragment, source.fragment);
        gl.compileShader(fragment);
        var program = gl.createProgram();
        if (program == null) {
            return false;
        }
        gl.attachShader(program, vertex);
        gl.attachShader(program, fragment);
        gl.linkProgram(program);
        lastProgram = program;
        return true;
        #else
        lastProgram = {};
        return true;
        #end
    }

    public function uploadTriangle(mesh:TriangleMesh):Bool {
        lastVertexCount = Std.int(mesh.positions.length / 3);
        #if js
        if (gl == null) {
            return false;
        }
        var buffer = gl.createBuffer();
        if (buffer == null) {
            return false;
        }
        lastBuffer = buffer;
        gl.bindBuffer(js.html.webgl.RenderingContext.ARRAY_BUFFER, buffer);
        gl.bufferData(
            js.html.webgl.RenderingContext.ARRAY_BUFFER,
            new js.lib.Float32Array(mesh.positions),
            js.html.webgl.RenderingContext.STATIC_DRAW
        );
        return true;
        #else
        lastBuffer = {};
        return true;
        #end
    }

    public function drawTriangle():Bool {
        #if js
        if (gl == null || lastProgram == null || lastBuffer == null || lastVertexCount == 0) {
            return false;
        }
        gl.useProgram(lastProgram);
        gl.bindBuffer(js.html.webgl.RenderingContext.ARRAY_BUFFER, lastBuffer);
        gl.drawArrays(js.html.webgl.RenderingContext.TRIANGLES, 0, lastVertexCount);
        return true;
        #else
        return lastProgram != null && lastBuffer != null && lastVertexCount == 3;
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
