package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Option;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryOptionDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryOptionDisjointConstraint", function(app) {
            app.world.spawn([new OptionDisjointHealth(5), new OptionDisjointPlayerTag(100)]);
            app.world.spawn([new OptionDisjointHealth(11), new OptionDisjointEnemyTag(200)]);
        }, 16);
    }

    @:system("Update")
    public static function legal(
        players:Query<Option<OptionDisjointHealth>, With<OptionDisjointPlayerTag>>,
        enemies:Query<OptionDisjointHealth, Without<OptionDisjointPlayerTag>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in players.iter()) {
            if (item.component.isSome()) {
                total += item.component.value.value;
            }
        }
        for (item in enemies.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class OptionDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class OptionDisjointPlayerTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class OptionDisjointEnemyTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
