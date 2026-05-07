package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Has;
import bevy.ecs.Option;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryAnyOfNoRequiredBranchDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryAnyOfNoRequiredBranchDisjointConstraint", function(app) {
            app.world.spawn([new QueryAnyOfNoRequiredBranchDisjointTag(1), new QueryAnyOfNoRequiredBranchDisjointHealth(4)]);
            app.world.spawn([new QueryAnyOfNoRequiredBranchDisjointTag(2)]);
            app.world.spawn([new QueryAnyOfNoRequiredBranchDisjointEnemyTag(3), new QueryAnyOfNoRequiredBranchDisjointHealth(6)]);
        }, 11);
    }

    @:system("Update")
    public static function legal(
        any:Query<AnyOf<Has<QueryAnyOfNoRequiredBranchDisjointHealth>, Option<QueryAnyOfNoRequiredBranchDisjointHealth>>, With<QueryAnyOfNoRequiredBranchDisjointTag>>,
        enemyHealth:Query<QueryAnyOfNoRequiredBranchDisjointHealth, Without<QueryAnyOfNoRequiredBranchDisjointTag>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in any.iter()) {
            if (item.component._0.isSome() && item.component._0.value.value) {
                total += 1;
            }
            if (item.component._1.isSome() && item.component._1.value.isSome()) {
                total += item.component._1.value.value.value;
            }
        }
        for (item in enemyHealth.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class QueryAnyOfNoRequiredBranchDisjointTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class QueryAnyOfNoRequiredBranchDisjointEnemyTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class QueryAnyOfNoRequiredBranchDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
