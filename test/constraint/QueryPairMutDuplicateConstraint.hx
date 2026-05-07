package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Mut;
import bevy.ecs.Query.Query2;

class QueryPairMutDuplicateConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryPairMutDuplicateConstraint");
    }

    @:system("Update")
    public static function illegal(pair:Query2<Mut<PairMutDuplicateHealth>, PairMutDuplicateHealth>):Void {
        var total = 0;
        for (item in pair.iter()) {
            item.a.setChanged();
            total += item.a.value.value + item.b.value;
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class PairMutDuplicateHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
