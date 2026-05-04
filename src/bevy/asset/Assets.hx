package bevy.asset;

class Assets<T> {
    private var nextId:Int = 1;
    private var values:Map<Int, T>;

    public function new() {
        values = new Map();
    }

    public function add(value:T):Handle<T> {
        var handle = new Handle<T>(nextId++);
        values.set(handle.id, value);
        return handle;
    }

    public function set(handle:Handle<T>, value:T):Void {
        values.set(handle.id, value);
    }

    public function get(handle:Handle<T>):Null<T> {
        return values.get(handle.id);
    }

    public function has(handle:Handle<T>):Bool {
        return values.exists(handle.id);
    }

    public function remove(handle:Handle<T>):Null<T> {
        var value = values.get(handle.id);
        values.remove(handle.id);
        return value;
    }
}
