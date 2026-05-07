package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Mut;
import bevy.ecs.Query;

class QueryMutConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryMutConflictConstraint");
    }

    @:system("Update")
    public static function illegal(healthMut:Query<Mut<MutConflictHealth>>, health:Query<MutConflictHealth>):Void {
        var total = 0;
        for (item in healthMut.iter()) {
            item.component.setChanged();
            total += item.component.value.value;
        }
        for (item in health.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class MutConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
