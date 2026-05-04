package haxe.asset;

/**
    Marker interface for asset types in Bevy.

    Assets are pieces of content that are loaded from disk and displayed in the game.
    Typically, these are authored by artists and designers, are relatively large in size,
    and include textures, models, sounds, music, levels, and scripts.

    Assets should implement this interface to be recognized by the asset system.
    They are typically stored in `Assets<T>` collections and accessed via `Handle<T>` references.

    Example usage:
    ```haxe
    class Image implements Asset {
        public var width:Int;
        public var height:Int;
        public var data:Dynamic; // Actual image data

        public function new(width:Int, height:Int) {
            this.width = width;
            this.height = height;
        }
    }
    ```
**/
interface Asset {
    /**
        Returns the type name for this asset type.
        Used for reflection and identification.
    **/
    function getTypeName():String;
}

/**
    Default implementation helper for Asset interface.
    Extend this class for simple asset types that don't need custom logic.
**/
class AssetDefault implements Asset {
    public function new() {}

    public function getTypeName():String {
        return Type.getClassName(Type.getClass(this));
    }
}
