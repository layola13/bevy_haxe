package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.Without;

class QueryTupleGenericDataDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTupleGenericDataDisjointConstraint", function(app) {
            app.world.spawn([new TupleGenericDataDisjointA(2), new TupleGenericDataDisjointB(5)]);
            app.world.spawn([new TupleGenericDataDisjointA(11)]);
        }, 18);
    }

    @:system("Update")
    public static function legal(tupleQuery:Query<Tuple<TupleGenericDataDisjointA, TupleGenericDataDisjointB>>, single:Query<TupleGenericDataDisjointA, Without<TupleGenericDataDisjointB>>, counter:ResMut<ConstraintCounter>):Void {
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

class TupleGenericDataDisjointA implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleGenericDataDisjointB implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
