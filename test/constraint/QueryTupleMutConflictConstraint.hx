package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Mut;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple;

class QueryTupleMutConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTupleMutConflictConstraint");
    }

    @:system("Update")
    public static function illegal(tupleMut:Query<Tuple<Mut<TupleMutConflictHealth>, TupleMutConflictTag>>, health:Query<TupleMutConflictHealth>):Void {
        var total = 0;
        for (item in tupleMut.iter()) {
            item.component._0.setChanged();
            total += item.component._0.value.value + item.component._1.value;
        }
        for (item in health.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class TupleMutConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleMutConflictTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
