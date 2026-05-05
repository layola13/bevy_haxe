package constraint;

import bevy.app.SystemClass;
import bevy.ecs.All;
import bevy.ecs.Changed;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleGenericChangedDisjointConstraint implements SystemClass {
    public static function main():Void {}

    @:system("Update")
    public static function legal(
        tupleQuery:Query<Tuple<TupleGenericChangedDisjointHealth, TupleGenericChangedDisjointSpeed>, With<TupleGenericChangedDisjointTag>>,
        changed:Query<TupleGenericChangedDisjointHealth, All<Changed<TupleGenericChangedDisjointHealth>, Without<TupleGenericChangedDisjointTag>>>
    ):Void {
        tupleQuery.toArray();
        changed.toArray();
    }
}

class TupleGenericChangedDisjointHealth implements Component {
    public function new() {}
}

class TupleGenericChangedDisjointSpeed implements Component {
    public function new() {}
}

class TupleGenericChangedDisjointTag implements Component {
    public function new() {}
}
