package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryDisjointConstraint", function(app) {
            app.world.spawn([new Health(3), new PlayerTag(20)]);
            app.world.spawn([new Health(7)]);
        }, 10);
    }

    @:system("Update")
    public static function legal(players:Query<Health, With<PlayerTag>>, enemies:Query<Health, Without<PlayerTag>>, counter:ResMut<ConstraintCounter>):Void {
        var total = 0;
        for (item in players.iter()) {
            total += item.component.value;
        }
        for (item in enemies.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class Health implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class PlayerTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}
