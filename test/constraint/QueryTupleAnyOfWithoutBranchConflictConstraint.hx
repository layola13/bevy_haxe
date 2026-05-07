package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.Without;

class QueryTupleAnyOfWithoutBranchConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTupleAnyOfWithoutBranchConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        tupleQuery:Query<Tuple2<AnyOf<QueryTupleAnyOfWithoutBranchConflictHealth, QueryTupleAnyOfWithoutBranchConflictSpeed>, QueryTupleAnyOfWithoutBranchConflictShared>>,
        withoutHealth:Query<QueryTupleAnyOfWithoutBranchConflictShared, Without<QueryTupleAnyOfWithoutBranchConflictHealth>>
    ):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            total += item.component._1.value;
            if (item.component._0._0.isSome()) {
                total += item.component._0._0.value.value;
            }
            if (item.component._0._1.isSome()) {
                total += item.component._0._1.value.value;
            }
        }
        for (item in withoutHealth.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class QueryTupleAnyOfWithoutBranchConflictHealth implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleAnyOfWithoutBranchConflictSpeed implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleAnyOfWithoutBranchConflictShared implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}
