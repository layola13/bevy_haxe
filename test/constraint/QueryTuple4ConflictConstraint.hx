package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple4;

class QueryTuple4ConflictConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple4<Tuple4Position, Tuple4Velocity, Tuple4Health, Tuple4Tag>>, single:Query<Tuple4Position>):Void {
        tupleQuery.toArray();
        single.toArray();
    }
}

class Tuple4Position implements Component {
    public function new() {}
}

class Tuple4Velocity implements Component {
    public function new() {}
}

class Tuple4Health implements Component {
    public function new() {}
}

class Tuple4Tag implements Component {
    public function new() {}
}
