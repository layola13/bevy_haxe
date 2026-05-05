package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query2;

class QueryPairConflictConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(pair:Query2<PairPosition, PairVelocity>, single:Query<PairPosition>):Void {
        pair.toArray();
        single.toArray();
    }
}

class PairPosition implements Component {
    public function new() {}
}

class PairVelocity implements Component {
    public function new() {}
}
