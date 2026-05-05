package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.Query.Query3;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTripleCompositeConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTripleCompositeConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        triple:Query3<TripleCompositeConflictHealth, TripleCompositeConflictTag, TripleCompositeConflictSpeed, Or<With<TripleCompositeConflictPlayer>, With<TripleCompositeConflictEnemy>>>,
        single:Query<TripleCompositeConflictHealth, Without<TripleCompositeConflictPlayer>>
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

class TripleCompositeConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleCompositeConflictTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleCompositeConflictSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleCompositeConflictPlayer implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleCompositeConflictEnemy implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
