package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Changed;
import bevy.ecs.Component;
import bevy.ecs.Query;

class QueryChangedConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryChangedConflictConstraint");
    }

    @:system("Update")
    public static function illegal(data:Query<ChangedTracked>, changed:Query<EntityMarker, Changed<ChangedTracked>>):Void {
        var total = 0;
        for (item in data.iter()) {
            total += item.component.value;
        }
        for (item in changed.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable query conflict probe";
        }
    }
}

class ChangedTracked implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class EntityMarker implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
