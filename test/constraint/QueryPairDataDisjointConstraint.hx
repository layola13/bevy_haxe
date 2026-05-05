package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query2;
import bevy.ecs.ResMut;
import bevy.ecs.Without;

class QueryPairDataDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryPairDataDisjointConstraint", function(app) {
            app.world.spawn([new PairDataHealth(2), new PairDataTag(5)]);
            app.world.spawn([new PairDataHealth(11)]);
        }, 18);
    }

    @:system("Update")
    public static function legal(pairQuery:Query2<PairDataHealth, PairDataTag>, single:Query<PairDataHealth, Without<PairDataTag>>, counter:ResMut<ConstraintCounter>):Void {
        var total = 0;
        for (item in pairQuery.iter()) {
            total += item.a.value + item.b.value;
        }
        for (item in single.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class PairDataHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class PairDataTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
