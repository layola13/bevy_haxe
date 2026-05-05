package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple5;

class QueryTuple5ConflictConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple5<Tuple5Position, Tuple5Velocity, Tuple5Health, Tuple5Armor, Tuple5Tag>>, single:Query<Tuple5Position>):Void {
        tupleQuery.toArray();
        single.toArray();
    }
}

class Tuple5Position implements Component {
    public function new() {}
}

class Tuple5Velocity implements Component {
    public function new() {}
}

class Tuple5Health implements Component {
    public function new() {}
}

class Tuple5Armor implements Component {
    public function new() {}
}

class Tuple5Tag implements Component {
    public function new() {}
}
