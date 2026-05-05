package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Spawned;

class QuerySpawnedConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QuerySpawnedConflictConstraint");
    }

    @:system("Update")
    public static function illegal(all:Query<SpawnedConflictHealth>, spawned:Query<SpawnedConflictHealth, Spawned>):Void {
        var total = 0;
        for (item in all.iter()) {
            total += item.component.value;
        }
        for (item in spawned.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable spawned query conflict probe";
        }
    }
}

class SpawnedConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
