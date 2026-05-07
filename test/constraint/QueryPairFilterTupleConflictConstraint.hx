package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query2;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryPairFilterTupleConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryPairFilterTupleConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        pair:Query2<PairFilterTupleConflictHealth, PairFilterTupleConflictSpeed>,
        single:Query<PairFilterTupleConflictHealth, Tuple2<With<PairFilterTupleConflictSpeed>, Without<PairFilterTupleConflictTag>>>
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

class PairFilterTupleConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class PairFilterTupleConflictSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class PairFilterTupleConflictTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
