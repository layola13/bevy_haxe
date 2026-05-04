package bevy.render;

import bevy.app.App;
import bevy.window.Window;

class RenderPlugin {
    public var context(default, null):RenderContext;

    public function new(?context:RenderContext) {
        this.context = context != null ? context : new RenderContext();
    }

    public function build(app:App):Void {
        var window = app.world.getResource(Window);
        if (window != null) {
            context.initialize(window);
        }
        app.world.insertResource(context);
    }
}
