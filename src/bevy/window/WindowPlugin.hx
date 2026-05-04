package bevy.window;

import bevy.app.App;

class WindowPlugin {
    public var config(default, null):Window;

    public function new(?config:Window) {
        this.config = config != null ? config : new Window();
    }

    public function build(app:App):Void {
        #if js
        bindCanvas(config);
        #end
        app.world.insertResource(config);
    }

    #if js
    public static function bindCanvas(window:Window):js.html.CanvasElement {
        var document = js.Browser.document;
        var existing = document.getElementById(window.canvasId);
        var canvas:js.html.CanvasElement;
        if (existing == null) {
            canvas = cast document.createCanvasElement();
            canvas.id = window.canvasId;
            document.body.appendChild(canvas);
        } else {
            canvas = cast existing;
        }
        window.canvas = canvas;
        var dpr = js.Browser.window.devicePixelRatio;
        window.resize(window.width, window.height, dpr > 0 ? dpr : 1.0);
        document.title = window.title;
        return canvas;
    }
    #end
}
