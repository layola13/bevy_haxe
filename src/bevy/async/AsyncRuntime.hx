package bevy.async;

class AsyncRuntime {
    private static var queue:Array<Void->Void> = [];
    private static var flushing:Bool = false;

    public static function schedule(callback:Void->Void):Void {
        queue.push(callback);
        requestFlush();
    }

    public static function flush():Void {
        if (flushing) {
            return;
        }
        flushing = true;
        try {
            drain();
            flushing = false;
        } catch (error:Dynamic) {
            flushing = false;
            throw error;
        }
    }

    public static function awaitImmediate<T>(value:Dynamic):T {
        var future = Future.fromDynamic(value);
        return cast future.getNow();
    }

    private static function requestFlush():Void {
        #if js
        js.Syntax.code("Promise.resolve().then({0})", function() {
            AsyncRuntime.flush();
        });
        #else
        flush();
        #end
    }

    private static function drain():Void {
        while (queue.length > 0) {
            var callback = queue.shift();
            callback();
        }
    }
}
