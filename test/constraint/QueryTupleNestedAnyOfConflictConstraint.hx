package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;

class QueryTupleNestedAnyOfConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTupleNestedAnyOfConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        tupleQuery:Query<Tuple2<AnyOf<AnyOf<QueryTupleNestedAnyOfConflictHealth, QueryTupleNestedAnyOfConflictSpeed>, QueryTupleNestedAnyOfConflictTag>, QueryTupleNestedAnyOfConflictMarker>>,
        health:Query<QueryTupleNestedAnyOfConflictHealth>
    ):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            if (item.component._0._0.isSome()) {
                var inner = item.component._0._0.value;
                if (inner._0.isSome()) {
                    total += inner._0.value.value;
                }
                if (inner._1.isSome()) {
                    total += inner._1.value.value;
                }
            }
            if (item.component._0._1.isSome()) {
                total += item.component._0._1.value.value;
            }
            total += item.component._1.value;
        }
        for (item in health.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class QueryTupleNestedAnyOfConflictHealth implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleNestedAnyOfConflictSpeed implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleNestedAnyOfConflictTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleNestedAnyOfConflictMarker implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}
