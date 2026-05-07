package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Ref;

class QueryRefConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryRefConflictConstraint");
    }

    @:system("Update")
    public static function illegal(healthRef:Query<Ref<RefConflictHealth>>, health:Query<RefConflictHealth>):Void {
        var total = 0;
        for (item in healthRef.iter()) {
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

class RefConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
