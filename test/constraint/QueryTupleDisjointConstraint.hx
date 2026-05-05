package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTupleDisjointConstraint", function(app) {
            app.world.spawn([new TupleDisjointHealth(5), new TupleDisjointSpeed(7), new TupleDisjointPlayerTag(100)]);
            app.world.spawn([new TupleDisjointHealth(11), new TupleDisjointSpeed(13)]);
        }, 23);
    }

    @:system("Update")
    public static function legal(players:Query<Tuple2<TupleDisjointHealth, TupleDisjointSpeed>, With<TupleDisjointPlayerTag>>, enemies:Query<TupleDisjointHealth, Without<TupleDisjointPlayerTag>>, counter:ResMut<ConstraintCounter>):Void {
        var total = 0;
        for (item in players.iter()) {
            total += item.component._0.value + item.component._1.value;
        }
        for (item in enemies.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class TupleDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleDisjointPlayerTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}
