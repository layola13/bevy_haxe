package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Entity.EntityWorldMut;
import bevy.ecs.Query;
import bevy.ecs.Res;
import bevy.ecs.Resource;

class QueryEntityWorldMutResConflictConstraint implements SystemClass {
    static function main():Void {
        ConstraintRuntime.runUpdate("QueryEntityWorldMutResConflictConstraint");
    }

    @:system("Update")
    public static function illegal(query:Query<EntityWorldMut>, counter:Res<QueryEntityWorldMutResConflictCounter>):Void {
        for (item in query.iter()) {
            var _ = item.component.id();
        }
        var _ = counter.value.value;
    }
}

class QueryEntityWorldMutResConflictCounter implements Resource {
    public var value:Int;

    public function new(?value:Int) {
        this.value = value != null ? value : 0;
    }
}
