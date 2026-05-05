package constraint;

import bevy.app.SystemClass;
import bevy.ecs.All;
import bevy.ecs.Changed;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query3;
import bevy.ecs.ResMut;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTripleChangedDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTripleChangedDisjointConstraint", function(app) {
            app.world.spawn([new TripleChangedDisjointHealth(2), new TripleChangedDisjointTag(3), new TripleChangedDisjointSpeed(5), new TripleChangedDisjointPlayerTag(100)]);
            app.world.spawn([new TripleChangedDisjointHealth(11), new TripleChangedDisjointTag(13), new TripleChangedDisjointSpeed(17)]);
        }, 21);
    }

    @:system("Update")
    public static function legal(
        triple:Query3<TripleChangedDisjointHealth, TripleChangedDisjointTag, TripleChangedDisjointSpeed, With<TripleChangedDisjointPlayerTag>>,
        changed:Query<TripleChangedDisjointHealth, All<Changed<TripleChangedDisjointHealth>, Without<TripleChangedDisjointPlayerTag>>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in triple.iter()) {
            total += item.a.value + item.b.value + item.c.value;
        }
        for (item in changed.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class TripleChangedDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleChangedDisjointTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleChangedDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleChangedDisjointPlayerTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}
