package constraint;

import bevy.app.App;
import bevy.app.MainSchedule;
import bevy.app.SystemClass;
import bevy.async.AsyncRuntime;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Resource;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryFilterTupleDisjointConstraint implements SystemClass {
    public static function main():Void {
        var app = new App();
        app.world.insertResource(new FilterTupleDisjointTotal());
        app.world.spawn([
            new FilterTupleDisjointHealth(5),
            new FilterTupleDisjointPlayer("player")
        ]);
        app.world.spawn([
            new FilterTupleDisjointHealth(11),
            new FilterTupleDisjointEnemy("enemy")
        ]);
        app.addRegisteredSystems(MainSchedule.Update);

        var done = false;
        app.runSchedule(MainSchedule.Update).handle(function(_) done = true, function(error) throw error);
        AsyncRuntime.flush();

        var total = app.world.getResource(FilterTupleDisjointTotal);
        if (!done || total == null || total.value != 16) {
            throw 'QueryFilterTupleDisjointConstraint expected total 16, got ' + (total == null ? "null" : Std.string(total.value));
        }
    }

    @:system("Update")
    public static function legal(
        players:Query<FilterTupleDisjointHealth, Tuple2<With<FilterTupleDisjointPlayer>, Without<FilterTupleDisjointEnemy>>>,
        enemies:Query<FilterTupleDisjointHealth, Without<FilterTupleDisjointPlayer>>,
        total:ResMut<FilterTupleDisjointTotal>
    ):Void {
        var next = 0;
        for (item in players.iter()) {
            next += item.component.value;
        }
        for (item in enemies.iter()) {
            next += item.component.value;
        }
        total.value.value = next;
    }
}

class FilterTupleDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class FilterTupleDisjointPlayer implements Component {
    public var label:String;

    public function new(label:String) {
        this.label = label;
    }
}

class FilterTupleDisjointEnemy implements Component {
    public var label:String;

    public function new(label:String) {
        this.label = label;
    }
}

class FilterTupleDisjointTotal implements Resource {
    public var value:Int;

    public function new() {
        value = 0;
    }
}
