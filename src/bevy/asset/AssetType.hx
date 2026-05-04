package bevy.asset;

import bevy.ecs.TypeKey;

class AssetType {
    public static function keyOf<T>(cls:Class<T>):String {
        return TypeKey.ofClass(cls);
    }

    public static function resourceKey<T>(cls:Class<T>):String {
        return TypeKey.parameterized(TypeKey.ofClass(Assets), [keyOf(cls)]);
    }
}
