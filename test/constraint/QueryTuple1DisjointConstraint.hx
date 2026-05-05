package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple1;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTuple1DisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTuple1DisjointConstraint", function(app) {
            app.world.spawn([new Tuple1DisjointHealth(5), new Tuple1DisjointPlayerTag(100)]);
            app.world.spawn([new Tuple1DisjointHealth(11)]);
        }, 16);
    }

    @:system("Update")
    public static function legal(players:Query<Tuple1<Tuple1DisjointHealth>, With<Tuple1DisjointPlayerTag>>, enemies:Query<Tuple1DisjointHealth, Without<Tuple1DisjointPlayerTag>>, counter:ResMut<ConstraintCounter>):Void {
        var total = 0;
        for (item in players.iter()) {
            total += item.component._0.value;
        }
        for (item in enemies.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class Tuple1DisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple1DisjointPlayerTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}
