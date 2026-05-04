package bevy.reflect;

import bevy.reflect.TypeInfo.TypeKind;

class TypeRegistry {
    private static var instance:TypeRegistry;
    private var types:Map<String, TypeInfo>;

    public function new() {
        types = new Map();
    }

    public static function global():TypeRegistry {
        if (instance == null) {
            instance = new TypeRegistry();
        }
        return instance;
    }

    public function register(cls:Class<Dynamic>, kind:TypeKind):TypeInfo {
        var info = TypeInfo.fromClass(cls, kind);
        types.set(fullName(info), info);
        return info;
    }

    public function registerInfo(info:TypeInfo):TypeInfo {
        types.set(fullName(info), info);
        return info;
    }

    public function get(cls:Class<Dynamic>):Null<TypeInfo> {
        return types.get(Type.getClassName(cls));
    }

    public function has(cls:Class<Dynamic>):Bool {
        return types.exists(Type.getClassName(cls));
    }

    public function all():Array<TypeInfo> {
        return [for (info in types) info];
    }

    private function fullName(info:TypeInfo):String {
        return info.modulePath.length == 0 ? info.typeName : info.modulePath + "." + info.typeName;
    }
}
