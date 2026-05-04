package bevy.app;

import bevy.async.Future;
import bevy.ecs.World;
import bevy.app.SystemRegistry.SystemRunner;

class App {
    public var world(default, null):World;
    private var schedules:Map<String, Schedule>;

    public function new() {
        world = new World();
        schedules = new Map();
        initSchedule(MainSchedule.First);
        initSchedule(MainSchedule.Startup);
        initSchedule(MainSchedule.PreUpdate);
        initSchedule(MainSchedule.Update);
        initSchedule(MainSchedule.PostUpdate);
        initSchedule(MainSchedule.Last);
    }

    public function addSystem(schedule:String, run:SystemRunner, ?name:String):App {
        initSchedule(schedule).addSystem(run, name);
        return this;
    }

    public function addRegisteredSystems(?schedule:String):App {
        if (schedule == null) {
            for (descriptor in SystemRegistry.all()) {
                initSchedule(descriptor.schedule).addDescriptor(descriptor);
            }
        } else {
            for (descriptor in SystemRegistry.bySchedule(schedule)) {
                initSchedule(schedule).addDescriptor(descriptor);
            }
        }
        return this;
    }

    public function runSchedule(schedule:String):Future<Dynamic> {
        return initSchedule(schedule).run(world);
    }

    public function update():Future<Dynamic> {
        return runSequence([
            MainSchedule.PreUpdate,
            MainSchedule.Update,
            MainSchedule.PostUpdate
        ], 0);
    }

    public function startup():Future<Dynamic> {
        return runSchedule(MainSchedule.Startup);
    }

    private function initSchedule(label:String):Schedule {
        var schedule = schedules.get(label);
        if (schedule == null) {
            schedule = new Schedule(label);
            schedules.set(label, schedule);
        }
        return schedule;
    }

    private function runSequence(labels:Array<String>, index:Int):Future<Dynamic> {
        if (index >= labels.length) {
            return Future.resolved(null);
        }
        return runSchedule(labels[index]).next(function(_) {
            return runSequence(labels, index + 1);
        });
    }
}
