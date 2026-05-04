package haxe.asset;

import haxe.utils.TypeId;

/**
    Asset events fired by the asset system.
**/
enum AssetEvent {
    /** Fired when a new asset is added to a collection **/
    Added(typeId:TypeId, id:UntypedAssetId);
    /** Fired when an asset is loaded from disk **/
    Loaded(typeId:TypeId, id:UntypedAssetId);
    /** Fired when an asset fails to load **/
    Failed(typeId:TypeId, id:UntypedAssetId);
    /** Fired when an asset is modified **/
    Modified(typeId:TypeId, id:UntypedAssetId);
    /** Fired when an asset is removed from a collection **/
    Removed(typeId:TypeId, id:UntypedAssetId);
}

/**
    Interface for asset loaders.

    Asset loaders load assets from a given byte source. They accept settings
    which configure how the asset should be loaded.

    This interface is typically used in concert with `AssetReader` to load
    assets from a byte source.

    Example usage:
    ```haxe
    class ImageLoader implements AssetLoader {
        public var extensions(default, never):Array<String> = ["png", "jpg", "jpeg"];
        public var assetType(default, never):Class<Dynamic> = Image;
        public var settingsType(default, never):Class<Dynamic> = LoaderSettings;

        public function load(reader:AssetReader, settings:Dynamic, context:LoadContext):Dynamic {
            var bytes = reader.readBytes();
            return new Image(bytes);
        }

        public function loadAsync(reader:AssetReader, settings:Dynamic, context:LoadContext):Future<Dynamic> {
            // Async implementation
        }
    }
    ```
**/
interface AssetLoader {
    /**
        The file extensions this loader handles.
    **/
    var extensions(get, never):Array<String>;

    /**
        The asset type this loader produces.
    **/
    var assetType(get, never):Class<Dynamic>;

    /**
        The settings type for configuring this loader.
    **/
    var settingsType(get, never):Class<Dynamic>;

    /**
        Synchronously loads an asset from the reader.
        Returns null if loading fails.
    **/
    function loadSync(path:String, reader:AssetReader):Dynamic;

    /**
        Asynchronously loads an asset from the reader.
        Returns a Future that resolves to the loaded asset.
    **/
    function loadAsync(path:String, reader:AssetReader, settings:Dynamic, context:LoadContext):Future<Dynamic>;

    /**
        Checks if this loader can handle the given extension.
    **/
    function canHandle(extension:String):Bool;
}

/**
    Default loader settings (empty).
**/
class LoaderSettings {
    public function new() {}
}

/**
    Future implementation for async operations.
    Simplified version for Haxe.
**/
class Future<T> {
    private var _value:T;
    private var _error:Dynamic;
    private var _complete:Bool;
    private var _callbacks:Array<T -> Void>;

    public function new() {
        _complete = false;
        _callbacks = [];
    }

    /**
        Completes the future with a value.
    **/
    public function complete(value:T):Void {
        if (_complete) return;
        _value = value;
        _complete = true;
        for (cb in _callbacks) {
            cb(value);
        }
        _callbacks = [];
    }

    /**
        Completes the future with an error.
    **/
    public function completeError(error:Dynamic):Void {
        if (_complete) return;
        _error = error;
        _complete = true;
    }

    /**
        Checks if the future is complete.
    **/
    public function isComplete():Bool {
        return _complete;
    }

    /**
        Gets the value if complete, or null otherwise.
    **/
    public function get():Null<T> {
        return _value;
    }

    /**
        Gets the error if complete with error, or null otherwise.
    **/
    public function error():Null<Dynamic> {
        return _error;
    }

    /**
        Registers a callback to be called when the future completes.
    **/
    public function then(callback:T -> Void):Void {
        if (_complete) {
            callback(_value);
        } else {
            _callbacks.push(callback);
        }
    }

    /**
        Static factory for creating an already-resolved future.
    **/
    public static function synchronous<T>(value:T):Future<T> {
        var f = new Future<T>();
        f.complete(value);
        return f;
    }

    /**
        Static factory for creating a failed future.
    **/
    public static function failure<T>(error:Dynamic):Future<T> {
        var f = new Future<T>();
        f.completeError(error);
        return f;
    }
}

/**
    Context provided to asset loaders during loading.
    Provides access to dependency management and asset operations.
**/
class LoadContext {
    /** The path being loaded **/
    public var path(default, null):AssetPath;

    /** Parent context if nested loading **/
    public var parent(default, null):LoadContext;

    /** Label for this asset in the parent context **/
    public var label(default, null):String;

    /** Asset dependencies discovered during loading **/
    private var _dependencies:Array<UntypedAssetId>;

    /** Loaded embedded assets **/
    private var _labeledAssets:Map<String, Dynamic>;

    /** Whether this is a primary asset or dependency **/
    private var _isPrimaryAsset:Bool;

    /** Asset data collected during loading **/
    private var _collectedAssets:Array<LoadedAsset>;

    public function new(path:AssetPath, ?parent:LoadContext, ?label:String, isPrimary:Bool = true) {
        this.path = path;
        this.parent = parent;
        this.label = label;
        _dependencies = [];
        _labeledAssets = new Map();
        _isPrimaryAsset = isPrimary;
        _collectedAssets = [];
    }

    /**
        Reads the asset bytes from the current path.
    **/
    public function readAssetBytes():Bytes {
        // Implementation would read from asset reader
        return null;
    }

    /**
        Reads and deserializes an asset of type T from the current path.
    **/
    public function readAsset<T>():T {
        // Implementation would use appropriate deserializer
        return null;
    }

    /**
        Loads a dependency asset by path.
        Returns a handle to the loaded dependency.
    **/
    public function load<T:(Asset)>(assetPath:String):Handle<T> {
        // This would be implemented to interact with AssetServer
        return null;
    }

    /**
        Loads a dependency asset with specific settings.
    **/
    public function loadWithSettings<T:(Asset)>(assetPath:String, settings:Dynamic):Handle<T> {
        return null;
    }

    /**
        Loads an asset asynchronously.
    **/
    public function loadAsync<T:(Asset)>(assetPath:String):Future<Handle<T>> {
        return null;
    }

    /**
        Gets a dependency by path without loading it.
    **/
    public function getDependency(assetPath:String):UntypedAssetId {
        return null;
    }

    /**
        Gets all discovered dependencies.
    **/
    public function getDependencies():Array<UntypedAssetId> {
        return _dependencies.copy();
    }

    /**
        Marks an asset as a dependency.
    **/
    public function trackDependency(id:UntypedAssetId):Void {
        if (!_dependencies.contains(id)) {
            _dependencies.push(id);
        }
    }

    /**
        Gets a labeled embedded asset.
    **/
    public function getLabeledAsset<T>(label:String):T {
        return _labeledAssets.get(label);
    }

    /**
        Sets a labeled embedded asset.
    **/
    public function setLabeledAsset<T>(label:String, asset:T):Void {
        _labeledAssets.set(label, asset);
    }

    /**
        Pushes a loaded asset to be collected.
    **/
    public function pushLoadedAsset(asset:LoadedAsset):Void {
        _collectedAssets.push(asset);
    }

    /**
        Gets all collected loaded assets.
    **/
    public function getCollectedAssets():Array<LoadedAsset> {
        return _collectedAssets.copy();
    }

    /**
        Creates a nested load context for processing dependencies.
    **/
    public function nested():LoadContext {
        return new LoadContext(path, this, null, false);
    }
}

/**
    A loaded asset with its computed type and dependencies.
**/
class LoadedAsset {
    /** The loaded asset data **/
    public var asset:Dynamic;

    /** Type of the loaded asset **/
    public var typeId:TypeId;

    /** Asset dependencies **/
    public var dependencies:Array<UntypedAssetId>;

    /** Whether this is a loaded dependency or primary asset **/
    public var isDependency:Bool;

    public function new(asset:Dynamic, typeId:TypeId) {
        this.asset = asset;
        this.typeId = typeId;
        this.dependencies = [];
        this.isDependency = false;
    }

    /**
        Adds a dependency to this loaded asset.
    **/
    public function addDependency(id:UntypedAssetId):Void {
        dependencies.push(id);
    }
}

/**
    Simple bytes container for asset loading.
**/
class Bytes {
    public var data(default, null):haxe.io.Bytes;
    public var length(default, null):Int;

    public function new(data:haxe.io.Bytes, length:Int) {
        this.data = data;
        this.length = length;
    }

    public function toString():String {
        return 'Bytes($length bytes)';
    }
}

/**
    AssetReader interface for reading asset data from various sources.
    Equivalent to Rust's `AssetReader` trait.
**/
interface AssetReader {
    /**
        Reads all bytes from the given path.
    **/
    function readBytes(path:AssetPath):Bytes;

    /**
        Opens a reader for the given path.
    **/
    function open(path:AssetPath):AssetReaderInstance;

    /**
        Checks if a path exists.
    **/
    function exists(path:AssetPath):Bool;
}

/**
    An opened asset reader instance for streaming reads.
**/
interface AssetReaderInstance {
    /**
        Reads available bytes.
    **/
    function read():Bytes;

    /**
        Reads exactly n bytes.
    **/
    function readBytes(n:Int):Bytes;

    /**
        Seeks to a position.
    **/
    function seek(position:Int, mode:SeekMode):Void;

    /**
        Returns the current position.
    **/
    function tell():Int;

    /**
        Closes the reader.
    **/
    function close():Void;
}

/**
    Seek mode for file reading.
**/
enum SeekMode {
    Set;
    Current;
    End;
}

/**
    Base asset loader implementation with common functionality.
**/
class BaseAssetLoader implements AssetLoader {
    public var extensions(get, never):Array<String>;
    public var assetType(get, never):Class<Dynamic>;
    public var settingsType(get, never):Class<Dynamic>;

    private var _extensions:Array<String>;
    private var _assetType:Class<Dynamic>;
    private var _settingsType:Class<Dynamic>;

    public function new(extensions:Array<String>, assetType:Class<Dynamic>, ?settingsType:Class<Dynamic>) {
        _extensions = extensions;
        _assetType = assetType;
        _settingsType = settingsType != null ? settingsType : LoaderSettings;
    }

    private function get_extensions():Array<String> return _extensions;
    private function get_assetType():Class<Dynamic> return _assetType;
    private function get_settingsType():Class<Dynamic> return _settingsType;

    public function canHandle(extension:String):Bool {
        return _extensions.indexOf(extension.toLowerCase()) >= 0;
    }

    public function loadSync(path:String, reader:AssetReader):Dynamic {
        var assetPath = AssetPath.parse(path);
        var bytes = reader.readBytes(assetPath);
        return loadFromBytes(bytes, null);
    }

    public function loadAsync(path:String, reader:AssetReader, settings:Dynamic, context:LoadContext):Future<Dynamic> {
        return Future.synchronous(loadSync(path, reader));
    }

    /**
        Override this method to implement actual asset loading from bytes.
    **/
    public function loadFromBytes(bytes:Bytes, settings:Dynamic):Dynamic {
        return null;
    }
}

/**
    AssetSaver interface for saving assets to disk.
    Complementary to AssetLoader.
**/
interface AssetSaver {
    /**
        The asset type this saver handles.
    **/
    var assetType(get, never):Class<Dynamic>;

    /**
        The settings type for saving.
    **/
    var settingsType(get, never):Class<Dynamic>;

    /**
        The file extensions this saver writes.
    **/
    var extensions(get, never):Array<String>;

    /**
        Saves an asset to the given writer.
    **/
    function save(writer:AssetWriter, asset:Dynamic, settings:Dynamic):Int;

    /**
        Checks if this saver can handle the given asset type.
    **/
    function canHandle(asset:Dynamic):Bool;
}

/**
    AssetWriter interface for writing asset data.
**/
interface AssetWriter {
    /**
        Writes bytes to the output.
    **/
    function writeBytes(bytes:Bytes):Void;

    /**
        Flushes any buffered data.
    **/
    function flush():Void;

    /**
        Closes the writer.
    **/
    function close():Void;
}

/**
    Meta information about an asset.
**/
class AssetMeta {
    /** Settings used when loading this asset **/
    public var settings:Dynamic;

    /** Hash of the asset content **/
    public var hash:String;

    /** Loader information **/
    public var loader:String;

    /** Dependencies of this asset **/
    public var dependencies:Array<String>;

    public function new() {
        dependencies = [];
    }
}
