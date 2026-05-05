package bevy.app;

import haxe.macro.Expr;

class PluginsDsl {
    public static macro function of(values:Array<Expr>):Expr {
        if (values == null || values.length == 0) {
            return macro ([] : Array<bevy.app.Plugins>);
        }

        var pushes:Array<Expr> = [];
        for (value in values) {
            pushes.push(macro __bevyPlugins.push(${buildPluginsExpr(value)}));
        }

        return macro {
            var __bevyPlugins:Array<bevy.app.Plugins> = [];
            $b{pushes};
            __bevyPlugins;
        };
    }

    static function buildPluginsExpr(value:Expr):Expr {
        return switch value.expr {
            case EArrayDecl(items):
                var pushes:Array<Expr> = [];
                for (item in items) {
                    pushes.push(macro __bevyNestedPlugins.push(${buildPluginsExpr(item)}));
                }
                macro {
                    var __bevyNestedPlugins:Array<bevy.app.Plugins> = [];
                    $b{pushes};
                    __bevyNestedPlugins;
                };
            default:
                value;
        };
    }
}
