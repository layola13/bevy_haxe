package asset_new;

import bevy.asset.AssetServer;
import bevy.asset.AssetServer.TextAsset;
import bevy.asset.Assets;
import bevy.async.AsyncRuntime;
import bevy.async.Future;

class AssetPipelineTest {
    static function main():Void {
        var server = new AssetServer(function(path) {
            return Future.resolved('asset:$path');
        });
        var assets = new Assets<TextAsset>();

        var handle = null;
        server.loadTextAsset(assets, "hello.txt").handle(function(result) {
            handle = result;
        }, function(error) throw error);
        AsyncRuntime.flush();

        assert(handle != null, "handle should resolve");
        assert(assets.has(handle), "asset should be stored");
        assertEq("asset:hello.txt", assets.get(handle).value, "asset text");
        assertEq(LoadState.Loaded, server.state(handle), "load state");
        trace("AssetPipelineTest ok");
    }

    static function assertEq<T>(expected:T, actual:T, label:String):Void {
        if (expected != actual) {
            throw '$label expected $expected, got $actual';
        }
    }

    static function assert(value:Bool, label:String):Void {
        if (!value) {
            throw label;
        }
    }
}
