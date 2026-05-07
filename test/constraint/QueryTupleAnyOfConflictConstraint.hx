package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;

class QueryTupleAnyOfConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTupleAnyOfConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        tupleQuery:Query<Tuple2<AnyOf<QueryTupleAnyOfConflictHealth, QueryTupleAnyOfConflictSpeed>, QueryTupleAnyOfConflictTag>>,
        health:Query<QueryTupleAnyOfConflictHealth>
    ):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            if (item.component._0._0.isSome()) {
                total += item.component._0._0.value.value;
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

class QueryTupleAnyOfConflictHealth implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleAnyOfConflictSpeed implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleAnyOfConflictTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}
