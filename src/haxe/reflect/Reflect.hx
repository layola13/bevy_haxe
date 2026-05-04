package haxe.reflect;

import haxe.utils.TypeId;

/**
    The core Reflect interface for runtime type introspection.

    This interface provides methods for dynamically accessing and modifying
    type information at runtime. It is the foundation of Bevy's reflection system.

    Implementors should override methods to provide type-specific behavior.
    Use the @:reflect macro to automatically generate implementations.

    Example:
    ```haxe
    @:reflect
    class Position implements Reflect {
        public var x:Float;
        public var y:Float;
        public var z:Float;

        public function new(x:Float = 0, y:Float = 0, z:Float = 0) {
            this.x = x;
            this.y = y;
            this.z = z;
        }
    }
    ```
**/
interface Reflect {
    /**
        Returns a reference to self as a Reflect instance.
    **/
    function asReflect():Reflect;

    /**
        Returns a mutable reference to self as a Reflect instance.
    **/
    function asReflectMut():Reflect;

    /**
        Returns the TypeInfo for this type.
    **/
    function typeInfo():TypeInfo;

    /**
        Returns the type ID for this type.
    **/
    function typeId():TypeId;

    /**
        Returns the type path string for this type.
    **/
    function typePath():String;

    /**
        Gets a field value by name.
        @param name The name of the field to get
        @return The field value wrapped in Dynamic, or null if not found
    **/
    function get(name:String):Dynamic;

    /**
        Sets a field value by name.
        @param name The name of the field to set
        @param value The new value to set
        @return true if successful, false if field not found
    **/
    function set(name:String, value:Dynamic):Bool;

    /**
        Gets the name of each field in order.
        @return Array of field names
    **/
    function fieldNames():Array<String>;

    /**
        Returns true if this reflect instance is the same type as T.
        @return True if types match
    **/
    function is<T>():Bool;

    /**
        Returns a clone of this reflect instance.
        @return A new instance with the same values
    **/
    function clone():Reflect;

    /**
        Gets the reflect kind (Struct, Enum, Primitive, etc.)
    **/
    function kind():ReflectKind;

    /**
        Returns the number of fields.
    **/
    function fieldCount():Int;
}

/**
    Enum representing the different kinds of reflected types.
**/
enum ReflectKind {
    Struct;
    TupleStruct;
    Tuple;
    List;
    Set;
    Map;
    Enum;
    Primitive;
    Opaque;
}

/**
    Error type for reflection operations.
**/
class ReflectError {
    public var message:String;

    public function new(message:String) {
        this.message = message;
    }

    public function toString():String {
        return 'ReflectError: $message';
    }
}

/**
    Result type for reflection operations that may fail.
**/
typedef ReflectResult<T> = {
    > haxe.ds.Result<T, ReflectError>,
};

/**
    A dynamic type path that can represent any type at runtime.
**/
class DynamicTypePath {
    public var typePath(default, null):String;
    public var shortTypePath(default, null):String;

    public function new(typePath:String, shortTypePath:String) {
        this.typePath = typePath;
        this.shortTypePath = shortTypePath;
    }

    public function toString():String {
        return 'DynamicTypePath($shortTypePath)';
    }
}

/**
    A typed reference to a reflected value.
**/
enum ReflectRef {
    /**
        A reference to a struct or struct-like type.
    **/
    Struct(fields:Map<String, Dynamic>);

    /**
        A reference to a tuple-like type.
    **/
    Tuple(values:Array<Dynamic>);

    /**
        A reference to an enum variant.
    **/
    Enum(variant:String, index:Int, values:Map<String, Dynamic>);

    /**
        A reference to a primitive value.
    **/
    Primitive(value:Dynamic);

    /**
        A reference to an opaque (non-indexable) type.
    **/
    Opaque;
}

/**
    Mutable reference to a reflected value.
**/
class ReflectMut {
    public var ref:ReflectRef;

    public function new(ref:ReflectRef) {
        this.ref = ref;
    }
}

/**
    Trait for types that can be reflected upon.
    Combines Reflect with TypePath capabilities.
**/
interface Reflectable extends Reflect {
    /**
        The full type path (module::TypeName).
    **/
    function fullTypePath():String;

    /**
        The short type name without module path.
    **/
    function shortTypeName():String;

    /**
        The module path (crate::module).
    **/
    function modulePath():String;

    /**
        The crate name.
    **/
    function crateName():String;
}

/**
    Dynamic struct that can be modified at runtime.
**/
class DynamicStruct implements Reflect {
    private var _typePath:String;
    private var _fields:Map<String, Dynamic>;
    private var _typeInfo:TypeInfo;

    public function new(typePath:String) {
        this._typePath = typePath;
        this._fields = new Map();
    }

    public function asReflect():Reflect return this;
    public function asReflectMut():Reflect return this;

    public function typeInfo():TypeInfo return _typeInfo;
    public function typeId():TypeId return TypeId.ofInstance(this);
    public function typePath():String return _typePath;
    public function kind():ReflectKind return Struct;

    public function get(name:String):Dynamic {
        return _fields.get(name);
    }

    public function set(name:String, value:Dynamic):Bool {
        _fields.set(name, value);
        return true;
    }

    public function fieldNames():Array<String> {
        return [for (k in _fields.keys()) k];
    }

    public function is<T>():Bool {
        return Std.is(this, T);
    }

    public function clone():Reflect {
        var copy = new DynamicStruct(_typePath);
        for (k in _fields.keys()) {
            copy.set(k, _fields.get(k));
        }
        return copy;
    }

    public function fieldCount():Int {
        return _fields.keys().hasNext() ? 0 : 0; // simplified
    }

    public function setField(name:String, value:Dynamic):Void {
        _fields.set(name, value);
    }

    public function getField(name:String):Dynamic {
        return _fields.get(name);
    }
}

/**
    Dynamic enum representation for runtime enum construction.
**/
class DynamicEnum implements Reflect {
    private var _variantName:String;
    private var _variantIndex:Int;
    private var _fields:Map<String, Dynamic>;
    private var _typeInfo:EnumInfo;

    public function new(typePath:String, variantName:String, variantIndex:Int) {
        this._variantName = variantName;
        this._variantIndex = variantIndex;
        this._fields = new Map();
    }

    public function asReflect():Reflect return this;
    public function asReflectMut():Reflect return this;

    public function typeInfo():TypeInfo return _typeInfo;
    public function typeId():TypeId return TypeId.ofInstance(this);
    public function typePath():String return _variantName;
    public function kind():ReflectKind return Enum;

    public function get(name:String):Dynamic {
        return _fields.get(name);
    }

    public function set(name:String, value:Dynamic):Bool {
        _fields.set(name, value);
        return true;
    }

    public function fieldNames():Array<String> {
        return [for (k in _fields.keys()) k];
    }

    public function is<T>():Bool {
        return Std.is(this, T);
    }

    public function clone():Reflect {
        var copy = new DynamicEnum(typePath(), _variantName, _variantIndex);
        for (k in _fields.keys()) {
            copy.set(k, _fields.get(k));
        }
        return copy;
    }

    public function fieldCount():Int {
        return _fields.keys().hasNext() ? 0 : 0; // simplified
    }

    public function variantName():String return _variantName;
    public function variantIndex():Int return _variantIndex;
}

/**
    Helper for applying values from one reflect to another.
**/
class ReflectApply {
    /**
        Apply values from source to target.
        Returns an error if types don't match.
    **/
    public static function apply<T:Reflect>(target:T, source:Reflect):ReflectResult<T> {
        if (target.typeId() != source.typeId()) {
            return Bad(new ReflectError(
                'Cannot apply ${source.typePath()} to ${target.typePath()}'
            ));
        }

        switch (source.kind()) {
            case Struct:
                for (fieldName in source.fieldNames()) {
                    target.set(fieldName, source.get(fieldName));
                }
            case Tuple:
                // Handle tuple fields
                for (i in 0...source.fieldCount()) {
                    // Tuple field access by index
                }
            default:
                // Handle other types
        }

        return Good(target);
    }
}
