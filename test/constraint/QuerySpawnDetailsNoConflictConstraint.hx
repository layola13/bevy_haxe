package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.SpawnDetails;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.With;

class QuerySpawnDetailsNoConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QuerySpawnDetailsNoConflictConstraint", function(app) {
            app.world.spawn([new SpawnDetailsHealth(5), new SpawnDetailsTag(100)]);
            app.world.spawn([new SpawnDetailsHealth(11)]);
        }, 118);
    }

    @:system("Update")
    public static function legal(
        health:Query<SpawnDetailsHealth>,
        details:Query<Tuple<bevy.ecs.Entity, SpawnDetails>, With<SpawnDetailsTag>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in health.iter()) {
            total += item.component.value;
        }
        for (item in details.iter()) {
            if (item.component._0.index == item.entity.index && item.component._1.isSpawned()) {
                total += 102;
            }
        }
        counter.value.record(total);
    }
}

class SpawnDetailsHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class SpawnDetailsTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}
