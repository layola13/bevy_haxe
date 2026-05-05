package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Res;
import bevy.ecs.ResMut;
import bevy.ecs.Resource;

class ResResMutConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("ResResMutConflictConstraint");
    }

    @:system("Update")
    public static function illegal(shared:Res<ConstraintCounter>, mutable:ResMut<ConstraintCounter>):Void {
        shared.value.value;
        mutable.value.value++;
    }
}

class ConstraintCounter implements Resource {
    public var value:Int;

    public function new(?value:Int) {
        this.value = value != null ? value : 0;
    }
}
