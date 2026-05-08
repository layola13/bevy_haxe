package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Option;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryOptionOptionDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryOptionOptionDisjointConstraint", function(app) {
            app.world.spawn([new QueryOptionOptionDisjointTag(), new QueryOptionOptionDisjointHealth(5)]);
            app.world.spawn([new QueryOptionOptionDisjointTag()]);
            app.world.spawn([new QueryOptionOptionDisjointHealth(11)]);
        }, 116);
    }

    @:system("Update")
    public static function legal(
        players:Query<Option<Option<QueryOptionOptionDisjointHealth>>, With<QueryOptionOptionDisjointTag>>,
        others:Query<QueryOptionOptionDisjointHealth, Without<QueryOptionOptionDisjointTag>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in players.iter()) {
            if (!item.component.isSome()) {
                total += 1;
                continue;
            }
            var inner = item.component.value;
            if (inner.isSome()) {
                total += inner.value.value;
            } else {
                total += 100;
            }
        }
        for (item in others.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class QueryOptionOptionDisjointTag implements Component {
    public function new() {}
}

class QueryOptionOptionDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
