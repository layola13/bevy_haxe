package constraint;

import bevy.app.SystemClass;
import bevy.ecs.All;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Spawned;
import bevy.ecs.With;
import bevy.ecs.Without;

class QuerySpawnedDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QuerySpawnedDisjointConstraint", function(app) {
            app.world.spawn([new SpawnedDisjointHealth(5), new SpawnedDisjointPlayerTag(100)]);
            app.world.spawn([new SpawnedDisjointHealth(11), new SpawnedDisjointEnemyTag(200)]);
        }, 16);
    }

    @:system("Update")
    public static function legal(
        players:Query<SpawnedDisjointHealth, All<Spawned, With<SpawnedDisjointPlayerTag>>>,
        enemies:Query<SpawnedDisjointHealth, Without<SpawnedDisjointPlayerTag>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in players.iter()) {
            total += item.component.value;
        }
        for (item in enemies.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class SpawnedDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class SpawnedDisjointPlayerTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}

class SpawnedDisjointEnemyTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}
