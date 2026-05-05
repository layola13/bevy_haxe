package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;

class QueryAnyOfConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryAnyOfConflictConstraint");
    }

    @:system("Update")
    public static function illegal(any:Query<AnyOf<AnyOfConflictHealth, AnyOfConflictSpeed>>, health:Query<AnyOfConflictHealth>):Void {
        var total = 0;
        for (item in any.iter()) {
            if (item.component._0.isSome()) {
                total += item.component._0.value.value;
            }
            if (item.component._1.isSome()) {
                total += item.component._1.value.value;
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

class AnyOfConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class AnyOfConflictSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
