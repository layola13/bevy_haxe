package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Added;
import bevy.ecs.All;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleAddedCompositeConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTupleAddedCompositeConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        tupleQuery:Query<Tuple2<TupleAddedCompositeConflictHealth, TupleAddedCompositeConflictSpeed>, Or<With<TupleAddedCompositeConflictPlayerTag>, With<TupleAddedCompositeConflictEnemyTag>>>,
        added:Query<TupleAddedCompositeConflictHealth, All<Added<TupleAddedCompositeConflictHealth>, Without<TupleAddedCompositeConflictPlayerTag>>>
    ):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            total += item.component._0.value + item.component._1.value;
        }
        for (item in added.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable query conflict probe";
        }
    }
}

class TupleAddedCompositeConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleAddedCompositeConflictSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleAddedCompositeConflictPlayerTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleAddedCompositeConflictEnemyTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
