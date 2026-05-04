package bevy.asset;

import bevy.async.Future;
import bevy.ecs.Resource;

enum LoadState {
    NotLoaded;
    Loading;
    Loaded;
    Failed(error:Dynamic);
}

@:using(bevy.asset.AssetLoad)
class AssetServer implements Resource {
    public var __world:Dynamic;

    private var textSource:String->Future<String>;
    private var states:Map<String, LoadState>;
    private var pathToHandle:Map<String, Int>;
    private var pathToType:Map<String, String>;
    private var loadersByType:Map<String, AssetLoaderRegistration>;
    private var loadersByExtension:Map<String, AssetLoaderRegistration>;

    public function new(?textSource:String->Future<String>) {
        __world = null;
        this.textSource = textSource != null ? textSource : defaultTextSource;
        states = new Map();
        pathToHandle = new Map();
        pathToType = new Map();
        loadersByType = new Map();
        loadersByExtension = new Map();
    }

    public function attachWorld(world:Dynamic):AssetServer {
        __world = world;
        return this;
    }

    public function registerLoader(loader:AssetLoaderRegistration):Void {
        loadersByType.set(loader.assetKey, loader);
        for (extension in loader.extensions) {
            loadersByExtension.set(extension, loader);
        }
    }

    public function loadTyped<T>(assets:Assets<T>, path:String):Handle<T> {
        var assetKey = assets.typeKey();
        var dedupKey = pathKey(assetKey, path);

        if (pathToHandle.exists(dedupKey)) {
            return new Handle<T>(pathToHandle.get(dedupKey));
        }

        var loader = loadersByType.get(assetKey);
        if (loader == null) {
            loader = loadersByExtension.get(pathExtension(path));
        }
        if (loader == null) {
            throw 'No asset loader registered for $assetKey at path $path';
        }

        var handle = assets.reserveHandle();
        pathToHandle.set(dedupKey, handle.id);
        pathToType.set(path, assetKey);
        states.set(stateKey(assetKey, handle.id), Loading);

        loader.load(path).handle(function(value) {
            assets.set(handle, cast value);
            states.set(stateKey(assetKey, handle.id), Loaded);
        }, function(error) {
            states.set(stateKey(assetKey, handle.id), Failed(error));
        });

        return handle;
    }

    public function add<T>(assets:Assets<T>, value:T):Handle<T> {
        var handle = assets.add(value);
        states.set(stateKey(assets.typeKey(), handle.id), Loaded);
        return handle;
    }

    public function loadText(path:String):Future<String> {
        return textSource(path);
    }

    public function state<T>(assets:Assets<T>, handle:Handle<T>):LoadState {
        var state = states.get(stateKey(assets.typeKey(), handle.id));
        return state != null ? state : NotLoaded;
    }

    private function stateKey(assetKey:String, handleId:Int):String {
        return assetKey + ":" + handleId;
    }

    private function pathKey(assetKey:String, path:String):String {
        return assetKey + ":" + path;
    }

    private function pathExtension(path:String):String {
        var dot = path.lastIndexOf(".");
        if (dot < 0 || dot >= path.length - 1) {
            return "";
        }
        return path.substr(dot + 1).toLowerCase();
    }

    private static function defaultTextSource(path:String):Future<String> {
        #if js
        return Future.create(function(resolve, reject) {
            js.Browser.window.fetch(path).then(function(response) {
                return response.text();
            }).then(function(text) {
                resolve(text);
                return text;
            }, function(error) {
                reject(error);
                return error;
            });
        });
        #else
        return Future.rejected("No default asset source is available on this target");
        #end
    }
}

class TextAsset implements Asset {
    public var value:String;

    public function new(value:String) {
        this.value = value;
    }
}
