package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Mut;
import bevy.ecs.Query;
import bevy.ecs.Ref;

class QueryRefMutConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryRefMutConflictConstraint");
    }

    @:system("Update")
    public static function illegal(healthRef:Query<Ref<RefMutConflictHealth>>, healthMut:Query<Mut<RefMutConflictHealth>>):Void {
        var total = 0;
        for (item in healthRef.iter()) {
            total += item.component.value.value;
        }
        for (item in healthMut.iter()) {
            item.component.setChanged();
            total += item.component.value.value;
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class RefMutConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
