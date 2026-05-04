package bevy.macro;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

class SystemMacro {
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
                    var methodExpr:Expr = {expr: EField(classExpr, field.name), pos: field.pos};
                    var resolved = resolveArgs(fn.args, field.pos);
                    var call = {expr: ECall(methodExpr, resolved.args), pos: field.pos};
                    var body = buildRunBody(call, fn.ret, resolved, field.pos);
                    registrations.push(macro bevy.app.SystemRegistry.register({
                        name: $v{systemName},
                        schedule: $v{schedule},
                        run: function(world:bevy.ecs.World):Dynamic {
                            $body;
                        }
                    }));
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
                        default:
                    }
                default:
            }
        }
    }

    static function resolveArgs(args:Array<FunctionArg>, pos:Position):{args:Array<Expr>, prelude:Array<Expr>, applyCommands:Expr, commandsName:Null<String>} {
        var resolved:Array<Expr> = [];
        var prelude:Array<Expr> = [];
        var commandsName:Null<String> = null;

        for (arg in args) {
            if (arg.type == null) {
                Context.error("@:system arguments must have explicit types", pos);
            }
            switch arg.type {
                case TPath(path):
                    var full = fullPath(path);
                    switch full {
                        case "bevy.ecs.World" | "World":
                            resolved.push(macro world);
                        case "bevy.ecs.Commands" | "Commands":
                            if (commandsName != null) {
                                Context.error("@:system supports only one Commands parameter", pos);
                            }
                            commandsName = "__bevyCommands";
                            prelude.push(varDecl(commandsName, macro world.commands(), pos));
                            resolved.push(macro $i{commandsName});
                        case "bevy.ecs.Res" | "Res":
                            resolved.push(macro new bevy.ecs.Res(${buildResourceAccess(path, false, pos)}));
                        case "bevy.ecs.ResMut" | "ResMut":
                            resolved.push(macro new bevy.ecs.ResMut(${buildResourceAccess(path, true, pos)}));
                        case "bevy.ecs.Query" | "Query":
                            resolved.push(macro world.query($p{extractSingleTypePath(path, pos)}));
                        case "bevy.ecs.Query2" | "Query2":
                            var pair = extractTwoTypePaths(path, pos);
                            resolved.push(macro world.queryPair($p{pair.a}, $p{pair.b}));
                        case "bevy.ecs.EventReader" | "EventReader":
                            resolved.push(macro world.getEvents($p{extractSingleTypePath(path, pos)}).reader());
                        case "bevy.ecs.EventWriter" | "EventWriter":
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

    static function buildRunBody(call:Expr, ret:Null<ComplexType>, resolved:{args:Array<Expr>, prelude:Array<Expr>, applyCommands:Expr, commandsName:Null<String>}, pos:Position):Expr {
        var exprs = resolved.prelude.copy();
        if (isVoidReturn(ret)) {
            exprs.push(call);
            exprs.push(resolved.applyCommands);
            exprs.push(macro return null);
            return {expr: EBlock(exprs), pos: pos};
        }

        if (resolved.commandsName == null) {
            exprs.push(macro return $call);
            return {expr: EBlock(exprs), pos: pos};
        }

        exprs.push(macro var __bevySystemResult = $call);
        exprs.push(macro return bevy.async.Future.fromDynamic(__bevySystemResult).map(function(__bevyIgnored) {
            ${resolved.applyCommands};
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
        return path.pack.length == 0 ? path.name : path.pack.join(".") + "." + path.name;
    }

    static function extractSingleTypePath(path:TypePath, pos:Position):Array<String> {
        if (path.params == null || path.params.length != 1) {
            Context.error("System resource params require exactly one type parameter", pos);
        }
        return switch path.params[0] {
            case TPType(TPath(inner)):
                inner.pack.concat([inner.name]);
            default:
                Context.error("System resource params require a class type parameter", pos);
        }
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
                    macro world.getResource($p{inner.pack.concat([inner.name])});
                }
            default:
                Context.error("System resource params require a class type parameter", pos);
        }
    }

    static function buildParameterizedTypeKeyExpr(path:TypePath, pos:Position):Expr {
        var params:Array<Expr> = [];
        if (path.params != null) {
            for (param in path.params) {
                params.push(buildTypeParamKeyExpr(param, pos));
            }
        }

        return macro bevy.ecs.TypeKey.parameterized(
            bevy.ecs.TypeKey.ofClass($p{path.pack.concat([path.name])}),
            $a{params}
        );
    }

    static function buildTypeParamKeyExpr(param:TypeParam, pos:Position):Expr {
        return switch param {
            case TPType(TPath(inner)):
                if (inner.params != null && inner.params.length > 0) {
                    buildParameterizedTypeKeyExpr(inner, pos);
                } else {
                    macro bevy.ecs.TypeKey.ofClass($p{inner.pack.concat([inner.name])});
                }
            default:
                Context.error("System resource params require class type parameters", pos);
        }
    }

    static function extractTwoTypePaths(path:TypePath, pos:Position):{a:Array<String>, b:Array<String>} {
        if (path.params == null || path.params.length != 2) {
            Context.error("System Query2 params require exactly two type parameters", pos);
        }
        return {
            a: switch path.params[0] {
                case TPType(TPath(inner)):
                    inner.pack.concat([inner.name]);
                default:
                    Context.error("Query2 first parameter must be a class path", pos);
            },
            b: switch path.params[1] {
                case TPType(TPath(inner)):
                    inner.pack.concat([inner.name]);
                default:
                    Context.error("Query2 second parameter must be a class path", pos);
            }
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
