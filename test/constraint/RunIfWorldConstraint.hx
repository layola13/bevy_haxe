package constraint;

import bevy.app.SystemClass;
import bevy.ecs.World;

class RunIfWorldConstraint implements SystemClass {
    @:system("Update")
    @:runIf("constraint.RunIfWorldConditions.illegal")
    public static function system():Void {}
}

class RunIfWorldConditions {
    public static function illegal(world:World):Bool {
        return world.entityCount() > 0;
    }
}
