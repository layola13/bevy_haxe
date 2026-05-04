package haxe.macro;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

/**
    Macro implementation for App methods.
    
    This module provides compile-time code generation for:
    - addPlugins - adding multiple plugins at once
    - addSystems - adding multiple systems at once
**/
class AppMacro {
    /**
        Macro implementation for `addPlugins`.
        
        Transforms: `app.addPlugins(PluginA, PluginB, PluginC)`
        Into: `app.addPlugin(new PluginA()).addPlugin(new PluginB()).addPlugin(new PluginC())`
    **/
    public static function addPlugins(appExpr:Expr, plugins:Array<Expr>):Expr {
        var result:Expr = appExpr;
        
        for (plugin in plugins) {
            // Wrap the plugin expression in a constructor call if it's a type path
            var addExpr = switch (plugin.expr) {
                case EConst(CIdent(name)):
                    // It's a type identifier, create new instance
                    macro $result.addPlugin(new $plugin());
                case EConst(CType(name)):
                    // It's a type name
                    macro $result.addPlugin(new $plugin());
                case ENew(_.params => [] .fields => [] .cl => path, _):
                    // It's already a constructor call
                    macro $result.addPlugin($plugin);
                default:
                    // Assume it's already an expression that yields a plugin
                    macro $result.addPlugin($plugin);
            };
            result = addExpr;
        }
        
        return result;
    }
    
    /**
        Macro implementation for `addSystems`.
        
        Transforms: `app.addSystems(Update, sys1, sys2, sys3)`
        Into: `app.addSystem(Update, sys1).addSystem(Update, sys2).addSystem(Update, sys3)`
    **/
    public static function addSystems(appExpr:Expr, schedule:Expr, systems:Array<Expr>):Expr {
        var result:Expr = appExpr;
        
        for (system in systems) {
            var addExpr = macro $result.addSystem($schedule, $system);
            result = addExpr;
        }
        
        return result;
    }
    
    /**
        Macro implementation for `addSystems` with conditions.
        
        Transforms: `app.addSystems((Update, system1).before(system2).after(system3), sys1, sys2)`
        Into chained addSystem calls with ordering applied.
    **/
    public static function addSystemsWithConfig(appExpr:Expr, config:Expr, systems:Array<Expr>):Expr {
        var result:Expr = appExpr;
        
        for (system in systems) {
            var addExpr = macro $result.addSystem($config.schedule, $system);
            result = addExpr;
        }
        
        return result;
    }
    
    /**
        Build function for @:app metadata.
        
        Applies app-level configurations.
    **/
    public static function build():Void {
        var type = Context.getTypeExpr(Context.getLocalClass().get());
        
        switch (type.expr) {
            case EClass(decl):
                processAppClass(decl);
            default:
                Context.error("@:app can only be applied to classes", Context.currentPos());
        }
    }
    
    /**
        Process an App subclass and add required fields/methods.
    **/
    static function processAppClass(decl:ClassDecl):Void {
        // Add default plugins field if not present
        var hasPluginsField = decl.fields.find(f -> f.name == 'defaultPlugins') != null;
        if (!hasPluginsField) {
            decl.fields.push({
                name: 'defaultPlugins',
                access: [APrivate],
                kind: FVar(macro:Array<haxe.app.Plugin>, macro []),
                pos: decl.pos
            });
        }
        
        // Add build method if not present
        var hasBuildMethod = decl.fields.find(f -> f.name == 'build') != null;
        if (!hasBuildMethod) {
            decl.fields.push({
                name: 'build',
                access: [APublic],
                kind: FFun({
                    args: [],
                    ret: macro:Void,
                    expr: macro {},
                    params: []
                }),
                pos: decl.pos
            });
        }
    }
    
    /**
        Extract plugin types from expressions.
    **/
    static function extractPluginTypes(plugins:Array<Expr>):Array<ComplexType> {
        var types:Array<ComplexType> = [];
        
        for (plugin in plugins) {
            switch (plugin.expr) {
                case EConst(CIdent(name)):
                    types.push(TPath({pack: [], name: name, params: [], sub: null}));
                case EConst(CType(name)):
                    types.push(TPath({pack: [], name: name, params: [], sub: null}));
                case ENew(_.cl => path, _):
                    types.push(TPath(path));
                default:
                    // Keep original expression type
                    var t = Context.typeof(plugin);
                    switch (Context.follow(t)) {
                        case TInst(c, _):
                            types.push(TPath(c.toString().split('.')
                                .filter(s -> s.length > 0)
                                .join('.')));
                        default:
                            // Skip if we can't determine the type
                    }
            }
        }
        
        return types;
    }
    
    /**
        Generate plugin registration code.
    **/
    static function generatePluginRegistration(types:Array<ComplexType>):Expr {
        var exprs:Array<Expr> = [];
        
        for (tp in types) {
            switch (tp) {
                case TPath(path):
                    exprs.push(macro plugins.push(new $tp()));
                default:
            }
        }
        
        if (exprs.length > 0) {
            return macro $b{exprs};
        }
        return macro {};
    }
    
    /**
        Generate system registration code.
    **/
    static function generateSystemRegistration(schedule:Expr, systems:Array<Expr>):Expr {
        var exprs:Array<Expr> = [];
        
        for (sys in systems) {
            exprs.push(macro addSystem($schedule, $sys));
        }
        
        if (exprs.length > 0) {
            return macro $b{exprs};
        }
        return macro {};
    }
}

/**
    Metadata for plugin configuration.
**/
typedef PluginConfig = {
    var ?before:Array<String>;
    var ?after:Array<String>;
    var ?settings:Dynamic;
}

/**
    Metadata for system configuration.
**/
typedef SystemConfig = {
    var ?schedule:Dynamic;
    var ?before:Array<String>;
    var ?after:Array<String>;
    var ?conditions:Array<Void->Bool>;
    var ?inSet:Dynamic;
}
