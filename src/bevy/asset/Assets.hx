package bevy.asset;

import bevy.ecs.Resource;

class Assets<T:Asset> implements Resource {
    public var resourceKey(default, null):String;

    private var assetKey:String;
    private var nextId:Int;
    private var values:Map<Int, T>;

    public function new(assetClass:Class<T>) {
        assetKey = AssetType.keyOf(assetClass);
        resourceKey = AssetType.resourceKey(assetClass);
        nextId = 1;
        values = new Map();
    }

    public function add(value:T):Handle<T> {
        var handle = reserveHandle();
        values.set(handle.id, value);
        return handle;
    }

    public function reserveHandle():Handle<T> {
        return new Handle<T>(nextId++);
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

    public function contains(id:Int):Bool {
        return values.exists(id);
    }

    public function typeKey():String {
        return assetKey;
    }
}
