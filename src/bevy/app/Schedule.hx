package bevy.app;

import bevy.async.Future;
import bevy.ecs.World;
import bevy.app.SystemRegistry.SystemDescriptor;
import bevy.app.SystemRegistry.SystemRunner;

class Schedule {
    public var label(default, null):String;
    private var systems:Array<SystemDescriptor>;

    public function new(label:String) {
        this.label = label;
        systems = [];
    }

    public function addSystem(run:SystemRunner, ?name:String):Schedule {
        systems.push({
            name: name != null ? name : "anonymous",
            schedule: label,
            run: run
        });
        return this;
    }

    public function addDescriptor(descriptor:SystemDescriptor):Schedule {
        systems.push(descriptor);
        return this;
    }

    public function run(world:World):Future<Dynamic> {
        return runAt(world, 0);
    }

    public function len():Int {
        return systems.length;
    }

    private function runAt(world:World, index:Int):Future<Dynamic> {
        if (index >= systems.length) {
            return Future.resolved(null);
        }

        return Future.create(function(resolve, reject) {
            try {
                var result = systems[index].run(world);
                Future.fromDynamic(result).handle(function(_) {
                    runAt(world, index + 1).handle(resolve, reject);
                }, reject);
            } catch (error:Dynamic) {
                reject(error);
            }
        });
    }
}
