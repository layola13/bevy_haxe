# Bevy Asset Module Improvement Plan

## 1. Overview

Improve the `bevy_asset` Haxe module with a web-oriented simplified implementation, based on the Rust `bevy_asset` crate.

### Goals
- Enhance `Asset.hx` - Add metadata support and asset lifecycle methods
- Enhance `AssetId.hx` - Improve UUID handling and comparison operators
- Enhance `Handle.hx` - Add handle provider pattern and improve reference counting
- Add `AssetServer.hx` - Complete asset loading and tracking system
- Add `AssetLoader.hx` - Asset loader interface with async support
- Add `AssetPath.hx` - Enhanced asset path parsing with label/source support

### Scope Boundaries
**Included:**
- All 6 files mentioned above
- Async loading patterns suitable for web
- Asset event system
- Asset source management

**Excluded:**
- Processor/pipeline support (not applicable for web)
- File watching (browser limitation)
- Low-level IO implementation

---

## 2. Prerequisites

### Dependencies
- `haxe.ds.Map` - Already available
- `haxe.io.Bytes` - For asset data
- `haxe.Timer` or Promise-based async - For web-compatible async
- Existing modules: `haxe.utils.TypeId`, `haxe.ecs.Resource`

### Environment
- Haxe 4.x+ with haxe.ds support
- Working directory: `/home/vscode/projects/bevy_haxe`

---

## 3. Implementation Steps

### Step 1: Enhance Asset.hx
**Description:** Add metadata support and asset lifecycle methods to the Asset interface.

**Files to modify:** `src/haxe/asset/Asset.hx`

**Key changes:**
```haxe
interface Asset {
    // Existing method
    function getTypeName():String;
    
    // New methods for asset lifecycle
    function getMeta():AssetMeta;
    function setMeta(meta:AssetMeta):Void;
    
    // Clone support
    function clone():Asset;
}
```

**Implementation details:**
- Add `AssetMeta` class with hash, loader info, dependencies
- Add default implementations via `AssetDefault` class
- Add asset lifecycle event support

---

### Step 2: Enhance AssetId.hx
**Description:** Improve AssetId with better UUID handling, validation, and comparison.

**Files to modify:** `src/haxe/asset/AssetId.hx`

**Key changes:**
```haxe
@:enum abstract AssetIdVariant(Int) {
    var Index = 0;
    var Uuid = 1;
}

class AssetId<A:Asset> {
    // Variant type for distinguishing Index vs Uuid
    public var variant(default, default):AssetIdVariant;
    
    // Validation
    public static function isValidUuid(uuid:String):Bool;
    
    // Default UUID constant
    public static var DEFAULT_UUID:String = "00000000-0000-0002-0000-000000000000";
}
```

**Implementation details:**
- Add variant tracking (Index vs Uuid)
- Add UUID validation helper
- Add `DEFAULT_UUID` constant
- Improve `toUntyped()` conversion

---

### Step 3: Enhance Handle.hx
**Description:** Add AssetHandleProvider pattern, improve reference counting, add reflection support.

**Files to modify:** `src/haxe/asset/Handle.hx`

**Key changes:**
```haxe
class AssetHandleProvider {
    public var typeId:TypeId;
    public var allocator:AssetIndexAllocator;
    
    public function reserve():UntypedHandle;
    public function getHandle(index:Int, managed:Bool):HandleUntyped;
}

class Handle<T:Asset> {
    // Add isValid() method
    // Add getPath() for asset source path
    // Reflection support methods
}
```

**Implementation details:**
- Extract `AssetHandleProvider` from existing Handle code
- Add `isValid()` validation
- Add `StrongHandle` and `WeakHandle` factory methods
- Improve clone semantics

---

### Step 4: Complete AssetServer.hx
**Description:** Finish implementing the AssetServer with async loading, source management, and diagnostics.

**Files to modify:** `src/haxe/asset/AssetServer.hx`

**Key additions:**
```haxe
class AssetServer implements Resource {
    // Asset sources management
    public function getSource(source:AssetSourceId):AssetSource;
    
    // Async loading
    public function loadAsync<T:Asset>(path:String):Promise<Handle<T>>;
    
    // Asset tracking
    public function getLoadState(id:UntypedAssetId):LoadState;
    public function getAsset<T:Asset>(id:AssetId<T>):T;
    
    // Source management
    public function registerSource(source:AssetSourceId, source:AssetSource):Void;
}
```

**Implementation details:**
- Add source management with `AssetSource`
- Complete async loading pipeline using Promise-based approach
- Add asset lifetime tracking
- Implement diagnostics methods

---

### Step 5: Complete AssetLoader.hx
**Description:** Complete the AssetLoader interface with async support, LoadContext, and error handling.

**Files to modify:** `src/haxe/asset/AssetLoader.hx`

**Key additions:**
```haxe
interface AssetLoader {
    var extensions(get, never):Array<String>;
    var assetType(get, never):Class<Dynamic>;
    var settingsType(get, never):Class<Dynamic>;
    
    function load(reader:AssetReader, settings:Dynamic, context:LoadContext):Dynamic;
    function loadAsync(reader:AssetReader, settings:Dynamic, context:LoadContext):Promise<Dynamic>;
}

class LoadContext {
    public var path:AssetPath;
    public var meta:AssetMeta;
    
    public function load<T:Asset>(path:String):Handle<T>;
    public function readBytes():haxe.io.Bytes;
}
```

**Implementation details:**
- Add `LoadContext` class with path/meta access
- Add `AssetReader` interface for byte reading
- Add common error types
- Implement `BytesLoader` base class

---

### Step 6: Complete AssetPath.hx
**Description:** Enhance path parsing with full extension support, path resolution, and typed paths.

**Files to modify:** `src/haxe/asset/AssetPath.hx`

**Key additions:**
```haxe
class AssetPath {
    // Existing: fullPath, source, path, label, extension, fileName
    
    // New properties
    public var fullExtension(get, never):String;  // e.g., "tar.gz"
    public var parent(get, never):AssetPath;
    public var fileStem(get, never):String;      // filename without extension
    
    // New methods
    public function resolve(relative:AssetPath):AssetPath;
    public function withSource(source:String):AssetPath;
    public function withLabel(label:String):AssetPath;
    
    // Static helpers
    public static function parse(path:String):AssetPath;
    public static function from(path:String):AssetPath;
}
```

**Implementation details:**
- Add `getFullExtension()` for compound extensions
- Add `parent` property for path hierarchy
- Add `fileStem` for filename without extension
- Add `resolve()` for relative path resolution
- Add fluent `with*()` methods

---

## 4. File Changes Summary

### Created Files
- None (all files already exist)

### Modified Files
| File | Changes |
|------|---------|
| `src/haxe/asset/Asset.hx` | Add metadata support, clone method, lifecycle methods |
| `src/haxe/asset/AssetId.hx` | Add variant tracking, UUID validation, DEFAULT_UUID |
| `src/haxe/asset/Handle.hx` | Add AssetHandleProvider, isValid, factory methods |
| `src/haxe/asset/AssetServer.hx` | Complete async loading, source management, diagnostics |
| `src/haxe/asset/AssetLoader.hx` | Complete LoadContext, error types, BytesLoader |
| `src/haxe/asset/AssetPath.hx` | Add full extension, parent, resolve, with* methods |

### Deleted Files
- None

---

## 5. Testing Strategy

### Unit Tests
1. **Asset tests:**
   - Test metadata get/set
   - Test clone produces independent copy

2. **AssetId tests:**
   - Test Index vs Uuid variant
   - Test UUID validation
   - Test DEFAULT_UUID format
   - Test comparison operators

3. **Handle tests:**
   - Test reference counting
   - Test Strong/Weak conversion
   - Test HandleProvider reserve/getHandle

4. **AssetServer tests:**
   - Test sync loading
   - Test async loading with Promise
   - Test source registration
   - Test diagnostics

5. **AssetPath tests:**
   - Test parse with various formats
   - Test resolve (relative paths)
   - Test full extension parsing
   - Test withSource/withLabel

### Manual Testing
1. Create test assets directory with sample files
2. Load assets and verify handles work
3. Test async loading with progress callbacks
4. Verify path parsing in browser context

---

## 6. Rollback Plan

**Revert procedure:**
1. If version control available: `git checkout HEAD -- src/haxe/asset/`
2. Manual revert: Restore from backup copies
3. No database migrations needed (pure Haxe code)

**No data migration required** - This is a code-only change.

---

## 7. Estimated Effort

| Component | Complexity | Time Estimate |
|-----------|------------|--------------|
| Asset.hx | Low | 30 minutes |
| AssetId.hx | Medium | 45 minutes |
| Handle.hx | Medium | 60 minutes |
| AssetServer.hx | High | 90 minutes |
| AssetLoader.hx | Medium | 60 minutes |
| AssetPath.hx | Medium | 45 minutes |

**Total:** ~5.5 hours (medium-high complexity)

---

## 8. Implementation Order

1. **Asset.hx** - Foundation, minimal dependencies
2. **AssetId.hx** - Foundation, uses Asset
3. **AssetPath.hx** - Utility, no dependencies
4. **Handle.hx** - Uses AssetId, Asset
5. **AssetLoader.hx** - Uses AssetPath
6. **AssetServer.hx** - Uses all other modules
