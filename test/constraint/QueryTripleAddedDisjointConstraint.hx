package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Added;
import bevy.ecs.All;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query3;
import bevy.ecs.ResMut;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTripleAddedDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTripleAddedDisjointConstraint", function(app) {
            app.world.spawn([new TripleAddedDisjointHealth(2), new TripleAddedDisjointTag(3), new TripleAddedDisjointSpeed(5), new TripleAddedDisjointPlayerTag(100)]);
            app.world.spawn([new TripleAddedDisjointHealth(11), new TripleAddedDisjointTag(13), new TripleAddedDisjointSpeed(17)]);
        }, 21);
    }

    @:system("Update")
    public static function legal(
        triple:Query3<TripleAddedDisjointHealth, TripleAddedDisjointTag, TripleAddedDisjointSpeed, With<TripleAddedDisjointPlayerTag>>,
        single:Query<TripleAddedDisjointHealth, All<Added<TripleAddedDisjointHealth>, Without<TripleAddedDisjointPlayerTag>>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in triple.iter()) {
            total += item.a.value + item.b.value + item.c.value;
        }
        for (item in single.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class TripleAddedDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleAddedDisjointTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleAddedDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleAddedDisjointPlayerTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}
