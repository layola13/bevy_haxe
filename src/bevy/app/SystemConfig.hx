package bevy.app;

import bevy.app.SystemRegistry.SystemConditionRunner;
import bevy.app.SystemRegistry.SystemRunner;

class SystemConfigBuilder {
    private var runner:SystemRunner;
    private var name:String;
    private var beforeNames:Array<String>;
    private var afterNames:Array<String>;
    private var conditionRunners:Array<SystemConditionRunner>;
    private var setNames:Array<String>;

    public function new(run:SystemRunner, ?name:String) {
        this.runner = run;
        this.name = name != null ? name : "anonymous";
        beforeNames = [];
        afterNames = [];
        conditionRunners = [];
        setNames = [];
    }

    public static function named(name:String, run:SystemRunner):SystemConfigBuilder {
        return new SystemConfigBuilder(run, name);
    }

    public function before(target:String):SystemConfigBuilder {
        beforeNames.push(target);
        return this;
    }

    public function after(target:String):SystemConfigBuilder {
        afterNames.push(target);
        return this;
    }

    public function runIf(condition:SystemConditionRunner):SystemConfigBuilder {
        conditionRunners.push(condition);
        return this;
    }

    public function inSet(setName:String):SystemConfigBuilder {
        setNames.push(setName);
        return this;
    }

    public function toDescriptor(schedule:String):SystemRegistry.SystemDescriptor {
        return {
            name: name,
            schedule: schedule,
            run: runner,
            before: beforeNames.copy(),
            after: afterNames.copy(),
            conditions: conditionRunners.copy(),
            sets: setNames.copy()
        };
    }
}

class SystemSetConfigBuilder {
    private var name:String;
    private var beforeNames:Array<String>;
    private var afterNames:Array<String>;
    private var conditionRunners:Array<SystemConditionRunner>;

    public function new(name:String) {
        this.name = name;
        beforeNames = [];
        afterNames = [];
        conditionRunners = [];
    }

    public static function named(name:String):SystemSetConfigBuilder {
        return new SystemSetConfigBuilder(name);
    }

    public function before(targetSet:String):SystemSetConfigBuilder {
        beforeNames.push(targetSet);
        return this;
    }

    public function after(targetSet:String):SystemSetConfigBuilder {
        afterNames.push(targetSet);
        return this;
    }

    public function runIf(condition:SystemConditionRunner):SystemSetConfigBuilder {
        conditionRunners.push(condition);
        return this;
    }

    public function apply(schedule:Schedule):Schedule {
        return schedule.configureSet(name, beforeNames, afterNames, conditionRunners);
    }
}
