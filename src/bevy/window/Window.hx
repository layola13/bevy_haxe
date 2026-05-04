package bevy.window;

import bevy.ecs.Resource;

class Window implements Resource {
    public var title:String;
    public var width:Int;
    public var height:Int;
    public var devicePixelRatio:Float;
    public var canvasId:String;
    #if js
    public var canvas:Null<js.html.CanvasElement>;
    #else
    public var canvas:Dynamic;
    #end

    public function new(title:String = "Bevy Haxe", width:Int = 800, height:Int = 600, canvasId:String = "bevy-canvas") {
        this.title = title;
        this.width = width;
        this.height = height;
        this.canvasId = canvasId;
        this.devicePixelRatio = 1.0;
        this.canvas = null;
    }

    public function resize(width:Int, height:Int, ?devicePixelRatio:Float):Void {
        this.width = width;
        this.height = height;
        if (devicePixelRatio != null) {
            this.devicePixelRatio = devicePixelRatio;
        }
        #if js
        if (canvas != null) {
            canvas.width = Std.int(width * this.devicePixelRatio);
            canvas.height = Std.int(height * this.devicePixelRatio);
            canvas.style.width = width + "px";
            canvas.style.height = height + "px";
        }
        #end
    }
}
