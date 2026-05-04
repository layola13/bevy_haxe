package bevy.async;

#if js
class PromiseFuture {
    public static function fromPromise<T>(promise:js.lib.Promise<T>):Future<T> {
        return Future.create(function(resolve, reject) {
            promise.then(function(value) {
                resolve(value);
                return value;
            }, function(error) {
                reject(error);
                return error;
            });
        });
    }
}
#else
class PromiseFuture {
    public static function fromPromise<T>(promise:Dynamic):Future<T> {
        return Future.rejected("PromiseFuture is only available on the JS target");
    }
}
#end
