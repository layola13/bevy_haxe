package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryAnyOfNestedDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryAnyOfNestedDisjointConstraint", function(app) {
            app.world.spawn([new QueryAnyOfNestedDisjointPlayerTag(), new QueryAnyOfNestedDisjointHealth(5)]);
            app.world.spawn([new QueryAnyOfNestedDisjointPlayerTag(), new QueryAnyOfNestedDisjointSpeed(7)]);
            app.world.spawn([new QueryAnyOfNestedDisjointPlayerTag(), new QueryAnyOfNestedDisjointTag(11)]);
            app.world.spawn([new QueryAnyOfNestedDisjointEnemyTag(), new QueryAnyOfNestedDisjointHealth(13)]);
        }, 36);
    }

    @:system("Update")
    public static function legal(
        nested:Query<AnyOf<AnyOf<QueryAnyOfNestedDisjointHealth, QueryAnyOfNestedDisjointSpeed>, QueryAnyOfNestedDisjointTag>, With<QueryAnyOfNestedDisjointPlayerTag>>,
        enemies:Query<QueryAnyOfNestedDisjointHealth, Without<QueryAnyOfNestedDisjointPlayerTag>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in nested.iter()) {
            if (item.component._0.isSome()) {
                var inner = item.component._0.value;
                if (inner._0.isSome()) {
                    total += inner._0.value.value;
                }
                if (inner._1.isSome()) {
                    total += inner._1.value.value;
                }
            }
            if (item.component._1.isSome()) {
                total += item.component._1.value.value;
            }
        }
        for (item in enemies.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class QueryAnyOfNestedDisjointPlayerTag implements Component {
    public function new() {}
}

class QueryAnyOfNestedDisjointEnemyTag implements Component {
    public function new() {}
}

class QueryAnyOfNestedDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class QueryAnyOfNestedDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class QueryAnyOfNestedDisjointTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
