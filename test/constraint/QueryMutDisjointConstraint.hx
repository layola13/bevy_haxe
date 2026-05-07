package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Mut;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryMutDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryMutDisjointConstraint", function(app) {
            app.world.spawn([new MutDisjointHealth(7), new MutDisjointTag(1)]);
            app.world.spawn([new MutDisjointHealth(13)]);
        }, 21);
    }

    @:system("Update")
    public static function legal(
        tagged:Query<Mut<MutDisjointHealth>, With<MutDisjointTag>>,
        untagged:Query<MutDisjointHealth, Without<MutDisjointTag>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in tagged.iter()) {
            item.component.value.value += 1;
            item.component.setChanged();
            total += item.component.value.value;
        }
        for (item in untagged.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class MutDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class MutDisjointTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
