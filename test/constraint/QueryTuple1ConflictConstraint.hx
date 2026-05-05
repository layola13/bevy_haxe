package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple1;

class QueryTuple1ConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTuple1ConflictConstraint");
    }

    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple1<Tuple1ConflictPosition>>, single:Query<Tuple1ConflictPosition>):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            total += item.component._0.value;
        }
        for (item in single.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable query conflict probe";
        }
    }
}

class Tuple1ConflictPosition implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
