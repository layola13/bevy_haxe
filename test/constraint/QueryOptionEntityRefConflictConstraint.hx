package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Entity.EntityRef;
import bevy.ecs.Option;
import bevy.ecs.Query;

class QueryOptionEntityRefConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryOptionEntityRefConflictConstraint");
    }

    @:system("Update")
    public static function illegal(optionalRef:Query<Option<EntityRef>>, health:Query<OptionEntityRefConflictHealth>):Void {
        var total = 0;
        for (item in optionalRef.iter()) {
            if (item.component.isSome()) {
                var value = item.component.value.get(OptionEntityRefConflictHealth);
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

class OptionEntityRefConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
