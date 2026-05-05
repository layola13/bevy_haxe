package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Changed;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple;

class QueryTupleGenericChangedConflictConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple<TupleGenericChangedConflictPosition, TupleGenericChangedConflictVelocity>>, changed:Query<TupleGenericChangedConflictPosition, Changed<TupleGenericChangedConflictPosition>>):Void {
        tupleQuery.toArray();
        changed.toArray();
    }
}

class TupleGenericChangedConflictPosition implements Component {
    public function new() {}
}

class TupleGenericChangedConflictVelocity implements Component {
    public function new() {}
}
