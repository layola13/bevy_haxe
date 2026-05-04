package bevy.asset;

import bevy.app.App;
import bevy.ecs.World;

class AssetApp {
    public static function initAsset<T>(app:App, assetClass:Class<T>):App {
        var key = AssetType.resourceKey(assetClass);
        if (!app.world.hasResourceByKey(key)) {
            app.world.insertResource(new Assets<T>(assetClass));
        }
        return app;
    }

    public static function registerAssetLoader(app:App, loader:AssetLoaderRegistration):App {
        var server = requireServer(app.world);
        server.registerLoader(loader);
        return app;
    }

    public static function assets<T>(app:App, assetClass:Class<T>):Assets<T> {
        return requireAssets(app.world, assetClass);
    }

    public static function requireAssets<T>(world:World, assetClass:Class<T>):Assets<T> {
        var key = AssetType.resourceKey(assetClass);
        var assets:Assets<T> = world.getResourceByKey(key);
        if (assets == null) {
            throw 'Asset type not initialized: ${Type.getClassName(assetClass)}';
        }
        return assets;
    }

    public static function requireServer(world:World):AssetServer {
        var server = world.getResource(AssetServer);
        if (server == null) {
            throw "AssetServer resource is missing. Add AssetPlugin before using assets.";
        }
        return server;
    }
}
