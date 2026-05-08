package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Entity.EntityRef;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Resource;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.Without;

class QueryEntityRefResMutDisjointConstraint implements SystemClass {
    static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryEntityRefResMutDisjointConstraint", function(app) {
            app.world.spawn([new QueryEntityRefResMutDisjointHealth(4)]);
            app.world.spawn([new QueryEntityRefResMutDisjointHealth(9)]);
            app.world.insertResource(new QueryEntityRefResMutDisjointCounter());
        }, 13, 1);
    }

    @:system("Update")
    public static function legal(
        query:Query<EntityRef, Tuple<Without<QueryEntityRefResMutDisjointCounter>, Without<ConstraintCounter>>>,
        resource:ResMut<QueryEntityRefResMutDisjointCounter>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in query.iter()) {
            var health = item.component.get(QueryEntityRefResMutDisjointHealth);
            if (health != null) {
                total += health.value;
            }
        }
        resource.value.total += total;
        resource.value.writes++;
        counter.value.record(total);
    }
}

class QueryEntityRefResMutDisjointCounter implements Resource {
    public var total:Int;
    public var writes:Int;

    public function new() {
        total = 0;
        writes = 0;
    }
}

class QueryEntityRefResMutDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
