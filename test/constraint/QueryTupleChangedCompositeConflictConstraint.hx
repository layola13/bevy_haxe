package constraint;

import bevy.app.SystemClass;
import bevy.ecs.All;
import bevy.ecs.Changed;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleChangedCompositeConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTupleChangedCompositeConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        tupleQuery:Query<Tuple2<TupleChangedCompositeConflictHealth, TupleChangedCompositeConflictSpeed>, Or<With<TupleChangedCompositeConflictPlayerTag>, With<TupleChangedCompositeConflictEnemyTag>>>,
        changed:Query<TupleChangedCompositeConflictHealth, All<Changed<TupleChangedCompositeConflictHealth>, Without<TupleChangedCompositeConflictPlayerTag>>>
    ):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            total += item.component._0.value + item.component._1.value;
        }
        for (item in changed.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable query conflict probe";
        }
    }
}

class TupleChangedCompositeConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleChangedCompositeConflictSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleChangedCompositeConflictPlayerTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleChangedCompositeConflictEnemyTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
