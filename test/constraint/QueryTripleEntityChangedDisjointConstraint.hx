package constraint;

import bevy.app.App;
import bevy.app.MainSchedule;
import bevy.app.SystemClass;
import bevy.async.AsyncRuntime;
import bevy.ecs.All;
import bevy.ecs.Changed;
import bevy.ecs.Component;
import bevy.ecs.Entity;
import bevy.ecs.Query;
import bevy.ecs.Query.Query3;
import bevy.ecs.ResMut;
import bevy.ecs.Resource;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTripleEntityChangedDisjointConstraint implements SystemClass {
    public static function main():Void {
        var app = new App();
        app.world.insertResource(new TripleEntityChangedDisjointTotal());
        app.world.spawn([
            new TripleEntityChangedDisjointHealth(3),
            new TripleEntityChangedDisjointSpeed(4),
            new TripleEntityChangedDisjointTag("tagged")
        ]);
        app.world.spawn([
            new TripleEntityChangedDisjointHealth(17),
            new TripleEntityChangedDisjointSpeed(19)
        ]);
        app.addRegisteredSystems(MainSchedule.Update);

        var done = false;
        app.runSchedule(MainSchedule.Update).handle(function(_) done = true, function(error) throw error);
        AsyncRuntime.flush();

        var total = app.world.getResource(TripleEntityChangedDisjointTotal);
        if (!done || total == null || total.value != 24) {
            throw 'QueryTripleEntityChangedDisjointConstraint expected total 24, got ' + (total == null ? "null" : Std.string(total.value));
        }
    }

    @:system("Update")
    public static function legal(
        triple:Query3<Entity, TripleEntityChangedDisjointHealth, TripleEntityChangedDisjointSpeed, With<TripleEntityChangedDisjointTag>>,
        changed:Query<TripleEntityChangedDisjointHealth, All<Changed<TripleEntityChangedDisjointHealth>, Without<TripleEntityChangedDisjointTag>>>,
        total:ResMut<TripleEntityChangedDisjointTotal>
    ):Void {
        var next = 0;
        for (item in triple.iter()) {
            next += item.b.value + item.c.value;
        }
        for (item in changed.iter()) {
            next += item.component.value;
        }
        total.value.value = next;
    }
}

class TripleEntityChangedDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleEntityChangedDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleEntityChangedDisjointTag implements Component {
    public var label:String;

    public function new(label:String) {
        this.label = label;
    }
}

class TripleEntityChangedDisjointTotal implements Resource {
    public var value:Int;

    public function new() {
        value = 0;
    }
}
