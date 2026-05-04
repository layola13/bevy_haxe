package asset_new;

using bevy.asset.AssetLoad;

import bevy.app.App;
import bevy.app.MainSchedule;
import bevy.app.SystemClass;
import bevy.asset.AssetServer;
import bevy.asset.AssetServer.LoadState;
import bevy.asset.AssetServer.TextAsset;
import bevy.asset.AssetLoader;
import bevy.asset.AssetPlugin;
import bevy.asset.Assets;
import bevy.asset.Handle;
import bevy.async.AsyncRuntime;
import bevy.async.Future;
import bevy.ecs.Commands;
import bevy.ecs.Res;
import bevy.ecs.Resource;

class AssetPipelineTest {
    static function main():Void {
        var app = new App();
        app.addPlugin(new AssetPlugin(function(path) {
            return Future.resolved('asset:$path');
        }));
        app.initAsset(TextAsset);
        app.registerAssetLoader(AssetLoader.create(TextAsset, ["txt"], function(path) {
            return Future.resolved(new TextAsset('asset:$path'));
        }));
        app.addRegisteredSystems(MainSchedule.Update);

        var server:AssetServer = app.world.getResource(AssetServer);
        var assets:Assets<TextAsset> = app.world.getResourceByKey(bevy.asset.AssetType.resourceKey(TextAsset));

        var handle:Handle<TextAsset> = server.load("hello.txt");
        app.world.insertResource(new RequestedTextHandle(handle));
        AsyncRuntime.flush();
        var updateDone = false;
        app.update().handle(function(_) {
            updateDone = true;
        }, function(error) throw error);
        AsyncRuntime.flush();

        assert(handle != null, "handle should resolve");
        assert(updateDone, "asset update systems should run");
        assert(assets.has(handle), "asset should be stored");
        assertEq("asset:hello.txt", assets.get(handle).value, "asset text");
        assertEq(LoadState.Loaded, server.loadState(handle), "load state");
        assertEq("asset:hello.txt", app.world.getResource(LoadedText).value, "system should read typed Assets<TextAsset> resource");
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

class LoadedText implements Resource {
    public var value:String;

    public function new(value:String) {
        this.value = value;
    }
}

class RequestedTextHandle implements Resource {
    public var value:Handle<TextAsset>;

    public function new(value:Handle<TextAsset>) {
        this.value = value;
    }
}

class AssetPipelineSystems implements SystemClass {
    @:system("Update")
    public static function observe(assets:Res<Assets<TextAsset>>, requested:Res<RequestedTextHandle>, commands:Commands):Void {
        var asset = assets.value.get(requested.value.value);
        if (asset != null) {
            commands.insertResource(new LoadedText(asset.value));
        }
    }
}
