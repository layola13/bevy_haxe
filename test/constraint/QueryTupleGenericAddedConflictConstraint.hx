package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Added;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple;

class QueryTupleGenericAddedConflictConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple<TupleGenericAddedConflictPosition, TupleGenericAddedConflictVelocity>, Added<TupleGenericAddedConflictPosition>>, single:Query<TupleGenericAddedConflictPosition>):Void {
        tupleQuery.toArray();
        single.toArray();
    }
}

class TupleGenericAddedConflictPosition implements Component {
    public function new() {}
}

class TupleGenericAddedConflictVelocity implements Component {
    public function new() {}
}
