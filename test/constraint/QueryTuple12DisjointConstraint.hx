package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple12;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTuple12DisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTuple12DisjointConstraint", function(app) {
            app.world.spawn([
                new Tuple12DisjointPosition(1),
                new Tuple12DisjointVelocity(2),
                new Tuple12DisjointHealth(3),
                new Tuple12DisjointArmor(4),
                new Tuple12DisjointStatA(5),
                new Tuple12DisjointStatB(6),
                new Tuple12DisjointStatC(7),
                new Tuple12DisjointStatD(8),
                new Tuple12DisjointStatE(9),
                new Tuple12DisjointStatF(10),
                new Tuple12DisjointStatG(11),
                new Tuple12DisjointTag(12)
            ]);
            app.world.spawn([new Tuple12DisjointPosition(100)]);
        }, 178);
    }

    @:system("Update")
    public static function legal(tupleQuery:Query<Tuple12<Tuple12DisjointPosition, Tuple12DisjointVelocity, Tuple12DisjointHealth, Tuple12DisjointArmor, Tuple12DisjointStatA, Tuple12DisjointStatB, Tuple12DisjointStatC, Tuple12DisjointStatD, Tuple12DisjointStatE, Tuple12DisjointStatF, Tuple12DisjointStatG, Tuple12DisjointTag>, With<Tuple12DisjointTag>>, single:Query<Tuple12DisjointPosition, Without<Tuple12DisjointTag>>, counter:ResMut<ConstraintCounter>):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            total += item.component._0.value + item.component._1.value + item.component._2.value + item.component._3.value + item.component._4.value + item.component._5.value;
            total += item.component._6.value + item.component._7.value + item.component._8.value + item.component._9.value + item.component._10.value + item.component._11.value;
        }
        for (item in single.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class Tuple12DisjointPosition implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple12DisjointVelocity implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple12DisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple12DisjointArmor implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple12DisjointStatA implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple12DisjointStatB implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple12DisjointStatC implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple12DisjointStatD implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple12DisjointStatE implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple12DisjointStatF implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple12DisjointStatG implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple12DisjointTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
