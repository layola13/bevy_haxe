package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.Without;

class QueryTupleGenericDataDisjointConstraint implements SystemClass {
    public static function main():Void {}

    @:system("Update")
    public static function legal(tupleQuery:Query<Tuple<TupleGenericDataDisjointA, TupleGenericDataDisjointB>>, single:Query<TupleGenericDataDisjointA, Without<TupleGenericDataDisjointB>>):Void {
        tupleQuery.toArray();
        single.toArray();
    }
}

class TupleGenericDataDisjointA implements Component {
    public function new() {}
}

class TupleGenericDataDisjointB implements Component {
    public function new() {}
}
