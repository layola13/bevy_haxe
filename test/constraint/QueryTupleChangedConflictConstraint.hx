package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Changed;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;

class QueryTupleChangedConflictConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple2<TupleChangedPosition, TupleChangedVelocity>>, changed:Query<TupleChangedPosition, Changed<TupleChangedPosition>>):Void {
        tupleQuery.toArray();
        changed.toArray();
    }
}

class TupleChangedPosition implements Component {
    public function new() {}
}

class TupleChangedVelocity implements Component {
    public function new() {}
}
