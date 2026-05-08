package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Entity.EntityRef;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Resource;

class QueryEntityRefResMutConflictConstraint implements SystemClass {
    static function main():Void {
        ConstraintRuntime.runUpdate("QueryEntityRefResMutConflictConstraint");
    }

    @:system("Update")
    public static function illegal(query:Query<EntityRef>, counter:ResMut<QueryEntityRefResMutConflictCounter>):Void {
        for (item in query.iter()) {
            var _ = item.component.id();
        }
        counter.value.value++;
    }
}

class QueryEntityRefResMutConflictCounter implements Resource {
    public var value:Int;

    public function new(?value:Int) {
        this.value = value != null ? value : 0;
    }
}

class QueryEntityRefResMutConflictMarker implements Component {
    public function new() {}
}
