package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Mut;
import bevy.ecs.Option;
import bevy.ecs.Query;

class QueryAnyOfMutOptionConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryAnyOfMutOptionConflictConstraint");
    }

    @:system("Update")
    public static function illegal(any:Query<AnyOf<Mut<QueryAnyOfMutOptionConflictHealth>, Option<QueryAnyOfMutOptionConflictHealth>>>):Void {
        var total = 0;
        for (item in any.iter()) {
            if (item.component._0.isSome()) {
                total += item.component._0.value.value.value;
                item.component._0.value.setChanged();
            }
            if (item.component._1.isSome()) {
                total += item.component._1.value.value.value;
            }
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class QueryAnyOfMutOptionConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
