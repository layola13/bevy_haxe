package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple6;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTuple6DisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTuple6DisjointConstraint", function(app) {
            app.world.spawn([
                new Tuple6DisjointPosition(1),
                new Tuple6DisjointVelocity(2),
                new Tuple6DisjointHealth(3),
                new Tuple6DisjointArmor(4),
                new Tuple6DisjointStatA(5),
                new Tuple6DisjointTag(6)
            ]);
            app.world.spawn([new Tuple6DisjointPosition(100)]);
        }, 121);
    }

    @:system("Update")
    public static function legal(tupleQuery:Query<Tuple6<Tuple6DisjointPosition, Tuple6DisjointVelocity, Tuple6DisjointHealth, Tuple6DisjointArmor, Tuple6DisjointStatA, Tuple6DisjointTag>, With<Tuple6DisjointTag>>, single:Query<Tuple6DisjointPosition, Without<Tuple6DisjointTag>>, counter:ResMut<ConstraintCounter>):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            total += item.component._0.value + item.component._1.value + item.component._2.value + item.component._3.value + item.component._4.value + item.component._5.value;
        }
        for (item in single.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class Tuple6DisjointPosition implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple6DisjointVelocity implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple6DisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple6DisjointArmor implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple6DisjointStatA implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple6DisjointTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
