package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Has;
import bevy.ecs.Option;
import bevy.ecs.Query;
import bevy.ecs.ResMut;

class QueryOptionHasNoConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryOptionHasNoConflictConstraint", function(app) {
            app.world.spawn([new OptionHasNoConflictTag(7)]);
            app.world.spawn([new OptionHasNoConflictMarker(3)]);
        }, 117);
    }

    @:system("Update")
    public static function legal(optionalHasTag:Query<Option<Has<OptionHasNoConflictTag>>>, tags:Query<OptionHasNoConflictTag>, counter:ResMut<ConstraintCounter>):Void {
        var total = 0;
        for (item in optionalHasTag.iter()) {
            if (item.component.isSome()) {
                total += item.component.value.value ? 100 : 10;
            }
        }
        for (item in tags.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class OptionHasNoConflictTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class OptionHasNoConflictMarker implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
