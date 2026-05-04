package bevy.reflect;

@:autoBuild(bevy.macro.ReflectMacro.build())
interface Reflect {
    function typeInfo():TypeInfo;
    function getField(name:String):Dynamic;
    function setField(name:String, value:Dynamic):Bool;
}
