package bevy.macro;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

class EcsRegistrationMacro {
    public static function build(registryPath:String, methodName:String):Array<Field> {
        var fields = Context.getBuildFields();
        var cls = Context.getLocalClass().get();
        var pos = Context.currentPos();
        var classPath = cls.pack.concat([cls.name]).join(".");
        var classExpr = Context.parse(classPath, pos);

        var registerFieldName = "__bevyRegister" + methodName;
        if (!hasField(fields, registerFieldName)) {
            fields.push({
                name: registerFieldName,
                doc: null,
                meta: [],
                access: [APublic, AStatic],
                kind: FFun({
                    args: [],
                    ret: macro:Void,
                    expr: macro $p{registryPath.split(".")}.register($classExpr),
                    params: []
                }),
                pos: pos
            });
        }

        appendToInit(fields, macro $i{registerFieldName}(), pos);
        return fields;
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
}
#end
