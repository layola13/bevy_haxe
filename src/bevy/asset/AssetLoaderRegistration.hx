package bevy.asset;

import bevy.async.Future;

typedef ErasedAssetLoader = String->Future<Asset>;

class AssetLoaderRegistration {
    public var assetKey(default, null):String;
    public var extensions(default, null):Array<String>;
    public var load(default, null):ErasedAssetLoader;

    public function new(assetKey:String, extensions:Array<String>, load:ErasedAssetLoader) {
        this.assetKey = assetKey;
        this.extensions = extensions;
        this.load = load;
    }
}
