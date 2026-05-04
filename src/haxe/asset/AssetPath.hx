package haxe.asset;

import haxe.utils.TypeId;

/**
    Represents a parsed asset path with support for labels and sources.

    Asset paths follow the format: `[<source>]://<path>#<label>`
    - `source`: Optional asset source (e.g., "assets", "embedded")
    - `path`: The file path to the asset
    - `label`: Optional label for embedded assets

    Examples:
    - `"textures/player.png"` - simple path
    - `"assets://textures/player.png"` - with source
    - `"textures/sprites.png#idle"` - with label
    - `"embedded://folder/asset.png#variant"` - source with label
**/
class AssetPath {
    /** The full original path string **/
    public var fullPath(default, null):String;

    /** The asset source (e.g., "assets", "embedded") or null for default **/
    public var source(default, null):String;

    /** The file path within the source **/
    public var path(default, null):String;

    /** Optional label for embedded assets **/
    public var label(default, null):String;

    /** The file extension **/
    public var extension(default, null):String;

    /** The file name without extension **/
    public var fileName(default, null):String;

    /** Type ID if this is a typed asset path **/
    public var typeId(default, null):TypeId;

    private function new() {
        fullPath = "";
        source = null;
        path = "";
        label = null;
        extension = "";
        fileName = "";
        typeId = null;
    }

    /**
        Parses an asset path string into an AssetPath object.
        
        Supports formats:
        - `path/to/asset.png`
        - `source://path/to/asset.png`
        - `path/to/asset.png#label`
        - `source://path/to/asset.png#label`
    **/
    public static function parse(path:String):AssetPath {
        var assetPath = new AssetPath();
        assetPath.fullPath = path;

        var workingPath = path;
        var labelIndex = workingPath.indexOf("#");

        // Extract label if present
        if (labelIndex >= 0) {
            assetPath.label = workingPath.substr(labelIndex + 1);
            workingPath = workingPath.substr(0, labelIndex);
        }

        // Extract source (e.g., "assets://")
        var sourceEnd = workingPath.indexOf("://");
        if (sourceEnd >= 0) {
            assetPath.source = workingPath.substr(0, sourceEnd);
            workingPath = workingPath.substr(sourceEnd + 3);
        }

        // The remaining path is the file path
        assetPath.path = workingPath;

        // Extract extension
        var extStart = workingPath.lastIndexOf(".");
        if (extStart >= 0) {
            assetPath.extension = workingPath.substr(extStart + 1).toLowerCase();
            assetPath.fileName = workingPath.substr(0, extStart);
        } else {
            assetPath.fileName = workingPath;
        }

        return assetPath;
    }

    /**
        Creates an asset path from just a file path (no source or label).
    **/
    public static function fromPath(path:String):AssetPath {
        return parse(path);
    }

    /**
        Creates an asset path with a label.
    **/
    public static function withLabel(path:String, label:String):AssetPath {
        var assetPath = parse(path);
        assetPath.label = label;
        return assetPath;
    }

    /**
        Creates an asset path with a source.
    **/
    public static function withSource(path:String, source:String):AssetPath {
        var assetPath = parse(path);
        assetPath.source = source;
        return assetPath;
    }

    /**
        Creates an asset path with source, path, and label.
    **/
    public static function create(source:String, path:String, label:String):AssetPath {
        var assetPath = new AssetPath();
        
        // Build full path
        var fullPath = path;
        if (source != null && source.length > 0) {
            fullPath = '$source://$path';
        }
        if (label != null && label.length > 0) {
            fullPath = '$fullPath#$label';
        }
        
        assetPath.fullPath = fullPath;
        assetPath.source = source;
        assetPath.path = path;
        assetPath.label = label;

        // Extract extension and filename
        var extStart = path.lastIndexOf(".");
        if (extStart >= 0) {
            assetPath.extension = path.substr(extStart + 1).toLowerCase();
            assetPath.fileName = path.substr(0, extStart);
        } else {
            assetPath.fileName = path;
        }

        return assetPath;
    }

    /**
        Checks if this path has a label.
    **/
    public inline function hasLabel():Bool {
        return label != null && label.length > 0;
    }

    /**
        Checks if this path has a source.
    **/
    public inline function hasSource():Bool {
        return source != null && source.length > 0;
    }

    /**
        Gets the path without extension.
    **/
    public inline function getPathWithoutExtension():String {
        if (extension.length > 0) {
            return path.substr(0, path.length - extension.length - 1);
        }
        return path;
    }

    /**
        Checks if this path matches another path.
    **/
    @:op(A == B)
    public function equals(other:AssetPath):Bool {
        if (other == null) return false;
        return fullPath == other.fullPath;
    }

    @:op(A != B)
    public function notEquals(other:AssetPath):Bool {
        return !equals(other);
    }

    public function hashCode():Int {
        return fullPath.hashCode();
    }

    public function toString():String {
        return fullPath;
    }

    /**
        Returns the dependency key for this path.
        Used for tracking asset dependencies.
    **/
    public function getDependencyKey():String {
        if (source != null) {
            return '$source://$path';
        }
        return path;
    }

    /**
        Creates a child path by appending a segment.
    **/
    public function child(segment:String):AssetPath {
        var newPath = path;
        if (!newPath.endsWith("/")) {
            newPath += "/";
        }
        newPath += segment;

        if (source != null) {
            return create(source, newPath, label);
        }
        return parse(newPath + (label != null ? '#$label' : ''));
    }

    /**
        Gets the parent path.
    **/
    public function parent():AssetPath {
        var lastSlash = path.lastIndexOf("/");
        if (lastSlash < 0) {
            return create(source, "", null);
        }
        var parentPath = path.substr(0, lastSlash);
        return create(source, parentPath, null);
    }
}

/**
    Asset source identifiers.
    These are predefined source types used by the asset system.
**/
class AssetSourceId {
    public var name(default, null):String;
    public var isProcessed(default, null):Bool;

    private function new(name:String, isProcessed:Bool) {
        this.name = name;
        this.isProcessed = isProcessed;
    }

    /** The default asset source (typically file system) **/
    public static var DEFAULT(get, never):AssetSourceId;

    /** The processed assets source **/
    public static var PROCESSED(get, never):AssetSourceId;

    /** Embedded asset source **/
    public static var EMBEDDED(get, never):AssetSourceId;

    /** File system source **/
    public static var FILE_SYSTEM(get, never):AssetSourceId;

    private static var _default:AssetSourceId;
    private static var _processed:AssetSourceId;
    private static var _embedded:AssetSourceId;
    private static var _fileSystem:AssetSourceId;

    private static function get_DEFAULT():AssetSourceId {
        if (_default == null) _default = new AssetSourceId("default", false);
        return _default;
    }

    private static function get_PROCESSED():AssetSourceId {
        if (_processed == null) _processed = new AssetSourceId("processed", true);
        return _processed;
    }

    private static function get_EMBEDDED():AssetSourceId {
        if (_embedded == null) _embedded = new AssetSourceId("embedded", false);
        return _embedded;
    }

    private static function get_FILE_SYSTEM():AssetSourceId {
        if (_fileSystem == null) _fileSystem = new AssetSourceId("file_system", false);
        return _fileSystem;
    }

    @:op(A == B)
    public function equals(other:AssetSourceId):Bool {
        if (other == null) return false;
        return name == other.name;
    }

    public function hashCode():Int {
        return name.hashCode();
    }

    public function toString():String {
        return 'AssetSourceId($name)';
    }
}
