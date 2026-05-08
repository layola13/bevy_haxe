package constraint;

import bevy.app.App;
import bevy.app.MainSchedule;
import bevy.app.SystemClass;
import bevy.async.AsyncRuntime;
import bevy.ecs.Commands;
import bevy.ecs.Component;
import bevy.ecs.Entity.EntityRef;
import bevy.ecs.Option;
import bevy.ecs.Query;
import bevy.ecs.Resource;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryOptionEntityRefDisjointConstraint implements SystemClass {
    public static function main():Void {
        var app = new App();
        app.world.spawn([new OptionEntityRefDisjointPlayerTag(), new OptionEntityRefDisjointHealth(5)]);
        app.world.spawn([new OptionEntityRefDisjointPlayerTag()]);
        app.world.spawn([new OptionEntityRefDisjointEnemyTag(), new OptionEntityRefDisjointHealth(11)]);
        app.addRegisteredSystems(MainSchedule.Update);

        var done = false;
        app.runSchedule(MainSchedule.Update).handle(function(_) {
            done = true;
        }, function(error) throw error);
        AsyncRuntime.flush();
        if (!done) {
            throw "QueryOptionEntityRefDisjointConstraint update did not complete";
        }

        var score = app.world.getResource(OptionEntityRefDisjointScore);
        if (score == null || score.value != 16) {
            throw "QueryOptionEntityRefDisjointConstraint expected score=16, got " + (score == null ? "null" : Std.string(score.value));
        }
    }

    @:system("Update")
    public static function legal(
        players:Query<Option<EntityRef>, With<OptionEntityRefDisjointPlayerTag>>,
        enemies:Query<OptionEntityRefDisjointHealth, Without<OptionEntityRefDisjointPlayerTag>>,
        commands:Commands
    ):Void {
        var total = 0;
        for (item in players.iter()) {
            if (item.component.isSome()) {
                var value = item.component.value.get(OptionEntityRefDisjointHealth);
                if (value != null) {
                    total += value.value;
                }
            }
        }
        for (item in enemies.iter()) {
            total += item.component.value;
        }
        commands.insertResource(new OptionEntityRefDisjointScore(total));
    }
}

class OptionEntityRefDisjointScore implements Resource {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class OptionEntityRefDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class OptionEntityRefDisjointPlayerTag implements Component {
    public function new() {}
}

class OptionEntityRefDisjointEnemyTag implements Component {
    public function new() {}
}
