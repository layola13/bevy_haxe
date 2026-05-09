package haxe.app;

import haxe.macro.Expr;

class PluginsDsl {
    public static macro function of(values:Array<Expr>):Expr {
        if (values == null || values.length == 0) {
            return macro ([] : Array<haxe.app.Plugins>);
        }

        var pushes:Array<Expr> = [];
        for (value in values) {
            pushes.push(macro __haxePlugins.push(${buildPluginsExpr(value)}));
        }

        return macro {
            var __haxePlugins:Array<haxe.app.Plugins> = [];
            $b{pushes};
            __haxePlugins;
        };
    }

    static function buildPluginsExpr(value:Expr):Expr {
        return switch value.expr {
            case EArrayDecl(items):
                var pushes:Array<Expr> = [];
                for (item in items) {
                    pushes.push(macro __haxeNestedPlugins.push(${buildPluginsExpr(item)}));
                }
                macro {
                    var __haxeNestedPlugins:Array<haxe.app.Plugins> = [];
                    $b{pushes};
                    __haxeNestedPlugins;
                };
            default:
                value;
        };
    }
}

