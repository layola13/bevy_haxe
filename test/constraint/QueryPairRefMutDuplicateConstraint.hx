package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Mut;
import bevy.ecs.Query.Query2;
import bevy.ecs.Ref;

class QueryPairRefMutDuplicateConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryPairRefMutDuplicateConstraint");
    }

    @:system("Update")
    public static function illegal(pair:Query2<Ref<PairRefMutDuplicateHealth>, Mut<PairRefMutDuplicateHealth>>):Void {
        var total = 0;
        for (item in pair.iter()) {
            item.b.setChanged();
            total += item.a.value.value + item.b.value.value;
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class PairRefMutDuplicateHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
