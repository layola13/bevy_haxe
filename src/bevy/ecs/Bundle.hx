package bevy.ecs;

@:autoBuild(bevy.macro.BundleMacro.build())
interface Bundle {
    function toBundle():Array<Dynamic>;
}
