package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Added;
import bevy.ecs.All;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleAddedDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTupleAddedDisjointConstraint", function(app) {
            app.world.spawn([new TupleAddedDisjointHealth(5), new TupleAddedDisjointSpeed(7), new TupleAddedDisjointPlayerTag(100)]);
            app.world.spawn([new TupleAddedDisjointHealth(11), new TupleAddedDisjointSpeed(13)]);
        }, 23);
    }

    @:system("Update")
    public static function legal(
        tupleQuery:Query<Tuple2<TupleAddedDisjointHealth, TupleAddedDisjointSpeed>, With<TupleAddedDisjointPlayerTag>>,
        added:Query<TupleAddedDisjointHealth, All<Added<TupleAddedDisjointHealth>, Without<TupleAddedDisjointPlayerTag>>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            total += item.component._0.value + item.component._1.value;
        }
        for (item in added.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class TupleAddedDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleAddedDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleAddedDisjointPlayerTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}
