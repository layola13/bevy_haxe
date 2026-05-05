package bevy.app;

import bevy.ecs.World;

typedef SystemRunner = World->Dynamic;
typedef SystemConditionRunner = World->Dynamic;

typedef SystemDescriptor = {
    var name:String;
    var schedule:String;
    var run:SystemRunner;
    var before:Array<String>;
    var after:Array<String>;
    var conditions:Array<SystemConditionRunner>;
    var sets:Array<String>;
}

class SystemRegistry {
    private static var systems:Array<SystemDescriptor>;
    private static var configuredSets:Map<String, Array<SetConfig>>;

    public static function register(descriptor:SystemDescriptor):SystemDescriptor {
        normalize(descriptor);
        storage().push(descriptor);
        return descriptor;
    }

    public static function all():Array<SystemDescriptor> {
        return storage().copy();
    }

    public static function bySchedule(schedule:String):Array<SystemDescriptor> {
        return [for (system in storage()) if (system.schedule == schedule) system];
    }

    public static function configureSet(schedule:String, setName:String, ?before:Array<String>, ?after:Array<String>, ?conditions:Array<SystemConditionRunner>):Void {
        var configs = setStorage().get(schedule);
        if (configs == null) {
            configs = [];
            setStorage().set(schedule, configs);
        }

        configs.push({
            name: setName,
            before: before != null ? before.copy() : [],
            after: after != null ? after.copy() : [],
            conditions: conditions != null ? conditions.copy() : []
        });
    }

    public static function configuredSetEntries(schedule:String):Array<SetConfig> {
        var configs = setStorage().get(schedule);
        return configs != null ? configs.copy() : [];
    }

    public static function clear():Void {
        systems = [];
        configuredSets = null;
    }

    private static function storage():Array<SystemDescriptor> {
        if (systems == null) {
            systems = [];
        }
        return systems;
    }

    private static function setStorage():Map<String, Array<SetConfig>> {
        if (configuredSets == null) {
            configuredSets = new Map();
        }
        return configuredSets;
    }

    private static function normalize(descriptor:SystemDescriptor):Void {
        if (descriptor.before == null) {
            descriptor.before = [];
        }
        if (descriptor.after == null) {
            descriptor.after = [];
        }
        if (descriptor.conditions == null) {
            descriptor.conditions = [];
        }
        if (descriptor.sets == null) {
            descriptor.sets = [];
        }
    }
}

typedef SetConfig = {
    var name:String;
    var before:Array<String>;
    var after:Array<String>;
    var conditions:Array<SystemConditionRunner>;
}
