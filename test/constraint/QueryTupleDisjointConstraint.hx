package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleDisjointConstraint implements SystemClass {
    public static function main():Void {}

    @:system("Update")
    public static function legal(players:Query<Tuple2<TupleDisjointHealth, TupleDisjointSpeed>, With<TupleDisjointPlayerTag>>, enemies:Query<TupleDisjointHealth, Without<TupleDisjointPlayerTag>>):Void {
        players.toArray();
        enemies.toArray();
    }
}

class TupleDisjointHealth implements Component {
    public function new() {}
}

class TupleDisjointSpeed implements Component {
    public function new() {}
}

class TupleDisjointPlayerTag implements Component {
    public function new() {}
}
