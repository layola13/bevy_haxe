package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query3;
import bevy.ecs.Without;

class QueryTripleAnyOfWithoutBranchConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTripleAnyOfWithoutBranchConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        triple:Query3<AnyOf<QueryTripleAnyOfWithoutBranchConflictHealth, QueryTripleAnyOfWithoutBranchConflictSpeed>, QueryTripleAnyOfWithoutBranchConflictShared, QueryTripleAnyOfWithoutBranchConflictMarker>,
        withoutHealth:Query<QueryTripleAnyOfWithoutBranchConflictShared, Without<QueryTripleAnyOfWithoutBranchConflictHealth>>
    ):Void {
        var total = 0;
        for (item in triple.iter()) {
            total += item.b.value + item.c.value;
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

class QueryTripleAnyOfWithoutBranchConflictHealth implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleAnyOfWithoutBranchConflictSpeed implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleAnyOfWithoutBranchConflictShared implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleAnyOfWithoutBranchConflictMarker implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}
