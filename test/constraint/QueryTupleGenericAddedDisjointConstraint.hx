package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Added;
import bevy.ecs.All;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleGenericAddedDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTupleGenericAddedDisjointConstraint", function(app) {
            app.world.spawn([new TupleGenericAddedDisjointHealth(5), new TupleGenericAddedDisjointSpeed(7), new TupleGenericAddedDisjointTag(100)]);
            app.world.spawn([new TupleGenericAddedDisjointHealth(11), new TupleGenericAddedDisjointSpeed(13)]);
        }, 23);
    }

    @:system("Update")
    public static function legal(
        tupleQuery:Query<Tuple<TupleGenericAddedDisjointHealth, TupleGenericAddedDisjointSpeed>, With<TupleGenericAddedDisjointTag>>,
        added:Query<TupleGenericAddedDisjointHealth, All<Added<TupleGenericAddedDisjointHealth>, Without<TupleGenericAddedDisjointTag>>>,
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

class TupleGenericAddedDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleGenericAddedDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleGenericAddedDisjointTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}
