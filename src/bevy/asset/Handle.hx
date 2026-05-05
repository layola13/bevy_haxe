package bevy.asset;

class Handle<T:Asset> {
    public var id(default, null):Int;
    public var componentKey(default, null):String;

    public function new(id:Int, ?componentKey:String) {
        this.id = id;
        this.componentKey = componentKey;
    }

    public function equals(other:Handle<T>):Bool {
        return other != null && id == other.id && componentKey == other.componentKey;
    }

    public function toString():String {
        return 'Handle($componentKey:$id)';
    }
}
