package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Added;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;

class QueryTupleAddedConflictConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple2<TupleAddedConflictPosition, TupleAddedConflictVelocity>, Added<TupleAddedConflictPosition>>, single:Query<TupleAddedConflictPosition>):Void {
        tupleQuery.toArray();
        single.toArray();
    }
}

class TupleAddedConflictPosition implements Component {
    public function new() {}
}

class TupleAddedConflictVelocity implements Component {
    public function new() {}
}
