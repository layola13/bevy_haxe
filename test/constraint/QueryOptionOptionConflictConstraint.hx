package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Option;
import bevy.ecs.Query;

class QueryOptionOptionConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryOptionOptionConflictConstraint");
    }

    @:system("Update")
    public static function illegal(optionalOptional:Query<Option<Option<QueryOptionOptionConflictHealth>>>, health:Query<QueryOptionOptionConflictHealth>):Void {
        var total = 0;
        for (item in optionalOptional.iter()) {
            if (item.component.isSome() && item.component.value.isSome()) {
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

class QueryOptionOptionConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
