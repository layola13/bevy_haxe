package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query2;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryPairAnyOfWithoutBranchesDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryPairAnyOfWithoutBranchesDisjointConstraint", function(app) {
            app.world.spawn([new QueryPairAnyOfWithoutBranchesHealth(5), new QueryPairAnyOfWithoutBranchesShared(1), new QueryPairAnyOfWithoutBranchesLeftTag()]);
            app.world.spawn([new QueryPairAnyOfWithoutBranchesSpeed(7), new QueryPairAnyOfWithoutBranchesShared(2), new QueryPairAnyOfWithoutBranchesLeftTag()]);
            app.world.spawn([new QueryPairAnyOfWithoutBranchesShared(3), new QueryPairAnyOfWithoutBranchesRightTag()]);
        }, 18);
    }

    @:system("Update")
    public static function legal(
        anyShared:Query2<AnyOf<QueryPairAnyOfWithoutBranchesHealth, QueryPairAnyOfWithoutBranchesSpeed>, QueryPairAnyOfWithoutBranchesShared, Tuple<With<QueryPairAnyOfWithoutBranchesLeftTag>, Without<QueryPairAnyOfWithoutBranchesRightTag>>>,
        noneAnyShared:Query<QueryPairAnyOfWithoutBranchesShared, Tuple<With<QueryPairAnyOfWithoutBranchesRightTag>, Without<QueryPairAnyOfWithoutBranchesLeftTag>, Without<QueryPairAnyOfWithoutBranchesHealth>, Without<QueryPairAnyOfWithoutBranchesSpeed>>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in anyShared.iter()) {
            total += item.b.value;
            if (item.a._0.isSome()) {
                total += item.a._0.value.value;
            }
            if (item.a._1.isSome()) {
                total += item.a._1.value.value;
            }
        }
        for (item in noneAnyShared.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class QueryPairAnyOfWithoutBranchesHealth implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryPairAnyOfWithoutBranchesSpeed implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryPairAnyOfWithoutBranchesShared implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryPairAnyOfWithoutBranchesLeftTag implements Component {
    public function new() {}
}

class QueryPairAnyOfWithoutBranchesRightTag implements Component {
    public function new() {}
}
