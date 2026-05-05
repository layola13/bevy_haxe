package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;

class QueryTupleDuplicateConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTupleDuplicateConstraint");
    }

    @:system("Update")
    public static function illegal(query:Query<Tuple2<TupleDupPosition, TupleDupPosition>>):Void {
        var total = 0;
        for (item in query.iter()) {
            total += item.component._0.value + item.component._1.value;
        }
        if (total == -1) {
            throw "unreachable query conflict probe";
        }
    }
}

class TupleDupPosition implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
