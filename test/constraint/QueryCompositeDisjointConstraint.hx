package constraint;

import bevy.app.SystemClass;
import bevy.ecs.All;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryCompositeDisjointConstraint implements SystemClass {
    public static function main():Void {}

    @:system("Update")
    public static function legal(
        left:Query<CompositeHealth, Or<With<CompositePlayer>, With<CompositeEnemy>>>,
        right:Query<CompositeHealth, All<Without<CompositePlayer>, Without<CompositeEnemy>>>
    ):Void {
        left.toArray();
        right.toArray();
    }
}

class CompositeHealth implements Component {
    public function new() {}
}

class CompositePlayer implements Component {
    public function new() {}
}

class CompositeEnemy implements Component {
    public function new() {}
}
