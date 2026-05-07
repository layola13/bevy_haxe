package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Mut;
import bevy.ecs.Query;

class QueryAnyOfWithMutAndRefConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryAnyOfWithMutAndRefConflictConstraint");
    }

    @:system("Update")
    public static function illegal(any:Query<AnyOf<Mut<QueryAnyOfWithMutAndRefConflictHealth>, QueryAnyOfWithMutAndRefConflictHealth>>):Void {
        var total = 0;
        for (item in any.iter()) {
            if (item.component._0.isSome()) {
                total += item.component._0.value.value.value;
                item.component._0.value.setChanged();
            }
            if (item.component._1.isSome()) {
                total += item.component._1.value.value;
            }
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class QueryAnyOfWithMutAndRefConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
