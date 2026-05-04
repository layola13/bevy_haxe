package bevy.asset;

class Handle<T> {
    public var id(default, null):Int;

    public function new(id:Int) {
        this.id = id;
    }

    public function equals(other:Handle<T>):Bool {
        return other != null && id == other.id;
    }

    public function toString():String {
        return 'Handle($id)';
    }
}
