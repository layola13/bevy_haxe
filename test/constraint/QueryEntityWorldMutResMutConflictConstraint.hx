package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Entity.EntityWorldMut;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Resource;

class QueryEntityWorldMutResMutConflictConstraint implements SystemClass {
    static function main():Void {
        ConstraintRuntime.runUpdate("QueryEntityWorldMutResMutConflictConstraint");
    }

    @:system("Update")
    public static function illegal(query:Query<EntityWorldMut>, counter:ResMut<QueryEntityWorldMutResMutConflictCounter>):Void {
        for (item in query.iter()) {
            var _ = item.component.id();
        }
        counter.value.value++;
    }
}

class QueryEntityWorldMutResMutConflictCounter implements Resource {
    public var value:Int;

    public function new(?value:Int) {
        this.value = value != null ? value : 0;
    }
}
