package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Mut;
import bevy.ecs.Query;
import bevy.ecs.Ref;
import bevy.ecs.Tuple.Tuple;

class QueryTupleRefMutDuplicateConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTupleRefMutDuplicateConstraint");
    }

    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple<Ref<TupleRefMutDuplicateHealth>, Mut<TupleRefMutDuplicateHealth>>>):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            item.component._1.setChanged();
            total += item.component._0.value.value + item.component._1.value.value;
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class TupleRefMutDuplicateHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
