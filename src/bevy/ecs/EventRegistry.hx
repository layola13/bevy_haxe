package bevy.ecs;

import bevy.reflect.TypeInfo;
import bevy.reflect.TypeInfo.TypeKind;
import bevy.reflect.TypeRegistry;

class EventRegistry {
    private static var events:Map<String, TypeInfo>;

    public static function register(cls:Class<Dynamic>):TypeInfo {
        var key = TypeKey.ofClass(cls);
        var existing = storage().get(key);
        if (existing != null) {
            return existing;
        }
        var info = TypeRegistry.global().register(cls, TypeKind.Event);
        storage().set(key, info);
        return info;
    }

    public static function get(cls:Class<Dynamic>):Null<TypeInfo> {
        return storage().get(TypeKey.ofClass(cls));
    }

    public static function has(cls:Class<Dynamic>):Bool {
        return storage().exists(TypeKey.ofClass(cls));
    }

    private static function storage():Map<String, TypeInfo> {
        if (events == null) {
            events = new Map();
        }
        return events;
    }
}
