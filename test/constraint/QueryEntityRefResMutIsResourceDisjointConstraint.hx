package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Entity.EntityRef;
import bevy.ecs.IsResource;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Resource;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.Without;

class QueryEntityRefResMutIsResourceDisjointConstraint implements SystemClass {
    static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryEntityRefResMutIsResourceDisjointConstraint", function(app) {
            app.world.spawn([new QueryEntityRefResMutIsResourceDisjointHealth(4)]);
            app.world.spawn([new QueryEntityRefResMutIsResourceDisjointHealth(9)]);
            app.world.insertResource(new QueryEntityRefResMutIsResourceDisjointCounter());
        }, 13, 1);
    }

    @:system("Update")
    public static function legal(
        query:Query<EntityRef, Tuple<Without<IsResource>, Without<QueryEntityRefResMutIsResourceDisjointCounter>, Without<ConstraintCounter>>>,
        resource:ResMut<QueryEntityRefResMutIsResourceDisjointCounter>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in query.iter()) {
            var health = item.component.get(QueryEntityRefResMutIsResourceDisjointHealth);
            if (health != null) {
                total += health.value;
            }
        }
        resource.value.total += total;
        resource.value.writes++;
        counter.value.record(total);
    }
}

class QueryEntityRefResMutIsResourceDisjointCounter implements Resource {
    public var total:Int;
    public var writes:Int;

    public function new() {
        total = 0;
        writes = 0;
    }
}

class QueryEntityRefResMutIsResourceDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
