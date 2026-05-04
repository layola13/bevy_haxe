package bevy.async;

import bevy.async.AsyncIterator.ArrayAsyncIterator;

#if macro
import haxe.macro.Expr;
#end

class Async {
    public static macro function async(fn:Expr):Expr {
        return bevy.macro.AsyncMacro.async(fn);
    }

    public static inline function await<T>(value:Dynamic):T {
        return AsyncRuntime.awaitImmediate(value);
    }

    public static macro function forAwait(source:Expr, fn:Expr):Expr {
        return bevy.macro.AsyncMacro.forAwait(source, fn);
    }

    public static function join(values:Array<Dynamic>):Future<Array<Dynamic>> {
        return Future.join(values);
    }

    public static function race(values:Array<Dynamic>):Future<Dynamic> {
        return Future.race(values);
    }

    public static function forAwaitRuntime(source:Dynamic, fn:Dynamic->Dynamic):Future<Dynamic> {
        return Future.create(function(resolve, reject) {
            var iterator = makeIterator(source);
            var step:Void->Void = null;
            step = function() {
                iterator.nextAsync().handle(function(result) {
                    if (result.done) {
                        resolve(null);
                        return;
                    }
                    Future.fromDynamic(fn(result.value)).handle(function(_) {
                        step();
                    }, reject);
                }, reject);
            };
            step();
        });
    }

    private static function makeIterator(source:Dynamic):AsyncIterator<Dynamic> {
        if (Std.isOfType(source, Array)) {
            return new ArrayAsyncIterator(cast source);
        }
        if (Std.isOfType(source, AsyncIterator)) {
            return cast source;
        }
        throw "forAwait source must be an Array or AsyncIterator";
    }
}
