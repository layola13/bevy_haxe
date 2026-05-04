package bevy.asset;

import bevy.async.Future;

class AssetLoader {
    public static function create<T:Asset>(assetClass:Class<T>, extensions:Array<String>, load:String->Future<T>):AssetLoaderRegistration {
        return new AssetLoaderRegistration(
            AssetType.keyOf(assetClass),
            normalizeExtensions(extensions),
            function(path:String):Future<Asset> return cast load(path)
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
