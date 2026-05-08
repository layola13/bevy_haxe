package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Entity.EntityWorldMut;
import bevy.ecs.Query;

class QueryAnyOfEntityWorldMutConflictConstraint implements SystemClass {
    static function main():Void {
        ConstraintRuntime.runUpdate("QueryAnyOfEntityWorldMutConflictConstraint");
    }

    @:system("Update")
    public static function illegal(any:Query<AnyOf<EntityWorldMut, QueryAnyOfEntityWorldMutConflictHealth>>, health:Query<QueryAnyOfEntityWorldMutConflictHealth>):Void {
        var total = 0;
        for (item in any.iter()) {
            if (item.component._0.isSome()) {
                total += item.component._0.value.id().index;
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

class QueryAnyOfEntityWorldMutConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int = 1) {
        this.value = value;
    }
}
