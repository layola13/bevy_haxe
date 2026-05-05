package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.Without;

class QueryTupleGenericCompositeDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTupleGenericCompositeDisjointConstraint", function(app) {
            app.world.spawn([new TupleGenericCompositeHealth(3), new TupleGenericCompositeSpeed(4)]);
            app.world.spawn([new TupleGenericCompositeHealth(11)]);
        }, 18);
    }

    @:system("Update")
    public static function legal(tupleQuery:Query<Tuple<TupleGenericCompositeHealth, TupleGenericCompositeSpeed>>, single:Query<TupleGenericCompositeHealth, Or<Without<TupleGenericCompositeSpeed>, Without<TupleGenericCompositeHealth>>>, counter:ResMut<ConstraintCounter>):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            total += item.component._0.value + item.component._1.value;
        }
        for (item in single.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class TupleGenericCompositeHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleGenericCompositeSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
