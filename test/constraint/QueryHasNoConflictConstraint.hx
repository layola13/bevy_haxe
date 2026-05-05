package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Has;
import bevy.ecs.Query;
import bevy.ecs.ResMut;

class QueryHasNoConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryHasNoConflictConstraint", function(app) {
            app.world.spawn([new HasNoConflictTag(7)]);
            app.world.spawn([new HasNoConflictMarker(3)]);
        }, 117);
    }

    @:system("Update")
    public static function legal(hasTag:Query<Has<HasNoConflictTag>>, tags:Query<HasNoConflictTag>, counter:ResMut<ConstraintCounter>):Void {
        var total = 0;
        for (item in hasTag.iter()) {
            total += item.component.value ? 100 : 10;
        }
        for (item in tags.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class HasNoConflictTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class HasNoConflictMarker implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
