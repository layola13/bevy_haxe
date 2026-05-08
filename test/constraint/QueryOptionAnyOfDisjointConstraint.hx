package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Option;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryOptionAnyOfDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryOptionAnyOfDisjointConstraint", function(app) {
            app.world.spawn([new QueryOptionAnyOfDisjointPlayerTag(), new QueryOptionAnyOfDisjointHealth(5)]);
            app.world.spawn([new QueryOptionAnyOfDisjointPlayerTag(), new QueryOptionAnyOfDisjointSpeed(7)]);
            app.world.spawn([new QueryOptionAnyOfDisjointEnemyTag(), new QueryOptionAnyOfDisjointHealth(11)]);
        }, 23);
    }

    @:system("Update")
    public static function legal(
        players:Query<Option<AnyOf<QueryOptionAnyOfDisjointHealth, QueryOptionAnyOfDisjointSpeed>>, With<QueryOptionAnyOfDisjointPlayerTag>>,
        enemies:Query<QueryOptionAnyOfDisjointHealth, Without<QueryOptionAnyOfDisjointPlayerTag>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in players.iter()) {
            if (item.component.isSome()) {
                var any = item.component.value;
                if (any._0.isSome()) {
                    total += any._0.value.value;
                }
                if (any._1.isSome()) {
                    total += any._1.value.value;
                }
            }
        }
        for (item in enemies.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class QueryOptionAnyOfDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class QueryOptionAnyOfDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class QueryOptionAnyOfDisjointPlayerTag implements Component {
    public function new() {}
}

class QueryOptionAnyOfDisjointEnemyTag implements Component {
    public function new() {}
}
