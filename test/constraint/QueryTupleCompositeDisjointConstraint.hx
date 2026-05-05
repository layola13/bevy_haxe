package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.Without;

class QueryTupleCompositeDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTupleCompositeDisjointConstraint", function(app) {
            app.world.spawn([new TupleCompositeHealth(3), new TupleCompositeSpeed(4)]);
            app.world.spawn([new TupleCompositeHealth(11)]);
        }, 18);
    }

    @:system("Update")
    public static function legal(tupleQuery:Query<Tuple2<TupleCompositeHealth, TupleCompositeSpeed>>, single:Query<TupleCompositeHealth, Or<Without<TupleCompositeSpeed>, Without<TupleCompositeHealth>>>, counter:ResMut<ConstraintCounter>):Void {
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

class TupleCompositeHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleCompositeSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
