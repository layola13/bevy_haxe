package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Entity.EntityRef;
import bevy.ecs.Query;

class QueryAnyOfEntityRefConflictConstraint implements SystemClass {
    static function main():Void {
        ConstraintRuntime.runUpdate("QueryAnyOfEntityRefConflictConstraint");
    }

    @:system("Update")
    public static function illegal(any:Query<AnyOf<EntityRef, QueryAnyOfEntityRefConflictHealth>>, health:Query<QueryAnyOfEntityRefConflictHealth>):Void {
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

class QueryAnyOfEntityRefConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int = 1) {
        this.value = value;
    }
}
