package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Option;
import bevy.ecs.Query;
import bevy.ecs.Ref;

class QueryOptionRefConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryOptionRefConflictConstraint");
    }

    @:system("Update")
    public static function illegal(optionalRef:Query<Option<Ref<OptionRefConflictHealth>>>, health:Query<OptionRefConflictHealth>):Void {
        var total = 0;
        for (item in optionalRef.iter()) {
            if (item.component.isSome()) {
                total += item.component.value.value.value;
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

class OptionRefConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
