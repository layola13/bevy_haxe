package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleCompositeConflictConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(
        tupleQuery:Query<Tuple2<TupleCompositeConflictHealth, TupleCompositeConflictSpeed>, Or<With<TupleCompositeConflictPlayer>, With<TupleCompositeConflictEnemy>>>,
        single:Query<TupleCompositeConflictHealth, Without<TupleCompositeConflictPlayer>>
    ):Void {
        tupleQuery.toArray();
        single.toArray();
    }
}

class TupleCompositeConflictHealth implements Component {
    public function new() {}
}

class TupleCompositeConflictSpeed implements Component {
    public function new() {}
}

class TupleCompositeConflictPlayer implements Component {
    public function new() {}
}

class TupleCompositeConflictEnemy implements Component {
    public function new() {}
}
