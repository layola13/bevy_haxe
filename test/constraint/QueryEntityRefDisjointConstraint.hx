package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Entity.EntityRef;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryEntityRefDisjointConstraint implements SystemClass {
    static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryEntityRefDisjointConstraint", function(app) {
            app.world.spawn([new QueryEntityRefDisjointHealth(4), new QueryEntityRefDisjointTag()]);
            app.world.spawn([new QueryEntityRefDisjointHealth(9)]);
        }, 13, 1);
    }

    @:system("Update")
    public static function legal(
        refs:Query<EntityRef, Tuple<With<QueryEntityRefDisjointTag>, Without<ConstraintCounter>>>,
        health:Query<QueryEntityRefDisjointHealth, Without<QueryEntityRefDisjointTag>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in refs.iter()) {
            var value = item.component.get(QueryEntityRefDisjointHealth);
            if (value != null) {
                total += value.value;
            }
        }
        for (item in health.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class QueryEntityRefDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class QueryEntityRefDisjointTag implements Component {
    public function new() {}
}
