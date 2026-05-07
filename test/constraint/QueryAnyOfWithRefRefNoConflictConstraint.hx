package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;

class QueryAnyOfWithRefRefNoConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryAnyOfWithRefRefNoConflictConstraint", function(app) {
            app.world.spawn([new QueryAnyOfWithRefRefNoConflictHealth(4), new QueryAnyOfWithRefRefNoConflictTag(1)]);
            app.world.spawn([new QueryAnyOfWithRefRefNoConflictHealth(6)]);
            app.world.spawn([new QueryAnyOfWithRefRefNoConflictTag(2)]);
        }, 30);
    }

    @:system("Update")
    public static function legal(any:Query<AnyOf<QueryAnyOfWithRefRefNoConflictHealth, QueryAnyOfWithRefRefNoConflictHealth>>, counter:ResMut<ConstraintCounter>):Void {
        var total = 0;
        for (item in any.iter()) {
            if (item.component._0.isSome()) {
                total += item.component._0.value.value;
            }
            if (item.component._1.isSome()) {
                total += item.component._1.value.value * 2;
            }
        }
        counter.value.record(total);
    }
}

class QueryAnyOfWithRefRefNoConflictHealth implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryAnyOfWithRefRefNoConflictTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}
