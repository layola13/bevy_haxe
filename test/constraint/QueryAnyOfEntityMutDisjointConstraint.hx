package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Entity;
import bevy.ecs.Mut;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryAnyOfEntityMutDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryAnyOfEntityMutDisjointConstraint", function(app) {
            app.world.spawn([new QueryAnyOfEntityMutPlayerTag(10), new QueryAnyOfEntityMutHealth(4), new QueryAnyOfEntityMutScore(1)]);
            app.world.spawn([new QueryAnyOfEntityMutPlayerTag(20), new QueryAnyOfEntityMutHealth(5), new QueryAnyOfEntityMutScore(2)]);
            app.world.spawn([new QueryAnyOfEntityMutEnemyTag(30), new QueryAnyOfEntityMutHealth(7)]);
        }, 17);
    }

    @:system("Update")
    public static function legal(
        players:Query<AnyOf<Entity, Mut<QueryAnyOfEntityMutHealth>>, With<QueryAnyOfEntityMutPlayerTag>>,
        enemies:Query<QueryAnyOfEntityMutHealth, Without<QueryAnyOfEntityMutPlayerTag>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in players.iter()) {
            if (item.component._0.isSome()) {
                total += item.component._0.value.index;
            }
            if (item.component._1.isSome()) {
                total += item.component._1.value.value.value;
                item.component._1.value.setChanged();
            }
        }
        for (item in enemies.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class QueryAnyOfEntityMutPlayerTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryAnyOfEntityMutEnemyTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryAnyOfEntityMutHealth implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryAnyOfEntityMutScore implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}
