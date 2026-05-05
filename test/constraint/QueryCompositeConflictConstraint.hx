package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryCompositeConflictConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(
        left:Query<CompositeConflictHealth, Or<With<CompositeConflictPlayer>, With<CompositeConflictEnemy>>>,
        right:Query<CompositeConflictHealth, Without<CompositeConflictPlayer>>
    ):Void {
        left.toArray();
        right.toArray();
    }
}

class CompositeConflictHealth implements Component {
    public function new() {}
}

class CompositeConflictPlayer implements Component {
    public function new() {}
}

class CompositeConflictEnemy implements Component {
    public function new() {}
}
