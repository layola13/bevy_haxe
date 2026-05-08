package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Entity.EntityWorldMut;
import bevy.ecs.Option;
import bevy.ecs.Query;

class QueryOptionEntityWorldMutConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryOptionEntityWorldMutConflictConstraint");
    }

    @:system("Update")
    public static function illegal(optionalMut:Query<Option<EntityWorldMut>>, health:Query<OptionEntityWorldMutConflictHealth>):Void {
        var total = 0;
        for (item in optionalMut.iter()) {
            if (item.component.isSome()) {
                var value = item.component.value.get(OptionEntityWorldMutConflictHealth);
                if (value != null) {
                    total += value.value;
                }
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

class OptionEntityWorldMutConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
