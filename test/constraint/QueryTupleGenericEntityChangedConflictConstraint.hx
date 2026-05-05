package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Changed;
import bevy.ecs.Component;
import bevy.ecs.Entity;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple;

class QueryTupleGenericEntityChangedConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTupleGenericEntityChangedConflictConstraint");
    }

    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple<Entity, TupleGenericEntityChangedConflictPosition, TupleGenericEntityChangedConflictVelocity>>, changed:Query<TupleGenericEntityChangedConflictPosition, Changed<TupleGenericEntityChangedConflictPosition>>):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            if (!item.entity.equals(item.component._0)) { throw "mismatched Entity data in tuple conflict probe"; }
            total += item.component._1.value + item.component._2.value;
        }
        for (item in changed.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable query conflict probe";
        }
    }
}

class TupleGenericEntityChangedConflictPosition implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleGenericEntityChangedConflictVelocity implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
