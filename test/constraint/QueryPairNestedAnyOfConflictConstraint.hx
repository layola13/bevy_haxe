package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query2;

class QueryPairNestedAnyOfConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryPairNestedAnyOfConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        pair:Query2<AnyOf<AnyOf<QueryPairNestedAnyOfConflictHealth, QueryPairNestedAnyOfConflictSpeed>, QueryPairNestedAnyOfConflictTag>, QueryPairNestedAnyOfConflictMarker>,
        health:Query<QueryPairNestedAnyOfConflictHealth>
    ):Void {
        var total = 0;
        for (item in pair.iter()) {
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
            total += item.b.value;
        }
        for (item in health.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class QueryPairNestedAnyOfConflictHealth implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryPairNestedAnyOfConflictSpeed implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryPairNestedAnyOfConflictTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryPairNestedAnyOfConflictMarker implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}
