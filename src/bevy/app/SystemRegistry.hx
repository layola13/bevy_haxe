package bevy.app;

import bevy.ecs.World;

typedef SystemRunner = World->Dynamic;

typedef SystemDescriptor = {
    var name:String;
    var schedule:String;
    var run:SystemRunner;
}

class SystemRegistry {
    private static var systems:Array<SystemDescriptor>;

    public static function register(descriptor:SystemDescriptor):SystemDescriptor {
        storage().push(descriptor);
        return descriptor;
    }

    public static function all():Array<SystemDescriptor> {
        return storage().copy();
    }

    public static function bySchedule(schedule:String):Array<SystemDescriptor> {
        return [for (system in storage()) if (system.schedule == schedule) system];
    }

    public static function clear():Void {
        systems = [];
    }

    private static function storage():Array<SystemDescriptor> {
        if (systems == null) {
            systems = [];
        }
        return systems;
    }
}
