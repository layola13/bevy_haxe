package bevy.reflect;

enum TypeKind {
    Component;
    Resource;
    Event;
    Reflectable;
    Unknown;
}

class TypeInfo {
    public var typeName(default, null):String;
    public var modulePath(default, null):String;
    public var kind(default, null):TypeKind;
    public var fields(default, null):Array<String>;

    public function new(typeName:String, modulePath:String, kind:TypeKind, fields:Array<String>) {
        this.typeName = typeName;
        this.modulePath = modulePath;
        this.kind = kind;
        this.fields = fields;
    }

    public static function fromClass(cls:Class<Dynamic>, kind:TypeKind):TypeInfo {
        var fullName = Type.getClassName(cls);
        if (fullName == null) {
            throw "Cannot reflect an anonymous class";
        }
        var parts = fullName.split(".");
        var typeName = parts.pop();
        return new TypeInfo(typeName, parts.join("."), kind, Type.getInstanceFields(cls));
    }
}
