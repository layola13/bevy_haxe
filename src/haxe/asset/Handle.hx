package haxe.asset;

import haxe.utils.TypeId;

/**
    Represents a weak or strong reference to an asset.

    - Strong references keep the asset loaded in memory
    - Weak references don't prevent the asset from being unloaded
    when all strong references are dropped
**/
enum HandleKind {
    Strong;
    Weak;
}

/**
    A typed handle to an asset of type T.

    Handles serve as id-based references to entries in the `Assets<T>` collection,
    allowing them to be cheaply shared between systems, and providing a way to
    initialize objects before the required assets are loaded.

    In short: Handles are not the assets themselves, they just tell how to look them up!

    This implementation uses reference counting to track strong/weak references.
**/
@:keep
class Handle<T:(Asset)> {
    /** The unique identifier for the asset this handle points to **/
    public var id(default, null):AssetId;

    /** The kind of reference (strong or weak) **/
    public var kind(default, null):HandleKind;

    /** Reference count for strong handles **/
    private var _refCount:Int;

    /** Type ID for the asset type T **/
    private var _typeId:TypeId;

    /**
        Creates a new strong handle for the given asset ID.
    **/
    public function new(id:AssetId, ?kind:HandleKind = Strong) {
        this.id = id;
        this.kind = kind;
        this._refCount = kind == Strong ? 1 : 0;
        this._typeId = TypeId.of(T);
    }

    /**
        Returns the asset ID as an untyped ID.
    **/
    public function getUntypedId():UntypedAssetId {
        return {
            typeId: _typeId,
            index: id.index,
            generation: id.generation
        };
    }

    /**
        Returns the type ID of this handle's asset type.
    **/
    public function getTypeId():TypeId {
        return _typeId;
    }

    /**
        Checks if this is a strong handle.
    **/
    public inline function isStrong():Bool {
        return kind == Strong;
    }

    /**
        Checks if this is a weak handle.
    **/
    public inline function isWeak():Bool {
        return kind == Weak;
    }

    /**
        Returns the current reference count.
    **/
    public inline function getRefCount():Int {
        return _refCount;
    }

    /**
        Increments the reference count (for cloning).
    **/
    private function incrementRef():Void {
        _refCount++;
    }

    /**
        Decrements the reference count.
        Returns true if the reference count reached zero.
    **/
    private function decrementRef():Bool {
        _refCount--;
        return _refCount <= 0;
    }

    /**
        Clones this handle, incrementing the reference count if strong.
    **/
    public function clone():Handle<T> {
        if (isStrong()) {
            incrementRef();
        }
        var cloned = new Handle<T>(id, kind);
        return cloned;
    }

    /**
        Check if this handle points to a valid asset.
        Note: The asset may still not be loaded even if the handle is valid.
    **/
    public function isValid():Bool {
        return id.index > 0 || id.generation > 0;
    }

    /**
        Check if this handle matches another by ID and type.
    **/
    @:op(A == B)
    public function equals(other:Handle<T>):Bool {
        if (other == null) return false;
        return id == other.id && _typeId.equals(other._typeId);
    }

    public function hashCode():Int {
        return id.hashCode() ^ _typeId.hashCode();
    }

    public function toString():String {
        return 'Handle<${Type.getClassName(T)}>(${id}, ${kind})';
    }

    /**
        Internal cleanup method called when handle is dropped.
        Returns true if this was the last strong reference.
    **/
    public function onDrop():Bool {
        if (isStrong()) {
            return decrementRef();
        }
        return false;
    }
}

/**
    An untyped handle that can represent any asset type.
    Used for cases where the asset type is not known at compile time.
**/
@:keep
class HandleUntyped {
    /** The untyped asset ID **/
    public var id(default, null):UntypedAssetId;

    /** The kind of reference (strong or weak) **/
    public var kind(default, null):HandleKind;

    /** Reference count for strong handles **/
    private var _refCount:Int;

    /** Type name for debugging **/
    private var _typeName:String;

    public function new(id:UntypedAssetId, ?kind:HandleKind = Strong) {
        this.id = id;
        this.kind = kind;
        this._refCount = kind == Strong ? 1 : 0;
        this._typeName = id.typeId != null ? id.typeId.typeName : "Unknown";
    }

    public inline function isStrong():Bool return kind == Strong;
    public inline function isWeak():Bool return kind == Weak;
    public inline function getRefCount():Int return _refCount;

    private function incrementRef():Void {
        if (isStrong()) _refCount++;
    }

    private function decrementRef():Bool {
        if (isStrong()) {
            _refCount--;
            return _refCount <= 0;
        }
        return false;
    }

    public function clone():HandleUntyped {
        if (isStrong()) incrementRef();
        return new HandleUntyped(id, kind);
    }

    public function isValid():Bool {
        return id.index > 0 || id.generation > 0;
    }

    @:op(A == B)
    public function equals(other:HandleUntyped):Bool {
        if (other == null) return false;
        return id == other.id;
    }

    public function hashCode():Int {
        return id.hashCode();
    }

    public function toString():String {
        return 'HandleUntyped(${id}, ${kind})';
    }

    public function onDrop():Bool {
        if (isStrong()) return decrementRef();
        return false;
    }
}

/**
    Handle provider for creating and managing handles of a specific asset type.
    This is the equivalent of Rust's `AssetHandleProvider`.
**/
class HandleProvider {
    private var _typeId:TypeId;
    private var _typeName:String;
    private var _allocator:AssetIndexAllocator;
    private var _dropListeners:Array<DropEvent -> Void>;

    public function new(typeId:TypeId, typeName:String, allocator:AssetIndexAllocator) {
        this._typeId = typeId;
        this._typeName = typeName;
        this._allocator = allocator;
        this._dropListeners = [];
    }

    /**
        Creates a new strong handle with a freshly allocated asset ID.
    **/
    public function reserveHandle():HandleUntyped {
        var index = _allocator.reserve();
        var id:UntypedAssetId = {
            typeId: _typeId,
            index: index.index,
            generation: index.generation
        };
        return new HandleUntyped(id, Strong);
    }

    /**
        Creates a handle for an existing asset ID.
    **/
    public function getHandle(index:Int, generation:Int, managed:Bool = false):HandleUntyped {
        var id:UntypedAssetId = {
            typeId: _typeId,
            index: index,
            generation: generation
        };
        return new HandleUntyped(id, Strong);
    }

    /**
        Registers a listener for handle drop events.
    **/
    public function onDrop(listener:DropEvent -> Void):Void {
        _dropListeners.push(listener);
    }

    /**
        Called internally when a handle is dropped.
    **/
    public function notifyDropped(index:Int, managed:Bool):Void {
        var event = new DropEvent(index, managed);
        for (listener in _dropListeners) {
            listener(event);
        }
    }
}

/**
    Event fired when a handle is dropped.
**/
class DropEvent {
    public var index(default, null):Int;
    public var managed(default, null):Bool;

    public function new(index:Int, managed:Bool) {
        this.index = index;
        this.managed = managed;
    }
}
