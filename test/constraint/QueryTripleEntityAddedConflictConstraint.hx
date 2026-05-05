package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Added;
import bevy.ecs.Component;
import bevy.ecs.Entity;
import bevy.ecs.Query;
import bevy.ecs.Query.Query3;

class QueryTripleEntityAddedConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTripleEntityAddedConflictConstraint");
    }

    @:system("Update")
    public static function illegal(
        triple:Query3<Entity, TripleEntityAddedConflictHealth, TripleEntityAddedConflictSpeed>,
        added:Query<TripleEntityAddedConflictHealth, Added<TripleEntityAddedConflictHealth>>
    ):Void {
        for (item in triple.iter()) {
            item.b.value += item.c.value;
        }
        for (item in added.iter()) {
            item.component.value++;
        }
    }
}

class TripleEntityAddedConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleEntityAddedConflictSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
