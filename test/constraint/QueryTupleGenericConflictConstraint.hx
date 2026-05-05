package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple;

class QueryTupleGenericConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTupleGenericConflictConstraint");
    }

    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple<TupleGenericPosition, TupleGenericVelocity>>, single:Query<TupleGenericPosition>):Void {
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

class TupleGenericPosition implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleGenericVelocity implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
