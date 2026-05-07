package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query3;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTripleAnyOfWithoutBranchesDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTripleAnyOfWithoutBranchesDisjointConstraint", function(app) {
            app.world.spawn([
                new QueryTripleAnyOfWithoutBranchesHealth(5),
                new QueryTripleAnyOfWithoutBranchesShared(1),
                new QueryTripleAnyOfWithoutBranchesMarker(10),
                new QueryTripleAnyOfWithoutBranchesLeftTag()
            ]);
            app.world.spawn([
                new QueryTripleAnyOfWithoutBranchesSpeed(7),
                new QueryTripleAnyOfWithoutBranchesShared(2),
                new QueryTripleAnyOfWithoutBranchesMarker(11),
                new QueryTripleAnyOfWithoutBranchesLeftTag()
            ]);
            app.world.spawn([
                new QueryTripleAnyOfWithoutBranchesShared(3),
                new QueryTripleAnyOfWithoutBranchesMarker(12),
                new QueryTripleAnyOfWithoutBranchesRightTag()
            ]);
        }, 39);
    }

    @:system("Update")
    public static function legal(
        triple:Query3<AnyOf<QueryTripleAnyOfWithoutBranchesHealth, QueryTripleAnyOfWithoutBranchesSpeed>, QueryTripleAnyOfWithoutBranchesShared, QueryTripleAnyOfWithoutBranchesMarker, Tuple<With<QueryTripleAnyOfWithoutBranchesLeftTag>, Without<QueryTripleAnyOfWithoutBranchesRightTag>>>,
        withoutAny:Query<QueryTripleAnyOfWithoutBranchesShared, Tuple<With<QueryTripleAnyOfWithoutBranchesRightTag>, Without<QueryTripleAnyOfWithoutBranchesLeftTag>, Without<QueryTripleAnyOfWithoutBranchesHealth>, Without<QueryTripleAnyOfWithoutBranchesSpeed>>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in triple.iter()) {
            total += item.b.value + item.c.value;
            if (item.a._0.isSome()) {
                total += item.a._0.value.value;
            }
            if (item.a._1.isSome()) {
                total += item.a._1.value.value;
            }
        }
        for (item in withoutAny.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class QueryTripleAnyOfWithoutBranchesHealth implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleAnyOfWithoutBranchesSpeed implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleAnyOfWithoutBranchesShared implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleAnyOfWithoutBranchesMarker implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleAnyOfWithoutBranchesLeftTag implements Component {
    public function new() {}
}

class QueryTripleAnyOfWithoutBranchesRightTag implements Component {
    public function new() {}
}
