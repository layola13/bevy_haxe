package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple1;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTuple1DisjointConstraint implements SystemClass {
    public static function main():Void {}

    @:system("Update")
    public static function legal(tupleQuery:Query<Tuple1<Tuple1DisjointHealth>, With<Tuple1DisjointPlayerTag>>, single:Query<Tuple1DisjointHealth, Without<Tuple1DisjointPlayerTag>>):Void {
        tupleQuery.toArray();
        single.toArray();
    }
}

class Tuple1DisjointHealth implements Component {
    public function new() {}
}

class Tuple1DisjointPlayerTag implements Component {
    public function new() {}
}
