package constraint;

import bevy.app.App;
import bevy.app.MainSchedule;
import bevy.app.SystemClass;
import bevy.async.AsyncRuntime;
import bevy.ecs.Commands;
import bevy.ecs.Component;
import bevy.ecs.Entity.EntityWorldMut;
import bevy.ecs.Option;
import bevy.ecs.Query;
import bevy.ecs.Resource;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryOptionEntityWorldMutDisjointConstraint implements SystemClass {
    public static function main():Void {
        var app = new App();
        app.world.spawn([new OptionEntityWorldMutDisjointPlayerTag(), new OptionEntityWorldMutDisjointHealth(5)]);
        app.world.spawn([new OptionEntityWorldMutDisjointPlayerTag()]);
        app.world.spawn([new OptionEntityWorldMutDisjointEnemyTag(), new OptionEntityWorldMutDisjointHealth(11)]);
        app.addRegisteredSystems(MainSchedule.Update);

        var done = false;
        app.runSchedule(MainSchedule.Update).handle(function(_) {
            done = true;
        }, function(error) throw error);
        AsyncRuntime.flush();
        if (!done) {
            throw "QueryOptionEntityWorldMutDisjointConstraint update did not complete";
        }

        var score = app.world.getResource(OptionEntityWorldMutDisjointScore);
        if (score == null || score.value != 16) {
            throw "QueryOptionEntityWorldMutDisjointConstraint expected score=16, got " + (score == null ? "null" : Std.string(score.value));
        }
    }

    @:system("Update")
    public static function legal(
        players:Query<Option<EntityWorldMut>, With<OptionEntityWorldMutDisjointPlayerTag>>,
        enemies:Query<OptionEntityWorldMutDisjointHealth, Without<OptionEntityWorldMutDisjointPlayerTag>>,
        commands:Commands
    ):Void {
        var total = 0;
        for (item in players.iter()) {
            if (item.component.isSome()) {
                var value = item.component.value.get(OptionEntityWorldMutDisjointHealth);
                if (value != null) {
                    total += value.value;
                }
            }
        }
        for (item in enemies.iter()) {
            total += item.component.value;
        }
        commands.insertResource(new OptionEntityWorldMutDisjointScore(total));
    }
}

class OptionEntityWorldMutDisjointScore implements Resource {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class OptionEntityWorldMutDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class OptionEntityWorldMutDisjointPlayerTag implements Component {
    public function new() {}
}

class OptionEntityWorldMutDisjointEnemyTag implements Component {
    public function new() {}
}
