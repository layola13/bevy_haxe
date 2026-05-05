package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleGenericCompositeConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTupleGenericCompositeConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        tupleQuery:Query<Tuple<TupleGenericCompositeConflictHealth, TupleGenericCompositeConflictSpeed>, Or<With<TupleGenericCompositeConflictPlayer>, With<TupleGenericCompositeConflictEnemy>>>,
        single:Query<TupleGenericCompositeConflictHealth, Without<TupleGenericCompositeConflictPlayer>>
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

class TupleGenericCompositeConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleGenericCompositeConflictSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleGenericCompositeConflictPlayer implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleGenericCompositeConflictEnemy implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
