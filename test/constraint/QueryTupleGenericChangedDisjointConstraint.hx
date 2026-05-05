package constraint;

import bevy.app.SystemClass;
import bevy.ecs.All;
import bevy.ecs.Changed;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleGenericChangedDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTupleGenericChangedDisjointConstraint", function(app) {
            app.world.spawn([new TupleGenericChangedDisjointHealth(5), new TupleGenericChangedDisjointSpeed(7), new TupleGenericChangedDisjointTag(100)]);
            app.world.spawn([new TupleGenericChangedDisjointHealth(11), new TupleGenericChangedDisjointSpeed(13)]);
        }, 23);
    }

    @:system("Update")
    public static function legal(
        tupleQuery:Query<Tuple<TupleGenericChangedDisjointHealth, TupleGenericChangedDisjointSpeed>, With<TupleGenericChangedDisjointTag>>,
        changed:Query<TupleGenericChangedDisjointHealth, All<Changed<TupleGenericChangedDisjointHealth>, Without<TupleGenericChangedDisjointTag>>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
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

class TupleGenericChangedDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleGenericChangedDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleGenericChangedDisjointTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}
