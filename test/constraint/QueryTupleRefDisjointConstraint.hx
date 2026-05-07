package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Ref;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleRefDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTupleRefDisjointConstraint", function(app) {
            app.world.spawn([new TupleRefDisjointHealth(5), new TupleRefDisjointTag(7)]);
            app.world.spawn([new TupleRefDisjointHealth(11)]);
        }, 23);
    }

    @:system("Update")
    public static function legal(
        tagged:Query<Tuple<Ref<TupleRefDisjointHealth>, TupleRefDisjointTag>, With<TupleRefDisjointTag>>,
        untagged:Query<TupleRefDisjointHealth, Without<TupleRefDisjointTag>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in tagged.iter()) {
            total += item.component._0.value.value;
            total += item.component._1.value;
        }
        for (item in untagged.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class TupleRefDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleRefDisjointTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
