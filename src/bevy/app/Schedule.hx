package bevy.app;

import bevy.async.Future;
import bevy.ecs.World;
import bevy.app.SystemRegistry.SystemConditionRunner;
import bevy.app.SystemRegistry.SystemDescriptor;
import bevy.app.SystemRegistry.SystemRunner;
import bevy.app.SystemRegistry.SetConfig;

class Schedule {
    public var label(default, null):String;
    private var systems:Array<SystemDescriptor>;
    private var setBefore:Map<String, Array<String>>;
    private var setAfter:Map<String, Array<String>>;
    private var setConditions:Map<String, Array<SystemConditionRunner>>;

    public function new(label:String) {
        this.label = label;
        systems = [];
        setBefore = new Map();
        setAfter = new Map();
        setConditions = new Map();
    }

    public function addSystem(run:SystemRunner, ?name:String):Schedule {
        systems.push({
            name: name != null ? name : "anonymous",
            schedule: label,
            run: run,
            before: [],
            after: [],
            conditions: [],
            sets: []
        });
        return this;
    }

    public function addDescriptor(descriptor:SystemDescriptor):Schedule {
        systems.push(descriptor);
        return this;
    }

    public function configureSet(setName:String, ?before:Array<String>, ?after:Array<String>, ?conditions:Array<SystemConditionRunner>):Schedule {
        var normalized = normalizeSetName(setName);
        if (before != null && before.length > 0) {
            setBefore.set(normalized, normalizeSetRefs(before));
        }
        if (after != null && after.length > 0) {
            setAfter.set(normalized, normalizeSetRefs(after));
        }
        if (conditions != null && conditions.length > 0) {
            setConditions.set(normalized, conditions.copy());
        }
        return this;
    }

    public function run(world:World):Future<Dynamic> {
        return runAt(world, 0);
    }

    public function len():Int {
        return systems.length;
    }

    private function runAt(world:World, index:Int):Future<Dynamic> {
        syncConfiguredSets();
        var ordered = orderedSystems();
        return runOrdered(world, ordered, index);
    }

    private function runOrdered(world:World, ordered:Array<SystemDescriptor>, index:Int):Future<Dynamic> {
        if (index >= systems.length) {
            return Future.resolved(null);
        }

        return Future.create(function(resolve, reject) {
            try {
                var combined = combinedConditions(ordered[index]);
                evaluateConditions(world, combined, 0).handle(function(shouldRun) {
                    if (!shouldRun) {
                        runOrdered(world, ordered, index + 1).handle(resolve, reject);
                        return;
                    }

                    var result = ordered[index].run(world);
                    Future.fromDynamic(result).handle(function(_) {
                        runOrdered(world, ordered, index + 1).handle(resolve, reject);
                    }, reject);
                }, reject);
            } catch (error:Dynamic) {
                reject(error);
            }
        });
    }

    private function evaluateConditions(world:World, conditions:Array<SystemConditionRunner>, index:Int):Future<Bool> {
        if (conditions == null || index >= conditions.length) {
            return Future.resolved(true);
        }

        return Future.fromDynamic(conditions[index](world)).next(function(value) {
            if (!asBool(value)) {
                return Future.resolved(false);
            }
            return evaluateConditions(world, conditions, index + 1);
        });
    }

    private function orderedSystems():Array<SystemDescriptor> {
        if (systems.length <= 1) {
            return systems.copy();
        }

        var descriptorByName:Map<String, SystemDescriptor> = new Map();
        var indexByName:Map<String, Int> = new Map();
        var edges:Map<String, Array<String>> = new Map();
        var indegree:Map<String, Int> = new Map();
        var systemsBySet:Map<String, Array<String>> = new Map();

        for (i in 0...systems.length) {
            var descriptor = systems[i];
            descriptorByName.set(descriptor.name, descriptor);
            indexByName.set(descriptor.name, i);
            edges.set(descriptor.name, []);
            indegree.set(descriptor.name, 0);
            for (setName in descriptor.sets) {
                var normalized = normalizeSetName(setName);
                var members = systemsBySet.get(normalized);
                if (members == null) {
                    members = [];
                    systemsBySet.set(normalized, members);
                }
                members.push(descriptor.name);
            }
        }

        for (descriptor in systems) {
            for (target in descriptor.before) {
                addEdge(descriptor.name, target, edges, indegree, descriptorByName);
            }
            for (source in descriptor.after) {
                addEdge(source, descriptor.name, edges, indegree, descriptorByName);
            }
        }

        for (setName => targets in setBefore) {
            var members = requireSetMembers(setName, systemsBySet);
            for (targetSet in targets) {
                var targetMembers = requireSetMembers(targetSet, systemsBySet);
                for (member in members) {
                    for (targetMember in targetMembers) {
                        addEdge(member, targetMember, edges, indegree, descriptorByName);
                    }
                }
            }
        }

        for (setName => sources in setAfter) {
            var members = requireSetMembers(setName, systemsBySet);
            for (sourceSet in sources) {
                var sourceMembers = requireSetMembers(sourceSet, systemsBySet);
                for (sourceMember in sourceMembers) {
                    for (member in members) {
                        addEdge(sourceMember, member, edges, indegree, descriptorByName);
                    }
                }
            }
        }

        var ready:Array<String> = [];
        for (descriptor in systems) {
            if (indegree.get(descriptor.name) == 0) {
                ready.push(descriptor.name);
            }
        }
        ready.sort(function(a, b) return indexByName.get(a) - indexByName.get(b));

        var ordered:Array<SystemDescriptor> = [];
        while (ready.length > 0) {
            var current = ready.shift();
            ordered.push(descriptorByName.get(current));

            for (next in edges.get(current)) {
                var nextDegree = indegree.get(next) - 1;
                indegree.set(next, nextDegree);
                if (nextDegree == 0) {
                    ready.push(next);
                    ready.sort(function(a, b) return indexByName.get(a) - indexByName.get(b));
                }
            }
        }

        if (ordered.length != systems.length) {
            throw 'Schedule ordering cycle detected in "$label"';
        }

        return ordered;
    }

    private function addEdge(source:String, target:String, edges:Map<String, Array<String>>, indegree:Map<String, Int>, descriptors:Map<String, SystemDescriptor>):Void {
        if (!descriptors.exists(source)) {
            throw 'System ordering reference "$source" was not found in schedule "$label"';
        }
        if (!descriptors.exists(target)) {
            throw 'System ordering reference "$target" was not found in schedule "$label"';
        }

        var outgoing = edges.get(source);
        if (Lambda.has(outgoing, target)) {
            return;
        }
        outgoing.push(target);
        indegree.set(target, indegree.get(target) + 1);
    }

    private function combinedConditions(descriptor:SystemDescriptor):Array<SystemConditionRunner> {
        var combined:Array<SystemConditionRunner> = [];
        if (descriptor.conditions != null) {
            combined = combined.concat(descriptor.conditions);
        }
        if (descriptor.sets != null) {
            for (setName in descriptor.sets) {
                var conditions = setConditions.get(normalizeSetName(setName));
                if (conditions != null) {
                    combined = combined.concat(conditions);
                }
            }
        }
        return combined;
    }

    private function requireSetMembers(setName:String, systemsBySet:Map<String, Array<String>>):Array<String> {
        var members = systemsBySet.get(normalizeSetName(setName));
        if (members == null || members.length == 0) {
            throw 'System set "$setName" has no systems in schedule "$label"';
        }
        return members;
    }

    private function normalizeSetRefs(values:Array<String>):Array<String> {
        var result:Array<String> = [];
        for (value in values) {
            result.push(normalizeSetName(value));
        }
        return result;
    }

    private function normalizeSetName(value:String):String {
        if (value == null || value == "") {
            throw 'System set name must not be empty in schedule "$label"';
        }
        return value;
    }

    private function syncConfiguredSets():Void {
        for (config in SystemRegistry.configuredSetEntries(label)) {
            configureSet(config.name, config.before, config.after, config.conditions);
        }
    }

    private function asBool(value:Dynamic):Bool {
        if (!Std.isOfType(value, Bool)) {
            throw 'run_if condition in schedule "$label" must resolve to Bool';
        }
        return cast value;
    }
}
