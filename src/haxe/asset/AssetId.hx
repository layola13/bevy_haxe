package haxe.asset;

import haxe.utils.TypeId;

/**
    A generational runtime-only identifier for a specific asset stored in `Assets<T>`.
    This is optimized for efficient runtime usage and is not suitable for
    identifying assets across app runs.
**/
@:forward
abstract AssetIndex(Int) from Int to Int {
    inline function new(i:Int) {
        this = i;
    }

    /**
        The index value (lower 32 bits).
    **/
    public var index(get, never):Int;
    private inline function get_index():Int return this & 0xFFFFFFFF;

    /**
        The generation value (upper 32 bits).
    **/
    public var generation(get, never):Int;
    private inline function get_generation():Int return (this >> 32) & 0xFFFFFFFF;

    /**
        Creates an AssetIndex from separate index and generation values.
    **/
    public static inline function create(index:Int, generation:Int):AssetIndex {
        return ((generation : UInt) << 32) | (index : UInt);
    }

    /**
        Creates an AssetIndex with generation 0.
    **/
    public static inline function fromIndex(index:Int):AssetIndex {
        return index;
    }

    public function toString():String {
        return 'AssetIndex(${index}, gen=${generation})';
    }

    @:op(A == B)
    static function equals(a:AssetIndex, b:AssetIndex):Bool;

    @:op(A != B)
    static function notEquals(a:AssetIndex, b:AssetIndex):Bool;

    @:op(A < B)
    static function less(a:AssetIndex, b:AssetIndex):Bool;

    @:op(A > B)
    static function greater(a:AssetIndex, b:AssetIndex):Bool;
}

/**
    Allocates generational AssetIndex values and facilitates the freeing of asset indices.
**/
class AssetIndexAllocator {
    private var _freeIndices:Array<Int>;
    private var _nextIndex:Int;
    private var _generations:Map<Int, UInt>;

    public function new() {
        _freeIndices = [];
        _nextIndex = 1; // Start at 1, 0 is typically invalid
        _generations = new Map();
    }

    /**
        Reserves a new index, returning the AssetIndex.
    **/
    public function reserve():AssetIndex {
        var index:Int;
        if (_freeIndices.length > 0) {
            index = _freeIndices.pop();
        } else {
            index = _nextIndex++;
        }
        var gen = _getNextGeneration(index);
        return AssetIndex.create(index, gen);
    }

    /**
        Frees an index, allowing it to be reused.
    **/
    public function free(index:Int):Void {
        _freeIndices.push(index);
    }

    private function _getNextGeneration(index:Int):Int {
        var gen = _generations.exists(index) ? _generations.get(index)! + 1 : 1;
        _generations.set(index, gen);
        return gen;
    }

    /**
        Gets the current generation for an index.
    **/
    public function getGeneration(index:Int):Int {
        return _generations.exists(index) ? _generations.get(index)! : 0;
    }

    /**
        Validates if a generation matches the expected generation.
    **/
    public function isValidGeneration(index:Int, generation:Int):Bool {
        return getGeneration(index) == generation;
    }
}

/**
    A unique runtime-only identifier for an Asset.
    This is cheap to copy and clone and is not directly tied to the
    lifetime of the Asset. This means it can point to an Asset that no longer exists.

    For an identifier tied to the lifetime of an asset, see `Handle<T>`.
**/
class AssetId {
    /** The asset index within the Assets<T> collection **/
    public var index(default, null):Int;

    /** The generation counter for this asset index **/
    public var generation(default, null):Int;

    /** The type UUID if using UUID-based identification **/
    public var uuid(default, null):String;

    /** Whether this is a UUID-based ID **/
    public var isUuid(default, null):Bool;

    private function new() {
        this.index = 0;
        this.generation = 0;
        this.uuid = null;
        this.isUuid = false;
    }

    /**
        Creates an index-based AssetId.
    **/
    public static function index(index:Int, generation:Int):AssetId {
        var id = new AssetId();
        id.index = index;
        id.generation = generation;
        id.isUuid = false;
        return id;
    }

    /**
        Creates a UUID-based AssetId.
    **/
    public static function uuid(uuid:String):AssetId {
        var id = new AssetId();
        id.uuid = uuid;
        id.isUuid = true;
        return id;
    }

    /**
        The default AssetId UUID constant.
    **/
    public static var DEFAULT_UUID(default, never):String = "00000000-0000-0000-0000-000000000002";

    @:op(A == B)
    public function equals(other:AssetId):Bool {
        if (other == null) return false;
        if (isUuid && other.isUuid) {
            return uuid == other.uuid;
        } else if (!isUuid && !other.isUuid) {
            return index == other.index && generation == other.generation;
        }
        return false;
    }

    @:op(A != B)
    public function notEquals(other:AssetId):Bool {
        return !equals(other);
    }

    @:op(A < B)
    public function less(other:AssetId):Bool {
        if (isUuid && other.isUuid) {
            return uuid < other.uuid;
        } else if (!isUuid && !other.isUuid) {
            return index < other.index || (index == other.index && generation < other.generation);
        }
        return !isUuid; // Index-based IDs are "less than" UUID-based
    }

    public function hashCode():Int {
        if (isUuid) {
            return uuid.hashCode();
        }
        return index ^ (generation * 31);
    }

    public function toString():String {
        if (isUuid) {
            return 'AssetId(Uuid: $uuid)';
        }
        return 'AssetId($index:gen=$generation)';
    }

    /**
        Check if this is a default/uninitialized ID.
    **/
    public function isDefault():Bool {
        return !isUuid && index == 0 && generation == 0;
    }
}

/**
    An untyped asset ID that includes type information.
    Used when the asset type is not known at compile time.
**/
class UntypedAssetId {
    /** The type identifier for this asset **/
    public var typeId(default, null):TypeId;

    /** The asset index within the Assets<T> collection **/
    public var index(default, null):Int;

    /** The generation counter for this asset index **/
    public var generation(default, null):Int;

    /** The type UUID if using UUID-based identification **/
    public var uuid(default, null):String;

    /** Whether this is a UUID-based ID **/
    public var isUuid(default, null):Bool;

    private function new() {
        this.typeId = null;
        this.index = 0;
        this.generation = 0;
        this.uuid = null;
        this.isUuid = false;
    }

    /**
        Creates an untyped index-based AssetId.
    **/
    public static function index(typeId:TypeId, index:Int, generation:Int):UntypedAssetId {
        var id = new UntypedAssetId();
        id.typeId = typeId;
        id.index = index;
        id.generation = generation;
        id.isUuid = false;
        return id;
    }

    /**
        Creates an untyped UUID-based AssetId.
    **/
    public static function uuid(typeId:TypeId, uuid:String):UntypedAssetId {
        var id = new UntypedAssetId();
        id.typeId = typeId;
        id.uuid = uuid;
        id.isUuid = true;
        return id;
    }

    @:op(A == B)
    public function equals(other:UntypedAssetId):Bool {
        if (other == null) return false;
        if (!typeId.equals(other.typeId)) return false;
        if (isUuid && other.isUuid) {
            return uuid == other.uuid;
        } else if (!isUuid && !other.isUuid) {
            return index == other.index && generation == other.generation;
        }
        return false;
    }

    @:op(A != B)
    public function notEquals(other:UntypedAssetId):Bool {
        return !equals(other);
    }

    @:op(A < B)
    public function less(other:UntypedAssetId):Bool {
        // First compare by type
        if (!typeId.equals(other.typeId)) {
            return typeId.id < other.typeId.id;
        }
        // Same type, compare by ID
        if (isUuid && other.isUuid) {
            return uuid < other.uuid;
        } else if (!isUuid && !other.isUuid) {
            return index < other.index || (index == other.index && generation < other.generation);
        }
        return !isUuid;
    }

    public function hashCode():Int {
        var h = typeId.hashCode();
        if (isUuid) {
            h ^= uuid.hashCode();
        } else {
            h ^= index ^ (generation * 31);
        }
        return h;
    }

    public function toString():String {
        var typeName = typeId != null ? typeId.typeName : "Unknown";
        if (isUuid) {
            return 'UntypedAssetId($typeName, Uuid: $uuid)';
        }
        return 'UntypedAssetId($typeName, $index:gen=$generation)';
    }

    /**
        Converts to a typed AssetId if possible.
    **/
    public function toTyped<T:(Asset)>():AssetId {
        if (isUuid) {
            return AssetId.uuid(uuid);
        }
        return AssetId.index(index, generation);
    }
}
