package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.Query.Query2;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryPairNestedTupleOrConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryPairNestedTupleOrConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        pair:Query2<PairNestedTupleOrConflictHealth, PairNestedTupleOrConflictSpeed>,
        single:Query<PairNestedTupleOrConflictHealth, Or<Tuple2<With<PairNestedTupleOrConflictSpeed>, Without<PairNestedTupleOrConflictTag>>, Without<PairNestedTupleOrConflictHealth>>>
    ):Void {
        var total = 0;
        for (item in pair.iter()) {
            total += item.a.value + item.b.value;
        }
        for (item in single.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class PairNestedTupleOrConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class PairNestedTupleOrConflictSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class PairNestedTupleOrConflictTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
