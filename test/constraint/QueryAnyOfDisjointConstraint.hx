package constraint;

import bevy.app.SystemClass;
import bevy.ecs.AnyOf;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryAnyOfDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryAnyOfDisjointConstraint", function(app) {
            app.world.spawn([new AnyOfDisjointHealth(5), new AnyOfDisjointPlayerTag(100)]);
            app.world.spawn([new AnyOfDisjointSpeed(7), new AnyOfDisjointPlayerTag(101)]);
            app.world.spawn([new AnyOfDisjointHealth(11), new AnyOfDisjointEnemyTag(200)]);
        }, 23);
    }

    @:system("Update")
    public static function legal(
        players:Query<AnyOf<AnyOfDisjointHealth, AnyOfDisjointSpeed>, With<AnyOfDisjointPlayerTag>>,
        enemies:Query<AnyOfDisjointHealth, Without<AnyOfDisjointPlayerTag>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in players.iter()) {
            if (item.component._0.isSome()) {
                total += item.component._0.value.value;
            }
            if (item.component._1.isSome()) {
                total += item.component._1.value.value;
            }
        }
        for (item in enemies.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class AnyOfDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class AnyOfDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class AnyOfDisjointPlayerTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class AnyOfDisjointEnemyTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
