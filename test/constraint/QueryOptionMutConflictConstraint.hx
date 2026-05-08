package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Mut;
import bevy.ecs.Option;
import bevy.ecs.Query;

class QueryOptionMutConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryOptionMutConflictConstraint");
    }

    @:system("Update")
    public static function illegal(optionalMut:Query<Option<Mut<OptionMutConflictHealth>>>, health:Query<OptionMutConflictHealth>):Void {
        var total = 0;
        for (item in optionalMut.iter()) {
            if (item.component.isSome()) {
                total += item.component.value.value.value;
                item.component.value.setChanged();
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

class OptionMutConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
