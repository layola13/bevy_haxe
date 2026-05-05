package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.Without;

class QueryTupleCompositeDisjointConstraint implements SystemClass {
    public static function main():Void {}

    @:system("Update")
    public static function legal(tupleQuery:Query<Tuple2<TupleCompositeHealth, TupleCompositeSpeed>>, single:Query<TupleCompositeHealth, Or<Without<TupleCompositeSpeed>, Without<TupleCompositeHealth>>>):Void {
        tupleQuery.toArray();
        single.toArray();
    }
}

class TupleCompositeHealth implements Component {
    public function new() {}
}

class TupleCompositeSpeed implements Component {
    public function new() {}
}
