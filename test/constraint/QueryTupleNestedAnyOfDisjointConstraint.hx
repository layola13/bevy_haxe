package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleNestedAnyOfDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTupleNestedAnyOfDisjointConstraint", function(app) {
            app.world.spawn([new QueryTupleNestedAnyOfDisjointHealth(5), new QueryTupleNestedAnyOfDisjointMarker(10), new QueryTupleNestedAnyOfDisjointPlayerTag(100)]);
            app.world.spawn([new QueryTupleNestedAnyOfDisjointSpeed(7), new QueryTupleNestedAnyOfDisjointMarker(11), new QueryTupleNestedAnyOfDisjointPlayerTag(101)]);
            app.world.spawn([new QueryTupleNestedAnyOfDisjointTag(11), new QueryTupleNestedAnyOfDisjointMarker(12), new QueryTupleNestedAnyOfDisjointPlayerTag(102)]);
            app.world.spawn([new QueryTupleNestedAnyOfDisjointHealth(13), new QueryTupleNestedAnyOfDisjointMarker(13), new QueryTupleNestedAnyOfDisjointEnemyTag(200)]);
        }, 36);
    }

    @:system("Update")
    public static function legal(
        players:Query<Tuple2<AnyOf<AnyOf<QueryTupleNestedAnyOfDisjointHealth, QueryTupleNestedAnyOfDisjointSpeed>, QueryTupleNestedAnyOfDisjointTag>, QueryTupleNestedAnyOfDisjointMarker>, With<QueryTupleNestedAnyOfDisjointPlayerTag>>,
        enemies:Query<QueryTupleNestedAnyOfDisjointHealth, Without<QueryTupleNestedAnyOfDisjointPlayerTag>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in players.iter()) {
            if (item.component._0._0.isSome()) {
                var inner = item.component._0._0.value;
                if (inner._0.isSome()) {
                    total += inner._0.value.value;
                }
                if (inner._1.isSome()) {
                    total += inner._1.value.value;
                }
            }
            if (item.component._0._1.isSome()) {
                total += item.component._0._1.value.value;
            }
            total += item.component._1.value;
        }
        for (item in enemies.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class QueryTupleNestedAnyOfDisjointHealth implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleNestedAnyOfDisjointSpeed implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleNestedAnyOfDisjointTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleNestedAnyOfDisjointMarker implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleNestedAnyOfDisjointPlayerTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleNestedAnyOfDisjointEnemyTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}
