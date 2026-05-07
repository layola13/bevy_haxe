package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Mut;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleMutDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTupleMutDisjointConstraint", function(app) {
            app.world.spawn([new TupleMutDisjointHealth(7), new TupleMutDisjointTag(5)]);
            app.world.spawn([new TupleMutDisjointHealth(13)]);
        }, 26);
    }

    @:system("Update")
    public static function legal(
        tagged:Query<Tuple<Mut<TupleMutDisjointHealth>, TupleMutDisjointTag>, With<TupleMutDisjointTag>>,
        untagged:Query<TupleMutDisjointHealth, Without<TupleMutDisjointTag>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in tagged.iter()) {
            item.component._0.value.value += 1;
            item.component._0.setChanged();
            total += item.component._0.value.value;
            total += item.component._1.value;
        }
        for (item in untagged.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class TupleMutDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleMutDisjointTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
