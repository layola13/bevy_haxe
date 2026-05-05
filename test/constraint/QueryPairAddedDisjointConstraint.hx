package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Added;
import bevy.ecs.All;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query2;
import bevy.ecs.ResMut;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryPairAddedDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryPairAddedDisjointConstraint", function(app) {
            app.world.spawn([new PairAddedDisjointHealth(5), new PairAddedDisjointSpeed(7), new PairAddedDisjointTag(100)]);
            app.world.spawn([new PairAddedDisjointHealth(11), new PairAddedDisjointSpeed(13)]);
        }, 23);
    }

    @:system("Update")
    public static function legal(
        pair:Query2<PairAddedDisjointHealth, PairAddedDisjointSpeed, With<PairAddedDisjointTag>>,
        single:Query<PairAddedDisjointHealth, All<Added<PairAddedDisjointHealth>, Without<PairAddedDisjointTag>>>,
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

class PairAddedDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class PairAddedDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class PairAddedDisjointTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}
