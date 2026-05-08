package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query2;
import bevy.ecs.ResMut;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryPairNestedAnyOfDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryPairNestedAnyOfDisjointConstraint", function(app) {
            app.world.spawn([new QueryPairNestedAnyOfDisjointHealth(5), new QueryPairNestedAnyOfDisjointPlayerTag(100), new QueryPairNestedAnyOfDisjointMarker(1)]);
            app.world.spawn([new QueryPairNestedAnyOfDisjointSpeed(7), new QueryPairNestedAnyOfDisjointPlayerTag(101), new QueryPairNestedAnyOfDisjointMarker(2)]);
            app.world.spawn([new QueryPairNestedAnyOfDisjointTag(11), new QueryPairNestedAnyOfDisjointPlayerTag(102), new QueryPairNestedAnyOfDisjointMarker(3)]);
            app.world.spawn([new QueryPairNestedAnyOfDisjointHealth(13), new QueryPairNestedAnyOfDisjointEnemyTag(200), new QueryPairNestedAnyOfDisjointMarker(4)]);
        }, 27);
    }

    @:system("Update")
    public static function legal(
        players:Query2<AnyOf<AnyOf<QueryPairNestedAnyOfDisjointHealth, QueryPairNestedAnyOfDisjointSpeed>, QueryPairNestedAnyOfDisjointTag>, QueryPairNestedAnyOfDisjointMarker, With<QueryPairNestedAnyOfDisjointPlayerTag>>,
        enemies:Query<QueryPairNestedAnyOfDisjointHealth, Without<QueryPairNestedAnyOfDisjointPlayerTag>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in players.iter()) {
            if (item.a._0.isSome()) {
                var inner = item.a._0.value;
                if (inner._0.isSome()) {
                    total += inner._0.value.value;
                }
                if (inner._1.isSome()) {
                    total += inner._1.value.value;
                }
            }
            if (item.a._1.isSome()) {
                total += item.a._1.value.value;
            }
            total += item.b.value;
        }
        for (item in enemies.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class QueryPairNestedAnyOfDisjointHealth implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryPairNestedAnyOfDisjointSpeed implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryPairNestedAnyOfDisjointTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryPairNestedAnyOfDisjointMarker implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryPairNestedAnyOfDisjointPlayerTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryPairNestedAnyOfDisjointEnemyTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}
