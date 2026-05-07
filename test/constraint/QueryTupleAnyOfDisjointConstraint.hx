package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleAnyOfDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTupleAnyOfDisjointConstraint", function(app) {
            app.world.spawn([new QueryTupleAnyOfDisjointHealth(5), new QueryTupleAnyOfDisjointTag(10), new QueryTupleAnyOfDisjointPlayerTag(100)]);
            app.world.spawn([new QueryTupleAnyOfDisjointSpeed(7), new QueryTupleAnyOfDisjointTag(11), new QueryTupleAnyOfDisjointPlayerTag(101)]);
            app.world.spawn([new QueryTupleAnyOfDisjointHealth(11), new QueryTupleAnyOfDisjointTag(12), new QueryTupleAnyOfDisjointEnemyTag(200)]);
        }, 44);
    }

    @:system("Update")
    public static function legal(
        players:Query<Tuple2<AnyOf<QueryTupleAnyOfDisjointHealth, QueryTupleAnyOfDisjointSpeed>, QueryTupleAnyOfDisjointTag>, With<QueryTupleAnyOfDisjointPlayerTag>>,
        enemies:Query<QueryTupleAnyOfDisjointHealth, Without<QueryTupleAnyOfDisjointPlayerTag>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in players.iter()) {
            total += item.component._1.value;
            if (item.component._0._0.isSome()) {
                total += item.component._0._0.value.value;
            }
            if (item.component._0._1.isSome()) {
                total += item.component._0._1.value.value;
            }
        }
        for (item in enemies.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class QueryTupleAnyOfDisjointHealth implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleAnyOfDisjointSpeed implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleAnyOfDisjointTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleAnyOfDisjointPlayerTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleAnyOfDisjointEnemyTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}
