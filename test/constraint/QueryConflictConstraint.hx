package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;

class QueryConflictConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(left:Query<ConflictPosition>, right:Query<ConflictPosition>):Void {
        left.toArray();
        right.toArray();
    }
}

class ConflictPosition implements Component {
    public function new() {}
}
