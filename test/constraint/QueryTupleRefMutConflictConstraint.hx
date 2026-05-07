package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Mut;
import bevy.ecs.Query;
import bevy.ecs.Ref;
import bevy.ecs.Tuple.Tuple;

class QueryTupleRefMutConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTupleRefMutConflictConstraint");
    }

    @:system("Update")
    public static function illegal(tupleRef:Query<Tuple<Ref<TupleRefMutConflictHealth>, TupleRefMutConflictTag>>, tupleMut:Query<Tuple<Mut<TupleRefMutConflictHealth>, TupleRefMutConflictTag>>):Void {
        var total = 0;
        for (item in tupleRef.iter()) {
            total += item.component._0.value.value + item.component._1.value;
        }
        for (item in tupleMut.iter()) {
            item.component._0.setChanged();
            total += item.component._0.value.value + item.component._1.value;
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class TupleRefMutConflictHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleRefMutConflictTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
