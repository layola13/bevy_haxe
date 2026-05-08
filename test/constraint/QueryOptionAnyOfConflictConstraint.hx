package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Option;
import bevy.ecs.Query;

class QueryOptionAnyOfConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryOptionAnyOfConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        optionalAny:Query<Option<AnyOf<QueryOptionAnyOfConflictHealth, QueryOptionAnyOfConflictSpeed>>>,
        health:Query<QueryOptionAnyOfConflictHealth>
    ):Void {
        var total = 0;
        for (item in optionalAny.iter()) {
            if (item.component.isSome()) {
                var any = item.component.value;
                if (any._0.isSome()) {
                    total += any._0.value.value;
                }
                if (any._1.isSome()) {
                    total += any._1.value.value;
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

class QueryOptionAnyOfConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class QueryOptionAnyOfConflictSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
