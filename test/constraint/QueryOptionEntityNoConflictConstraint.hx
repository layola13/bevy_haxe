package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Option;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.With;

class QueryOptionEntityNoConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryOptionEntityNoConflictConstraint", function(app) {
            app.world.spawn([new OptionEntityNoConflictTag(), new OptionEntityNoConflictHealth(5)]);
            app.world.spawn([new OptionEntityNoConflictTag()]);
        }, 2);
    }

    @:system("Update")
    public static function legal(optionalEntity:Query<Option<bevy.ecs.Entity>, With<OptionEntityNoConflictTag>>, counter:ResMut<ConstraintCounter>):Void {
        var total = 0;
        for (item in optionalEntity.iter()) {
            if (item.component.isSome()) {
                total += 1;
            }
        }
        counter.value.record(total);
    }
}

class OptionEntityNoConflictTag implements Component {
    public function new() {}
}

class OptionEntityNoConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
