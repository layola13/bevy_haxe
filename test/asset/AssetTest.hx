package;

import haxe.asset.*;
import haxe.utils.TypeId;

/**
    Test/example for the bevy_asset module.
**/
class AssetTest {
    public static function run():Void {
        trace("=== Asset System Test ===");

        // Test 1: Asset interface
        trace("\n--- Test 1: Asset Interface ---");
        var image = new TestImage(256, 128);
        trace('Image type: ${image.getTypeName()}');

        // Test 2: AssetId
        trace("\n--- Test 2: AssetId ---");
        var id1 = AssetId.index(1, 1);
        var id2 = AssetId.index(1, 2);
        var id3 = AssetId.index(1, 1);
        trace('id1 = $id1');
        trace('id2 = $id2');
        trace('id3 = $id3');
        trace('id1 == id3: ${id1.equals(id3)}');
        trace('id1 == id2: ${id1.equals(id2)}');
        trace('id1 < id2: ${id1.less(id2)}');

        var uuidId = AssetId.uuid("550e8400-e29b-41d4-a716-446655440000");
        trace('uuidId = $uuidId');

        // Test 3: AssetIndex and Allocator
        trace("\n--- Test 3: AssetIndex Allocator ---");
        var allocator = new AssetIndexAllocator();
        var index1 = allocator.reserve();
        var index2 = allocator.reserve();
        var index3 = allocator.reserve();
        trace('Allocated indices: $index1, $index2, $index3');

        allocator.free(index1.index);
        var reusedIndex = allocator.reserve();
        trace('Reused index: $reusedIndex');

        // Test 4: Handle
        trace("\n--- Test 4: Handle ---");
        var handle1 = new Handle<TestImage>(id1, Strong);
        var handle2 = handle1.clone();
        var weakHandle = new Handle<TestImage>(id1, Weak);

        trace('handle1 ref count: ${handle1.getRefCount()}');
        trace('handle2 ref count: ${handle2.getRefCount()}');
        trace('handle1 is strong: ${handle1.isStrong()}');
        trace('weakHandle is weak: ${weakHandle.isWeak()}');

        // Test 5: HandleUntyped
        trace("\n--- Test 5: HandleUntyped ---");
        var typeId = TypeId.ofClass(TestImage);
        var untypedId:UntypedAssetId = {
            typeId: typeId,
            index: 1,
            generation: 1
        };
        var untypedHandle = new HandleUntyped(untypedId, Strong);
        trace('untypedHandle: $untypedHandle');

        // Test 6: AssetServer
        trace("\n--- Test 6: AssetServer ---");
        var server = new AssetServer();

        server.initAsset(TestImage);
        var imageHandle = server.add(image);
        trace('Added image with handle: $imageHandle');

        var loadedImage = server.get(imageHandle);
        trace('Retrieved image: ${loadedImage != null ? "success" : "failed"}');

        var isLoaded = server.isLoaded(imageHandle);
        trace('Is loaded: $isLoaded');

        var count = server.assetCount();
        trace('Asset count: $count');

        // Test 7: AssetPath
        trace("\n--- Test 7: AssetPath ---");
        var path1 = AssetPath.parse("textures/player.png");
        trace('Parsed path: $path1');
        trace('  source: ${path1.source}');
        trace('  path: ${path1.path}');
        trace('  extension: ${path1.extension}');
        trace('  fileName: ${path1.fileName}');

        var path2 = AssetPath.parse("assets://sprites/hero.png#idle");
        trace('Parsed path with source/label: $path2');
        trace('  source: ${path2.source}');
        trace('  path: ${path2.path}');
        trace('  label: ${path2.label}');

        // Test 8: AssetEvent
        trace("\n--- Test 8: AssetEvent ---");
        var listener = function(event:AssetEvent) {
            switch (event) {
                case Added(typeId, id):
                    trace('  Event: Added ${typeId.typeName}');
                case Loaded(typeId, id):
                    trace('  Event: Loaded ${typeId.typeName}');
                case Failed(typeId, id):
                    trace('  Event: Failed ${typeId.typeName}');
                case Modified(typeId, id):
                    trace('  Event: Modified ${typeId.typeName}');
                case Removed(typeId, id):
                    trace('  Event: Removed ${typeId.typeName}');
            }
        };
        server.listen(listener);

        // Trigger an event
        server.add(new TestImage(100, 100));

        // Test 9: LoadState
        trace("\n--- Test 9: LoadState ---");
        var loadInfo = new AssetLoadInfo();
        trace('Initial state: $loadInfo.loadState');
        loadInfo.loadState = Loading;
        trace('After loading: $loadInfo.loadState');
        trace('isLoaded: ${loadInfo.isLoaded()}');

        // Test 10: Diagnostics
        trace("\n--- Test 10: Diagnostics ---");
        var diagnostics = server.getDiagnostics();
        trace('Diagnostics: $diagnostics');

        trace("\n=== All Tests Complete ===");
    }
}

/**
    Test asset class for testing.
**/
class TestImage implements Asset {
    public var width:Int;
    public var height:Int;
    public var data:Dynamic;

    public function new(width:Int, height:Int) {
        this.width = width;
        this.height = height;
    }

    public function getTypeName():String {
        return Type.getClassName(TestImage);
    }
}

/**
    Main entry point to run tests.
**/
class Main {
    public static function main():Void {
        AssetTest.run();
    }
}
