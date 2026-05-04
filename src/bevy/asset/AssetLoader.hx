package bevy.asset;

import bevy.async.Future;

typedef AssetLoaderFn = String->Future<Dynamic>;

class AssetLoaderRegistration {
    public var assetKey(default, null):String;
    public var extensions(default, null):Array<String>;
    public var load(default, null):AssetLoaderFn;

    public function new(assetKey:String, extensions:Array<String>, load:AssetLoaderFn) {
        this.assetKey = assetKey;
        this.extensions = extensions;
        this.load = load;
    }
}

class AssetLoader {
    public static function create<T>(assetClass:Class<T>, extensions:Array<String>, load:String->Future<T>):AssetLoaderRegistration {
        return new AssetLoaderRegistration(
            AssetType.keyOf(assetClass),
            normalizeExtensions(extensions),
            function(path:String) return cast load(path)
        );
    }

    static function normalizeExtensions(extensions:Array<String>):Array<String> {
        var result:Array<String> = [];
        for (extension in extensions) {
            if (extension == null) {
                continue;
            }
            var normalized = StringTools.trim(extension).toLowerCase();
            if (StringTools.startsWith(normalized, ".")) {
                normalized = normalized.substr(1);
            }
            if (normalized != "") {
                result.push(normalized);
            }
        }
        return result;
    }
}
