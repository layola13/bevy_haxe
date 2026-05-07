package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.Query.Query3;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTripleNestedTupleOrConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTripleNestedTupleOrConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        triple:Query3<TripleNestedTupleOrConflictHealth, TripleNestedTupleOrConflictTag, TripleNestedTupleOrConflictSpeed>,
        single:Query<TripleNestedTupleOrConflictHealth, Or<Tuple2<With<TripleNestedTupleOrConflictSpeed>, Without<TripleNestedTupleOrConflictGuard>>, Without<TripleNestedTupleOrConflictHealth>>>
    ):Void {
        var total = 0;
        for (item in triple.iter()) {
            total += item.a.value + item.b.value + item.c.value;
        }
        for (item in single.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class TripleNestedTupleOrConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleNestedTupleOrConflictTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleNestedTupleOrConflictSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleNestedTupleOrConflictGuard implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
