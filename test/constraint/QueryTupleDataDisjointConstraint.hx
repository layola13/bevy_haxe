package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.Without;

class QueryTupleDataDisjointConstraint implements SystemClass {
    public static function main():Void {}

    @:system("Update")
    public static function legal(tupleQuery:Query<Tuple2<TupleDataHealth, TupleDataTag>>, single:Query<TupleDataHealth, Without<TupleDataTag>>):Void {
        tupleQuery.toArray();
        single.toArray();
    }
}

class TupleDataHealth implements Component {
    public function new() {}
}

class TupleDataTag implements Component {
    public function new() {}
}
