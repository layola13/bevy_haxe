package bevy.ecs;

import bevy.ecs.EcsError.TypeKeyError;
import bevy.ecs.EcsError.TypeKeyErrorKind;

class TypeKey {
    public static function ofClass<T>(cls:Class<T>):String {
        var name = Type.getClassName(cls);
        if (name == null) {
            throw new TypeKeyError(TypeKeyErrorKind.AnonymousClass);
        }
        return name;
    }

    public static function ofInstance(value:Dynamic):String {
        var cls = Type.getClass(value);
        if (cls == null) {
            throw new TypeKeyError(TypeKeyErrorKind.ValueWithoutClass);
        }
        return ofClass(cls);
    }

    public static function named(name:String):String {
        if (name == null || name == "") {
            throw new TypeKeyError(TypeKeyErrorKind.EmptyName);
        }
        return name;
    }

    public static function parameterized(base:String, params:Array<String>):String {
        if (params == null || params.length == 0) {
            return named(base);
        }

        var normalized:Array<String> = [];
        for (param in params) {
            normalized.push(named(param));
        }
        return named(base) + "<" + normalized.join(",") + ">";
    }

    public static function ofParameterizedClass<T>(cls:Class<T>, params:Array<Class<Dynamic>>):String {
        var keys:Array<String> = [];
        if (params != null) {
            for (param in params) {
                keys.push(ofClass(param));
            }
        }
        return parameterized(ofClass(cls), keys);
    }
}
