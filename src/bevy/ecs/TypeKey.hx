package bevy.ecs;

class TypeKey {
    public static function ofClass<T>(cls:Class<T>):String {
        var name = Type.getClassName(cls);
        if (name == null) {
            throw "Cannot derive a TypeKey for an anonymous class";
        }
        return name;
    }

    public static function ofInstance(value:Dynamic):String {
        var cls = Type.getClass(value);
        if (cls == null) {
            throw "Cannot derive a TypeKey for a value without a class";
        }
        return ofClass(cls);
    }
}
