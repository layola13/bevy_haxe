package bevy.macro;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

class ReflectMacro {
    public static function build():Array<Field> {
        var fields = Context.getBuildFields();
        var cls = Context.getLocalClass().get();
        var pos = Context.currentPos();
        var className = cls.name;
        var modulePath = cls.pack.join(".");
        var reflectedFields = collectInstanceFields(fields);
        var reflectedFieldExprs = [for (field in reflectedFields) macro $v{field}];

        ensureMethod(fields, "typeInfo", macro:bevy.reflect.TypeInfo, macro {
            return new bevy.reflect.TypeInfo($v{className}, $v{modulePath}, bevy.reflect.TypeInfo.TypeKind.Reflectable, $a{reflectedFieldExprs});
        }, pos);

        ensureMethod(fields, "getField", macro:Dynamic, buildGetField(reflectedFields, pos), pos, [
            {name: "name", opt: false, type: macro:String, value: null}
        ]);

        ensureMethod(fields, "setField", macro:Bool, buildSetField(reflectedFields, pos), pos, [
            {name: "name", opt: false, type: macro:String, value: null},
            {name: "value", opt: false, type: macro:Dynamic, value: null}
        ]);

        appendToInit(fields, buildRegistration(className, modulePath, reflectedFields, pos), pos);
        return fields;
    }

    static function collectInstanceFields(fields:Array<Field>):Array<String> {
        var result:Array<String> = [];
        for (field in fields) {
            if (field.name == "new" || hasAccess(field, AStatic)) {
                continue;
            }
            switch field.kind {
                case FVar(_, _) | FProp(_, _, _, _):
                    if (!hasMeta(field.meta, "no_reflect") && !hasMeta(field.meta, "skip")) {
                        result.push(field.name);
                    }
                default:
            }
        }
        return result;
    }

    static function buildGetField(names:Array<String>, pos:Position):Expr {
        var cases:Array<Case> = [
            for (name in names) {
                values: [macro $v{name}],
                guard: null,
                expr: {
                    expr: EReturn({expr: EField(macro this, name), pos: pos}),
                    pos: pos
                }
            }
        ];
        return {
            expr: ESwitch(macro name, cases, macro return null),
            pos: pos
        };
    }

    static function buildSetField(names:Array<String>, pos:Position):Expr {
        var cases:Array<Case> = [
            for (name in names) {
                values: [macro $v{name}],
                guard: null,
                expr: {
                    expr: EBlock([
                        {
                            expr: EBinop(
                                OpAssign,
                                {expr: EField(macro this, name), pos: pos},
                                {expr: ECast(macro value, null), pos: pos}
                            ),
                            pos: pos
                        },
                        macro return true
                    ]),
                    pos: pos
                }
            }
        ];
        return {
            expr: ESwitch(macro name, cases, macro return false),
            pos: pos
        };
    }

    static function buildRegistration(className:String, modulePath:String, reflectedFields:Array<String>, pos:Position):Expr {
        var reflectedFieldExprs = [for (field in reflectedFields) macro $v{field}];
        return macro bevy.reflect.TypeRegistry.global().registerInfo(
            new bevy.reflect.TypeInfo($v{className}, $v{modulePath}, bevy.reflect.TypeInfo.TypeKind.Reflectable, $a{reflectedFieldExprs})
        );
    }

    static function ensureMethod(fields:Array<Field>, name:String, ret:ComplexType, body:Expr, pos:Position, ?args:Array<FunctionArg>):Void {
        if (hasField(fields, name)) {
            return;
        }
        fields.push({
            name: name,
            doc: null,
            meta: [],
            access: [APublic],
            kind: FFun({
                args: args != null ? args : [],
                ret: ret,
                expr: body,
                params: []
            }),
            pos: pos
        });
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
                expr: {expr: EBlock([expr]), pos: pos},
                params: []
            }),
            pos: pos
        });
    }

    static function hasField(fields:Array<Field>, name:String):Bool {
        for (field in fields) {
            if (field.name == name) {
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

    static function hasAccess(field:Field, access:Access):Bool {
        for (item in field.access) {
            if (item == access) {
                return true;
            }
        }
        return false;
    }
}
#end
