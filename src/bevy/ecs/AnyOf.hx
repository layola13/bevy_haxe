package bevy.ecs;

@:genericBuild(bevy.macro.AnyOfMacro.buildAnyOf())
class AnyOf<Rest> {
    @:noCompletion
    private function new() {
        throw "AnyOf is a generic-build anchor and should resolve to a generated any-of query data class";
    }
}
