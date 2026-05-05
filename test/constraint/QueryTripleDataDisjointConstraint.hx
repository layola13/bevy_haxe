package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query3;
import bevy.ecs.ResMut;
import bevy.ecs.Without;

class QueryTripleDataDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTripleDataDisjointConstraint", function(app) {
            app.world.spawn([new TripleDataHealth(2), new TripleDataTag(3), new TripleDataSpeed(5)]);
            app.world.spawn([new TripleDataHealth(11), new TripleDataSpeed(13)]);
        }, 21);
    }

    @:system("Update")
    public static function legal(tripleQuery:Query3<TripleDataHealth, TripleDataTag, TripleDataSpeed>, single:Query<TripleDataHealth, Without<TripleDataTag>>, counter:ResMut<ConstraintCounter>):Void {
        var total = 0;
        for (item in tripleQuery.iter()) {
            total += item.a.value + item.b.value + item.c.value;
        }
        for (item in single.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class TripleDataHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleDataTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleDataSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
