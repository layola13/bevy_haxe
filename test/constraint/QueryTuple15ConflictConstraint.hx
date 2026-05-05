package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple15;

class QueryTuple15ConflictConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple15<Tuple15Position, Tuple15Velocity, Tuple15Health, Tuple15Armor, Tuple15StatA, Tuple15StatB, Tuple15StatC, Tuple15StatD, Tuple15StatE, Tuple15StatF, Tuple15StatG, Tuple15StatH, Tuple15StatI, Tuple15StatJ, Tuple15Tag>>, single:Query<Tuple15Position>):Void {
        tupleQuery.toArray();
        single.toArray();
    }
}

class Tuple15Position implements Component {
    public function new() {}
}

class Tuple15Velocity implements Component {
    public function new() {}
}

class Tuple15Health implements Component {
    public function new() {}
}

class Tuple15Armor implements Component {
    public function new() {}
}

class Tuple15StatA implements Component {
    public function new() {}
}

class Tuple15StatB implements Component {
    public function new() {}
}

class Tuple15StatC implements Component {
    public function new() {}
}

class Tuple15StatD implements Component {
    public function new() {}
}

class Tuple15StatE implements Component {
    public function new() {}
}

class Tuple15StatF implements Component {
    public function new() {}
}

class Tuple15StatG implements Component {
    public function new() {}
}

class Tuple15StatH implements Component {
    public function new() {}
}

class Tuple15StatI implements Component {
    public function new() {}
}

class Tuple15StatJ implements Component {
    public function new() {}
}

class Tuple15Tag implements Component {
    public function new() {}
}
