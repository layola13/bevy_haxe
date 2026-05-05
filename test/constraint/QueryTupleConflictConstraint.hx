package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;

class QueryTupleConflictConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple2<TupleConflictPosition, TupleConflictVelocity>>, single:Query<TupleConflictPosition>):Void {
        tupleQuery.toArray();
        single.toArray();
    }
}

class TupleConflictPosition implements Component {
    public function new() {}
}

class TupleConflictVelocity implements Component {
    public function new() {}
}
