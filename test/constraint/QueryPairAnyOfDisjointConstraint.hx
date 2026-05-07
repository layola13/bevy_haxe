package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query2;
import bevy.ecs.ResMut;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryPairAnyOfDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryPairAnyOfDisjointConstraint", function(app) {
            app.world.spawn([new QueryPairAnyOfDisjointHealth(5), new QueryPairAnyOfDisjointPlayerTag(100), new QueryPairAnyOfDisjointTag(1)]);
            app.world.spawn([new QueryPairAnyOfDisjointSpeed(7), new QueryPairAnyOfDisjointPlayerTag(101), new QueryPairAnyOfDisjointTag(2)]);
            app.world.spawn([new QueryPairAnyOfDisjointHealth(11), new QueryPairAnyOfDisjointEnemyTag(200), new QueryPairAnyOfDisjointTag(3)]);
        }, 26);
    }

    @:system("Update")
    public static function legal(
        players:Query2<AnyOf<QueryPairAnyOfDisjointHealth, QueryPairAnyOfDisjointSpeed>, QueryPairAnyOfDisjointTag, With<QueryPairAnyOfDisjointPlayerTag>>,
        enemies:Query<QueryPairAnyOfDisjointHealth, Without<QueryPairAnyOfDisjointPlayerTag>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in players.iter()) {
            total += item.b.value;
            if (item.a._0.isSome()) {
                total += item.a._0.value.value;
            }
            if (item.a._1.isSome()) {
                total += item.a._1.value.value;
            }
        }
        for (item in enemies.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class QueryPairAnyOfDisjointHealth implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryPairAnyOfDisjointSpeed implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryPairAnyOfDisjointTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryPairAnyOfDisjointPlayerTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryPairAnyOfDisjointEnemyTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}
