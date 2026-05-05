package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple15;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTuple15DisjointConstraint implements SystemClass {
    public static function main():Void {}

    @:system("Update")
    public static function legal(tupleQuery:Query<Tuple15<Tuple15DisjointPosition, Tuple15DisjointVelocity, Tuple15DisjointHealth, Tuple15DisjointArmor, Tuple15DisjointStatA, Tuple15DisjointStatB, Tuple15DisjointStatC, Tuple15DisjointStatD, Tuple15DisjointStatE, Tuple15DisjointStatF, Tuple15DisjointStatG, Tuple15DisjointStatH, Tuple15DisjointStatI, Tuple15DisjointStatJ, Tuple15DisjointTag>, With<Tuple15DisjointTag>>, single:Query<Tuple15DisjointPosition, Without<Tuple15DisjointTag>>):Void {
        tupleQuery.toArray();
        single.toArray();
    }
}

class Tuple15DisjointPosition implements Component {
    public function new() {}
}

class Tuple15DisjointVelocity implements Component {
    public function new() {}
}

class Tuple15DisjointHealth implements Component {
    public function new() {}
}

class Tuple15DisjointArmor implements Component {
    public function new() {}
}

class Tuple15DisjointStatA implements Component {
    public function new() {}
}

class Tuple15DisjointStatB implements Component {
    public function new() {}
}

class Tuple15DisjointStatC implements Component {
    public function new() {}
}

class Tuple15DisjointStatD implements Component {
    public function new() {}
}

class Tuple15DisjointStatE implements Component {
    public function new() {}
}

class Tuple15DisjointStatF implements Component {
    public function new() {}
}

class Tuple15DisjointStatG implements Component {
    public function new() {}
}

class Tuple15DisjointStatH implements Component {
    public function new() {}
}

class Tuple15DisjointStatI implements Component {
    public function new() {}
}

class Tuple15DisjointStatJ implements Component {
    public function new() {}
}

class Tuple15DisjointTag implements Component {
    public function new() {}
}
