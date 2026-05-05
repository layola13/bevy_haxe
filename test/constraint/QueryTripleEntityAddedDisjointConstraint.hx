package constraint;

import bevy.app.App;
import bevy.app.MainSchedule;
import bevy.app.SystemClass;
import bevy.async.AsyncRuntime;
import bevy.ecs.Added;
import bevy.ecs.All;
import bevy.ecs.Component;
import bevy.ecs.Entity;
import bevy.ecs.Query;
import bevy.ecs.Query.Query3;
import bevy.ecs.ResMut;
import bevy.ecs.Resource;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTripleEntityAddedDisjointConstraint implements SystemClass {
    public static function main():Void {
        var app = new App();
        app.world.insertResource(new TripleEntityAddedDisjointTotal());
        app.world.spawn([
            new TripleEntityAddedDisjointHealth(5),
            new TripleEntityAddedDisjointSpeed(7),
            new TripleEntityAddedDisjointTag("tagged")
        ]);
        app.world.spawn([
            new TripleEntityAddedDisjointHealth(11),
            new TripleEntityAddedDisjointSpeed(13)
        ]);
        app.addRegisteredSystems(MainSchedule.Update);

        var done = false;
        app.runSchedule(MainSchedule.Update).handle(function(_) done = true, function(error) throw error);
        AsyncRuntime.flush();

        var total = app.world.getResource(TripleEntityAddedDisjointTotal);
        if (!done || total == null || total.value != 23) {
            throw 'QueryTripleEntityAddedDisjointConstraint expected total 23, got ' + (total == null ? "null" : Std.string(total.value));
        }
    }

    @:system("Update")
    public static function legal(
        triple:Query3<Entity, TripleEntityAddedDisjointHealth, TripleEntityAddedDisjointSpeed, With<TripleEntityAddedDisjointTag>>,
        added:Query<TripleEntityAddedDisjointHealth, All<Added<TripleEntityAddedDisjointHealth>, Without<TripleEntityAddedDisjointTag>>>,
        total:ResMut<TripleEntityAddedDisjointTotal>
    ):Void {
        var next = 0;
        for (item in triple.iter()) {
            next += item.b.value + item.c.value;
        }
        for (item in added.iter()) {
            next += item.component.value;
        }
        total.value.value = next;
    }
}

class TripleEntityAddedDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleEntityAddedDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleEntityAddedDisjointTag implements Component {
    public var label:String;

    public function new(label:String) {
        this.label = label;
    }
}

class TripleEntityAddedDisjointTotal implements Resource {
    public var value:Int;

    public function new() {
        value = 0;
    }
}
