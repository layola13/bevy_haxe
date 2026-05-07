package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.Query.Query2;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryPairNestedTupleOrDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryPairNestedTupleOrDisjointConstraint", function(app) {
            app.world.spawn([new PairNestedTupleOrDisjointHealth(3), new PairNestedTupleOrDisjointSpeed(4)]);
            app.world.spawn([new PairNestedTupleOrDisjointHealth(11), new PairNestedTupleOrDisjointTag(2)]);
        }, 18);
    }

    @:system("Update")
    public static function legal(
        pair:Query2<PairNestedTupleOrDisjointHealth, PairNestedTupleOrDisjointSpeed>,
        single:Query<PairNestedTupleOrDisjointHealth, Or<Tuple2<With<PairNestedTupleOrDisjointTag>, Without<PairNestedTupleOrDisjointSpeed>>, Tuple2<Without<PairNestedTupleOrDisjointSpeed>, Without<PairNestedTupleOrDisjointTag>>>>,
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

class PairNestedTupleOrDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class PairNestedTupleOrDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class PairNestedTupleOrDisjointTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
