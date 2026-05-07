package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query3;
import bevy.ecs.ResMut;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTripleAnyOfDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTripleAnyOfDisjointConstraint", function(app) {
            app.world.spawn([
                new QueryTripleAnyOfDisjointHealth(5),
                new QueryTripleAnyOfDisjointTag(10),
                new QueryTripleAnyOfDisjointMarker(20),
                new QueryTripleAnyOfDisjointPlayerTag(100)
            ]);
            app.world.spawn([
                new QueryTripleAnyOfDisjointSpeed(7),
                new QueryTripleAnyOfDisjointTag(11),
                new QueryTripleAnyOfDisjointMarker(21),
                new QueryTripleAnyOfDisjointPlayerTag(101)
            ]);
            app.world.spawn([
                new QueryTripleAnyOfDisjointHealth(11),
                new QueryTripleAnyOfDisjointTag(12),
                new QueryTripleAnyOfDisjointMarker(22),
                new QueryTripleAnyOfDisjointEnemyTag(200)
            ]);
        }, 85);
    }

    @:system("Update")
    public static function legal(
        players:Query3<AnyOf<QueryTripleAnyOfDisjointHealth, QueryTripleAnyOfDisjointSpeed>, QueryTripleAnyOfDisjointTag, QueryTripleAnyOfDisjointMarker, With<QueryTripleAnyOfDisjointPlayerTag>>,
        enemies:Query<QueryTripleAnyOfDisjointHealth, Without<QueryTripleAnyOfDisjointPlayerTag>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in players.iter()) {
            total += item.b.value + item.c.value;
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

class QueryTripleAnyOfDisjointHealth implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleAnyOfDisjointSpeed implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleAnyOfDisjointTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleAnyOfDisjointMarker implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleAnyOfDisjointPlayerTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleAnyOfDisjointEnemyTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}
