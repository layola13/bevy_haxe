package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleOrBranchConflictConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(
        tupleQuery:Query<Tuple2<TupleOrBranchHealth, TupleOrBranchSpeed>>,
        single:Query<TupleOrBranchHealth, Or<With<TupleOrBranchSpeed>, Without<TupleOrBranchHealth>>>
    ):Void {
        tupleQuery.toArray();
        single.toArray();
    }
}

class TupleOrBranchHealth implements Component {
    public function new() {}
}

class TupleOrBranchSpeed implements Component {
    public function new() {}
}
