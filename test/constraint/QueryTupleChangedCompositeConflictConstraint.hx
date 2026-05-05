package constraint;

import bevy.app.SystemClass;
import bevy.ecs.All;
import bevy.ecs.Changed;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleChangedCompositeConflictConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(
        tupleQuery:Query<Tuple2<TupleChangedCompositeConflictHealth, TupleChangedCompositeConflictSpeed>, Or<With<TupleChangedCompositeConflictPlayerTag>, With<TupleChangedCompositeConflictEnemyTag>>>,
        changed:Query<TupleChangedCompositeConflictHealth, All<Changed<TupleChangedCompositeConflictHealth>, Without<TupleChangedCompositeConflictPlayerTag>>>
    ):Void {
        tupleQuery.toArray();
        changed.toArray();
    }
}

class TupleChangedCompositeConflictHealth implements Component {
    public function new() {}
}

class TupleChangedCompositeConflictSpeed implements Component {
    public function new() {}
}

class TupleChangedCompositeConflictPlayerTag implements Component {
    public function new() {}
}

class TupleChangedCompositeConflictEnemyTag implements Component {
    public function new() {}
}
