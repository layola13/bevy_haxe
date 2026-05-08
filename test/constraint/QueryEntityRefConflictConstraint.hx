package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Entity.EntityRef;
import bevy.ecs.Query;

class QueryEntityRefConflictConstraint implements SystemClass {
    static function main():Void {
        ConstraintRuntime.runUpdate("QueryEntityRefConflictConstraint");
    }

    @:system("Update")
    public static function illegal(entityRefs:Query<EntityRef>, health:Query<QueryEntityRefConflictHealth>):Void {
        for (item in entityRefs.iter()) {
            var _ = item.component.id();
        }
        for (item in health.iter()) {
            var _ = item.component.value;
        }
    }
}

class QueryEntityRefConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int = 1) {
        this.value = value;
    }
}
