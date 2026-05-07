package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query3;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTripleFilterTupleConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTripleFilterTupleConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        triple:Query3<TripleFilterTupleConflictHealth, TripleFilterTupleConflictTag, TripleFilterTupleConflictSpeed>,
        single:Query<TripleFilterTupleConflictHealth, Tuple2<With<TripleFilterTupleConflictSpeed>, Without<TripleFilterTupleConflictGuard>>>
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

class TripleFilterTupleConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleFilterTupleConflictTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleFilterTupleConflictSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleFilterTupleConflictGuard implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
