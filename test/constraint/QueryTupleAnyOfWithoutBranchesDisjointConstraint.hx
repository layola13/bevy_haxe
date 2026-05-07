package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleAnyOfWithoutBranchesDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTupleAnyOfWithoutBranchesDisjointConstraint", function(app) {
            app.world.spawn([new QueryTupleAnyOfWithoutBranchesHealth(5), new QueryTupleAnyOfWithoutBranchesShared(1), new QueryTupleAnyOfWithoutBranchesLeftTag()]);
            app.world.spawn([new QueryTupleAnyOfWithoutBranchesSpeed(7), new QueryTupleAnyOfWithoutBranchesShared(2), new QueryTupleAnyOfWithoutBranchesLeftTag()]);
            app.world.spawn([new QueryTupleAnyOfWithoutBranchesShared(3), new QueryTupleAnyOfWithoutBranchesRightTag()]);
        }, 18);
    }

    @:system("Update")
    public static function legal(
        tupleQuery:Query<Tuple2<AnyOf<QueryTupleAnyOfWithoutBranchesHealth, QueryTupleAnyOfWithoutBranchesSpeed>, QueryTupleAnyOfWithoutBranchesShared>, Tuple<With<QueryTupleAnyOfWithoutBranchesLeftTag>, Without<QueryTupleAnyOfWithoutBranchesRightTag>>>,
        withoutAny:Query<QueryTupleAnyOfWithoutBranchesShared, Tuple<With<QueryTupleAnyOfWithoutBranchesRightTag>, Without<QueryTupleAnyOfWithoutBranchesLeftTag>, Without<QueryTupleAnyOfWithoutBranchesHealth>, Without<QueryTupleAnyOfWithoutBranchesSpeed>>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            total += item.component._1.value;
            if (item.component._0._0.isSome()) {
                total += item.component._0._0.value.value;
            }
            if (item.component._0._1.isSome()) {
                total += item.component._0._1.value.value;
            }
        }
        for (item in withoutAny.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class QueryTupleAnyOfWithoutBranchesHealth implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleAnyOfWithoutBranchesSpeed implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleAnyOfWithoutBranchesShared implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleAnyOfWithoutBranchesLeftTag implements Component {
    public function new() {}
}

class QueryTupleAnyOfWithoutBranchesRightTag implements Component {
    public function new() {}
}
