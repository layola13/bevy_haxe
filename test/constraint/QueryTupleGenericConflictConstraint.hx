package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple;

class QueryTupleGenericConflictConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple<TupleGenericPosition, TupleGenericVelocity>>, single:Query<TupleGenericPosition>):Void {
        tupleQuery.toArray();
        single.toArray();
    }
}

class TupleGenericPosition implements Component {
    public function new() {}
}

class TupleGenericVelocity implements Component {
    public function new() {}
}
