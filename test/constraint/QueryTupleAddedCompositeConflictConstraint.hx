package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Added;
import bevy.ecs.All;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleAddedCompositeConflictConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(
        tupleQuery:Query<Tuple2<TupleAddedCompositeConflictHealth, TupleAddedCompositeConflictSpeed>, Or<With<TupleAddedCompositeConflictPlayerTag>, With<TupleAddedCompositeConflictEnemyTag>>>,
        added:Query<TupleAddedCompositeConflictHealth, All<Added<TupleAddedCompositeConflictHealth>, Without<TupleAddedCompositeConflictPlayerTag>>>
    ):Void {
        tupleQuery.toArray();
        added.toArray();
    }
}

class TupleAddedCompositeConflictHealth implements Component {
    public function new() {}
}

class TupleAddedCompositeConflictSpeed implements Component {
    public function new() {}
}

class TupleAddedCompositeConflictPlayerTag implements Component {
    public function new() {}
}

class TupleAddedCompositeConflictEnemyTag implements Component {
    public function new() {}
}
