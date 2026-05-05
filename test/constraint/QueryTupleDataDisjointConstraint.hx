package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.Without;

class QueryTupleDataDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTupleDataDisjointConstraint", function(app) {
            app.world.spawn([new TupleDataHealth(2), new TupleDataTag(5)]);
            app.world.spawn([new TupleDataHealth(11)]);
        }, 18);
    }

    @:system("Update")
    public static function legal(tupleQuery:Query<Tuple2<TupleDataHealth, TupleDataTag>>, single:Query<TupleDataHealth, Without<TupleDataTag>>, counter:ResMut<ConstraintCounter>):Void {
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

class TupleDataHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleDataTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
