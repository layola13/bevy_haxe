package constraint;

import bevy.app.SystemClass;
import bevy.ecs.All;
import bevy.ecs.Changed;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleChangedDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTupleChangedDisjointConstraint", function(app) {
            app.world.spawn([new TupleChangedDisjointHealth(5), new TupleChangedDisjointSpeed(7), new TupleChangedDisjointPlayerTag(100)]);
            app.world.spawn([new TupleChangedDisjointHealth(11), new TupleChangedDisjointSpeed(13)]);
        }, 23);
    }

    @:system("Update")
    public static function legal(tupleQuery:Query<Tuple2<TupleChangedDisjointHealth, TupleChangedDisjointSpeed>, With<TupleChangedDisjointPlayerTag>>, changed:Query<TupleChangedDisjointHealth, All<Changed<TupleChangedDisjointHealth>, Without<TupleChangedDisjointPlayerTag>>>, counter:ResMut<ConstraintCounter>):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            total += item.component._0.value + item.component._1.value;
        }
        for (item in changed.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class TupleChangedDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleChangedDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleChangedDisjointPlayerTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}
