package bevy.async;

class CancellationToken {
    private var cancelled:Bool = false;

    public function new() {}

    public function cancel():Void {
        cancelled = true;
    }

    public function isCancelled():Bool {
        return cancelled;
    }
}

class Task<T> {
    public var future(default, null):Future<T>;
    public var cancellation(default, null):CancellationToken;

    public function new(future:Future<T>, ?cancellation:CancellationToken) {
        this.future = future;
        this.cancellation = cancellation != null ? cancellation : new CancellationToken();
    }

    public static function spawn<T>(work:Void->Future<T>):Task<T> {
        var token = new CancellationToken();
        var future = Future.create(function(resolve, reject) {
            AsyncRuntime.schedule(function() {
                if (token.isCancelled()) {
                    reject("Task cancelled");
                    return;
                }
                try {
                    work().handle(resolve, reject);
                } catch (error:Dynamic) {
                    reject(error);
                }
            });
        });
        return new Task(future, token);
    }

    public function cancel():Void {
        cancellation.cancel();
        future.cancel();
    }

    public function isFinished():Bool {
        return future.isReady();
    }
}
