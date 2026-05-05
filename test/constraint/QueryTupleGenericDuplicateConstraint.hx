package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple;

class QueryTupleGenericDuplicateConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple<TupleGenericDuplicateHealth, TupleGenericDuplicateHealth>>):Void {
        tupleQuery.toArray();
    }
}

class TupleGenericDuplicateHealth implements Component {
    public function new() {}
}
