package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Entity;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple;

class QueryTupleGenericEntityConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTupleGenericEntityConflictConstraint");
    }

    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple<Entity, TupleGenericEntityConflictPosition>>, single:Query<TupleGenericEntityConflictPosition>):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            if (!item.entity.equals(item.component._0)) { throw "mismatched Entity data in tuple conflict probe"; }
            total += item.component._1.value;
        }
        for (item in single.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable query conflict probe";
        }
    }
}

class TupleGenericEntityConflictPosition implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
