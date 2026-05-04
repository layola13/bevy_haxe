package bevy.asset;

import bevy.app.App;
import bevy.app.Plugin;

class AssetPlugin implements Plugin {
    private var textSource:String->bevy.async.Future<String>;

    public function new(?textSource:String->bevy.async.Future<String>) {
        this.textSource = textSource;
    }

    public function build(app:App):Void {
        if (!app.world.hasResource(AssetServer)) {
            app.world.insertResource(new AssetServer(textSource).attachWorld(app.world));
        }
    }
}
