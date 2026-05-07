package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.Without;

class QueryAnyOfAndWithoutDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryAnyOfAndWithoutDisjointConstraint", function(app) {
            app.world.spawn([new QueryAnyOfAndWithoutDisjointHealth(5), new QueryAnyOfAndWithoutDisjointC(10)]);
            app.world.spawn([new QueryAnyOfAndWithoutDisjointSpeed(7), new QueryAnyOfAndWithoutDisjointC(20)]);
            app.world.spawn([new QueryAnyOfAndWithoutDisjointHealth(11), new QueryAnyOfAndWithoutDisjointD(30)]);
        }, 23);
    }

    @:system("Update")
    public static function legal(
        first:Query<AnyOf<QueryAnyOfAndWithoutDisjointHealth, QueryAnyOfAndWithoutDisjointSpeed>>,
        second:Query<QueryAnyOfAndWithoutDisjointC, Tuple2<Without<QueryAnyOfAndWithoutDisjointHealth>, Without<QueryAnyOfAndWithoutDisjointSpeed>>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in first.iter()) {
            if (item.component._0.isSome()) {
                total += item.component._0.value.value;
            }
            if (item.component._1.isSome()) {
                total += item.component._1.value.value;
            }
        }
        for (item in second.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class QueryAnyOfAndWithoutDisjointHealth implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryAnyOfAndWithoutDisjointSpeed implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryAnyOfAndWithoutDisjointC implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryAnyOfAndWithoutDisjointD implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}
