package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple10;

class QueryTuple10ConflictConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple10<Tuple10Position, Tuple10Velocity, Tuple10Health, Tuple10Armor, Tuple10StatA, Tuple10StatB, Tuple10StatC, Tuple10StatD, Tuple10StatE, Tuple10Tag>>, single:Query<Tuple10Position>):Void {
        tupleQuery.toArray();
        single.toArray();
    }
}

class Tuple10Position implements Component {
    public function new() {}
}

class Tuple10Velocity implements Component {
    public function new() {}
}

class Tuple10Health implements Component {
    public function new() {}
}

class Tuple10Armor implements Component {
    public function new() {}
}

class Tuple10StatA implements Component {
    public function new() {}
}

class Tuple10StatB implements Component {
    public function new() {}
}

class Tuple10StatC implements Component {
    public function new() {}
}

class Tuple10StatD implements Component {
    public function new() {}
}

class Tuple10StatE implements Component {
    public function new() {}
}

class Tuple10Tag implements Component {
    public function new() {}
}
