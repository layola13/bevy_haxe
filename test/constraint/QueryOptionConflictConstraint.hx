package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Option;
import bevy.ecs.Query;

class QueryOptionConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryOptionConflictConstraint");
    }

    @:system("Update")
    public static function illegal(optional:Query<Option<OptionConflictHealth>>, health:Query<OptionConflictHealth>):Void {
        var total = 0;
        for (item in optional.iter()) {
            total += item.component.isSome() ? item.component.value.value : 1;
        }
        for (item in health.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class OptionConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
