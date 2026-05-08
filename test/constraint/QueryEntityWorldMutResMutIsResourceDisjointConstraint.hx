package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Entity.EntityWorldMut;
import bevy.ecs.IsResource;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.Without;

class QueryEntityWorldMutResMutIsResourceDisjointConstraint implements SystemClass {
    static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryEntityWorldMutResMutIsResourceDisjointConstraint", function(app) {
            app.world.spawn([new QueryEntityWorldMutResMutIsResourceDisjointTag()]);
        }, 1, 1);
    }

    @:system("Update")
    public static function legal(
        query:Query<EntityWorldMut, Tuple<Without<IsResource>, Without<ConstraintCounter>>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var count = 0;
        for (_ in query.iter()) {
            count++;
        }
        counter.value.record(count);
    }
}

class QueryEntityWorldMutResMutIsResourceDisjointTag implements Component {
    public function new() {}
}
