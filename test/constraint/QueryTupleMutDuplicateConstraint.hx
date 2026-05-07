package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Mut;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple;

class QueryTupleMutDuplicateConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTupleMutDuplicateConstraint");
    }

    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple<Mut<TupleMutDuplicateHealth>, TupleMutDuplicateHealth>>):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            item.component._0.setChanged();
            total += item.component._0.value.value + item.component._1.value;
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class TupleMutDuplicateHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
