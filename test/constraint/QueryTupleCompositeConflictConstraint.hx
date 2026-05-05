package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleCompositeConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTupleCompositeConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        tupleQuery:Query<Tuple2<TupleCompositeConflictHealth, TupleCompositeConflictSpeed>, Or<With<TupleCompositeConflictPlayer>, With<TupleCompositeConflictEnemy>>>,
        single:Query<TupleCompositeConflictHealth, Without<TupleCompositeConflictPlayer>>
    ):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            total += item.component._0.value + item.component._1.value;
        }
        for (item in single.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable query conflict probe";
        }
    }
}

class TupleCompositeConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleCompositeConflictSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleCompositeConflictPlayer implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleCompositeConflictEnemy implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
