package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query2;
import bevy.ecs.Without;

class QueryPairDataDisjointConstraint implements SystemClass {
    public static function main():Void {}

    @:system("Update")
    public static function legal(pairQuery:Query2<PairDataHealth, PairDataTag>, single:Query<PairDataHealth, Without<PairDataTag>>):Void {
        pairQuery.toArray();
        single.toArray();
    }
}

class PairDataHealth implements Component {
    public function new() {}
}

class PairDataTag implements Component {
    public function new() {}
}
