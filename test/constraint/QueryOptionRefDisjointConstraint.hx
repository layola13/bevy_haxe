package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Option;
import bevy.ecs.Query;
import bevy.ecs.Ref;
import bevy.ecs.ResMut;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryOptionRefDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryOptionRefDisjointConstraint", function(app) {
            app.world.spawn([new OptionRefDisjointHealth(5), new OptionRefDisjointPlayerTag()]);
            app.world.spawn([new OptionRefDisjointPlayerTag()]);
            app.world.spawn([new OptionRefDisjointHealth(11)]);
        }, 16);
    }

    @:system("Update")
    public static function legal(
        players:Query<Option<Ref<OptionRefDisjointHealth>>, With<OptionRefDisjointPlayerTag>>,
        enemies:Query<OptionRefDisjointHealth, Without<OptionRefDisjointPlayerTag>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in players.iter()) {
            if (item.component.isSome()) {
                total += item.component.value.value.value;
            }
        }
        for (item in enemies.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class OptionRefDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class OptionRefDisjointPlayerTag implements Component {
    public function new() {}
}
