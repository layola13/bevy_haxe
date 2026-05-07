package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query2;

class QueryPairAnyOfConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryPairAnyOfConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        pair:Query2<AnyOf<QueryPairAnyOfConflictHealth, QueryPairAnyOfConflictSpeed>, QueryPairAnyOfConflictTag>,
        health:Query<QueryPairAnyOfConflictHealth>
    ):Void {
        var total = 0;
        for (item in pair.iter()) {
            if (item.a._0.isSome()) {
                total += item.a._0.value.value;
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

class QueryPairAnyOfConflictHealth implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryPairAnyOfConflictSpeed implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryPairAnyOfConflictTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}
