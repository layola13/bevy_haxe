package constraint;

import bevy.app.SystemClass;
import bevy.ecs.ResMut;
import bevy.ecs.Resource;

class DuplicateResMutConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("DuplicateResMutConstraint");
    }

    @:system("Update")
    public static function illegal(first:ResMut<MutableCounter>, second:ResMut<MutableCounter>):Void {
        first.value.value++;
        second.value.value++;
    }
}

class MutableCounter implements Resource {
    public var value:Int;

    public function new(?value:Int) {
        this.value = value != null ? value : 0;
    }
}
