package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.Query.Query3;
import bevy.ecs.ResMut;
import bevy.ecs.Without;

class QueryTripleCompositeDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTripleCompositeDisjointConstraint", function(app) {
            app.world.spawn([new TripleCompositeDisjointHealth(2), new TripleCompositeDisjointTag(3), new TripleCompositeDisjointSpeed(5)]);
            app.world.spawn([new TripleCompositeDisjointHealth(11)]);
        }, 21);
    }

    @:system("Update")
    public static function legal(
        triple:Query3<TripleCompositeDisjointHealth, TripleCompositeDisjointTag, TripleCompositeDisjointSpeed>,
        single:Query<TripleCompositeDisjointHealth, Or<Without<TripleCompositeDisjointSpeed>, Without<TripleCompositeDisjointHealth>>>,
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

class TripleCompositeDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleCompositeDisjointTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleCompositeDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
