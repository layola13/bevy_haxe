package haxe.asset;

import haxe.utils.TypeId;
import haxe.ecs.Resource;

/**
    Asset loading states.
**/
enum LoadState {
    /** Asset is not yet loaded **/
    NotLoaded;
    /** Asset is currently loading **/
    Loading;
    /** Asset is loaded and ready to use **/
    Loaded;
    /** Asset failed to load **/
    Failed;
}

/**
    Load information for an asset, including its state and dependencies.
**/
class AssetLoadInfo {
    public var loadState(default, default):LoadState;
    public var dependencies:Array<UntypedAssetId>;
    public var loadedDependents:Array<UntypedAssetId>;

    public function new() {
        loadState = NotLoaded;
        dependencies = [];
        loadedDependents = [];
    }

    public function isLoaded():Bool {
        return loadState == Loaded;
    }

    public function isFailed():Bool {
        return loadState == Failed;
    }
}

/**
    AssetServer manages the loading and tracking of assets.

    The AssetServer is the main entry point for loading assets. Typically,
    you'll use the `load` method to load an asset from disk, which returns a `Handle<T>`.
    Note that this method does not attempt to reload the asset if it has already been loaded:
    as long as at least one handle has not been dropped, calling `load` on the same path
    will return the same handle.

    The handle that's returned can be used to instantiate various Components that require
    asset data to function, which will then be spawned into the world as part of an entity.

    Implements the `Resource` interface to be stored in the ECS World.
**/
@:keep
class AssetServer implements Resource {
    /** Asset collections by type ID **/
    private var _assets:Map<TypeId, Map<Int, Dynamic>>;

    /** Asset load information by untyped ID **/
    private var _loadInfo:Map<String, AssetLoadInfo>;

    /** Handle providers by type ID **/
    private var _handleProviders:Map<TypeId, HandleProvider>;

    /** Index allocator **/
    private var _allocator:AssetIndexAllocator;

    /** Registered asset loaders by extension **/
    private var _loaders:Map<String, AssetLoader>;

    /** Asset sources/configuration **/
    private var _assetSources:Map<String, String>;

    /** Path to handle mappings for deduplication **/
    private var _pathToId:Map<String, UntypedAssetId>;

    /** Pending async loads **/
    private var _pendingLoads:Array<AsyncLoad>;

    /** Asset event listeners **/
    private var _eventListeners:Array<AssetEvent -> Void>;

    public function new() {
        _assets = new Map();
        _loadInfo = new Map();
        _handleProviders = new Map();
        _allocator = new AssetIndexAllocator();
        _loaders = new Map();
        _assetSources = new Map();
        _pathToId = new Map();
        _pendingLoads = [];
        _eventListeners = [];

        // Register default loaders
        _registerDefaultLoaders();
    }

    /**
        Creates a default instance for Resource interface.
    **/
    public static function createDefault():Resource {
        return new AssetServer();
    }

    private function _registerDefaultLoaders():Void {
        // Default loaders will be registered here
        // They can be extended via the plugin system
    }

    /**
        Initializes an asset type for use with the AssetServer.
        Must be called before loading assets of type T.
    **/
    public function initAsset<T:(Asset)>(assetClass:Class<T>):Void {
        var typeId = TypeId.ofClass(assetClass);
        if (!_assets.exists(typeId)) {
            _assets.set(typeId, new Map());
        }
        if (!_handleProviders.exists(typeId)) {
            var typeName = Type.getClassName(assetClass);
            var provider = new HandleProvider(typeId, typeName, _allocator);
            _handleProviders.set(typeId, provider);
        }
    }

    /**
        Loads an asset from the given path.
        Returns a Handle that can be used to access the asset once loaded.
    **/
    public function load<T:(Asset)>(path:String):Handle<T> {
        initAsset(T);
        var assetPath = AssetPath.parse(path);

        // Check if already loaded
        var typeId = TypeId.ofClass(T);
        if (_pathToId.exists(assetPath.fullPath)) {
            var existingId = _pathToId.get(assetPath.fullPath);
            return _createHandle(typeId, existingId.index, existingId.generation);
        }

        // Get or create asset ID
        var provider = _handleProviders.get(typeId);
        var index = _allocator.reserve();
        var id:UntypedAssetId = {
            typeId: typeId,
            index: index.index,
            generation: index.generation
        };

        // Track path for deduplication
        _pathToId.set(assetPath.fullPath, id);

        // Create load info
        var loadInfo = new AssetLoadInfo();
        loadInfo.loadState = Loading;
        _loadInfo.set(_getLoadKey(typeId, id.index), loadInfo);

        // Queue async load
        _queueLoad(path, assetPath, typeId, id);

        return _createHandle(typeId, id.index, id.generation);
    }

    /**
        Loads an asset asynchronously.
    **/
    private function _queueLoad(path:String, assetPath:AssetPath, typeId:TypeId, id:UntypedAssetId):Void {
        var loader = _getLoaderForPath(path);
        var load:AsyncLoad = {
            path: path,
            assetPath: assetPath,
            typeId: typeId,
            id: id,
            loader: loader,
            state: LoadState.Loading
        };
        _pendingLoads.push(load);

        // In a real implementation, this would spawn an async task
        // For now, simulate immediate loading for demonstration
        _processLoad(load);
    }

    private function _processLoad(load:AsyncLoad):Void {
        try {
            // Find loader for file extension
            var ext = load.assetPath.extension;
            var loader = _loaders.get(ext);

            if (loader != null) {
                // Simulate asset loading
                var asset = loader.loadSync(load.path);
                if (asset != null) {
                    _assets.get(load.typeId).set(load.id.index, asset);
                    _updateLoadState(load.typeId, load.id.index, LoadState.Loaded);
                    _emitEvent(AssetEvent.Loaded(load.typeId, load.id));
                }
            } else {
                _updateLoadState(load.typeId, load.id.index, LoadState.Failed);
                _emitEvent(AssetEvent.Failed(load.typeId, load.id));
            }
        } catch (e:Dynamic) {
            _updateLoadState(load.typeId, load.id.index, LoadState.Failed);
            _emitEvent(AssetEvent.Failed(load.typeId, load.id));
        }
    }

    private function _getLoaderForPath(path:String):AssetLoader {
        var ext = path.split('.').pop().toLowerCase();
        return _loaders.get(ext);
    }

    /**
        Registers an asset loader for a file extension.
    **/
    public function registerLoader<T:(Asset)>(extension:String, loader:AssetLoader):Void {
        _loaders.set(extension.toLowerCase(), loader);
    }

    private function _createHandle<T:(Asset)>(typeId:TypeId, index:Int, generation:Int):Handle<T> {
        var id = AssetId.index(index, generation);
        return new Handle<T>(id, Strong);
    }

    private function _getLoadKey(typeId:TypeId, index:Int):String {
        return '${typeId.id}_$index';
    }

    private function _updateLoadState(typeId:TypeId, index:Int, state:LoadState):Void {
        var key = _getLoadKey(typeId, index);
        if (_loadInfo.exists(key)) {
            _loadInfo.get(key).loadState = state;
        }
    }

    /**
        Retrieves the load state for an asset.
    **/
    public function getLoadState(id:UntypedAssetId):LoadState {
        var key = _getLoadKey(id.typeId, id.index);
        if (_loadInfo.exists(key)) {
            return _loadInfo.get(key).loadState;
        }
        return NotLoaded;
    }

    /**
        Gets load information for an asset.
    **/
    public function getLoadInfo(id:UntypedAssetId):AssetLoadInfo {
        var key = _getLoadKey(id.typeId, id.index);
        return _loadInfo.exists(key) ? _loadInfo.get(key) : null;
    }

    /**
        Gets the asset for a handle, if it's loaded.
    **/
    public function get<T:(Asset)>(handle:Handle<T>):T {
        var typeId = TypeId.ofClass(T);
        if (_assets.exists(typeId)) {
            var assets = _assets.get(typeId);
            if (assets.exists(handle.id.index)) {
                return assets.get(handle.id.index);
            }
        }
        return null;
    }

    /**
        Checks if an asset is loaded.
    **/
    public function isLoaded<T:(Asset)>(handle:Handle<T>):Bool {
        return getLoadState(handle.getUntypedId()) == Loaded;
    }

    /**
        Gets the asset count for a type.
    **/
    public function assetCount<T:(Asset)>():Int {
        var typeId = TypeId.ofClass(T);
        if (_assets.exists(typeId)) {
            return _assets.get(typeId).size();
        }
        return 0;
    }

    /**
        Adds an asset directly (without loading from file).
    **/
    public function add<T:(Asset)>(asset:T):Handle<T> {
        initAsset(T);
        var typeId = TypeId.ofClass(T);
        var index = _allocator.reserve();

        _assets.get(typeId).set(index.index, asset);

        // Create load info
        var loadInfo = new AssetLoadInfo();
        loadInfo.loadState = Loaded;
        var id:UntypedAssetId = {
            typeId: typeId,
            index: index.index,
            generation: index.generation
        };
        _loadInfo.set(_getLoadKey(typeId, index.index), loadInfo);

        _emitEvent(AssetEvent.Added(typeId, id));

        return _createHandle(typeId, index.index, index.generation);
    }

    /**
        Removes an asset by handle.
    **/
    public function remove<T:(Asset)>(handle:Handle<T>):Void {
        var typeId = TypeId.ofClass(T);
        if (_assets.exists(typeId)) {
            var id = handle.getUntypedId();
            _assets.get(typeId).remove(id.index);
            _emitEvent(AssetEvent.Removed(typeId, id));
        }
    }

    /**
        Registers an event listener for asset events.
    **/
    public function listen(listener:AssetEvent -> Void):Void {
        _eventListeners.push(listener);
    }

    /**
        Removes an event listener.
    **/
    public function unlisten(listener:AssetEvent -> Void):Void {
        _eventListeners.remove(listener);
    }

    private function _emitEvent(event:AssetEvent):Void {
        for (listener in _eventListeners) {
            listener(event);
        }
    }

    /**
        Gets all loaded asset IDs for a type.
    **/
    public function getLoadedIds<T:(Asset)>():Array<AssetId> {
        var typeId = TypeId.ofClass(T);
        var result:Array<AssetId> = [];
        if (_assets.exists(typeId)) {
            for (index in _assets.get(typeId).keys()) {
                var gen = _allocator.getGeneration(index);
                result.push(AssetId.index(index, gen));
            }
        }
        return result;
    }

    /**
        Processes any pending asset operations.
        Should be called each frame.
    **/
    public function process():Void {
        // Process pending loads
        var completed:Array<Int> = [];
        for (i in 0..._pendingLoads.length) {
            var load = _pendingLoads[i];
            if (load.state == Loaded || load.state == Failed) {
                completed.push(i);
            }
        }

        // Remove completed loads (reverse order to maintain indices)
        for (i in 0...completed.length) {
            _pendingLoads.splice(completed.length - 1 - i, 1);
        }
    }

    /**
        Creates a weak handle from a strong handle.
    **/
    public function makeWeak<T:(Asset)>(handle:Handle<T>):Handle<T> {
        return new Handle<T>(handle.id, Weak);
    }

    /**
        Forces an asset to reload from disk.
    **/
    public function reload<T:(Asset)>(handle:Handle<T>):Void {
        var typeId = TypeId.ofClass(T);
        var id = handle.getUntypedId();

        // Remove existing asset
        if (_assets.exists(typeId)) {
            _assets.get(typeId).remove(id.index);
        }

        // Update generation for fresh load
        var newGen = _allocator.getNextGeneration(id.index);
        var newId:UntypedAssetId = {
            typeId: typeId,
            index: id.index,
            generation: newGen
        };

        // Queue reload
        _updateLoadState(typeId, id.index, Loading);
        _emitEvent(AssetEvent.Modified(typeId, newId));

        // In real implementation, would reload from source
    }

    /**
        Gets diagnostic information.
    **/
    public function getDiagnostics():AssetDiagnostics {
        var totalAssets = 0;
        for (assets in _assets) {
            totalAssets += assets.size();
        }
        return {
            totalAssets: totalAssets,
            pendingLoads: _pendingLoads.length,
            loaderCount: _loaders.size()
        };
    }
}

/**
    Represents an async load operation.
**/
private class AsyncLoad {
    public var path:String;
    public var assetPath:AssetPath;
    public var typeId:TypeId;
    public var id:UntypedAssetId;
    public var loader:AssetLoader;
    public var state:LoadState;
}

/**
    Diagnostic information about the asset server.
**/
class AssetDiagnostics {
    public var totalAssets:Int;
    public var pendingLoads:Int;
    public var loaderCount:Int;

    public function toString():String {
        return 'AssetDiagnostics { total: $totalAssets, pending: $pendingLoads, loaders: $loaderCount }';
    }
}
