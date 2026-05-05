package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleGenericDisjointConstraint implements SystemClass {
    public static function main():Void {}

    @:system("Update")
    public static function legal(players:Query<Tuple<TupleGenericDisjointHealth, TupleGenericDisjointSpeed>, With<TupleGenericDisjointTag>>, enemies:Query<TupleGenericDisjointHealth, Without<TupleGenericDisjointTag>>):Void {
        players.toArray();
        enemies.toArray();
    }
}

class TupleGenericDisjointHealth implements Component {
    public function new() {}
}

class TupleGenericDisjointSpeed implements Component {
    public function new() {}
}

class TupleGenericDisjointTag implements Component {
    public function new() {}
}
