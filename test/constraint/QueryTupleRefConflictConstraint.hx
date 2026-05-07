package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Ref;
import bevy.ecs.Tuple.Tuple;

class QueryTupleRefConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTupleRefConflictConstraint");
    }

    @:system("Update")
    public static function illegal(tupleRef:Query<Tuple<Ref<TupleRefConflictHealth>, TupleRefConflictTag>>, health:Query<TupleRefConflictHealth>):Void {
        var total = 0;
        for (item in tupleRef.iter()) {
            total += item.component._0.value.value + item.component._1.value;
        }
        for (item in health.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class TupleRefConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleRefConflictTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
