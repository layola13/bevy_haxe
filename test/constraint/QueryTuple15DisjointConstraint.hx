package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple15;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTuple15DisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTuple15DisjointConstraint", function(app) {
            app.world.spawn([
                new Tuple15DisjointPosition(1),
                new Tuple15DisjointVelocity(2),
                new Tuple15DisjointHealth(3),
                new Tuple15DisjointArmor(4),
                new Tuple15DisjointStatA(5),
                new Tuple15DisjointStatB(6),
                new Tuple15DisjointStatC(7),
                new Tuple15DisjointStatD(8),
                new Tuple15DisjointStatE(9),
                new Tuple15DisjointStatF(10),
                new Tuple15DisjointStatG(11),
                new Tuple15DisjointStatH(12),
                new Tuple15DisjointStatI(13),
                new Tuple15DisjointStatJ(14),
                new Tuple15DisjointTag(15)
            ]);
            app.world.spawn([new Tuple15DisjointPosition(100)]);
        }, 220);
    }

    @:system("Update")
    public static function legal(tupleQuery:Query<Tuple15<Tuple15DisjointPosition, Tuple15DisjointVelocity, Tuple15DisjointHealth, Tuple15DisjointArmor, Tuple15DisjointStatA, Tuple15DisjointStatB, Tuple15DisjointStatC, Tuple15DisjointStatD, Tuple15DisjointStatE, Tuple15DisjointStatF, Tuple15DisjointStatG, Tuple15DisjointStatH, Tuple15DisjointStatI, Tuple15DisjointStatJ, Tuple15DisjointTag>, With<Tuple15DisjointTag>>, single:Query<Tuple15DisjointPosition, Without<Tuple15DisjointTag>>, counter:ResMut<ConstraintCounter>):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            total += item.component._0.value + item.component._1.value + item.component._2.value + item.component._3.value + item.component._4.value;
            total += item.component._5.value + item.component._6.value + item.component._7.value + item.component._8.value + item.component._9.value;
            total += item.component._10.value + item.component._11.value + item.component._12.value + item.component._13.value + item.component._14.value;
        }
        for (item in single.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class Tuple15DisjointPosition implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple15DisjointVelocity implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple15DisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple15DisjointArmor implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple15DisjointStatA implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple15DisjointStatB implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple15DisjointStatC implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple15DisjointStatD implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple15DisjointStatE implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple15DisjointStatF implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple15DisjointStatG implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple15DisjointStatH implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple15DisjointStatI implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple15DisjointStatJ implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple15DisjointTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
