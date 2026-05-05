package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Res;
import bevy.ecs.Resource;
import bevy.ecs.World;

class WorldMixedParamConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(world:World, counter:Res<WorldMixedCounter>):Void {
        world.entityCount();
        counter.value.value;
    }
}

class WorldMixedCounter implements Resource {
    public var value:Int = 0;

    public function new() {}
}
