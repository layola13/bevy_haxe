package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleGenericCompositeConflictConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(
        tupleQuery:Query<Tuple<TupleGenericCompositeConflictHealth, TupleGenericCompositeConflictSpeed>, Or<With<TupleGenericCompositeConflictPlayer>, With<TupleGenericCompositeConflictEnemy>>>,
        single:Query<TupleGenericCompositeConflictHealth, Without<TupleGenericCompositeConflictPlayer>>
    ):Void {
        tupleQuery.toArray();
        single.toArray();
    }
}

class TupleGenericCompositeConflictHealth implements Component {
    public function new() {}
}

class TupleGenericCompositeConflictSpeed implements Component {
    public function new() {}
}

class TupleGenericCompositeConflictPlayer implements Component {
    public function new() {}
}

class TupleGenericCompositeConflictEnemy implements Component {
    public function new() {}
}
