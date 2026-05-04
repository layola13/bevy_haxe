package haxe.reflect;

import haxe.utils.TypeId;

/**
    A static accessor to compile-time type information.

    This information includes details about the type's structure,
    fields, and reflection capabilities.

    The @:reflect macro automatically implements this for types.

    Example:
    ```haxe
    @:reflect
    class Position implements Reflect implements TypeInfo {
        public var x:Float;
        public var y:Float;
        public var z:Float;
    }
    ```
**/
interface TypeInfo {
    /**
        Returns the TypeId for this type.
    **/
    function id():TypeId;

    /**
        Returns the type path string.
    **/
    function typePath():String;

    /**
        Returns the kind of this type (Struct, Enum, etc).
    **/
    function kind():ReflectKind;

    /**
        Returns the number of type data entries.
    **/
    function dataCount():Int;

    /**
        Gets type data by type ID.
        @param typeId The type ID to look for
        @return The type data if found, null otherwise
    **/
    function getData<T>(typeId:TypeId):Null<T>;

    /**
        Returns struct-specific info if this is a struct.
    **/
    function asStruct():StructInfo;

    /**
        Returns enum-specific info if this is an enum.
    **/
    function asEnum():EnumInfo;

    /**
        Returns tuple-specific info if this is a tuple.
    **/
    function asTuple():TupleInfo;

    /**
        Returns list-specific info if this is a list.
    **/
    function asList():ListInfo;

    /**
        Returns map-specific info if this is a map.
    **/
    function asMap():MapInfo;
}

/**
    Error type for TypeInfo operations.
**/
enum TypeInfoError {
    /**
        Type is not a struct.
    **/
    NotAStruct;

    /**
        Type is not an enum.
    **/
    NotAnEnum;

    /**
        Type is not a tuple.
    **/
    NotATuple;

    /**
        Type is not a list.
    **/
    NotAList;

    /**
        Type is not a map.
    **/
    NotAMap;

    /**
        Kind mismatch when casting.
    **/
    KindMismatch(expected:ReflectKind, received:ReflectKind);
}

/**
    Information about a struct type.
**/
class StructInfo {
    /**
        The field names in order.
    **/
    public var fieldNames(default, null):Array<String>;

    /**
        The number of fields.
    **/
    public var fieldCount(default, null):Int;

    /**
        Type information for each field.
    **/
    public var fields(default, null):Array<FieldInfo>;

    public function new(fieldNames:Array<String>, fields:Array<FieldInfo>) {
        this.fieldNames = fieldNames;
        this.fields = fields;
        this.fieldCount = fields.length;
    }

    /**
        Gets field info by name.
    **/
    public function field(name:String):Null<FieldInfo> {
        for (field in fields) {
            if (field.name == name) return field;
        }
        return null;
    }

    /**
        Gets field info by index.
    **/
    public function fieldAt(index:Int):Null<FieldInfo> {
        if (index >= 0 && index < fields.length) {
            return fields[index];
        }
        return null;
    }
}

/**
    Information about an enum type.
**/
class EnumInfo {
    /**
        The variant names.
    **/
    public var variantNames(default, null):Array<String>;

    /**
        The number of variants.
    **/
    public var variantCount(default, null):Int;

    /**
        Information about each variant.
    **/
    public var variants(default, null):Array<VariantInfo>;

    public function new(variants:Array<VariantInfo>) {
        this.variants = variants;
        this.variantNames = [for (v in variants) v.name];
        this.variantCount = variants.length;
    }

    /**
        Gets variant info by name.
    **/
    public function variant(name:String):Null<VariantInfo> {
        for (variant in variants) {
            if (variant.name == name) return variant;
        }
        return null;
    }

    /**
        Gets variant info by index.
    **/
    public function variantAt(index:Int):Null<VariantInfo> {
        if (index >= 0 && index < variants.length) {
            return variants[index];
        }
        return null;
    }
}

/**
    Information about an enum variant.
**/
class VariantInfo {
    /**
        The name of this variant.
    **/
    public var name(default, null):String;

    /**
        The index of this variant in the enum.
    **/
    public var index(default, null):Int;

    /**
        The type of data this variant holds.
    **/
    public var data(default, null):StructInfo;

    public function new(name:String, index:Int, data:StructInfo) {
        this.name = name;
        this.index = index;
        this.data = data;
    }
}

/**
    Information about a tuple type.
**/
class TupleInfo {
    /**
        The number of elements.
    **/
    public var fieldCount(default, null):Int;

    /**
        Type information for each element.
    **/
    public var types(default, null):Array<TypeId>;

    public function new(types:Array<TypeId>) {
        this.types = types;
        this.fieldCount = types.length;
    }
}

/**
    Information about a list type.
**/
class ListInfo {
    /**
        The type of elements in the list.
    **/
    public var elementType(default, null):TypeId;

    public function new(elementType:TypeId) {
        this.elementType = elementType;
    }
}

/**
    Information about a map type.
**/
class MapInfo {
    /**
        The key type.
    **/
    public var keyType(default, null):TypeId;

    /**
        The value type.
    **/
    public var valueType(default, null):TypeId;

    public function new(keyType:TypeId, valueType:TypeId) {
        this.keyType = keyType;
        this.valueType = valueType;
    }
}

/**
    Information about a field.
**/
class FieldInfo {
    /**
        The name of the field.
    **/
    public var name(default, null):String;

    /**
        The type ID of the field.
    **/
    public var typeId(default, null):TypeId;

    /**
        The index of the field in the struct.
    **/
    public var index(default, null):Int;

    /**
        Whether this field is read-only.
    **/
    public var readOnly(default, null):Bool;

    public function new(name:String, typeId:TypeId, index:Int, readOnly:Bool = false) {
        this.name = name;
        this.typeId = typeId;
        this.index = index;
        this.readOnly = readOnly;
    }
}

/**
    Dynamic TypeInfo that can be constructed at runtime.
**/
class DynamicTypeInfo implements TypeInfo {
    private var _typeId:TypeId;
    private var _typePath:String;
    private var _kind:ReflectKind;
    private var _data:Map<TypeId, Dynamic>;
    private var _structInfo:Null<StructInfo>;
    private var _enumInfo:Null<EnumInfo>;

    public function new(typePath:String, kind:ReflectKind) {
        this._typeId = TypeId.ofInstance(this);
        this._typePath = typePath;
        this._kind = kind;
        this._data = new Map();
    }

    public function id():TypeId return _typeId;
    public function typePath():String return _typePath;
    public function kind():ReflectKind return _kind;
    public function dataCount():Int return _data.keys().hasNext() ? 0 : 0;

    public function getData<T>(typeId:TypeId):Null<T> {
        return _data.get(typeId);
    }

    public function addData<T>(typeId:TypeId, data:T):Void {
        _data.set(typeId, data);
    }

    public function asStruct():StructInfo {
        if (_kind != Struct) {
            throw TypeInfoError.KindMismatch(Struct, _kind);
        }
        return _structInfo;
    }

    public function asEnum():EnumInfo {
        if (_kind != Enum) {
            throw TypeInfoError.KindMismatch(Enum, _kind);
        }
        return _enumInfo;
    }

    public function asTuple():TupleInfo {
        throw TypeInfoError.NotATuple;
    }

    public function asList():ListInfo {
        throw TypeInfoError.NotAList;
    }

    public function asMap():MapInfo {
        throw TypeInfoError.NotAMap;
    }

    public function withStructInfo(info:StructInfo):DynamicTypeInfo {
        _structInfo = info;
        return this;
    }

    public function withEnumInfo(info:EnumInfo):DynamicTypeInfo {
        _enumInfo = info;
        return this;
    }
}
