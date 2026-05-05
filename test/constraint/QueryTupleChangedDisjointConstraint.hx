package constraint;

import bevy.app.SystemClass;
import bevy.ecs.All;
import bevy.ecs.Changed;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleChangedDisjointConstraint implements SystemClass {
    public static function main():Void {}

    @:system("Update")
    public static function legal(tupleQuery:Query<Tuple2<TupleChangedDisjointHealth, TupleChangedDisjointSpeed>, With<TupleChangedDisjointPlayerTag>>, changed:Query<TupleChangedDisjointHealth, All<Changed<TupleChangedDisjointHealth>, Without<TupleChangedDisjointPlayerTag>>>):Void {
        tupleQuery.toArray();
        changed.toArray();
    }
}

class TupleChangedDisjointHealth implements Component {
    public function new() {}
}

class TupleChangedDisjointSpeed implements Component {
    public function new() {}
}

class TupleChangedDisjointPlayerTag implements Component {
    public function new() {}
}
