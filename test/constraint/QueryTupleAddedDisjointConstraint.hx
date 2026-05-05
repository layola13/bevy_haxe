package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Added;
import bevy.ecs.All;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleAddedDisjointConstraint implements SystemClass {
    public static function main():Void {}

    @:system("Update")
    public static function legal(
        tupleQuery:Query<Tuple2<TupleAddedDisjointHealth, TupleAddedDisjointSpeed>, With<TupleAddedDisjointPlayerTag>>,
        added:Query<TupleAddedDisjointHealth, All<Added<TupleAddedDisjointHealth>, Without<TupleAddedDisjointPlayerTag>>>
    ):Void {
        tupleQuery.toArray();
        added.toArray();
    }
}

class TupleAddedDisjointHealth implements Component {
    public function new() {}
}

class TupleAddedDisjointSpeed implements Component {
    public function new() {}
}

class TupleAddedDisjointPlayerTag implements Component {
    public function new() {}
}
