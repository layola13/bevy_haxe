package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.Query.Query3;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTripleNestedTupleOrDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTripleNestedTupleOrDisjointConstraint", function(app) {
            app.world.spawn([new TripleNestedTupleOrDisjointHealth(2), new TripleNestedTupleOrDisjointTag(3), new TripleNestedTupleOrDisjointSpeed(5)]);
            app.world.spawn([new TripleNestedTupleOrDisjointHealth(11), new TripleNestedTupleOrDisjointGuard(7)]);
        }, 21);
    }

    @:system("Update")
    public static function legal(
        triple:Query3<TripleNestedTupleOrDisjointHealth, TripleNestedTupleOrDisjointTag, TripleNestedTupleOrDisjointSpeed>,
        single:Query<TripleNestedTupleOrDisjointHealth, Or<Tuple2<With<TripleNestedTupleOrDisjointGuard>, Without<TripleNestedTupleOrDisjointSpeed>>, Tuple2<Without<TripleNestedTupleOrDisjointSpeed>, Without<TripleNestedTupleOrDisjointGuard>>>>,
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

class TripleNestedTupleOrDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleNestedTupleOrDisjointTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleNestedTupleOrDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleNestedTupleOrDisjointGuard implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
