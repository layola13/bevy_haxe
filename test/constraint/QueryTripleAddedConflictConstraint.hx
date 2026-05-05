package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Added;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query3;

class QueryTripleAddedConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTripleAddedConflictConstraint");
    }

    @:system("Update")
    public static function illegal(triple:Query3<TripleAddedConflictHealth, TripleAddedConflictTag, TripleAddedConflictSpeed, Added<TripleAddedConflictHealth>>, single:Query<TripleAddedConflictHealth>):Void {
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

class TripleAddedConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleAddedConflictTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleAddedConflictSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
