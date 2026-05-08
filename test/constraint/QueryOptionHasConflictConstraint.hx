package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Has;
import bevy.ecs.Mut;
import bevy.ecs.Option;
import bevy.ecs.Query;

class QueryOptionHasConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryOptionHasConflictConstraint");
    }

    @:system("Update")
    public static function illegal(optionalHas:Query<Option<Has<OptionHasConflictHealth>>>, health:Query<Mut<OptionHasConflictHealth>>):Void {
        var total = 0;
        for (item in optionalHas.iter()) {
            if (item.component.isSome() && item.component.value.value) {
                total += 100;
            }
        }
        for (item in health.iter()) {
            total += item.component.value.value;
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class OptionHasConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
