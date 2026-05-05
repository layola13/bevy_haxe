package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.Query.Query3;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTripleOrBranchConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTripleOrBranchConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        triple:Query3<TripleOrBranchHealth, TripleOrBranchTag, TripleOrBranchSpeed>,
        single:Query<TripleOrBranchHealth, Or<With<TripleOrBranchSpeed>, Without<TripleOrBranchHealth>>>
    ):Void {
        var total = 0;
        for (item in triple.iter()) {
            total += item.a.value + item.b.value + item.c.value;
        }
        for (item in single.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable query conflict probe";
        }
    }
}

class TripleOrBranchHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleOrBranchTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleOrBranchSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
