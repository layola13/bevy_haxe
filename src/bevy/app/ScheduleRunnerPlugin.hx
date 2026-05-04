package bevy.app;

import bevy.async.Future;

enum RunMode {
    Once;
    Loop(waitMs:Null<Int>);
}

class ScheduleRunnerPlugin implements Plugin {
    public var runMode(default, null):RunMode;

    public function new(?runMode:RunMode) {
        this.runMode = runMode != null ? runMode : Once;
    }

    public static function runOnce():ScheduleRunnerPlugin {
        return new ScheduleRunnerPlugin(Once);
    }

    public static function runLoop(?waitMs:Int):ScheduleRunnerPlugin {
        return new ScheduleRunnerPlugin(Loop(waitMs));
    }

    public function build(app:App):Void {
        var mode = runMode;
        app.setRunner(function(target:App) {
            return switch mode {
                case Once:
                    runOnceApp(target);
                case Loop(waitMs):
                    runLoopApp(target, waitMs);
            };
        });
    }

    private static function runOnceApp(app:App):Future<Dynamic> {
        return app.startup().next(function(_) {
            return app.update().map(function(result) {
                return app.shouldExit() != null ? app.shouldExit() : result;
            });
        });
    }

    private static function runLoopApp(app:App, waitMs:Null<Int>):Future<Dynamic> {
        return Future.create(function(resolve, reject) {
            function step():Void {
                runOnceApp(app).handle(function(_) {
                    var exit = app.shouldExit();
                    if (exit != null) {
                        resolve(exit);
                        return;
                    }
                    scheduleNext(waitMs, step);
                }, reject);
            }

            step();
        });
    }

    private static function scheduleNext(waitMs:Null<Int>, callback:Void->Void):Void {
        var delay = waitMs != null ? waitMs : 0;
        #if js
        js.Browser.window.setTimeout(function() {
            callback();
        }, delay > 0 ? delay : 1);
        #else
        haxe.Timer.delay(callback, delay > 0 ? delay : 1);
        #end
    }
}
