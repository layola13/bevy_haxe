package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query3;

class QueryTripleNestedAnyOfConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTripleNestedAnyOfConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        triple:Query3<AnyOf<AnyOf<QueryTripleNestedAnyOfConflictHealth, QueryTripleNestedAnyOfConflictSpeed>, QueryTripleNestedAnyOfConflictTag>, QueryTripleNestedAnyOfConflictMarker, QueryTripleNestedAnyOfConflictFlag>,
        health:Query<QueryTripleNestedAnyOfConflictHealth>
    ):Void {
        var total = 0;
        for (item in triple.iter()) {
            if (item.a._0.isSome()) {
                var inner = item.a._0.value;
                if (inner._0.isSome()) {
                    total += inner._0.value.value;
                }
                if (inner._1.isSome()) {
                    total += inner._1.value.value;
                }
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

class QueryTripleNestedAnyOfConflictHealth implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleNestedAnyOfConflictSpeed implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleNestedAnyOfConflictTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleNestedAnyOfConflictMarker implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleNestedAnyOfConflictFlag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}
