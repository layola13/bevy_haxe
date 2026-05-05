package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.Query.Query2;
import bevy.ecs.ResMut;
import bevy.ecs.Without;

class QueryPairCompositeDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryPairCompositeDisjointConstraint", function(app) {
            app.world.spawn([new PairCompositeDisjointHealth(3), new PairCompositeDisjointSpeed(4)]);
            app.world.spawn([new PairCompositeDisjointHealth(11)]);
        }, 18);
    }

    @:system("Update")
    public static function legal(
        pair:Query2<PairCompositeDisjointHealth, PairCompositeDisjointSpeed>,
        single:Query<PairCompositeDisjointHealth, Or<Without<PairCompositeDisjointSpeed>, Without<PairCompositeDisjointHealth>>>,
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

class PairCompositeDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class PairCompositeDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
