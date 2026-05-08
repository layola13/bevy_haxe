package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;

class QueryAnyOfNestedConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryAnyOfNestedConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        nested:Query<AnyOf<AnyOf<QueryAnyOfNestedConflictHealth, QueryAnyOfNestedConflictSpeed>, QueryAnyOfNestedConflictTag>>,
        health:Query<QueryAnyOfNestedConflictHealth>
    ):Void {
        var total = 0;
        for (item in nested.iter()) {
            if (item.component._0.isSome()) {
                var inner = item.component._0.value;
                if (inner._0.isSome()) {
                    total += inner._0.value.value;
                }
                if (inner._1.isSome()) {
                    total += inner._1.value.value;
                }
            }
            if (item.component._1.isSome()) {
                total += item.component._1.value.value;
            }
        }
        for (item in health.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class QueryAnyOfNestedConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class QueryAnyOfNestedConflictSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class QueryAnyOfNestedConflictTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
