package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query2;
import bevy.ecs.Without;

class QueryPairAnyOfWithoutBranchConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryPairAnyOfWithoutBranchConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        anyShared:Query2<AnyOf<QueryPairAnyOfWithoutBranchConflictHealth, QueryPairAnyOfWithoutBranchConflictSpeed>, QueryPairAnyOfWithoutBranchConflictShared>,
        withoutHealth:Query<QueryPairAnyOfWithoutBranchConflictShared, Without<QueryPairAnyOfWithoutBranchConflictHealth>>
    ):Void {
        var total = 0;
        for (item in anyShared.iter()) {
            total += item.b.value;
            if (item.a._0.isSome()) {
                total += item.a._0.value.value;
            }
            if (item.a._1.isSome()) {
                total += item.a._1.value.value;
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

class QueryPairAnyOfWithoutBranchConflictHealth implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryPairAnyOfWithoutBranchConflictSpeed implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryPairAnyOfWithoutBranchConflictShared implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}
