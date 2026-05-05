package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Res;
import bevy.ecs.Resource;
import bevy.ecs.World;

class WorldMixedParamConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("WorldMixedParamConstraint");
    }

    @:system("Update")
    public static function illegal(world:World, counter:Res<WorldMixedCounter>):Void {
        world.entityCount();
        counter.value.value;
    }
}

class WorldMixedCounter implements Resource {
    public var value(default, null):Int;

    public function new(?value:Int) {
        this.value = value != null ? value : 0;
    }
}
