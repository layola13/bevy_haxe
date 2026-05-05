package constraint;

import bevy.app.SystemClass;
import bevy.ecs.ResMut;
import bevy.ecs.Resource;

class DuplicateResMutConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(first:ResMut<MutableCounter>, second:ResMut<MutableCounter>):Void {
        first.value.value++;
        second.value.value++;
    }
}

class MutableCounter implements Resource {
    public var value:Int = 0;

    public function new() {}
}
