package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Entity.EntityWorldMut;
import bevy.ecs.IsResource;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryAnyOfEntityWorldMutDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryAnyOfEntityWorldMutDisjointConstraint", function(app) {
            app.world.spawn([new QueryAnyOfEntityWorldMutDisjointPlayerTag(), new QueryAnyOfEntityWorldMutDisjointHealth(4)]);
            app.world.spawn([new QueryAnyOfEntityWorldMutDisjointPlayerTag(), new QueryAnyOfEntityWorldMutDisjointHealth(5)]);
            app.world.spawn([new QueryAnyOfEntityWorldMutDisjointEnemyTag(), new QueryAnyOfEntityWorldMutDisjointHealth(7)]);
        }, 17);
    }

    @:system("Update")
    public static function legal(
        players:Query<AnyOf<EntityWorldMut, QueryAnyOfEntityWorldMutDisjointHealth>, Tuple<With<QueryAnyOfEntityWorldMutDisjointPlayerTag>, Without<IsResource>, Without<ConstraintCounter>>>,
        enemies:Query<QueryAnyOfEntityWorldMutDisjointHealth, Without<QueryAnyOfEntityWorldMutDisjointPlayerTag>>,
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

class QueryAnyOfEntityWorldMutDisjointPlayerTag implements Component {
    public function new() {}
}

class QueryAnyOfEntityWorldMutDisjointEnemyTag implements Component {
    public function new() {}
}

class QueryAnyOfEntityWorldMutDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
