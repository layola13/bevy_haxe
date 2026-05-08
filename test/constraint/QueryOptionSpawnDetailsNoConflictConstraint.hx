package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Option;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.SpawnDetails;
import bevy.ecs.With;

class QueryOptionSpawnDetailsNoConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryOptionSpawnDetailsNoConflictConstraint", function(app) {
            app.world.spawn([new OptionSpawnDetailsNoConflictTag(), new OptionSpawnDetailsNoConflictHealth(5)]);
            app.world.spawn([new OptionSpawnDetailsNoConflictTag()]);
        }, 2);
    }

    @:system("Update")
    public static function legal(optionalDetails:Query<Option<SpawnDetails>, With<OptionSpawnDetailsNoConflictTag>>, counter:ResMut<ConstraintCounter>):Void {
        var total = 0;
        for (item in optionalDetails.iter()) {
            if (item.component.isSome()) {
                total += item.component.value.spawnTick() > 0 ? 1 : 10;
            }
        }
        counter.value.record(total);
    }
}

class OptionSpawnDetailsNoConflictTag implements Component {
    public function new() {}
}

class OptionSpawnDetailsNoConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
