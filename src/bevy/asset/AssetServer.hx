package bevy.asset;

import bevy.async.Future;

enum LoadState {
    NotLoaded;
    Loading;
    Loaded;
    Failed(error:Dynamic);
}

typedef AssetLoader<T> = String->Future<T>;

class AssetServer {
    private var textSource:String->Future<String>;
    private var states:Map<Int, LoadState>;

    public function new(?textSource:String->Future<String>) {
        this.textSource = textSource != null ? textSource : defaultTextSource;
        states = new Map();
    }

    public function add<T>(assets:Assets<T>, value:T):Handle<T> {
        var handle = assets.add(value);
        states.set(handle.id, Loaded);
        return handle;
    }

    public function loadAsync<T>(assets:Assets<T>, path:String, loader:AssetLoader<T>):Future<Handle<T>> {
        var placeholder = assets.add(null);
        states.set(placeholder.id, Loading);
        return loader(path).map(function(value) {
            assets.set(placeholder, value);
            states.set(placeholder.id, Loaded);
            return placeholder;
        }).recover(function(error) {
            states.set(placeholder.id, Failed(error));
            throw error;
        });
    }

    public function loadText(path:String):Future<String> {
        return textSource(path);
    }

    public function loadTextAsset(assets:Assets<TextAsset>, path:String):Future<Handle<TextAsset>> {
        return loadAsync(assets, path, function(path) {
            return loadText(path).map(function(value) return new TextAsset(value));
        });
    }

    public function state<T>(handle:Handle<T>):LoadState {
        var state = states.get(handle.id);
        return state != null ? state : NotLoaded;
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
