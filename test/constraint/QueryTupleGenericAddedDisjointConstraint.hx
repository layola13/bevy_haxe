package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Added;
import bevy.ecs.All;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleGenericAddedDisjointConstraint implements SystemClass {
    public static function main():Void {}

    @:system("Update")
    public static function legal(
        tupleQuery:Query<Tuple<TupleGenericAddedDisjointHealth, TupleGenericAddedDisjointSpeed>, With<TupleGenericAddedDisjointTag>>,
        added:Query<TupleGenericAddedDisjointHealth, All<Added<TupleGenericAddedDisjointHealth>, Without<TupleGenericAddedDisjointTag>>>
    ):Void {
        tupleQuery.toArray();
        added.toArray();
    }
}

class TupleGenericAddedDisjointHealth implements Component {
    public function new() {}
}

class TupleGenericAddedDisjointSpeed implements Component {
    public function new() {}
}

class TupleGenericAddedDisjointTag implements Component {
    public function new() {}
}
