package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryFilterTupleConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryFilterTupleConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        left:Query<FilterTupleConflictHealth, Tuple2<With<FilterTupleConflictPlayer>, Without<FilterTupleConflictEnemy>>>,
        right:Query<FilterTupleConflictHealth, Without<FilterTupleConflictEnemy>>
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

class FilterTupleConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class FilterTupleConflictPlayer implements Component {
    public var label:String;

    public function new(label:String) {
        this.label = label;
    }
}

class FilterTupleConflictEnemy implements Component {
    public var label:String;

    public function new(label:String) {
        this.label = label;
    }
}
