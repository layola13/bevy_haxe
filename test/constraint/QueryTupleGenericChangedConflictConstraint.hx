package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Changed;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple;

class QueryTupleGenericChangedConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTupleGenericChangedConflictConstraint");
    }

    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple<TupleGenericChangedConflictPosition, TupleGenericChangedConflictVelocity>>, changed:Query<TupleGenericChangedConflictPosition, Changed<TupleGenericChangedConflictPosition>>):Void {
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

class TupleGenericChangedConflictPosition implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleGenericChangedConflictVelocity implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
