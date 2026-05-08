package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query3;
import bevy.ecs.ResMut;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTripleNestedAnyOfDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTripleNestedAnyOfDisjointConstraint", function(app) {
            app.world.spawn([
                new QueryTripleNestedAnyOfDisjointHealth(5),
                new QueryTripleNestedAnyOfDisjointMarker(10),
                new QueryTripleNestedAnyOfDisjointFlag(20),
                new QueryTripleNestedAnyOfDisjointPlayerTag(100)
            ]);
            app.world.spawn([
                new QueryTripleNestedAnyOfDisjointSpeed(7),
                new QueryTripleNestedAnyOfDisjointMarker(11),
                new QueryTripleNestedAnyOfDisjointFlag(21),
                new QueryTripleNestedAnyOfDisjointPlayerTag(101)
            ]);
            app.world.spawn([
                new QueryTripleNestedAnyOfDisjointTag(11),
                new QueryTripleNestedAnyOfDisjointMarker(12),
                new QueryTripleNestedAnyOfDisjointFlag(22),
                new QueryTripleNestedAnyOfDisjointPlayerTag(102)
            ]);
            app.world.spawn([
                new QueryTripleNestedAnyOfDisjointHealth(13),
                new QueryTripleNestedAnyOfDisjointMarker(13),
                new QueryTripleNestedAnyOfDisjointFlag(23),
                new QueryTripleNestedAnyOfDisjointEnemyTag(200)
            ]);
        }, 58);
    }

    @:system("Update")
    public static function legal(
        players:Query3<AnyOf<AnyOf<QueryTripleNestedAnyOfDisjointHealth, QueryTripleNestedAnyOfDisjointSpeed>, QueryTripleNestedAnyOfDisjointTag>, QueryTripleNestedAnyOfDisjointMarker, QueryTripleNestedAnyOfDisjointFlag, With<QueryTripleNestedAnyOfDisjointPlayerTag>>,
        enemies:Query<QueryTripleNestedAnyOfDisjointHealth, Without<QueryTripleNestedAnyOfDisjointPlayerTag>>,
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
            total += item.b.value + item.c.value;
        }
        for (item in enemies.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class QueryTripleNestedAnyOfDisjointHealth implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleNestedAnyOfDisjointSpeed implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleNestedAnyOfDisjointTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleNestedAnyOfDisjointMarker implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleNestedAnyOfDisjointFlag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleNestedAnyOfDisjointPlayerTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleNestedAnyOfDisjointEnemyTag implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}
