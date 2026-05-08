package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Mut;
import bevy.ecs.Option;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryOptionMutDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryOptionMutDisjointConstraint", function(app) {
            app.world.spawn([new OptionMutDisjointHealth(5), new OptionMutDisjointPlayerTag()]);
            app.world.spawn([new OptionMutDisjointPlayerTag()]);
            app.world.spawn([new OptionMutDisjointHealth(11)]);
        }, 16);
    }

    @:system("Update")
    public static function legal(
        players:Query<Option<Mut<OptionMutDisjointHealth>>, With<OptionMutDisjointPlayerTag>>,
        enemies:Query<OptionMutDisjointHealth, Without<OptionMutDisjointPlayerTag>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in players.iter()) {
            if (item.component.isSome()) {
                total += item.component.value.value.value;
                item.component.value.setChanged();
            }
        }
        for (item in enemies.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class OptionMutDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class OptionMutDisjointPlayerTag implements Component {
    public function new() {}
}
