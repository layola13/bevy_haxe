package haxe.macro;

#if !macro
import haxe.ds.StringMap;

class EcsMacroRuntime {
    public static var componentTypeIds(default, null):StringMap<Int> = new StringMap();
    public static var bundleLayouts(default, null):StringMap<Array<String>> = new StringMap();
    public static var systemDescriptors(default, null):StringMap<Dynamic> = new StringMap();

    private static var _nextComponentId:Int = 1;

    public static function ensureComponentId(typePath:String):Int {
        var v = componentTypeIds.get(typePath);
        if (v != null) return v;
        var id = _nextComponentId++;
        componentTypeIds.set(typePath, id);
        return id;
    }

    public static function registerBundle(typePath:String, components:Array<String>):Void {
        bundleLayouts.set(typePath, components);
    }

    public static function registerSystem(typePath:String, descriptor:Dynamic):Void {
        systemDescriptors.set(typePath, descriptor);
    }
}
#end
