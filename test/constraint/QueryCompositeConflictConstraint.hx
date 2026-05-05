package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryCompositeConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryCompositeConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        left:Query<CompositeConflictHealth, Or<With<CompositeConflictPlayer>, With<CompositeConflictEnemy>>>,
        right:Query<CompositeConflictHealth, Without<CompositeConflictPlayer>>
    ):Void {
        var total = 0;
        for (item in left.iter()) {
            total += item.component.value;
        }
        for (item in right.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable query conflict probe";
        }
    }
}

class CompositeConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class CompositeConflictPlayer implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class CompositeConflictEnemy implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
