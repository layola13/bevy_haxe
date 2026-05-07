package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query3;

class QueryTripleAnyOfConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTripleAnyOfConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        triple:Query3<AnyOf<QueryTripleAnyOfConflictHealth, QueryTripleAnyOfConflictSpeed>, QueryTripleAnyOfConflictTag, QueryTripleAnyOfConflictMarker>,
        health:Query<QueryTripleAnyOfConflictHealth>
    ):Void {
        var total = 0;
        for (item in triple.iter()) {
            if (item.a._0.isSome()) {
                total += item.a._0.value.value;
            }
            if (item.a._1.isSome()) {
                total += item.a._1.value.value;
            }
            total += item.b.value + item.c.value;
        }
        for (item in health.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class QueryTripleAnyOfConflictHealth implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleAnyOfConflictSpeed implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleAnyOfConflictTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleAnyOfConflictMarker implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}
