package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Ref;
import bevy.ecs.Tuple.Tuple;

class QueryTupleRefDuplicateConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTupleRefDuplicateConstraint");
    }

    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple<Ref<TupleRefDuplicateHealth>, TupleRefDuplicateHealth>>):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            total += item.component._0.value.value + item.component._1.value;
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class TupleRefDuplicateHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
