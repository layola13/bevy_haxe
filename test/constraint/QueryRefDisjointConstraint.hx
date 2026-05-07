package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Ref;
import bevy.ecs.ResMut;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryRefDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryRefDisjointConstraint", function(app) {
            app.world.spawn([new RefDisjointHealth(5), new RefDisjointTag(1)]);
            app.world.spawn([new RefDisjointHealth(11)]);
        }, 16);
    }

    @:system("Update")
    public static function legal(
        tagged:Query<Ref<RefDisjointHealth>, With<RefDisjointTag>>,
        untagged:Query<RefDisjointHealth, Without<RefDisjointTag>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in tagged.iter()) {
            total += item.component.value.value;
        }
        for (item in untagged.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class RefDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class RefDisjointTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
