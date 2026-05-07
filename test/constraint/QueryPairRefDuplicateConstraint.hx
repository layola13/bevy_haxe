package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query.Query2;
import bevy.ecs.Ref;

class QueryPairRefDuplicateConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryPairRefDuplicateConstraint");
    }

    @:system("Update")
    public static function illegal(pair:Query2<Ref<PairRefDuplicateHealth>, PairRefDuplicateHealth>):Void {
        var total = 0;
        for (item in pair.iter()) {
            total += item.a.value.value + item.b.value;
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class PairRefDuplicateHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
