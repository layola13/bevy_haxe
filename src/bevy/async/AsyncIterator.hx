package bevy.async;

interface AsyncIterator<T> {
    function nextAsync():Future<AsyncIteratorResult<T>>;
}

typedef AsyncIteratorResult<T> = {
    var done:Bool;
    var value:Null<T>;
}

class ArrayAsyncIterator<T> implements AsyncIterator<T> {
    private var values:Array<T>;
    private var index:Int = 0;

    public function new(values:Array<T>) {
        this.values = values;
    }

    public function nextAsync():Future<AsyncIteratorResult<T>> {
        if (index >= values.length) {
            return Future.resolved({done: true, value: null});
        }
        return Future.resolved({done: false, value: values[index++]});
    }
}
