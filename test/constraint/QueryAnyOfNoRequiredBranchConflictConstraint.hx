package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Has;
import bevy.ecs.Option;
import bevy.ecs.Query;

class QueryAnyOfNoRequiredBranchConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryAnyOfNoRequiredBranchConflictConstraint");
    }

    @:system("Update")
    public static function illegal(any:Query<AnyOf<Has<QueryAnyOfNoRequiredBranchHealth>, Option<QueryAnyOfNoRequiredBranchHealth>>>, health:Query<QueryAnyOfNoRequiredBranchHealth>):Void {
        var total = 0;
        for (item in any.iter()) {
            if (item.component._0.isSome() && item.component._0.value.value) {
                total++;
            }
            if (item.component._1.isSome() && item.component._1.value.isSome()) {
                total += item.component._1.value.value.value;
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

class QueryAnyOfNoRequiredBranchHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
