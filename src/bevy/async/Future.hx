package bevy.async;

enum FutureState<T> {
    Pending;
    Resolved(value:T);
    Rejected(error:Dynamic);
    Cancelled;
}

typedef Canceller = Void->Void;

class Future<T> {
    private var state:FutureState<T>;
    private var successCallbacks:Array<T->Void>;
    private var failureCallbacks:Array<Dynamic->Void>;
    private var cancelCallbacks:Array<Canceller>;

    public function new() {
        state = Pending;
        successCallbacks = [];
        failureCallbacks = [];
        cancelCallbacks = [];
    }

    public static function create<T>(starter:(T->Void, Dynamic->Void)->Void):Future<T> {
        var future = new Future<T>();
        try {
            starter(future.resolve, future.reject);
        } catch (error:Dynamic) {
            future.reject(error);
        }
        return future;
    }

    public static function resolved<T>(value:T):Future<T> {
        var future = new Future<T>();
        future.resolve(value);
        return future;
    }

    public static function rejected<T>(error:Dynamic):Future<T> {
        var future = new Future<T>();
        future.reject(error);
        return future;
    }

    public static function cancelled<T>():Future<T> {
        var future = new Future<T>();
        future.cancel();
        return future;
    }

    public static function fromDynamic(value:Dynamic):Future<Dynamic> {
        if (Std.isOfType(value, Future)) {
            return cast value;
        }
        #if js
        if (value != null && Reflect.hasField(value, "then")) {
            return PromiseFuture.fromPromise(cast value);
        }
        #end
        return Future.resolved(value);
    }

    public function resolve(value:T):Void {
        switch state {
            case Pending:
                state = Resolved(value);
                var callbacks = successCallbacks;
                successCallbacks = [];
                failureCallbacks = [];
                for (callback in callbacks) {
                    AsyncRuntime.schedule(function() callback(value));
                }
            default:
        }
    }

    public function reject(error:Dynamic):Void {
        switch state {
            case Pending:
                state = Rejected(error);
                var callbacks = failureCallbacks;
                successCallbacks = [];
                failureCallbacks = [];
                if (callbacks.length == 0) {
                    return;
                }
                for (callback in callbacks) {
                    AsyncRuntime.schedule(function() callback(error));
                }
            default:
        }
    }

    public function cancel():Void {
        switch state {
            case Pending:
                state = Cancelled;
                var callbacks = cancelCallbacks;
                successCallbacks = [];
                failureCallbacks = [];
                cancelCallbacks = [];
                for (callback in callbacks) {
                    AsyncRuntime.schedule(callback);
                }
                reject("Future cancelled");
            default:
        }
    }

    public function onCancel(callback:Canceller):Future<T> {
        switch state {
            case Pending:
                cancelCallbacks.push(callback);
            case Cancelled:
                AsyncRuntime.schedule(callback);
            default:
        }
        return this;
    }

    public function handle(onResolved:T->Void, ?onRejected:Dynamic->Void):Future<T> {
        switch state {
            case Pending:
                successCallbacks.push(onResolved);
                failureCallbacks.push(onRejected != null ? onRejected : function(error) throw error);
            case Resolved(value):
                AsyncRuntime.schedule(function() onResolved(value));
            case Rejected(error):
                if (onRejected != null) {
                    AsyncRuntime.schedule(function() onRejected(error));
                }
            case Cancelled:
                if (onRejected != null) {
                    AsyncRuntime.schedule(function() onRejected("Future cancelled"));
                }
        }
        return this;
    }

    public function map<U>(mapper:T->U):Future<U> {
        return Future.create(function(resolve, reject) {
            handle(function(value) {
                try {
                    resolve(mapper(value));
                } catch (error:Dynamic) {
                    reject(error);
                }
            }, reject);
        });
    }

    public function next<U>(mapper:T->Future<U>):Future<U> {
        return Future.create(function(resolve, reject) {
            handle(function(value) {
                try {
                    mapper(value).handle(resolve, reject);
                } catch (error:Dynamic) {
                    reject(error);
                }
            }, reject);
        });
    }

    public function recover(handler:Dynamic->T):Future<T> {
        return Future.create(function(resolve, reject) {
            handle(resolve, function(error) {
                try {
                    resolve(handler(error));
                } catch (nextError:Dynamic) {
                    reject(nextError);
                }
            });
        });
    }

    public function isReady():Bool {
        return switch state {
            case Pending: false;
            default: true;
        };
    }

    public function isResolved():Bool {
        return switch state {
            case Resolved(_): true;
            default: false;
        };
    }

    public function isRejected():Bool {
        return switch state {
            case Rejected(_): true;
            default: false;
        };
    }

    public function getState():FutureState<T> {
        return state;
    }

    public function getNow():T {
        return switch state {
            case Resolved(value):
                value;
            case Rejected(error):
                throw error;
            case Cancelled:
                throw "Future cancelled";
            case Pending:
                throw "Future is still pending";
        };
    }

    public static function join(values:Array<Dynamic>):Future<Array<Dynamic>> {
        if (values.length == 0) {
            return Future.resolved([]);
        }
        return Future.create(function(resolve, reject) {
            var remaining = values.length;
            var result:Array<Dynamic> = [];
            for (i in 0...values.length) {
                result[i] = null;
                Future.fromDynamic(values[i]).handle(function(value) {
                    result[i] = value;
                    remaining--;
                    if (remaining == 0) {
                        resolve(result);
                    }
                }, reject);
            }
        });
    }

    public static function race(values:Array<Dynamic>):Future<Dynamic> {
        return Future.create(function(resolve, reject) {
            var settled = false;
            for (value in values) {
                Future.fromDynamic(value).handle(function(result) {
                    if (!settled) {
                        settled = true;
                        resolve(result);
                    }
                }, function(error) {
                    if (!settled) {
                        settled = true;
                        reject(error);
                    }
                });
            }
        });
    }

    #if js
    public function toPromise():js.lib.Promise<T> {
        return new js.lib.Promise(function(resolve, reject) {
            handle(resolve, reject);
        });
    }
    #end
}
