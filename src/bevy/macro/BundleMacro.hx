package bevy.macro;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

class BundleMacro {
    public static function build():Array<Field> {
        var fields = Context.getBuildFields();
        var cls = Context.getLocalClass().get();
        var pos = Context.currentPos();
        var classPath = cls.pack.concat([cls.name]).join(".");
        var classExpr = Context.parse(classPath, pos);
        var bundleFields = collectBundleFields(fields);

        if (!hasField(fields, "toBundle")) {
            fields.push({
                name: "toBundle",
                doc: null,
                meta: [],
                access: [APublic],
                kind: FFun({
                    args: [],
                    ret: macro:Array<Dynamic>,
                    expr: buildToBundle(bundleFields, pos),
                    params: []
                }),
                pos: pos
            });
        }

        appendToInit(fields, macro bevy.ecs.BundleRegistry.register($classExpr), pos);
        return fields;
    }

    static function collectBundleFields(fields:Array<Field>):Array<String> {
        var result:Array<String> = [];
        for (field in fields) {
            if (field.name == "new" || hasAccess(field, AStatic)) {
                continue;
            }
            switch field.kind {
                case FVar(_, _) | FProp(_, _, _, _):
                    if (!hasMeta(field.meta, "bundle_skip") && !hasMeta(field.meta, "skip")) {
                        result.push(field.name);
                    }
                default:
            }
        }
        return result;
    }

    static function buildToBundle(names:Array<String>, pos:Position):Expr {
        var values = [
            for (name in names) {
                expr: EField(macro this, name),
                pos: pos
            }
        ];
        return macro return $a{values};
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
