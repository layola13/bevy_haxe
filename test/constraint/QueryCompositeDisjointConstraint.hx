package constraint;

import bevy.app.SystemClass;
import bevy.ecs.All;
import bevy.ecs.Component;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryCompositeDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryCompositeDisjointConstraint", function(app) {
            app.world.spawn([new CompositeHealth(5), new CompositePlayer(100)]);
            app.world.spawn([new CompositeHealth(11), new CompositeEnemy(200)]);
            app.world.spawn([new CompositeHealth(17)]);
        }, 33);
    }

    @:system("Update")
    public static function legal(
        left:Query<CompositeHealth, Or<With<CompositePlayer>, With<CompositeEnemy>>>,
        right:Query<CompositeHealth, All<Without<CompositePlayer>, Without<CompositeEnemy>>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in left.iter()) {
            total += item.component.value;
        }
        for (item in right.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class CompositeHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class CompositePlayer implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}

class CompositeEnemy implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}
