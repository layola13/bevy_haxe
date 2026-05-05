package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Changed;
import bevy.ecs.Component;
import bevy.ecs.Entity;
import bevy.ecs.Query;
import bevy.ecs.Query.Query3;

class QueryTripleEntityChangedConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTripleEntityChangedConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        triple:Query3<Entity, TripleEntityChangedConflictHealth, TripleEntityChangedConflictSpeed>,
        changed:Query<TripleEntityChangedConflictHealth, Changed<TripleEntityChangedConflictHealth>>
    ):Void {
        for (item in triple.iter()) {
            item.b.value += item.c.value;
        }
        for (item in changed.iter()) {
            item.component.value++;
        }
    }
}

class TripleEntityChangedConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleEntityChangedConflictSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
