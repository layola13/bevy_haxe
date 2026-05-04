package haxe.reflect;

import haxe.utils.TypeId;

/**
    A static accessor to type paths and names.

    The engine uses this trait over Haxe's Type API for stability and flexibility.

    This trait is automatically implemented by the @:reflect macro
    and allows type path information to be processed without an instance of that type.

    Example:
    ```haxe
    class MyComponent implements Reflect implements TypePath {
        public static inline function typePath():String return "my_crate::MyComponent";
        public static inline function shortTypePath():String return "MyComponent";
    }
    ```
**/
interface TypePath {
    /**
        The full path to this type (crate::module::TypeName).
        This should be stable across compiler versions and recompiles.
    **/
    static function type_path():String;

    /**
        The short path to this type (just TypeName or module::TypeName).
        Used for display purposes and user-facing identification.
    **/
    static function short_type_path():String;

    /**
        The identifier of this type (without module path).
        Returns null for anonymous types like arrays.
    **/
    static function type_ident():Null<String>;

    /**
        The name of the crate containing this type.
    **/
    static function crate_name():Null<String>;

    /**
        The module path leading to this type (crate::module).
    **/
    static function module_path():Null<String>;

    /**
        Returns the short type path dynamically from an instance.
    **/
    function shortTypePath():String {
        return short_type_path();
    }

    /**
        Returns the type identifier dynamically from an instance.
    **/
    function typeIdent():Null<String> {
        return type_ident();
    }

    /**
        Returns the crate name dynamically from an instance.
    **/
    function crateName():Null<String> {
        return crate_name();
    }

    /**
        Returns the module path dynamically from an instance.
    **/
    function modulePath():Null<String> {
        return module_path();
    }
}

/**
    A helper class for storing type path information in a static table.
    Useful for runtime type path lookups.
**/
class TypePathTable {
    /**
        The full type path.
    **/
    public var typePath(default, null):String;

    /**
        Function to get the short type path.
    **/
    private var _shortTypePath:() -> String;

    /**
        Function to get the type identifier.
    **/
    private var _typeIdent:() -> Null<String>;

    /**
        Function to get the crate name.
    **/
    private var _crateName:() -> Null<String>;

    /**
        Function to get the module path.
    **/
    private var _modulePath:() -> Null<String>;

    public function new(
        typePath:String,
        shortTypePath:() -> String,
        typeIdent:() -> Null<String>,
        crateName:() -> Null<String>,
        modulePath:() -> Null<String>
    ) {
        this.typePath = typePath;
        this._shortTypePath = shortTypePath;
        this._typeIdent = typeIdent;
        this._crateName = crateName;
        this._modulePath = modulePath;
    }

    /**
        Creates a new table from a TypePath implementing type.
    **/
    public static function of<T:TypePath>():TypePathTable {
        return new TypePathTable(
            T.type_path(),
            T.short_type_path,
            T.type_ident,
            T.crate_name,
            T.module_path
        );
    }

    /**
        Returns the full type path.
    **/
    public function path():String {
        return typePath;
    }

    /**
        Returns the short type path.
    **/
    public function shortPath():String {
        return _shortTypePath();
    }

    /**
        Returns the type identifier.
    **/
    public function ident():Null<String> {
        return _typeIdent();
    }

    /**
        Returns the crate name.
    **/
    public function crateName():Null<String> {
        return _crateName();
    }

    /**
        Returns the module path.
    **/
    public function modulePath():Null<String> {
        return _modulePath();
    }

    public function toString():String {
        return 'TypePathTable($typePath)';
    }
}

/**
    Trait for types that can provide type information statically.
**/
interface Typed {
    /**
        Returns the TypeInfo for this type.
    **/
    static function typeInfo():TypeInfo;

    /**
        Returns the TypeId for this type.
    **/
    static function typeId():TypeId;

    /**
        Returns the TypePath for this type.
    **/
    static function typePath():String;
}

/**
    Default TypePath implementation using Haxe's Type API.
**/
class DefaultTypePath {
    /**
        Generates the type path from a class type.
    **/
    public static function getTypePath<T>(type:Class<T>):String {
        return Type.getClassName(type);
    }

    /**
        Generates the short type path (just the class name).
    **/
    public static function getShortTypePath<T>(type:Class<T>):String {
        var fullPath = Type.getClassName(type);
        var parts = fullPath.split(".");
        return parts[parts.length - 1];
    }

    /**
        Generates the module path from a class.
    **/
    public static function getModulePath<T>(type:Class<T>):Null<String> {
        var fullPath = Type.getClassName(type);
        var lastDot = fullPath.lastIndexOf(".");
        if (lastDot < 0) return null;
        return fullPath.substring(0, lastDot);
    }
}
