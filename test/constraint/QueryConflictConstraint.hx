package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;

class QueryConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryConflictConstraint");
    }

    @:system("Update")
    public static function illegal(left:Query<ConflictPosition>, right:Query<ConflictPosition>):Void {
        var total = 0;
        for (item in left.iter()) {
            total += item.component.value;
        }
        for (item in right.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable query conflict probe";
        }
    }
}

class ConflictPosition implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
