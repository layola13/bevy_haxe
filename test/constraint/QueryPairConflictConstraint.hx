package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query2;

class QueryPairConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryPairConflictConstraint");
    }

    @:system("Update")
    public static function illegal(pair:Query2<PairPosition, PairVelocity>, single:Query<PairPosition>):Void {
        var total = 0;
        for (item in pair.iter()) {
            total += item.a.value + item.b.value;
        }
        for (item in single.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable query conflict probe";
        }
    }
}

class PairPosition implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class PairVelocity implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
