package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Entity.EntityRef;
import bevy.ecs.IsResource;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryAnyOfEntityRefDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryAnyOfEntityRefDisjointConstraint", function(app) {
            app.world.spawn([new QueryAnyOfEntityRefDisjointPlayerTag(), new QueryAnyOfEntityRefDisjointHealth(4)]);
            app.world.spawn([new QueryAnyOfEntityRefDisjointPlayerTag(), new QueryAnyOfEntityRefDisjointHealth(5)]);
            app.world.spawn([new QueryAnyOfEntityRefDisjointEnemyTag(), new QueryAnyOfEntityRefDisjointHealth(7)]);
        }, 17);
    }

    @:system("Update")
    public static function legal(
        players:Query<AnyOf<EntityRef, QueryAnyOfEntityRefDisjointHealth>, Tuple<With<QueryAnyOfEntityRefDisjointPlayerTag>, Without<IsResource>, Without<ConstraintCounter>>>,
        enemies:Query<QueryAnyOfEntityRefDisjointHealth, Without<QueryAnyOfEntityRefDisjointPlayerTag>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in players.iter()) {
            if (item.component._0.isSome()) {
                total += item.component._0.value.id().index;
            }
            if (item.component._1.isSome()) {
                total += item.component._1.value.value;
            }
        }
        for (item in enemies.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class QueryAnyOfEntityRefDisjointPlayerTag implements Component {
    public function new() {}
}

class QueryAnyOfEntityRefDisjointEnemyTag implements Component {
    public function new() {}
}

class QueryAnyOfEntityRefDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
