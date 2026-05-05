package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.Query.Query2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryPairOrBranchConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryPairOrBranchConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        pair:Query2<PairOrBranchHealth, PairOrBranchSpeed>,
        single:Query<PairOrBranchHealth, Or<With<PairOrBranchSpeed>, Without<PairOrBranchHealth>>>
    ):Void {
        var total = 0;
        for (item in pair.iter()) {
            total += item.a.value + item.b.value;
        }
        for (item in single.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable query conflict probe";
        }
    }
}

class PairOrBranchHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class PairOrBranchSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
