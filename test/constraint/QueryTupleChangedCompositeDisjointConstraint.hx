package constraint;

import bevy.app.SystemClass;
import bevy.ecs.All;
import bevy.ecs.Changed;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleChangedCompositeDisjointConstraint implements SystemClass {
    public static function main():Void {}

    @:system("Update")
    public static function legal(
        tupleQuery:Query<Tuple2<TupleChangedCompositeDisjointHealth, TupleChangedCompositeDisjointSpeed>, All<With<TupleChangedCompositeDisjointPlayerTag>, Without<TupleChangedCompositeDisjointEnemyTag>>>,
        changed:Query<TupleChangedCompositeDisjointHealth, All<Changed<TupleChangedCompositeDisjointHealth>, With<TupleChangedCompositeDisjointEnemyTag>>>
    ):Void {
        tupleQuery.toArray();
        changed.toArray();
    }
}

class TupleChangedCompositeDisjointHealth implements Component {
    public function new() {}
}

class TupleChangedCompositeDisjointSpeed implements Component {
    public function new() {}
}

class TupleChangedCompositeDisjointPlayerTag implements Component {
    public function new() {}
}

class TupleChangedCompositeDisjointEnemyTag implements Component {
    public function new() {}
}
