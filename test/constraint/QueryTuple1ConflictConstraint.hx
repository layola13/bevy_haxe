package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple1;

class QueryTuple1ConflictConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple1<Tuple1ConflictPosition>>, single:Query<Tuple1ConflictPosition>):Void {
        tupleQuery.toArray();
        single.toArray();
    }
}

class Tuple1ConflictPosition implements Component {
    public function new() {}
}
