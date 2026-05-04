package bevy.macro;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

class AsyncBuildMacro {
    public static function build():Array<Field> {
        var fields = Context.getBuildFields();
        for (field in fields) {
            if (!hasMeta(field.meta, "async")) {
                continue;
            }

            switch field.kind {
                case FFun(fn):
                    if (field.name == "new") {
                        Context.error("@:async constructors are not supported; use an async factory method instead", field.pos);
                    }
                    field.kind = FFun(AsyncMacro.transformFunction(fn, field.pos));
                default:
                    Context.error("@:async can only be applied to functions", field.pos);
            }
        }
        return fields;
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
