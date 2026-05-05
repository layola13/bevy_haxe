package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryDisjointConstraint implements SystemClass {
    public static function main():Void {}

    @:system("Update")
    public static function legal(players:Query<Health, With<PlayerTag>>, enemies:Query<Health, Without<PlayerTag>>):Void {
        players.toArray();
        enemies.toArray();
    }
}

class Health implements Component {
    public function new() {}
}

class PlayerTag implements Component {
    public function new() {}
}
