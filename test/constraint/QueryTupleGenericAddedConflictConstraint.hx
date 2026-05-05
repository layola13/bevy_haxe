package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Added;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple;

class QueryTupleGenericAddedConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTupleGenericAddedConflictConstraint");
    }

    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple<TupleGenericAddedConflictPosition, TupleGenericAddedConflictVelocity>, Added<TupleGenericAddedConflictPosition>>, single:Query<TupleGenericAddedConflictPosition>):Void {
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

class TupleGenericAddedConflictPosition implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleGenericAddedConflictVelocity implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
