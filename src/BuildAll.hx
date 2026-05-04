package;

import bevy.async.Async;
import bevy.async.Async.async;
import bevy.async.Async.await;
import bevy.async.AsyncClass;
import bevy.async.AsyncIterator;
import bevy.async.AsyncRuntime;
import bevy.async.Future;
import bevy.async.PromiseFuture;
import bevy.async.Task;
import bevy.app.App;
import bevy.app.MainSchedule;
import bevy.app.Schedule;
import bevy.app.SystemClass;
import bevy.app.SystemRegistry;
import bevy.asset.Asset;
import bevy.asset.AssetServer;
import bevy.asset.Assets;
import bevy.asset.Handle;
import bevy.ecs.Bundle;
import bevy.ecs.BundleRegistry;
import bevy.ecs.Commands;
import bevy.ecs.Entity;
import bevy.ecs.Events;
import bevy.ecs.Query;
import bevy.ecs.Resource;
import bevy.ecs.World;
import bevy.input.InputPlugin;
import bevy.input.Keyboard;
import bevy.input.Mouse;
import bevy.render.RenderContext;
import bevy.render.RenderPlugin;
import bevy.window.Window;
import bevy.window.WindowPlugin;

class BuildAll implements AsyncClass {
    static function main():Void {
        var future = boot();
        future.handle(function(_) {}, function(error) throw error);
        AsyncRuntime.flush();
    }

    @:async
    static function boot() {
        return @await Future.resolved(1);
    }
}
