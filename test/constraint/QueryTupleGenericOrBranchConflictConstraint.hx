package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleGenericOrBranchConflictConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(
        tupleQuery:Query<Tuple<TupleGenericOrBranchHealth, TupleGenericOrBranchSpeed>>,
        single:Query<TupleGenericOrBranchHealth, Or<With<TupleGenericOrBranchSpeed>, Without<TupleGenericOrBranchHealth>>>
    ):Void {
        tupleQuery.toArray();
        single.toArray();
    }
}

class TupleGenericOrBranchHealth implements Component {
    public function new() {}
}

class TupleGenericOrBranchSpeed implements Component {
    public function new() {}
}
