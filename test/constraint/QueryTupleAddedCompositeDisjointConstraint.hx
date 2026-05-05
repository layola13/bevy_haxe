package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Added;
import bevy.ecs.All;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleAddedCompositeDisjointConstraint implements SystemClass {
    public static function main():Void {}

    @:system("Update")
    public static function legal(
        tupleQuery:Query<Tuple2<TupleAddedCompositeDisjointHealth, TupleAddedCompositeDisjointSpeed>, All<With<TupleAddedCompositeDisjointPlayerTag>, Without<TupleAddedCompositeDisjointEnemyTag>>>,
        added:Query<TupleAddedCompositeDisjointHealth, All<Added<TupleAddedCompositeDisjointHealth>, With<TupleAddedCompositeDisjointEnemyTag>>>
    ):Void {
        tupleQuery.toArray();
        added.toArray();
    }
}

class TupleAddedCompositeDisjointHealth implements Component {
    public function new() {}
}

class TupleAddedCompositeDisjointSpeed implements Component {
    public function new() {}
}

class TupleAddedCompositeDisjointPlayerTag implements Component {
    public function new() {}
}

class TupleAddedCompositeDisjointEnemyTag implements Component {
    public function new() {}
}
