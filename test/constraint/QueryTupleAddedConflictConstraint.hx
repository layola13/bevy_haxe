package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Added;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;

class QueryTupleAddedConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTupleAddedConflictConstraint");
    }

    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple2<TupleAddedConflictPosition, TupleAddedConflictVelocity>, Added<TupleAddedConflictPosition>>, single:Query<TupleAddedConflictPosition>):Void {
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

class TupleAddedConflictPosition implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleAddedConflictVelocity implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
