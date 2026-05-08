package bevy.macro;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

private typedef FilterBranch = {
    var required:Map<String, Bool>;
    var excluded:Map<String, Bool>;
    var accessKeys:Map<String, Bool>;
}

private typedef FilterState = {
    var branches:Array<FilterBranch>;
    var required:Map<String, Bool>;
    var excluded:Map<String, Bool>;
    var accessKeys:Map<String, Bool>;
}

private typedef QueryAccessState = {
    var label:String;
    var dataKeys:Array<String>;
    var filterBranches:Array<FilterBranch>;
    var required:Map<String, Bool>;
    var excluded:Map<String, Bool>;
    var filterAccessKeys:Map<String, Bool>;
}

private typedef QueryDataState = {
    var accessKeys:Array<String>;
    var requiredBranches:Array<Map<String, Bool>>;
}

class SystemMacro {
    static inline var ENTITY_REF_RESOURCE_KEY:String = "__bevy_resource__:*";
    static inline var ENTITY_REF_MUT_KEY:String = "__bevy_entity_ref__";
    static inline var ENTITY_WORLD_MUT_KEY:String = "__bevy_entity_world_mut__";
    static inline var IS_RESOURCE_TYPE_KEY:String = "bevy.ecs.IsResource";

    public static function build():Array<Field> {
        var fields = Context.getBuildFields();
        var cls = Context.getLocalClass().get();
        var pos = Context.currentPos();
        var classPath = cls.pack.concat([cls.name]).join(".");
        var classExpr = Context.parse(classPath, pos);
        var registrations:Array<Expr> = [];

        for (field in fields) {
            var systemMeta = findMeta(field.meta, "system");
            if (systemMeta == null) {
                continue;
            }
            if (!hasAccess(field, AStatic)) {
                Context.error("@:system currently supports static methods only", field.pos);
            }
            switch field.kind {
                case FFun(fn):
                    validateAsyncSystem(field, fn);
                    var schedule = parseSchedule(systemMeta);
                    var systemName = classPath + "." + field.name;
                    var ordering = parseOrdering(field.meta, field.pos);
                    var setConfig = parseSetConfig(field.meta, field.pos, classPath, classExpr);
                    var conditions = parseRunConditions(field.meta, field.pos, classPath, classExpr);
                    var methodExpr:Expr = {expr: EField(classExpr, field.name), pos: field.pos};
                    var lastRunTickName = "__bevyLastRunTick";
                    var resolved = resolveArgs(fn.args, field.pos, lastRunTickName);
                    var call = {expr: ECall(methodExpr, resolved.args), pos: field.pos};
                    var body = buildRunBody(call, fn.ret, resolved, field.pos, lastRunTickName);
                    registrations.push(macro {
                        var $lastRunTickName:Int = 0;
                        var __bevyConditions = $e{conditions};
                        var __bevySetConditions = $e{setConfig.conditions};
                        if (($v{setConfig.before.length} > 0) || ($v{setConfig.after.length} > 0) || (__bevySetConditions.length > 0)) {
                            bevy.app.SystemRegistry.configureSet($v{schedule}, $v{setConfig.name}, $v{setConfig.before}, $v{setConfig.after}, __bevySetConditions);
                        }
                        bevy.app.SystemRegistry.register({
                            name: $v{systemName},
                            schedule: $v{schedule},
                            before: $v{ordering.before},
                            after: $v{ordering.after},
                            conditions: __bevyConditions,
                            sets: $v{setConfig.memberships},
                            run: function(world:bevy.ecs.World):Dynamic {
                                $body;
                            }
                        });
                    });
                default:
                    Context.error("@:system can only be applied to functions", field.pos);
            }
        }

        if (registrations.length > 0) {
            appendToInit(fields, {expr: EBlock(registrations), pos: pos}, pos);
        }
        return fields;
    }

    static function validateAsyncSystem(field:Field, fn:Function):Void {
        if (!hasMeta(field.meta, "async")) {
            return;
        }
        validateExclusiveWorldUsage(fn.args, field.pos);
        validateBorrowConflicts(fn.args, field.pos, false);
        validateQueryConflicts(fn.args, field.pos);
        for (arg in fn.args) {
            if (arg.type == null) {
                continue;
            }
            switch arg.type {
                case TPath(path):
                    var full = fullPath(path);
                    switch full {
                        case "bevy.ecs.Commands" | "Commands":
                            Context.error("Async systems cannot take Commands yet; split command emission into a follow-up sync system", field.pos);
                        case "bevy.ecs.ResMut" | "ResMut":
                            Context.error("Async systems cannot take ResMut yet; split mutable resource access into a sync system", field.pos);
                        case "bevy.ecs.Events.EventWriter" | "bevy.ecs.EventWriter" | "EventWriter":
                            Context.error("Async systems cannot take EventWriter yet; split event emission into a follow-up sync system", field.pos);
                        default:
                    }
                default:
            }
        }
    }

    static function resolveArgs(args:Array<FunctionArg>, pos:Position, lastRunTickName:String):{args:Array<Expr>, prelude:Array<Expr>, applyCommands:Expr, commandsName:Null<String>} {
        var types:Array<ComplexType> = [];
        for (arg in args) {
            if (arg.type == null) {
                Context.error("@:system arguments must have explicit types", pos);
            }
            types.push(arg.type);
        }
        validateExclusiveWorldUsage(args, pos);
        validateBorrowConflicts(args, pos, false);
        validateQueryConflicts(args, pos);
        return resolveParamTypes(types, pos, lastRunTickName, false);
    }

    static function resolveParamTypes(types:Array<ComplexType>, pos:Position, lastRunTickName:String, forbidMutation:Bool):{args:Array<Expr>, prelude:Array<Expr>, applyCommands:Expr, commandsName:Null<String>} {
        var resolved:Array<Expr> = [];
        var prelude:Array<Expr> = [];
        var commandsName:Null<String> = null;

        for (type in types) {
            switch type {
                case TPath(path):
                    var full = fullPath(path);
                    switch full {
                        case "bevy.ecs.World" | "World":
                            if (forbidMutation) {
                                Context.error("run_if conditions cannot take World; use Res<T>, Query<...>, or EventReader<T> for read-only access", pos);
                            }
                            resolved.push(macro world);
                        case "bevy.ecs.Commands" | "Commands":
                            if (forbidMutation) {
                                Context.error("run_if conditions cannot take Commands", pos);
                            }
                            if (commandsName != null) {
                                Context.error("@:system supports only one Commands parameter", pos);
                            }
                            commandsName = "__bevyCommands";
                            prelude.push(varDecl(commandsName, macro world.commands(), pos));
                            resolved.push(macro $i{commandsName});
                        case "bevy.ecs.Res" | "Res":
                            resolved.push(macro new bevy.ecs.Res(${buildResourceAccess(path, false, pos)}));
                        case "bevy.ecs.ResMut" | "ResMut":
                            if (forbidMutation) {
                                Context.error("run_if conditions cannot take ResMut", pos);
                            }
                            resolved.push(macro new bevy.ecs.ResMut(${buildResourceAccess(path, true, pos)}));
                        case "bevy.ecs.Query" | "Query":
                            var anyOfResolved = resolveAnyOfQueryArg(path, pos, lastRunTickName);
                            if (anyOfResolved != null) {
                                var anyOfClassExpr = buildAnyOfRuntimeClassExpr(path, pos, anyOfResolved.arity);
                                var anyOfExpr = macro new bevy.ecs.Query.QueryAnyOf(
                                    world,
                                    $e{anyOfClassExpr},
                                    $e{buildAnyOfFactoryExpr(path, pos, anyOfResolved.arity)},
                                    $e{anyOfResolved.itemClasses},
                                    $e{anyOfResolved.itemKeys},
                                    $e{anyOfResolved.filters},
                                    $i{lastRunTickName}
                                );
                                resolved.push({
                                    expr: ECheckType({expr: ECast(anyOfExpr, null), pos: pos}, TPath(path)),
                                    pos: pos
                                });
                            } else {
                                var tupleResolved = resolveTupleQueryArg(path, pos, lastRunTickName);
                                if (tupleResolved != null) {
                                var tupleClassExpr = buildTupleRuntimeClassExpr(path, pos, tupleResolved.arity);
                                var tupleExpr = macro new bevy.ecs.Query.QueryTuple(
                                    world,
                                    $e{tupleClassExpr},
                                    $e{buildTupleFactoryExpr(path, pos, tupleResolved.arity)},
                                    $e{tupleResolved.itemClasses},
                                    $e{tupleResolved.itemKeys},
                                    $e{tupleResolved.filters},
                                    $i{lastRunTickName}
                                );
                                resolved.push({
                                    expr: ECheckType({expr: ECast(tupleExpr, null), pos: pos}, TPath(path)),
                                    pos: pos
                                });
                                } else {
                                    var queryResolved = resolveQueryArg(path, pos, lastRunTickName);
                                    var queryExpr = macro world.queryFiltered($p{queryResolved.componentType}, $e{queryResolved.filters}, $e{queryResolved.componentKey}, $i{lastRunTickName});
                                    resolved.push({
                                        expr: ECheckType({expr: ECast(queryExpr, null), pos: pos}, TPath(path)),
                                        pos: pos
                                    });
                                }
                            }
                        case "bevy.ecs.Query2" | "Query2":
                            var pair = resolveQuery2Arg(path, pos, lastRunTickName);
                            var pairExpr = macro world.queryFilteredPair(cast $e{pair.aClass}, cast $e{pair.bClass}, $e{pair.filters}, $e{pair.aKey}, $e{pair.bKey}, $i{lastRunTickName});
                            resolved.push({
                                expr: ECheckType({expr: ECast(pairExpr, null), pos: pos}, TPath(path)),
                                pos: pos
                            });
                        case "bevy.ecs.Query3" | "Query3":
                            var triple = resolveQuery3Arg(path, pos, lastRunTickName);
                            var tripleExpr = macro world.queryFilteredTriple(cast $e{triple.aClass}, cast $e{triple.bClass}, cast $e{triple.cClass}, $e{triple.filters}, $e{triple.aKey}, $e{triple.bKey}, $e{triple.cKey}, $i{lastRunTickName});
                            resolved.push({
                                expr: ECheckType({expr: ECast(tripleExpr, null), pos: pos}, TPath(path)),
                                pos: pos
                            });
                        case "bevy.ecs.EventReader" | "EventReader":
                            resolved.push(macro world.getEvents($p{extractSingleTypePath(path, pos)}).reader());
                        case "bevy.ecs.EventWriter" | "EventWriter":
                            if (forbidMutation) {
                                Context.error("run_if conditions cannot take EventWriter", pos);
                            }
                            resolved.push(macro new bevy.ecs.Events.EventWriter(world.getEvents($p{extractSingleTypePath(path, pos)})));
                        default:
                            Context.error('Unsupported @:system parameter type: $full', pos);
                    }
                default:
                    Context.error("@:system arguments must use class paths", pos);
            }
        }

        if (commandsName == null) {
            return {args: resolved, prelude: prelude, applyCommands: macro null, commandsName: null};
        }

        return {args: resolved, prelude: prelude, applyCommands: {
            expr: ECall({expr: EField({expr: EConst(CIdent(commandsName)), pos: pos}, "apply"), pos: pos}, []),
            pos: pos
        }, commandsName: commandsName};
    }

    static function buildRunBody(call:Expr, ret:Null<ComplexType>, resolved:{args:Array<Expr>, prelude:Array<Expr>, applyCommands:Expr, commandsName:Null<String>}, pos:Position, lastRunTickName:String):Expr {
        var exprs = resolved.prelude.copy();
        if (isVoidReturn(ret)) {
            exprs.push(call);
            exprs.push(resolved.applyCommands);
            exprs.push({
                expr: EBinop(OpAssign, {expr: EConst(CIdent(lastRunTickName)), pos: pos}, macro world.tick()),
                pos: pos
            });
            exprs.push(macro return null);
            return {expr: EBlock(exprs), pos: pos};
        }

        exprs.push(macro var __bevySystemResult = $call);
        exprs.push(macro return bevy.async.Future.fromDynamic(__bevySystemResult).map(function(__bevyIgnored) {
            ${resolved.applyCommands};
            $i{lastRunTickName} = world.tick();
            return __bevyIgnored;
        }));
        return {expr: EBlock(exprs), pos: pos};
    }

    static function parseSchedule(meta:MetadataEntry):String {
        if (meta.params != null && meta.params.length > 0) {
            switch meta.params[0].expr {
                case EConst(CString(value)):
                    return value;
                default:
            }
        }
        return "Update";
    }

    static function parseOrdering(meta:Metadata, pos:Position):{before:Array<String>, after:Array<String>} {
        return {
            before: parseOrderingMeta(meta, "before", pos),
            after: parseOrderingMeta(meta, "after", pos)
        };
    }

    static function parseOrderingMeta(meta:Metadata, name:String, pos:Position):Array<String> {
        var entry = findMeta(meta, name);
        if (entry == null || entry.params == null || entry.params.length == 0) {
            return [];
        }

        var values:Array<String> = [];
        for (param in entry.params) {
            switch param.expr {
                case EConst(CString(value)):
                    values.push(value);
                default:
                    Context.error('System ordering metadata @$name only supports string system names', pos);
            }
        }
        return values;
    }

    static function parseRunConditions(meta:Metadata, pos:Position, classPath:String, classExpr:Expr):Expr {
        return parseConditionEntries(meta, "runIf", pos, classPath, classExpr);
    }

    static function parseConditionEntries(meta:Metadata, metaName:String, pos:Position, classPath:String, classExpr:Expr):Expr {
        var entries:Array<MetadataEntry> = [];
        for (entry in meta) {
            if (entry.name == metaName || entry.name == ":" + metaName) {
                entries.push(entry);
            }
        }

        if (entries.length == 0) {
            return macro [];
        }

        var generated:Array<Expr> = [];
        var counter = 0;
        for (entry in entries) {
            if (entry.params == null || entry.params.length == 0) {
                Context.error("@:runIf requires at least one condition function", pos);
            }
            for (param in entry.params) {
                generated.push(buildRunConditionExpr(param, pos, counter++, classPath, classExpr));
            }
        }
        return macro $a{generated};
    }

    static function parseSetConfig(meta:Metadata, pos:Position, classPath:String, classExpr:Expr):{name:String, memberships:Array<String>, before:Array<String>, after:Array<String>, conditions:Expr} {
        var setNames = parseSimpleStringMeta(meta, "inSet", pos);
        if (setNames.length == 0) {
            return {
                name: "",
                memberships: [],
                before: [],
                after: [],
                conditions: macro []
            };
        }

        if (setNames.length != 1) {
            Context.error("@:inSet currently supports exactly one set per system", pos);
        }

        var setName = setNames[0];
        return {
            name: setName,
            memberships: [setName],
            before: parseSimpleStringMeta(meta, "setBefore", pos),
            after: parseSimpleStringMeta(meta, "setAfter", pos),
            conditions: parseConditionEntries(meta, "setRunIf", pos, classPath, classExpr)
        };
    }

    static function parseSimpleStringMeta(meta:Metadata, name:String, pos:Position):Array<String> {
        var entry = findMeta(meta, name);
        if (entry == null || entry.params == null || entry.params.length == 0) {
            return [];
        }

        var values:Array<String> = [];
        for (param in entry.params) {
            switch param.expr {
                case EConst(CString(value)):
                    values.push(value);
                default:
                    Context.error('Metadata @$name only supports string values', pos);
            }
        }
        return values;
    }

    static function buildRunConditionExpr(param:Expr, pos:Position, index:Int, classPath:String, classExpr:Expr):Expr {
        var targetExpr = switch param.expr {
            case EConst(CString(value)):
                if (StringTools.startsWith(value, classPath + ".")) {
                    {expr: EField(classExpr, value.substr(classPath.length + 1)), pos: pos};
                } else if (value.indexOf(".") < 0) {
                    {expr: EField(classExpr, value), pos: pos};
                } else {
                    Context.parse(value, pos);
                }
            default:
                param;
        };
        var conditionType = Context.follow(Context.typeof(targetExpr));
        var lastRunTickName = "__bevyConditionLastRunTick" + index;

        return switch conditionType {
            case TFun(args, ret):
                var types:Array<ComplexType> = [];
                for (arg in args) {
                    types.push(Context.toComplexType(arg.t));
                }
                validateExclusiveWorldUsageFromComplexTypes(types, pos, true);
                validateBorrowConflictsFromComplexTypes(types, pos, true);
                validateQueryConflictsFromComplexTypes(types, pos);
                var resolved = resolveParamTypes(types, pos, lastRunTickName, true);
                validateRunConditionReturn(Context.toComplexType(ret), pos);
                var call:Expr = {expr: ECall(targetExpr, resolved.args), pos: pos};
                var body = buildRunBody(call, Context.toComplexType(ret), resolved, pos, lastRunTickName);
                macro {
                    var $lastRunTickName:Int = 0;
                    function(world:bevy.ecs.World):Dynamic {
                        $body;
                    };
                };
            default:
                Context.error("@:runIf expects a function or static method reference", pos);
        }
    }

    static function validateRunConditionReturn(ret:Null<ComplexType>, pos:Position):Void {
        // Intentionally permissive here. Schedule runtime validates that each condition
        // resolves to Bool after unwrapping synchronous values / Future values.
    }

    static function validateExclusiveWorldUsage(args:Array<FunctionArg>, pos:Position):Void {
        var types:Array<ComplexType> = [];
        for (arg in args) {
            if (arg.type != null) {
                types.push(arg.type);
            }
        }
        validateExclusiveWorldUsageFromComplexTypes(types, pos, false);
    }

    static function validateExclusiveWorldUsageFromComplexTypes(types:Array<ComplexType>, pos:Position, forbidWorld:Bool):Void {
        var worldCount = 0;
        for (type in types) {
            switch type {
                case TPath(path):
                    var full = fullPath(path);
                    if (full == "bevy.ecs.World" || full == "World") {
                        worldCount++;
                    }
                default:
            }
        }

        if (forbidWorld && worldCount > 0) {
            Context.error("run_if conditions cannot take World; use Res<T>, Query<...>, or EventReader<T> for read-only access", pos);
        }

        if (worldCount > 1) {
            Context.error("@:system supports only one World parameter", pos);
        }
        if (worldCount == 1 && types.length > 1) {
            Context.error("World is an exclusive system parameter and cannot be combined with other system params", pos);
        }
    }

    static function validateBorrowConflicts(args:Array<FunctionArg>, pos:Position, forbidMutation:Bool):Void {
        var types:Array<ComplexType> = [];
        for (arg in args) {
            if (arg.type != null) {
                types.push(arg.type);
            }
        }
        validateBorrowConflictsFromComplexTypes(types, pos, forbidMutation);
    }

    static function validateQueryConflicts(args:Array<FunctionArg>, pos:Position):Void {
        var types:Array<ComplexType> = [];
        for (arg in args) {
            if (arg.type != null) {
                types.push(arg.type);
            }
        }
        validateQueryConflictsFromComplexTypes(types, pos);
    }

    static function validateBorrowConflictsFromComplexTypes(types:Array<ComplexType>, pos:Position, forbidMutation:Bool):Void {
        var sharedResources:Map<String, Bool> = new Map();
        var mutableResources:Map<String, Bool> = new Map();
        var eventReaders:Map<String, Bool> = new Map();
        var eventWriters:Map<String, Bool> = new Map();
        var queries:Array<QueryAccessState> = [];

        for (type in types) {
            switch type {
                case TPath(path):
                    var full = fullPath(path);
                    switch full {
                        case "bevy.ecs.Query" | "Query":
                            var anyOfPath = extractAnyOfDataPath(path, pos);
                            if (anyOfPath != null && anyOfPath.params != null && anyOfPath.params.length > 0) {
                                queries.push(describeAnyOfQueryAccess(path, pos, anyOfPath.params.length));
                            } else {
                                var tuplePath = extractTupleDataPath(path, pos);
                                if (tuplePath != null && tuplePath.params != null && tuplePath.params.length > 0) {
                                    queries.push(describeTupleQueryAccess(path, pos, tuplePath.params.length));
                                } else {
                                    queries.push(describeQueryAccess(path, pos));
                                }
                            }
                        case "bevy.ecs.Query2" | "Query2":
                            queries.push(describeQuery2Access(path, pos));
                        case "bevy.ecs.Query3" | "Query3":
                            queries.push(describeQuery3Access(path, pos));
                        case "bevy.ecs.Res" | "Res":
                            var key = complexTypeStorageKey(path, pos, "resource");
                            if (mutableResources.exists(key)) {
                                Context.error('System parameter borrow conflict on resource $key: cannot combine Res<T> with ResMut<T>', pos);
                            }
                            sharedResources.set(key, true);
                        case "bevy.ecs.ResMut" | "ResMut":
                            if (forbidMutation) {
                                Context.error("run_if conditions cannot take ResMut", pos);
                            }
                            var key = complexTypeStorageKey(path, pos, "resource");
                            if (sharedResources.exists(key) || mutableResources.exists(key)) {
                                Context.error('System parameter borrow conflict on resource $key: mutable resource access must be unique', pos);
                            }
                            mutableResources.set(key, true);
                        case "bevy.ecs.EventReader" | "EventReader":
                            var key = complexTypeStorageKey(path, pos, "event");
                            if (eventWriters.exists(key)) {
                                Context.error('System parameter borrow conflict on event $key: cannot combine EventReader<T> with EventWriter<T>', pos);
                            }
                            eventReaders.set(key, true);
                        case "bevy.ecs.EventWriter" | "EventWriter" | "bevy.ecs.Events.EventWriter":
                            if (forbidMutation) {
                                Context.error("run_if conditions cannot take EventWriter", pos);
                            }
                            var key = complexTypeStorageKey(path, pos, "event");
                            if (eventReaders.exists(key) || eventWriters.exists(key)) {
                                Context.error('System parameter borrow conflict on event $key: event writer access must be unique', pos);
                            }
                            eventWriters.set(key, true);
                        default:
                    }
                default:
            }
        }

        for (query in queries) {
            var hasEntityRef = Lambda.has(query.dataKeys, ENTITY_REF_MUT_KEY);
            var hasEntityWorldMut = Lambda.has(query.dataKeys, ENTITY_WORLD_MUT_KEY);
            if (!hasEntityRef && !hasEntityWorldMut) {
                continue;
            }

            for (key in mutableResources.keys()) {
                if (queryDisjointFromResource(query, key)) {
                    continue;
                }
                if (hasEntityWorldMut) {
                    Context.error('System parameter borrow conflict on resource $key: query access overlaps with EntityWorldMut access', pos);
                }
                if (hasEntityRef) {
                    Context.error('System parameter borrow conflict on resource $key: query access overlaps with EntityRef access', pos);
                }
            }

            if (hasEntityWorldMut) {
                for (key in sharedResources.keys()) {
                    if (queryDisjointFromResource(query, key)) {
                        continue;
                    }
                    Context.error('System parameter borrow conflict on resource $key: query access overlaps with EntityWorldMut access', pos);
                }
            }
        }
    }

    static function validateQueryConflictsFromComplexTypes(types:Array<ComplexType>, pos:Position):Void {
        var queries:Array<QueryAccessState> = [];

        for (type in types) {
            switch type {
                case TPath(path):
                    var full = fullPath(path);
                    switch full {
                        case "bevy.ecs.Query" | "Query":
                            var anyOfPath = extractAnyOfDataPath(path, pos);
                            if (anyOfPath != null && anyOfPath.params != null && anyOfPath.params.length > 0) {
                                queries.push(describeAnyOfQueryAccess(path, pos, anyOfPath.params.length));
                            } else {
                                var tuplePath = extractTupleDataPath(path, pos);
                                if (tuplePath != null && tuplePath.params != null && tuplePath.params.length > 0) {
                                queries.push(describeTupleQueryAccess(path, pos, tuplePath.params.length));
                                } else {
                                    queries.push(describeQueryAccess(path, pos));
                                }
                            }
                        case "bevy.ecs.Query2" | "Query2":
                            queries.push(describeQuery2Access(path, pos));
                        case "bevy.ecs.Query3" | "Query3":
                            queries.push(describeQuery3Access(path, pos));
                        default:
                    }
                default:
            }
        }

        for (query in queries) {
            var seen:Map<String, Bool> = new Map();
            for (key in query.dataKeys) {
                if (seen.exists(key)) {
                    Context.error('Query parameter accesses component $key more than once; duplicate query component access must be split into separate disjoint queries', pos);
                }
                seen.set(key, true);
            }
        }

        for (i in 0...queries.length) {
            for (j in i + 1...queries.length) {
                var left = queries[i];
                var right = queries[j];
                var leftEntityRef = Lambda.has(left.dataKeys, ENTITY_REF_MUT_KEY);
                var rightEntityRef = Lambda.has(right.dataKeys, ENTITY_REF_MUT_KEY);
                var leftEntityWorldMut = Lambda.has(left.dataKeys, ENTITY_WORLD_MUT_KEY);
                var rightEntityWorldMut = Lambda.has(right.dataKeys, ENTITY_WORLD_MUT_KEY);

                if (leftEntityWorldMut || rightEntityWorldMut) {
                    if (queriesAreDisjoint(left, right)) {
                        continue;
                    }
                    Context.error('System parameter borrow conflict on resource $ENTITY_REF_RESOURCE_KEY: query access overlaps with EntityWorldMut access', pos);
                }

                if (leftEntityRef || rightEntityRef) {
                    if (queriesAreDisjoint(left, right)) {
                        continue;
                    }
                    var overlap = firstMeaningfulQueryAccessKey(leftEntityRef ? right : left);
                    Context.error('Query system parameter conflict on component $overlap: overlapping query accesses must be disjoint; add Without<T> filters or split conflicting queries into separate systems', pos);
                }

                var overlap = firstQueryConflictKey(queries[i], queries[j]);
                if (overlap == null) {
                    continue;
                }
                if (queriesAreDisjoint(queries[i], queries[j])) {
                    continue;
                }
                Context.error('Query system parameter conflict on component $overlap: overlapping query accesses must be disjoint; add Without<T> filters or split conflicting queries into separate systems', pos);
            }
        }
    }

    static function isVoidReturn(ret:Null<ComplexType>):Bool {
        if (ret == null) {
            return false;
        }
        return switch ret {
            case TPath(path):
                path.pack.length == 0 && path.name == "Void";
            default:
                false;
        }
    }

    static function fullPath(path:TypePath):String {
        return typePathSegments(path).join(".");
    }

    static function typePathSegments(path:TypePath):Array<String> {
        var segments = path.pack.concat([path.name]);
        if (path.sub != null && path.sub != "") {
            segments.push(path.sub);
        }
        return segments;
    }

    static function typePathExpr(path:TypePath, pos:Position):Expr {
        return Context.parse(typePathSegments(path).join("."), pos);
    }

    static function extractSingleTypePath(path:TypePath, pos:Position):Array<String> {
        if (path.params == null || path.params.length != 1) {
            Context.error("System resource params require exactly one type parameter", pos);
        }
        return switch path.params[0] {
            case TPType(TPath(inner)):
                typePathSegments(inner);
            default:
                Context.error("System resource params require a class type parameter", pos);
        }
    }

    static function resolveQueryArg(path:TypePath, pos:Position, lastRunTickName:String):{componentType:Array<String>, componentKey:Expr, filters:Expr} {
        if (path.params == null || path.params.length < 1 || path.params.length > 2) {
            Context.error("System Query params require one data type and an optional filter type", pos);
        }

        var componentType:Array<String>;
        var componentKey:Expr;
        switch path.params[0] {
            case TPType(TPath(inner)):
                componentType = typePathSegments(inner);
                componentKey = buildQueryDataTypeKeyExpr(inner, pos);
            default:
                Context.error("System Query data parameter must be a class path", pos);
        }

        var filters = path.params.length == 2 ? buildQueryFilterArrayExpr(path.params[1], pos, lastRunTickName) : macro [];
        return {
            componentType: componentType,
            componentKey: componentKey,
            filters: filters
        };
    }

    static function resolveTupleQueryArg(path:TypePath, pos:Position, lastRunTickName:String):Null<{arity:Int, itemClasses:Expr, itemKeys:Expr, filters:Expr}> {
        if (path.params == null || path.params.length < 1 || path.params.length > 2) {
            Context.error("System Query params require one data type and an optional filter type", pos);
        }

        var tuplePath = extractTupleDataPath(path, pos);
        if (tuplePath == null) {
            return null;
        }
        if (tuplePath.params == null || tuplePath.params.length == 0) {
            Context.error("Query tuple data parameter must declare at least one type parameter", pos);
        }

        var classExprs:Array<Expr> = [];
        var keyExprs:Array<Expr> = [];
        for (i in 0...tuplePath.params.length) {
            var itemParam = tuplePath.params[i];
            var itemPath = extractTypeParamPath(itemParam, pos, 'Query tuple parameter #${i + 1} must be a class path');
            classExprs.push(buildQueryDataRuntimeClassExpr(itemPath, pos));
            keyExprs.push(buildQueryDataTypeKeyExpr(itemPath, pos));
        }

        return {
            arity: tuplePath.params.length,
            itemClasses: macro $a{classExprs},
            itemKeys: macro $a{keyExprs},
            filters: path.params.length == 2 ? buildQueryFilterArrayExpr(path.params[1], pos, lastRunTickName) : macro []
        };
    }

    static function resolveAnyOfQueryArg(path:TypePath, pos:Position, lastRunTickName:String):Null<{arity:Int, itemClasses:Expr, itemKeys:Expr, filters:Expr}> {
        if (path.params == null || path.params.length < 1 || path.params.length > 2) {
            Context.error("System Query params require one data type and an optional filter type", pos);
        }

        var anyOfPath = extractAnyOfDataPath(path, pos);
        if (anyOfPath == null) {
            return null;
        }
        if (anyOfPath.params == null || anyOfPath.params.length == 0) {
            Context.error("Query AnyOf data parameter must declare at least one type parameter", pos);
        }

        var classExprs:Array<Expr> = [];
        var keyExprs:Array<Expr> = [];
        for (i in 0...anyOfPath.params.length) {
            var itemPath = extractTypeParamPath(anyOfPath.params[i], pos, 'Query AnyOf parameter #${i + 1} must be a class path');
            classExprs.push(buildQueryDataRuntimeClassExpr(itemPath, pos));
            keyExprs.push(buildAnyOfItemTypeKeyExpr(itemPath, pos));
        }

        return {
            arity: anyOfPath.params.length,
            itemClasses: macro $a{classExprs},
            itemKeys: macro $a{keyExprs},
            filters: path.params.length == 2 ? buildQueryFilterArrayExpr(path.params[1], pos, lastRunTickName) : macro []
        };
    }

    static function resolveQuery2Arg(path:TypePath, pos:Position, lastRunTickName:String):{aClass:Expr, bClass:Expr, aKey:Expr, bKey:Expr, filters:Expr} {
        if (path.params == null || path.params.length < 2 || path.params.length > 3) {
            Context.error("System Query2 params require two data types and an optional filter type", pos);
        }

        var pair = extractTwoTypeClassExprs(path, pos);
        var pairKeys = extractTwoTypeKeys(path, pos);
        var filters = path.params.length == 3 ? buildQueryFilterArrayExpr(path.params[2], pos, lastRunTickName) : macro [];
        return {
            aClass: pair.a,
            bClass: pair.b,
            aKey: pairKeys.a,
            bKey: pairKeys.b,
            filters: filters
        };
    }

    static function resolveQuery3Arg(path:TypePath, pos:Position, lastRunTickName:String):{aClass:Expr, bClass:Expr, cClass:Expr, aKey:Expr, bKey:Expr, cKey:Expr, filters:Expr} {
        if (path.params == null || path.params.length < 3 || path.params.length > 4) {
            Context.error("System Query3 params require three data types and an optional filter type", pos);
        }

        var triple = extractThreeTypeClassExprs(path, pos);
        var tripleKeys = extractThreeTypeKeys(path, pos);
        var filters = path.params.length == 4 ? buildQueryFilterArrayExpr(path.params[3], pos, lastRunTickName) : macro [];
        return {
            aClass: triple.a,
            bClass: triple.b,
            cClass: triple.c,
            aKey: tripleKeys.a,
            bKey: tripleKeys.b,
            cKey: tripleKeys.c,
            filters: filters
        };
    }

    static function describeQueryAccess(path:TypePath, pos:Position):QueryAccessState {
        if (path.params == null || path.params.length < 1 || path.params.length > 2) {
            Context.error("System Query params require one data type and an optional filter type", pos);
        }

        var dataKeys:Array<String> = [];
        var requiredDataKeys:Array<String> = [];
        switch path.params[0] {
            case TPType(TPath(inner)):
                collectQueryDataKeys(dataKeys, requiredDataKeys, inner, pos);
            default:
                Context.error("System Query data parameter must be a class path", pos);
        }

        var filterState = path.params.length == 2 ? describeFilterState(path.params[1], pos) : emptyFilterState();
        var branches = withDataRequirements(filterState.branches, requiredDataKeys);
        return {
            label: "Query",
            dataKeys: dataKeys,
            filterBranches: branches,
            required: withRequiredDataKeys(filterState.required, requiredDataKeys),
            excluded: filterState.excluded,
            filterAccessKeys: filterState.accessKeys
        };
    }

    static function describeTupleQueryAccess(path:TypePath, pos:Position, arity:Int):QueryAccessState {
        if (path.params == null || path.params.length < 1 || path.params.length > 2) {
            Context.error("System Query params require one data type and an optional filter type", pos);
        }
        var tuplePath = extractTupleDataPath(path, pos);
        if (tuplePath.params == null || tuplePath.params.length != arity) {
            Context.error('Query tuple data parameter arity mismatch: expected $arity data types', pos);
        }

        var dataKeys:Array<String> = [];
        var requiredDataKeys:Array<String> = [];
        for (i in 0...arity) {
            var inner = extractTypeParamPath(tuplePath.params[i], pos, 'Query tuple parameter #${i + 1} must be a class path');
            collectQueryDataKeys(dataKeys, requiredDataKeys, inner, pos);
        }

        var filterState = path.params.length == 2 ? describeFilterState(path.params[1], pos) : emptyFilterState();
        var branches = withDataRequirements(filterState.branches, requiredDataKeys);
        return {
            label: 'Query<Tuple$arity>',
            dataKeys: dataKeys,
            filterBranches: branches,
            required: withRequiredDataKeys(filterState.required, requiredDataKeys),
            excluded: filterState.excluded,
            filterAccessKeys: filterState.accessKeys
        };
    }

    static function describeAnyOfQueryAccess(path:TypePath, pos:Position, arity:Int):QueryAccessState {
        if (path.params == null || path.params.length < 1 || path.params.length > 2) {
            Context.error("System Query params require one data type and an optional filter type", pos);
        }
        var anyOfPath = extractAnyOfDataPath(path, pos);
        if (anyOfPath.params == null || anyOfPath.params.length != arity) {
            Context.error('Query AnyOf data parameter arity mismatch: expected $arity data types', pos);
        }

        var dataKeys:Array<String> = [];
        var anyOfBranches:Array<FilterBranch> = [];
        var anyOrderedAccess:Array<String> = [];
        var anyAccessHasMutable:Map<String, Bool> = new Map();
        for (i in 0...arity) {
            var itemPath = extractTypeParamPath(anyOfPath.params[i], pos, 'Query AnyOf parameter #${i + 1} must be a class path');
            var state = collectQueryDataState(itemPath, pos);
            var branchHasMutable = isMutTypePath(itemPath);
            for (key in state.accessKeys) {
                anyOrderedAccess.push(key);
                if (branchHasMutable) {
                    anyAccessHasMutable.set(key, true);
                }
            }
            for (required in state.requiredBranches) {
                var branch = emptyFilterBranch();
                mergeBranchKeys(branch.required, required);
                anyOfBranches.push(branch);
            }
        }
        var seenReadOnly:Map<String, Bool> = new Map();
        for (key in anyOrderedAccess) {
            if (anyAccessHasMutable.exists(key)) {
                dataKeys.push(key);
                continue;
            }
            if (!seenReadOnly.exists(key)) {
                dataKeys.push(key);
                seenReadOnly.set(key, true);
            }
        }

        var filterState = path.params.length == 2 ? describeFilterState(path.params[1], pos) : emptyFilterState();
        var branches = crossFilterBranches(filterState.branches, anyOfBranches);
        return {
            label: 'Query<AnyOf$arity>',
            dataKeys: dataKeys,
            filterBranches: branches,
            required: intersectBranchKeys(branches, function(branch) return branch.required),
            excluded: filterState.excluded,
            filterAccessKeys: filterState.accessKeys
        };
    }

    static function describeQuery2Access(path:TypePath, pos:Position):QueryAccessState {
        if (path.params == null || path.params.length < 2 || path.params.length > 3) {
            Context.error("System Query2 params require two data types and an optional filter type", pos);
        }

        var dataKeys:Array<String> = [];
        var requiredDataKeys:Array<String> = [];
        switch path.params[0] {
            case TPType(TPath(inner)):
                collectQueryDataKeys(dataKeys, requiredDataKeys, inner, pos);
            default:
                Context.error("Query2 first parameter must be a class path", pos);
        }
        switch path.params[1] {
            case TPType(TPath(inner)):
                collectQueryDataKeys(dataKeys, requiredDataKeys, inner, pos);
            default:
                Context.error("Query2 second parameter must be a class path", pos);
        }

        var filterState = path.params.length == 3 ? describeFilterState(path.params[2], pos) : emptyFilterState();
        var branches = withDataRequirements(filterState.branches, requiredDataKeys);
        return {
            label: "Query2",
            dataKeys: dataKeys,
            filterBranches: branches,
            required: withRequiredDataKeys(filterState.required, requiredDataKeys),
            excluded: filterState.excluded,
            filterAccessKeys: filterState.accessKeys
        };
    }

    static function describeQuery3Access(path:TypePath, pos:Position):QueryAccessState {
        if (path.params == null || path.params.length < 3 || path.params.length > 4) {
            Context.error("System Query3 params require three data types and an optional filter type", pos);
        }

        var dataKeys:Array<String> = [];
        var requiredDataKeys:Array<String> = [];
        switch path.params[0] {
            case TPType(TPath(inner)):
                collectQueryDataKeys(dataKeys, requiredDataKeys, inner, pos);
            default:
                Context.error("Query3 first parameter must be a class path", pos);
        }
        switch path.params[1] {
            case TPType(TPath(inner)):
                collectQueryDataKeys(dataKeys, requiredDataKeys, inner, pos);
            default:
                Context.error("Query3 second parameter must be a class path", pos);
        }
        switch path.params[2] {
            case TPType(TPath(inner)):
                collectQueryDataKeys(dataKeys, requiredDataKeys, inner, pos);
            default:
                Context.error("Query3 third parameter must be a class path", pos);
        }

        var filterState = path.params.length == 4 ? describeFilterState(path.params[3], pos) : emptyFilterState();
        var branches = withDataRequirements(filterState.branches, requiredDataKeys);
        return {
            label: "Query3",
            dataKeys: dataKeys,
            filterBranches: branches,
            required: withRequiredDataKeys(filterState.required, requiredDataKeys),
            excluded: filterState.excluded,
            filterAccessKeys: filterState.accessKeys
        };
    }

    static function emptyFilterState():FilterState {
        return {
            branches: [emptyFilterBranch()],
            required: new Map(),
            excluded: new Map(),
            accessKeys: new Map()
        };
    }

    static function describeFilterState(param:TypeParam, pos:Position):FilterState {
        var branches = collectFilterBranches(param, pos);
        if (branches.length == 0) {
            branches = [emptyFilterBranch()];
        }

        var required = intersectBranchKeys(branches, function(branch) return branch.required);
        var excluded = intersectBranchKeys(branches, function(branch) return branch.excluded);
        var accessKeys:Map<String, Bool> = new Map();
        for (branch in branches) {
            mergeBranchKeys(accessKeys, branch.required);
            mergeBranchKeys(accessKeys, branch.excluded);
            mergeBranchKeys(accessKeys, branch.accessKeys);
        }

        return {
            branches: branches,
            required: required,
            excluded: excluded,
            accessKeys: accessKeys
        };
    }

    static function firstOverlappingKey(left:Array<String>, right:Array<String>):Null<String> {
        for (key in left) {
            if (Lambda.has(right, key)) {
                return key;
            }
        }
        return null;
    }

    static function firstMeaningfulQueryAccessKey(query:QueryAccessState):String {
        for (key in query.dataKeys) {
            if (key != ENTITY_REF_MUT_KEY && key != ENTITY_WORLD_MUT_KEY) {
                return key;
            }
        }
        for (key in query.filterAccessKeys.keys()) {
            if (key != ENTITY_REF_MUT_KEY && key != ENTITY_WORLD_MUT_KEY) {
                return key;
            }
        }
        return ENTITY_REF_RESOURCE_KEY;
    }

    static function firstQueryConflictKey(left:QueryAccessState, right:QueryAccessState):Null<String> {
        var direct = firstOverlappingKey(left.dataKeys, right.dataKeys);
        if (direct != null) {
            return direct;
        }

        for (key in left.dataKeys) {
            if (right.filterAccessKeys.exists(key)) {
                return key;
            }
        }
        for (key in right.dataKeys) {
            if (left.filterAccessKeys.exists(key)) {
                return key;
            }
        }
        return null;
    }

    static function queriesAreDisjoint(left:QueryAccessState, right:QueryAccessState):Bool {
        for (leftBranch in left.filterBranches) {
            for (rightBranch in right.filterBranches) {
                if (!branchesConflict(leftBranch, rightBranch)) {
                    return false;
                }
            }
        }
        return true;
    }

    static function branchesConflict(left:FilterBranch, right:FilterBranch):Bool {
        for (key in left.required.keys()) {
            if (right.excluded.exists(key)) {
                return true;
            }
        }
        for (key in right.required.keys()) {
            if (left.excluded.exists(key)) {
                return true;
            }
        }
        return false;
    }

    static function queryDisjointFromResource(query:QueryAccessState, resourceKey:String):Bool {
        for (branch in query.filterBranches) {
            var excludesSpecific = branch.excluded.exists(resourceKey);
            var excludesAnyResource = branchExcludesAnyResource(branch);
            if (!excludesSpecific && !excludesAnyResource) {
                return false;
            }
        }
        return true;
    }

    static function branchExcludesAnyResource(branch:FilterBranch):Bool {
        for (key in branch.excluded.keys()) {
            if (isResourceMarkerKey(key)) {
                return true;
            }
        }
        return false;
    }

    static function isResourceMarkerKey(key:String):Bool {
        if (key == IS_RESOURCE_TYPE_KEY || key == "IsResource") {
            return true;
        }
        return StringTools.endsWith(key, ".IsResource");
    }

    static function collectFilterBranches(param:TypeParam, pos:Position):Array<FilterBranch> {
        return switch param {
            case TPType(TPath(path)):
                var full = fullPath(path);
                switch full {
                    case "bevy.ecs.With" | "With":
                        buildLeafBranches(path, pos, true, false, false, false);
                    case "bevy.ecs.Without" | "Without":
                        buildLeafBranches(path, pos, false, true, false, false);
                    case "bevy.ecs.Added" | "Added":
                        buildLeafBranches(path, pos, true, false, true, false);
                    case "bevy.ecs.Changed" | "Changed":
                        buildLeafBranches(path, pos, true, false, false, true);
                    case "bevy.ecs.Spawned" | "Spawned":
                        buildSpawnedBranches(path, pos);
                    case "bevy.ecs.All" | "All":
                        collectAllBranches(path, pos);
                    case "bevy.ecs.Or" | "Or":
                        collectOrBranches(path, pos);
                    default:
                        if (isTupleTypePath(path)) {
                            collectTupleFilterBranches(path, pos);
                        } else {
                            [emptyFilterBranch()];
                        }
                }
            default:
                [emptyFilterBranch()];
        };
    }

    static function collectTupleFilterBranches(path:TypePath, pos:Position):Array<FilterBranch> {
        if (path.params == null || path.params.length == 0) {
            Context.error("Query filter tuple requires at least one child filter", pos);
        }

        var branches:Array<FilterBranch> = [emptyFilterBranch()];
        for (child in path.params) {
            branches = crossFilterBranches(branches, collectFilterBranches(child, pos));
        }
        return branches;
    }

    static function collectAllBranches(path:TypePath, pos:Position):Array<FilterBranch> {
        if (path.params == null || path.params.length == 0) {
            Context.error("All<...> requires at least one child filter", pos);
        }

        var branches:Array<FilterBranch> = [emptyFilterBranch()];
        for (child in path.params) {
            branches = crossFilterBranches(branches, collectFilterBranches(child, pos));
        }
        return branches;
    }

    static function collectOrBranches(path:TypePath, pos:Position):Array<FilterBranch> {
        if (path.params == null || path.params.length == 0) {
            Context.error("Or<...> requires at least one child filter", pos);
        }

        var branches:Array<FilterBranch> = [];
        for (child in path.params) {
            var childBranches = collectFilterBranches(child, pos);
            for (branch in childBranches) {
                branches.push(copyFilterBranch(branch));
            }
        }
        return branches;
    }

    static function buildLeafBranches(path:TypePath, pos:Position, markRequired:Bool, markExcluded:Bool, markAdded:Bool, markChanged:Bool):Array<FilterBranch> {
        if (path.params == null || path.params.length != 1) {
            var label = path.name;
            Context.error('$label<T> requires exactly one type parameter', pos);
        }

        return switch path.params[0] {
            case TPType(TPath(inner)):
                var key = typePathStorageKey(inner, pos);
                var branch = emptyFilterBranch();
                if (markRequired) {
                    branch.required.set(key, true);
                }
                if (markExcluded) {
                    branch.excluded.set(key, true);
                }
                if (markAdded || markChanged) {
                    branch.accessKeys.set(key, true);
                }
                [branch];
            default:
                var label = path.name;
                Context.error('$label<T> requires a class type parameter', pos);
        };
    }

    static function buildSpawnedBranches(path:TypePath, pos:Position):Array<FilterBranch> {
        if (path.params != null && path.params.length != 0) {
            Context.error("Spawned query filter does not take type parameters", pos);
        }
        return [emptyFilterBranch()];
    }

    static function emptyFilterBranch():FilterBranch {
        return {
            required: new Map(),
            excluded: new Map(),
            accessKeys: new Map()
        };
    }

    static function copyFilterBranch(branch:FilterBranch):FilterBranch {
        return {
            required: copyKeyMap(branch.required),
            excluded: copyKeyMap(branch.excluded),
            accessKeys: copyKeyMap(branch.accessKeys)
        };
    }

    static function withDataRequirements(branches:Array<FilterBranch>, dataKeys:Array<String>):Array<FilterBranch> {
        var result:Array<FilterBranch> = [];
        for (branch in branches) {
            var next = copyFilterBranch(branch);
            for (key in dataKeys) {
                next.required.set(key, true);
            }
            result.push(next);
        }
        return result;
    }

    static function withRequiredDataKeys(required:Map<String, Bool>, dataKeys:Array<String>):Map<String, Bool> {
        var next = copyKeyMap(required);
        for (key in dataKeys) {
            next.set(key, true);
        }
        return next;
    }

    static function copyKeyMap(source:Map<String, Bool>):Map<String, Bool> {
        var result:Map<String, Bool> = new Map();
        if (source != null) {
            for (key in source.keys()) {
                result.set(key, true);
            }
        }
        return result;
    }

    static function crossFilterBranches(left:Array<FilterBranch>, right:Array<FilterBranch>):Array<FilterBranch> {
        var result:Array<FilterBranch> = [];
        for (leftBranch in left) {
            for (rightBranch in right) {
                result.push(mergeFilterBranches(leftBranch, rightBranch));
            }
        }
        return result;
    }

    static function mergeFilterBranches(left:FilterBranch, right:FilterBranch):FilterBranch {
        var branch = copyFilterBranch(left);
        mergeBranchKeys(branch.required, right.required);
        mergeBranchKeys(branch.excluded, right.excluded);
        mergeBranchKeys(branch.accessKeys, right.accessKeys);
        return branch;
    }

    static function mergeBranchKeys(into:Map<String, Bool>, values:Map<String, Bool>):Void {
        if (values == null) {
            return;
        }
        for (key in values.keys()) {
            into.set(key, true);
        }
    }

    static function intersectBranchKeys(branches:Array<FilterBranch>, getter:FilterBranch->Map<String, Bool>):Map<String, Bool> {
        var result:Map<String, Bool> = new Map();
        if (branches == null || branches.length == 0) {
            return result;
        }

        var first = getter(branches[0]);
        if (first == null) {
            return result;
        }

        for (key in first.keys()) {
            var keep = true;
            for (i in 1...branches.length) {
                var branchKeys = getter(branches[i]);
                if (branchKeys == null || !branchKeys.exists(key)) {
                    keep = false;
                    break;
                }
            }
            if (keep) {
                result.set(key, true);
            }
        }
        return result;
    }

    static function buildQueryFilterArrayExpr(param:TypeParam, pos:Position, lastRunTickName:String):Expr {
        var filters:Array<Expr> = [];
        collectQueryFilterExprs(param, filters, pos, lastRunTickName);
        return macro $a{filters};
    }

    static function collectQueryFilterExprs(param:TypeParam, into:Array<Expr>, pos:Position, lastRunTickName:String):Void {
        switch param {
            case TPType(TPath(path)):
                var full = fullPath(path);
                switch full {
                    case "bevy.ecs.With" | "With":
                        into.push(buildLeafFilterExpr("bevy.ecs.With", path, pos));
                    case "bevy.ecs.Without" | "Without":
                        into.push(buildLeafFilterExpr("bevy.ecs.Without", path, pos));
                    case "bevy.ecs.Added" | "Added":
                        into.push(buildLeafFilterExpr("bevy.ecs.Added", path, pos, lastRunTickName));
                    case "bevy.ecs.Changed" | "Changed":
                        into.push(buildLeafFilterExpr("bevy.ecs.Changed", path, pos, lastRunTickName));
                    case "bevy.ecs.Spawned" | "Spawned":
                        into.push(buildSpawnedFilterExpr(path, pos, lastRunTickName));
                    case "bevy.ecs.All" | "All":
                        into.push(buildCompositeFilterExpr("bevy.ecs.All", path, pos, lastRunTickName));
                    case "bevy.ecs.Or" | "Or":
                        into.push(buildCompositeFilterExpr("bevy.ecs.Or", path, pos, lastRunTickName));
                    default:
                        if (isTupleTypePath(path)) {
                            into.push(buildTupleFilterExpr(path, pos, lastRunTickName));
                        } else {
                            Context.error('Unsupported Query filter type: $full', pos);
                        }
                }
            default:
                Context.error("System Query filter parameter must be a class path", pos);
        }
    }

    static function buildLeafFilterExpr(ctorPath:String, path:TypePath, pos:Position, ?lastRunTickName:String):Expr {
        if (path.params == null || path.params.length != 1) {
            Context.error('Query filter $ctorPath requires exactly one type parameter', pos);
        }

        return switch path.params[0] {
            case TPType(TPath(inner)):
                var classExpr = typePathExpr(inner, pos);
                var keyExpr = inner.params != null && inner.params.length > 0 ? buildParameterizedTypeKeyExpr(inner, pos) : macro null;
                var ctor = Context.parse(ctorPath + ".of", pos);
                var args = switch ctorPath {
                    case "bevy.ecs.Added" | "bevy.ecs.Changed":
                        if (lastRunTickName == null) {
                            Context.error('Query filter $ctorPath requires a runtime last-run tick context', pos);
                        }
                        [classExpr, macro $i{lastRunTickName}, keyExpr];
                    default:
                        [classExpr, keyExpr];
                };
                {
                    expr: ECall(ctor, args),
                    pos: pos
                };
            default:
                Context.error('Query filter $ctorPath requires a class type parameter', pos);
        }
    }

    static function buildSpawnedFilterExpr(path:TypePath, pos:Position, lastRunTickName:String):Expr {
        if (path.params != null && path.params.length != 0) {
            Context.error("Query filter Spawned does not take type parameters", pos);
        }
        return {
            expr: ECall(Context.parse("bevy.ecs.Spawned.of", pos), [macro $i{lastRunTickName}]),
            pos: pos
        };
    }

    static function buildCompositeFilterExpr(ctorPath:String, path:TypePath, pos:Position, lastRunTickName:String):Expr {
        if (path.params == null || path.params.length == 0) {
            Context.error('Composite Query filter $ctorPath requires at least one type parameter', pos);
        }

        var children:Array<Expr> = [];
        for (param in path.params) {
            collectCompositeFilterChildren(param, children, pos, lastRunTickName);
        }
        var ctor = Context.parse(ctorPath + ".of", pos);
        return {
            expr: ECall(ctor, [macro $a{children}]),
            pos: pos
        };
    }

    static function collectCompositeFilterChildren(param:TypeParam, into:Array<Expr>, pos:Position, lastRunTickName:String):Void {
        switch param {
            case TPType(TPath(path)):
                var full = fullPath(path);
                switch full {
                    case "bevy.ecs.With" | "With":
                        into.push(buildLeafFilterExpr("bevy.ecs.With", path, pos));
                    case "bevy.ecs.Without" | "Without":
                        into.push(buildLeafFilterExpr("bevy.ecs.Without", path, pos));
                    case "bevy.ecs.All" | "All":
                        into.push(buildCompositeFilterExpr("bevy.ecs.All", path, pos, lastRunTickName));
                    case "bevy.ecs.Or" | "Or":
                        into.push(buildCompositeFilterExpr("bevy.ecs.Or", path, pos, lastRunTickName));
                    case "bevy.ecs.Added" | "Added":
                        into.push(buildLeafFilterExpr("bevy.ecs.Added", path, pos, lastRunTickName));
                    case "bevy.ecs.Changed" | "Changed":
                        into.push(buildLeafFilterExpr("bevy.ecs.Changed", path, pos, lastRunTickName));
                    case "bevy.ecs.Spawned" | "Spawned":
                        into.push(buildSpawnedFilterExpr(path, pos, lastRunTickName));
                    default:
                        if (isTupleTypePath(path)) {
                            into.push(buildTupleFilterExpr(path, pos, lastRunTickName));
                        } else {
                            Context.error('Unsupported nested Query filter type: $full', pos);
                        }
                }
            default:
                Context.error("Composite Query filters require type-path children", pos);
        }
    }

    static function buildTupleFilterExpr(path:TypePath, pos:Position, lastRunTickName:String):Expr {
        if (path.params == null || path.params.length == 0) {
            Context.error("Query filter tuple requires at least one child filter", pos);
        }

        var children:Array<Expr> = [];
        for (param in path.params) {
            collectCompositeFilterChildren(param, children, pos, lastRunTickName);
        }
        return {
            expr: ECall(Context.parse("bevy.ecs.All.of", pos), [macro $a{children}]),
            pos: pos
        };
    }

    static function buildResourceAccess(path:TypePath, mutable:Bool, pos:Position):Expr {
        if (path.params == null || path.params.length != 1) {
            Context.error("System resource params require exactly one type parameter", pos);
        }

        return switch path.params[0] {
            case TPType(TPath(inner)):
                if (inner.params != null && inner.params.length > 0) {
                    var key = buildParameterizedTypeKeyExpr(inner, pos);
                    macro world.getResourceByKey($key);
                } else {
                    macro world.getResource($e{typePathExpr(inner, pos)});
                }
            default:
                Context.error("System resource params require a class type parameter", pos);
        }
    }

    static function detectTupleQueryArity(path:TypePath, pos:Position):Int {
        var tuplePath = extractTupleDataPath(path, pos);
        if (tuplePath == null || tuplePath.params == null) {
            return 1;
        }
        return tuplePath.params.length;
    }

    static function extractTupleDataPath(path:TypePath, pos:Position):Null<TypePath> {
        if (path.params == null || path.params.length < 1) {
            Context.error("System Query params require one data type", pos);
        }
        return switch path.params[0] {
            case TPType(TPath(inner)):
                if (!isTupleTypePath(inner)) {
                    null;
                } else {
                    inner;
                }
            default:
                Context.error("Query tuple data parameter must be a class path", pos);
        };
    }

    static function extractAnyOfDataPath(path:TypePath, pos:Position):Null<TypePath> {
        if (path.params == null || path.params.length < 1) {
            Context.error("System Query params require one data type", pos);
        }
        return switch path.params[0] {
            case TPType(TPath(inner)):
                if (!isAnyOfTypePath(inner)) {
                    null;
                } else {
                    inner;
                }
            default:
                Context.error("Query AnyOf data parameter must be a class path", pos);
        };
    }

    static function isTupleTypePath(path:TypePath):Bool {
        if (path.pack.length == 0 && path.name == "Tuple") {
            return true;
        }
        if (path.pack.length == 0 && StringTools.startsWith(path.name, "Tuple")) {
            return isPositiveIntString(path.name.substr("Tuple".length));
        }
        if (path.pack.length == 2
            && path.pack[0] == "bevy"
            && path.pack[1] == "ecs"
            && path.name == "Tuple"
            && (path.sub == null || path.sub == "")) {
            return true;
        }
        if (path.pack.length == 2
            && path.pack[0] == "bevy"
            && path.pack[1] == "ecs"
            && path.name == "Tuple"
            && path.sub != null
            && StringTools.startsWith(path.sub, "Tuple")) {
            return isPositiveIntString(path.sub.substr("Tuple".length));
        }
        return false;
    }

    static function isAnyOfTypePath(path:TypePath):Bool {
        return path.pack.length == 2 && path.pack[0] == "bevy" && path.pack[1] == "ecs" && path.name == "AnyOf"
            || (path.pack.length == 0 && path.name == "AnyOf");
    }

    static function extractTypeParamPath(param:TypeParam, pos:Position, errorMessage:String):TypePath {
        return switch param {
            case TPType(TPath(inner)):
                inner;
            default:
                Context.error(errorMessage, pos);
        };
    }

    static function buildTupleRuntimeClassExpr(path:TypePath, pos:Position, arity:Int):Expr {
        var tupleDataPath = extractTupleDataPath(path, pos);
        var generatedPath = tupleGeneratedClassPath(tupleDataPath, arity).join(".");
        return macro cast Type.resolveClass($v{generatedPath});
    }

    static function buildAnyOfRuntimeClassExpr(path:TypePath, pos:Position, arity:Int):Expr {
        var anyOfDataPath = extractAnyOfDataPath(path, pos);
        var generatedPath = anyOfGeneratedClassPath(anyOfDataPath, arity).join(".");
        return macro cast Type.resolveClass($v{generatedPath});
    }

    static function tupleGeneratedClassPath(tupleDataPath:TypePath, arity:Int):Array<String> {
        var pack = tupleDataPath.pack.copy();
        var baseName = tupleDataPath.name;
        if (tupleDataPath.sub != null && tupleDataPath.sub != "") {
            baseName = tupleDataPath.sub;
        }
        if (isNumberedTupleName(baseName)) {
            baseName = "Tuple";
        }
        return pack.concat([baseName + "_" + arity]);
    }

    static function anyOfGeneratedClassPath(anyOfDataPath:TypePath, arity:Int):Array<String> {
        var pack = anyOfDataPath.pack.copy();
        var name = anyOfDataPath.name;
        if (anyOfDataPath.sub != null && anyOfDataPath.sub != "") {
            name = anyOfDataPath.sub;
        }
        if (pack.length == 0 && name == "AnyOf") {
            pack = ["bevy", "ecs"];
        }
        return pack.concat([name + "_" + arity]);
    }

    static function buildTupleFactoryExpr(path:TypePath, pos:Position, arity:Int):Expr {
        var tupleDataPath = extractTupleDataPath(path, pos);
        var ctorArgs:Array<Expr> = [for (i in 0...arity) macro __bevyTupleRaw[$v{i}]];

        return {
            expr: EFunction(FAnonymous, {
                args: [{
                    name: "__bevyTupleRaw",
                    type: macro : Array<Any>,
                    opt: false,
                    value: null
                }],
                ret: null,
                expr: {
                    expr: EReturn({
                        expr: ENew(tupleDataPath, ctorArgs),
                        pos: pos
                    }),
                    pos: pos
                },
                params: []
            }),
            pos: pos
        };
    }

    static function buildAnyOfFactoryExpr(path:TypePath, pos:Position, arity:Int):Expr {
        var anyOfDataPath = extractAnyOfDataPath(path, pos);
        var ctorArgs:Array<Expr> = [for (i in 0...arity) macro __bevyAnyOfRaw[$v{i}]];

        return {
            expr: EFunction(FAnonymous, {
                args: [{
                    name: "__bevyAnyOfRaw",
                    type: macro : Array<Any>,
                    opt: false,
                    value: null
                }],
                ret: null,
                expr: {
                    expr: EReturn({
                        expr: ENew(anyOfDataPath, ctorArgs),
                        pos: pos
                    }),
                    pos: pos
                },
                params: []
            }),
            pos: pos
        };
    }

    static function buildAnyOfQueryDataTypeKeyExpr(path:TypePath, pos:Position):Expr {
        if (path.params == null || path.params.length == 0) {
            Context.error("Query data AnyOf<...> requires at least one type parameter", pos);
        }
        var itemKeyExprs:Array<Expr> = [];
        for (i in 0...path.params.length) {
            var itemPath = extractTypeParamPath(path.params[i], pos, 'Query data AnyOf parameter #${i + 1} must be a class path');
            var keyExpr = buildAnyOfItemTypeKeyExpr(itemPath, pos, true);
            itemKeyExprs.push(keyExpr);
        }
        return macro bevy.ecs.QueryDataKey.encodeAnyOfKeys([$a{itemKeyExprs}]);
    }

    static function buildAnyOfItemTypeKeyExpr(path:TypePath, pos:Position, encodeDataClass:Bool = false):Expr {
        if (isEntityTypePath(path)) {
            return macro bevy.ecs.QueryDataKey.anyOfEntityItem();
        }
        if (isEntityRefTypePath(path)) {
            return macro bevy.ecs.QueryDataKey.anyOfEntityRefItem();
        }
        if (isEntityWorldMutTypePath(path)) {
            return macro bevy.ecs.QueryDataKey.anyOfEntityWorldMutItem();
        }
        if (isSpawnDetailsTypePath(path)) {
            return macro bevy.ecs.QueryDataKey.anyOfSpawnDetailsItem();
        }
        if (isHasTypePath(path)) {
            return macro bevy.ecs.QueryDataKey.anyOfHasItem(${buildConcreteTypeKeyExpr(extractHasTargetTypePath(path, pos), pos)});
        }
        if (isOptionTypePath(path)) {
            var target = extractOptionTargetTypePath(path, pos);
            rejectUnsupportedOptionSyntheticTarget(target, pos);
            return macro bevy.ecs.QueryDataKey.anyOfOptionItem(${buildOptionTargetTypeKeyExpr(target, pos)});
        }
        if (isRefTypePath(path) || isMutTypePath(path)) {
            var target = extractRefMutTargetTypePath(path, pos);
            var targetKey = buildConcreteTypeKeyExpr(target, pos);
            return isRefTypePath(path)
                ? macro bevy.ecs.QueryDataKey.anyOfRefItem($e{targetKey})
                : macro bevy.ecs.QueryDataKey.anyOfMutItem($e{targetKey});
        }
        if (isAnyOfTypePath(path)) {
            return buildAnyOfQueryDataTypeKeyExpr(path, pos);
        }
        var componentKeyExpr = buildConcreteTypeKeyExpr(path, pos);
        return encodeDataClass
            ? macro bevy.ecs.QueryDataKey.anyOfComponentItem($e{componentKeyExpr})
            : componentKeyExpr;
    }

    static function buildQueryDataRuntimeClassExpr(path:TypePath, pos:Position):Expr {
        if (isAnyOfTypePath(path)) {
            if (path.params == null || path.params.length == 0) {
                Context.error("Query data AnyOf<...> requires at least one type parameter", pos);
            }
            var generatedPath = anyOfGeneratedClassPath(path, path.params.length).join(".");
            return macro cast Type.resolveClass($v{generatedPath});
        }
        return typePathExpr(path, pos);
    }

    static function isPositiveIntString(value:String):Bool {
        if (value == null || value == "") {
            return false;
        }
        for (i in 0...value.length) {
            var code = value.charCodeAt(i);
            if (code < "0".code || code > "9".code) {
                return false;
            }
        }
        return true;
    }

    static function isNumberedTupleName(value:String):Bool {
        return value != null
            && StringTools.startsWith(value, "Tuple")
            && isPositiveIntString(value.substr("Tuple".length));
    }

    static function complexTypeStorageKey(path:TypePath, pos:Position, label:String):String {
        if (path.params == null || path.params.length != 1) {
            Context.error('System $label params require exactly one type parameter', pos);
        }

        return switch path.params[0] {
            case TPType(TPath(inner)):
                typePathStorageKey(inner, pos);
            default:
                Context.error('System $label params require a class type parameter', pos);
        }
    }

    static function typePathStorageKey(path:TypePath, pos:Position):String {
        var base = typePathSegments(path).join(".");
        if (path.params == null || path.params.length == 0) {
            return base;
        }

        var params:Array<String> = [];
        for (param in path.params) {
            params.push(typeParamStorageKey(param, pos));
        }
        return base + "<" + params.join(",") + ">";
    }

    static function pushQueryDataKey(into:Array<String>, path:TypePath, pos:Position):Void {
        if (isEntityTypePath(path) || isSpawnDetailsTypePath(path)) {
            return;
        }
        if (isHasTypePath(path)) {
            extractHasTargetTypePath(path, pos);
            return;
        }
        into.push(typePathStorageKey(path, pos));
    }

    static function collectQueryDataKeys(accessKeys:Array<String>, requiredKeys:Array<String>, path:TypePath, pos:Position):Void {
        var state = collectQueryDataState(path, pos);
        for (key in state.accessKeys) {
            accessKeys.push(key);
        }
        if (state.requiredBranches.length == 0) {
            return;
        }
        var intersected = intersectRequiredBranches(state.requiredBranches);
        for (key in intersected) {
            requiredKeys.push(key);
        }
    }

    static function collectQueryDataState(path:TypePath, pos:Position):QueryDataState {
        if (isEntityTypePath(path) || isSpawnDetailsTypePath(path)) {
            return {
                accessKeys: [],
                requiredBranches: [new Map()]
            };
        }
        if (isEntityRefTypePath(path)) {
            return {
                accessKeys: [ENTITY_REF_MUT_KEY],
                requiredBranches: [new Map()]
            };
        }
        if (isEntityWorldMutTypePath(path)) {
            return {
                accessKeys: [ENTITY_WORLD_MUT_KEY],
                requiredBranches: [new Map()]
            };
        }
        if (isRefTypePath(path) || isMutTypePath(path)) {
            var target = extractRefMutTargetTypePath(path, pos);
            var key = typePathStorageKey(target, pos);
            return {
                accessKeys: [key],
                requiredBranches: [mapWithSingleKey(key)]
            };
        }
        if (isHasTypePath(path)) {
            extractHasTargetTypePath(path, pos);
            return {
                accessKeys: [],
                requiredBranches: [new Map()]
            };
        }
        if (isOptionTypePath(path)) {
            var target = extractOptionTargetTypePath(path, pos);
            rejectUnsupportedOptionSyntheticTarget(target, pos);
            var targetState = collectQueryDataState(target, pos);
            return {
                accessKeys: targetState.accessKeys.copy(),
                requiredBranches: [new Map()]
            };
        }
        if (isAnyOfTypePath(path)) {
            if (path.params == null || path.params.length == 0) {
                Context.error("Query data AnyOf<...> requires at least one type parameter", pos);
            }
            var anyAccess:Array<String> = [];
            var anyBranches:Array<Map<String, Bool>> = [];
            var anyOrderedAccess:Array<String> = [];
            var anyAccessHasMutable:Map<String, Bool> = new Map();
            for (i in 0...path.params.length) {
                var itemPath = extractTypeParamPath(path.params[i], pos, 'Query data AnyOf parameter #${i + 1} must be a class path');
                var branchState = collectQueryDataState(itemPath, pos);
                var branchHasMutable = isMutTypePath(itemPath);
                for (key in branchState.accessKeys) {
                    anyOrderedAccess.push(key);
                    if (branchHasMutable) {
                        anyAccessHasMutable.set(key, true);
                    }
                }
                for (branch in branchState.requiredBranches) {
                    anyBranches.push(copyKeyMap(branch));
                }
            }
            var seenReadOnly:Map<String, Bool> = new Map();
            for (key in anyOrderedAccess) {
                if (anyAccessHasMutable.exists(key)) {
                    anyAccess.push(key);
                    continue;
                }
                if (!seenReadOnly.exists(key)) {
                    anyAccess.push(key);
                    seenReadOnly.set(key, true);
                }
            }
            return {
                accessKeys: anyAccess,
                requiredBranches: anyBranches
            };
        }
        var key = typePathStorageKey(path, pos);
        return {
            accessKeys: [key],
            requiredBranches: [mapWithSingleKey(key)]
        };
    }

    static function mapWithSingleKey(key:String):Map<String, Bool> {
        var map:Map<String, Bool> = new Map();
        map.set(key, true);
        return map;
    }

    static function intersectRequiredBranches(branches:Array<Map<String, Bool>>):Array<String> {
        var result:Array<String> = [];
        if (branches == null || branches.length == 0) {
            return result;
        }
        var first = branches[0];
        for (key in first.keys()) {
            var keep = true;
            for (i in 1...branches.length) {
                if (!branches[i].exists(key)) {
                    keep = false;
                    break;
                }
            }
            if (keep) {
                result.push(key);
            }
        }
        return result;
    }

    static function isEntityTypePath(path:TypePath):Bool {
        return path.pack.length == 2 && path.pack[0] == "bevy" && path.pack[1] == "ecs" && path.name == "Entity"
            || (path.pack.length == 0 && path.name == "Entity");
    }

    static function isEntityRefTypePath(path:TypePath):Bool {
        return path.pack.length == 2 && path.pack[0] == "bevy" && path.pack[1] == "ecs" && path.name == "Entity" && path.sub == "EntityRef"
            || path.pack.length == 2 && path.pack[0] == "bevy" && path.pack[1] == "ecs" && path.name == "EntityRef"
            || (path.pack.length == 0 && path.name == "EntityRef");
    }

    static function isEntityWorldMutTypePath(path:TypePath):Bool {
        return path.pack.length == 2 && path.pack[0] == "bevy" && path.pack[1] == "ecs" && path.name == "Entity" && path.sub == "EntityWorldMut"
            || path.pack.length == 2 && path.pack[0] == "bevy" && path.pack[1] == "ecs" && path.name == "EntityWorldMut"
            || (path.pack.length == 0 && path.name == "EntityWorldMut");
    }

    static function isSpawnDetailsTypePath(path:TypePath):Bool {
        return path.pack.length == 2 && path.pack[0] == "bevy" && path.pack[1] == "ecs" && path.name == "SpawnDetails"
            || (path.pack.length == 0 && path.name == "SpawnDetails");
    }

    static function isHasTypePath(path:TypePath):Bool {
        return path.pack.length == 2 && path.pack[0] == "bevy" && path.pack[1] == "ecs" && path.name == "Has"
            || (path.pack.length == 0 && path.name == "Has");
    }

    static function isOptionTypePath(path:TypePath):Bool {
        return path.pack.length == 2 && path.pack[0] == "bevy" && path.pack[1] == "ecs" && path.name == "Option"
            || (path.pack.length == 0 && path.name == "Option");
    }

    static function isRefTypePath(path:TypePath):Bool {
        return path.pack.length == 2 && path.pack[0] == "bevy" && path.pack[1] == "ecs" && path.name == "Ref"
            || (path.pack.length == 0 && path.name == "Ref");
    }

    static function isMutTypePath(path:TypePath):Bool {
        return path.pack.length == 2 && path.pack[0] == "bevy" && path.pack[1] == "ecs" && path.name == "Mut"
            || (path.pack.length == 0 && path.name == "Mut");
    }

    static function typeParamStorageKey(param:TypeParam, pos:Position):String {
        return switch param {
            case TPType(TPath(inner)):
                typePathStorageKey(inner, pos);
            default:
                Context.error("System params require class type parameters", pos);
        }
    }

    static function buildOptionalTypeKeyExpr(param:TypeParam, pos:Position):Expr {
        return switch param {
            case TPType(TPath(inner)):
                if (inner.params != null && inner.params.length > 0) {
                    buildParameterizedTypeKeyExpr(inner, pos);
                } else {
                    macro null;
                }
            default:
                Context.error("System params require class type parameters", pos);
        }
    }

    static function buildQueryDataParamKeyExpr(param:TypeParam, pos:Position):Expr {
        return switch param {
            case TPType(TPath(inner)):
                buildQueryDataTypeKeyExpr(inner, pos);
            default:
                Context.error("System Query data parameters require class type parameters", pos);
        }
    }

    static function buildQueryDataTypeKeyExpr(path:TypePath, pos:Position):Expr {
        if (isRefTypePath(path) || isMutTypePath(path)) {
            return buildConcreteTypeKeyExpr(extractRefMutTargetTypePath(path, pos), pos);
        }
        if (isHasTypePath(path)) {
            return buildConcreteTypeKeyExpr(extractHasTargetTypePath(path, pos), pos);
        }
        if (isOptionTypePath(path)) {
            var target = extractOptionTargetTypePath(path, pos);
            rejectUnsupportedOptionSyntheticTarget(target, pos);
            return buildOptionTargetTypeKeyExpr(target, pos);
        }
        if (isAnyOfTypePath(path)) {
            return buildAnyOfQueryDataTypeKeyExpr(path, pos);
        }
        return path.params != null && path.params.length > 0 ? buildParameterizedTypeKeyExpr(path, pos) : macro null;
    }

    static function buildOptionTargetTypeKeyExpr(path:TypePath, pos:Position):Expr {
        if (isEntityTypePath(path)) {
            return macro bevy.ecs.QueryDataKey.anyOfEntityItem();
        }
        if (isEntityRefTypePath(path)) {
            return macro bevy.ecs.QueryDataKey.anyOfEntityRefItem();
        }
        if (isEntityWorldMutTypePath(path)) {
            return macro bevy.ecs.QueryDataKey.anyOfEntityWorldMutItem();
        }
        if (isSpawnDetailsTypePath(path)) {
            return macro bevy.ecs.QueryDataKey.anyOfSpawnDetailsItem();
        }
        if (isHasTypePath(path)) {
            var target = extractHasTargetTypePath(path, pos);
            return macro bevy.ecs.QueryDataKey.anyOfHasItem(${buildConcreteTypeKeyExpr(target, pos)});
        }
        if (isOptionTypePath(path)) {
            var target = extractOptionTargetTypePath(path, pos);
            return macro bevy.ecs.QueryDataKey.anyOfOptionItem(${buildOptionTargetTypeKeyExpr(target, pos)});
        }
        if (isAnyOfTypePath(path)) {
            return buildAnyOfQueryDataTypeKeyExpr(path, pos);
        }
        if (isRefTypePath(path) || isMutTypePath(path)) {
            var target = extractRefMutTargetTypePath(path, pos);
            var targetKey = buildConcreteTypeKeyExpr(target, pos);
            return isRefTypePath(path)
                ? macro bevy.ecs.QueryDataKey.anyOfRefItem($e{targetKey})
                : macro bevy.ecs.QueryDataKey.anyOfMutItem($e{targetKey});
        }
        return buildConcreteTypeKeyExpr(path, pos);
    }

    static function extractHasTargetTypePath(path:TypePath, pos:Position):TypePath {
        if (path.params == null || path.params.length != 1) {
            Context.error("Query data Has<T> requires exactly one component type parameter", pos);
        }
        return switch path.params[0] {
            case TPType(TPath(inner)):
                inner;
            default:
                Context.error("Query data Has<T> requires a component class type parameter", pos);
        }
    }

    static function extractOptionTargetTypePath(path:TypePath, pos:Position):TypePath {
        if (path.params == null || path.params.length != 1) {
            Context.error("Query data Option<T> requires exactly one component type parameter", pos);
        }
        return switch path.params[0] {
            case TPType(TPath(inner)):
                inner;
            default:
                Context.error("Query data Option<T> requires a component class type parameter", pos);
        }
    }

    static function extractRefMutTargetTypePath(path:TypePath, pos:Position):TypePath {
        if (path.params == null || path.params.length != 1) {
            Context.error("Query data Ref<T>/Mut<T> requires exactly one component type parameter", pos);
        }
        return switch path.params[0] {
            case TPType(TPath(inner)):
                inner;
            default:
                Context.error("Query data Ref<T>/Mut<T> requires a component class type parameter", pos);
        }
    }

    static function rejectUnsupportedOptionSyntheticTarget(path:TypePath, pos:Position):Void {
        // Option<T> supports every query-data target T this macro can encode.
    }

    static function buildConcreteTypeKeyExpr(path:TypePath, pos:Position):Expr {
        if (path.params != null && path.params.length > 0) {
            return buildParameterizedTypeKeyExpr(path, pos);
        }
        return macro bevy.ecs.TypeKey.ofClass($e{typePathExpr(path, pos)});
    }

    static function buildParameterizedTypeKeyExpr(path:TypePath, pos:Position):Expr {
        var params:Array<Expr> = [];
        if (path.params != null) {
            for (param in path.params) {
                params.push(buildTypeParamKeyExpr(param, pos));
            }
        }

        return macro bevy.ecs.TypeKey.parameterized(
            bevy.ecs.TypeKey.ofClass($e{typePathExpr(path, pos)}),
            $a{params}
        );
    }

    static function buildTypeParamKeyExpr(param:TypeParam, pos:Position):Expr {
        return switch param {
            case TPType(TPath(inner)):
                if (inner.params != null && inner.params.length > 0) {
                    buildParameterizedTypeKeyExpr(inner, pos);
                } else {
                    macro bevy.ecs.TypeKey.ofClass($e{typePathExpr(inner, pos)});
                }
            default:
                Context.error("System resource params require class type parameters", pos);
        }
    }

    static function extractTwoTypeClassExprs(path:TypePath, pos:Position):{a:Expr, b:Expr} {
        if (path.params == null || path.params.length < 2) {
            Context.error("System Query2 params require at least two type parameters", pos);
        }
        return {
            a: switch path.params[0] {
                case TPType(TPath(inner)):
                    buildQueryDataRuntimeClassExpr(inner, pos);
                default:
                    Context.error("Query2 first parameter must be a class path", pos);
            },
            b: switch path.params[1] {
                case TPType(TPath(inner)):
                    buildQueryDataRuntimeClassExpr(inner, pos);
                default:
                    Context.error("Query2 second parameter must be a class path", pos);
            }
        };
    }

    static function extractTwoTypeKeys(path:TypePath, pos:Position):{a:Expr, b:Expr} {
        if (path.params == null || path.params.length < 2) {
            Context.error("System Query2 params require at least two type parameters", pos);
        }
        return {
            a: buildQueryDataParamKeyExpr(path.params[0], pos),
            b: buildQueryDataParamKeyExpr(path.params[1], pos)
        };
    }

    static function extractThreeTypeClassExprs(path:TypePath, pos:Position):{a:Expr, b:Expr, c:Expr} {
        if (path.params == null || path.params.length < 3) {
            Context.error("System Query3 params require at least three type parameters", pos);
        }
        return {
            a: switch path.params[0] {
                case TPType(TPath(inner)):
                    buildQueryDataRuntimeClassExpr(inner, pos);
                default:
                    Context.error("Query3 first parameter must be a class path", pos);
            },
            b: switch path.params[1] {
                case TPType(TPath(inner)):
                    buildQueryDataRuntimeClassExpr(inner, pos);
                default:
                    Context.error("Query3 second parameter must be a class path", pos);
            },
            c: switch path.params[2] {
                case TPType(TPath(inner)):
                    buildQueryDataRuntimeClassExpr(inner, pos);
                default:
                    Context.error("Query3 third parameter must be a class path", pos);
            }
        };
    }

    static function extractThreeTypeKeys(path:TypePath, pos:Position):{a:Expr, b:Expr, c:Expr} {
        if (path.params == null || path.params.length < 3) {
            Context.error("System Query3 params require at least three type parameters", pos);
        }
        return {
            a: buildQueryDataParamKeyExpr(path.params[0], pos),
            b: buildQueryDataParamKeyExpr(path.params[1], pos),
            c: buildQueryDataParamKeyExpr(path.params[2], pos)
        };
    }

    static function varDecl(name:String, value:Expr, pos:Position):Expr {
        return {
            expr: EVars([{name: name, type: null, expr: value}]),
            pos: pos
        };
    }

    static function appendToInit(fields:Array<Field>, expr:Expr, pos:Position):Void {
        for (field in fields) {
            if (field.name != "__init__") {
                continue;
            }
            switch field.kind {
                case FFun(fn):
                    fn.expr = switch fn.expr.expr {
                        case EBlock(exprs):
                            {expr: EBlock(exprs.concat([expr])), pos: fn.expr.pos};
                        default:
                            {expr: EBlock([fn.expr, expr]), pos: fn.expr.pos};
                    };
                    field.kind = FFun(fn);
                    return;
                default:
            }
        }

        fields.push({
            name: "__init__",
            doc: null,
            meta: [],
            access: [AStatic],
            kind: FFun({
                args: [],
                ret: macro:Void,
                expr: expr,
                params: []
            }),
            pos: pos
        });
    }

    static function findMeta(meta:Metadata, name:String):Null<MetadataEntry> {
        for (entry in meta) {
            if (entry.name == name || entry.name == ":" + name) {
                return entry;
            }
        }
        return null;
    }

    static function hasAccess(field:Field, access:Access):Bool {
        for (item in field.access) {
            if (item == access) {
                return true;
            }
        }
        return false;
    }

    static function hasMeta(meta:Metadata, name:String):Bool {
        for (entry in meta) {
            if (entry.name == name || entry.name == ":" + name) {
                return true;
            }
        }
        return false;
    }
}
#end
