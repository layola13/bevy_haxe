package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query3;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTripleFilterTupleDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTripleFilterTupleDisjointConstraint", function(app) {
            app.world.spawn([new TripleFilterTupleDisjointHealth(2), new TripleFilterTupleDisjointTag(3), new TripleFilterTupleDisjointSpeed(5)]);
            app.world.spawn([new TripleFilterTupleDisjointHealth(11), new TripleFilterTupleDisjointGuard(7)]);
        }, 21);
    }

    @:system("Update")
    public static function legal(
        triple:Query3<TripleFilterTupleDisjointHealth, TripleFilterTupleDisjointTag, TripleFilterTupleDisjointSpeed>,
        single:Query<TripleFilterTupleDisjointHealth, Tuple2<With<TripleFilterTupleDisjointGuard>, Without<TripleFilterTupleDisjointSpeed>>>,
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

class TripleFilterTupleDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleFilterTupleDisjointTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleFilterTupleDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleFilterTupleDisjointGuard implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
