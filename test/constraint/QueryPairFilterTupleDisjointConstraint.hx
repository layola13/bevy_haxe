package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query2;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryPairFilterTupleDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryPairFilterTupleDisjointConstraint", function(app) {
            app.world.spawn([new PairFilterTupleDisjointHealth(5), new PairFilterTupleDisjointSpeed(7)]);
            app.world.spawn([new PairFilterTupleDisjointHealth(11), new PairFilterTupleDisjointTag(3)]);
        }, 23);
    }

    @:system("Update")
    public static function legal(
        pair:Query2<PairFilterTupleDisjointHealth, PairFilterTupleDisjointSpeed>,
        single:Query<PairFilterTupleDisjointHealth, Tuple2<With<PairFilterTupleDisjointTag>, Without<PairFilterTupleDisjointSpeed>>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in pair.iter()) {
            total += item.a.value + item.b.value;
        }
        for (item in single.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class PairFilterTupleDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class PairFilterTupleDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class PairFilterTupleDisjointTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
