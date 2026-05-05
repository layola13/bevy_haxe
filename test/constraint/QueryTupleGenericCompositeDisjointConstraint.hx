package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.Without;

class QueryTupleGenericCompositeDisjointConstraint implements SystemClass {
    public static function main():Void {}

    @:system("Update")
    public static function legal(tupleQuery:Query<Tuple<TupleGenericCompositeHealth, TupleGenericCompositeSpeed>>, single:Query<TupleGenericCompositeHealth, Or<Without<TupleGenericCompositeSpeed>, Without<TupleGenericCompositeHealth>>>):Void {
        tupleQuery.toArray();
        single.toArray();
    }
}

class TupleGenericCompositeHealth implements Component {
    public function new() {}
}

class TupleGenericCompositeSpeed implements Component {
    public function new() {}
}
