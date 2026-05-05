package constraint;

import bevy.app.SystemClass;
import bevy.ecs.All;
import bevy.ecs.Changed;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query2;
import bevy.ecs.ResMut;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryPairChangedDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryPairChangedDisjointConstraint", function(app) {
            app.world.spawn([new PairChangedDisjointHealth(5), new PairChangedDisjointSpeed(7), new PairChangedDisjointTag(100)]);
            app.world.spawn([new PairChangedDisjointHealth(11), new PairChangedDisjointSpeed(13)]);
        }, 23);
    }

    @:system("Update")
    public static function legal(
        pair:Query2<PairChangedDisjointHealth, PairChangedDisjointSpeed, With<PairChangedDisjointTag>>,
        changed:Query<PairChangedDisjointHealth, All<Changed<PairChangedDisjointHealth>, Without<PairChangedDisjointTag>>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in pair.iter()) {
            total += item.a.value + item.b.value;
        }
        for (item in changed.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class PairChangedDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class PairChangedDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class PairChangedDisjointTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}
