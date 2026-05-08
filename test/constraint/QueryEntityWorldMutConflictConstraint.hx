package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Entity.EntityWorldMut;
import bevy.ecs.Query;

class QueryEntityWorldMutConflictConstraint implements SystemClass {
    static function main():Void {
        ConstraintRuntime.runUpdate("QueryEntityWorldMutConflictConstraint");
    }

    @:system("Update")
    public static function illegal(entityWorldMut:Query<EntityWorldMut>, health:Query<QueryEntityWorldMutConflictHealth>):Void {
        for (item in entityWorldMut.iter()) {
            var _ = item.component.id();
        }
        for (item in health.iter()) {
            var _ = item.component.value;
        }
    }
}

class QueryEntityWorldMutConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int = 1) {
        this.value = value;
    }
}
