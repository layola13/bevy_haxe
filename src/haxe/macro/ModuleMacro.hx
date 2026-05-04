package haxe.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

/**
 * Module building macro for ECS plugin and app construction.
 * Allows defining ECS modules as code units with automatic registration.
 * 
 * Usage:
 * ```haxe
 * @:module
 * class PhysicsModule {
 *     static function register(builder:haxe.ecs.app.AppBuilder) {
 *         builder.addPlugin(PhysicsPlugin);
 *         builder.addSystem(MovementSystem, PreUpdate);
 *         builder.addSystem(GravitySystem, Update);
 *     }
 * }
 * ```
 * 
 * Generates:
 * - Module registration
 * - Plugin initialization
 * - System registration
 * - Resource registration
 * - Startup systems
 * - Default resources
 */
class ModuleMacro {
    /**
     * Build function for @:module metadata
     */
    public static function build():Void {
        var type = Context.getTypeExpr(Context.getLocalClass().get());
        
        switch type.expr {
            case EClass(decl):
                processModuleClass(decl);
            default:
                Context.error("@:module can only be applied to classes", Context.currentPos());
        }
    }
    
    /**
     * Process module class
     */
    static function processModuleClass(decl:ClassDecl):Void {
        var moduleName = decl.name;
        var modulePath = Context.getLocalModule();
        
        // Extract module configuration
        var config = extractModuleConfig(decl);
        var plugins = extractPlugins(decl.fields);
        var systems = extractSystems(decl.fields);
        var resources = extractResources(decl.fields);
        var startupSystems = extractStartupSystems(decl.fields);
        
        // Validate module structure
        validateModuleStructure(decl, config, plugins, systems);
        
        // Generate module descriptor
        generateModuleDescriptor(moduleName, modulePath, config);
        
        // Generate plugin registration
        generatePluginRegistration(moduleName, plugins);
        
        // Generate system registration
        generateSystemRegistration(moduleName, systems);
        
        // Generate resource registration
        generateResourceRegistration(moduleName, resources);
        
        // Generate startup system registration
        generateStartupSystemRegistration(moduleName, startupSystems);
        
        // Add to module registry
        addToModuleRegistry(moduleName, modulePath, config);
        
        // Generate module entry point
        generateModuleEntry(moduleName, config);
    }
    
    /**
     * Module configuration
     */
    typedef ModuleConfig = {
        var name:String;
        var description:String;
        var version:String;
        var dependencies:Array<String>;
        var optional:Array<String>;
        var isPlugin:Bool;
        var order:Int;
    }
    
    /**
     * Extract module configuration from class metadata
     */
    static function extractModuleConfig(decl:ClassDecl):ModuleConfig {
        var config:ModuleConfig = {
            name: decl.name,
            description: null,
            version: "1.0.0",
            dependencies: [],
            optional: [],
            isPlugin: false,
            order: 0
        };
        
        for (entry in decl.meta) {
            switch entry.name {
                case ":module":
                    processModuleMeta(entry, config);
                case ":dependency":
                    if (entry.params != null) {
                        for (param in entry.params) {
                            switch param.expr {
                                case EConst(CString(s)):
                                    config.dependencies.push(s);
                                case EConst(CIdent(name)):
                                    config.dependencies.push(name);
                                default:
                            }
                        }
                    }
                case ":optional":
                    if (entry.params != null) {
                        for (param in entry.params) {
                            switch param.expr {
                                case EConst(CString(s)):
                                    config.optional.push(s);
                                case EConst(CIdent(name)):
                                    config.optional.push(name);
                                default:
                            }
                        }
                    }
            }
        }
        
        return config;
    }
    
    /**
     * Process @:module metadata parameters
     */
    static function processModuleMeta(entry:MetadataEntry, config:ModuleConfig):Void {
        if (entry.params == null) return;
        
        for (param in entry.params) {
            switch param.expr {
                case EObjectDecl(fields):
                    for (field in fields) {
                        switch field.field {
                            case "name":
                                if (field.expr != null) {
                                    switch field.expr.expr {
                                        case EConst(CString(s)):
                                            config.name = s;
                                        default:
                                    }
                                }
                            case "description":
                                if (field.expr != null) {
                                    switch field.expr.expr {
                                        case EConst(CString(s)):
                                            config.description = s;
                                        default:
                                    }
                                }
                            case "version":
                                if (field.expr != null) {
                                    switch field.expr.expr {
                                        case EConst(CString(s)):
                                            config.version = s;
                                        default:
                                    }
                                }
                            case "plugin":
                                if (field.expr != null) {
                                    switch field.expr.expr {
                                        case EConst(CIdent("true")):
                                            config.isPlugin = true;
                                        default:
                                    }
                                }
                            case "order":
                                if (field.expr != null) {
                                    switch field.expr.expr {
                                        case EConst(CInt(i)):
                                            config.order = Std.parseInt(i);
                                        default:
                                    }
                                }
                            default:
                        }
                    }
                default:
            }
        }
    }
    
    /**
     * Plugin information
     */
    typedef PluginInfo = {
        var pluginType:String;
        var config:Dynamic;
        var order:Int;
    }
    
    /**
     * Extract plugins from class fields
     */
    static function extractPlugins(fields:Array<Field>):Array<PluginInfo> {
        var plugins:Array<PluginInfo> = [];
        
        for (field in fields) {
            for (meta in field.meta) {
                if (meta.name == ":plugin") {
                    var pluginType = extractPluginType(field);
                    var pluginConfig = extractPluginConfig(meta);
                    plugins.push({
                        pluginType: pluginType,
                        config: pluginConfig,
                        order: 0
                    });
                }
            }
        }
        
        return plugins;
    }
    
    /**
     * Extract plugin type from field
     */
    static function extractPluginType(field:Field):String {
        switch field.kind {
            case FVar(t, _):
                return typeToString(t);
            default:
                return field.name;
        }
    }
    
    /**
     * Extract plugin configuration from metadata
     */
    static function extractPluginConfig(meta:MetadataEntry):Dynamic {
        if (meta.params == null || meta.params.length == 0) return null;
        
        var configExpr = meta.params[0];
        // Parse configuration object
        return parseConfigObject(configExpr);
    }
    
    /**
     * Parse configuration object expression
     */
    static function parseConfigObject(expr:Expr):Dynamic {
        switch expr.expr {
            case EObjectDecl(fields):
                var obj:Dynamic = {};
                for (field in fields) {
                    // Set property based on field name
                    var value = evalConfigValue(field.expr);
                    // Dynamic object assignment would go here
                }
                return obj;
            default:
                return null;
        }
    }
    
    /**
     * Evaluate configuration value
     */
    static function evalConfigValue(expr:Expr):Dynamic {
        switch expr.expr {
            case EConst(CInt(i)):
                return Std.parseInt(i);
            case EConst(CFloat(f)):
                return Std.parseFloat(f);
            case EConst(CString(s)):
                return s;
            case EConst(CIdent("true")):
                return true;
            case EConst(CIdent("false")):
                return false;
            case EConst(CIdent("null")):
                return null;
            default:
                return null;
        }
    }
    
    /**
     * System registration info
     */
    typedef SystemInfo = {
        var systemType:String;
        var schedule:String;
        var condition:Null<String>;
        var priority:Int;
    }
    
    /**
     * Extract systems from class fields
     */
    static function extractSystems(fields:Array<Field>):Array<SystemInfo> {
        var systems:Array<SystemInfo> = [];
        
        for (field in fields) {
            for (meta in field.meta) {
                if (meta.name == ":system") {
                    var systemInfo = extractSystemInfo(field, meta);
                    systems.push(systemInfo);
                }
            }
        }
        
        return systems;
    }
    
    /**
     * Extract system info from field and metadata
     */
    static function extractSystemInfo(field:Field, meta:MetadataEntry):SystemInfo {
        var systemType = extractSystemType(field);
        var schedule = "Update";
        var condition:Null<String> = null;
        var priority = 0;
        
        if (meta.params != null) {
            for (param in meta.params) {
                switch param.expr {
                    case EObjectDecl(fields):
                        for (f in fields) {
                            switch f.field {
                                case "schedule":
                                    if (f.expr != null) {
                                        switch f.expr.expr {
                                            case EConst(CIdent(s)):
                                                schedule = s;
                                            default:
                                        }
                                    }
                                case "condition":
                                    if (f.expr != null) {
                                        switch f.expr.expr {
                                            case EConst(CString(s)):
                                                condition = s;
                                            default:
                                        }
                                    }
                                case "priority":
                                    if (f.expr != null) {
                                        switch f.expr.expr {
                                            case EConst(CInt(i)):
                                                priority = Std.parseInt(i);
                                            default:
                                        }
                                    }
                                default:
                            }
                        }
                    default:
                }
            }
        }
        
        return {
            systemType: systemType,
            schedule: schedule,
            condition: condition,
            priority: priority
        };
    }
    
    /**
     * Extract system type from field
     */
    static function extractSystemType(field:Field):String {
        switch field.kind {
            case FVar(t, _):
                return typeToString(t);
            default:
                return field.name;
        }
    }
    
    /**
     * Convert type to string
     */
    static function typeToString(type:ComplexType):String {
        switch type {
            case TPath(p):
                return (p.pack.length > 0 ? p.pack.join(".") + "." : "") + p.name;
            case TParent(t):
                return typeToString(t);
            default:
                return "Unknown";
        }
    }
    
    /**
     * Resource registration info
     */
    typedef ResourceInfo = {
        var resourceType:String;
        var initialValue:Dynamic;
        var initFn:Null<String>;
    }
    
    /**
     * Extract resources from class fields
     */
    static function extractResources(fields:Array<Field>):Array<ResourceInfo> {
        var resources:Array<ResourceInfo> = [];
        
        for (field in fields) {
            for (meta in field.meta) {
                if (meta.name == ":resource" || meta.name == ":defaultResource") {
                    var resourceInfo = extractResourceInfo(field, meta);
                    resources.push(resourceInfo);
                }
            }
        }
        
        return resources;
    }
    
    /**
     * Extract resource info from field
     */
    static function extractResourceInfo(field:Field, meta:MetadataEntry):ResourceInfo {
        var resourceType = extractResourceType(field);
        var initialValue = extractInitialValue(field);
        var initFn:Null<String> = null;
        
        // Check for init function
        for (m in field.meta) {
            if (m.name == ":init") {
                initFn = field.name;
            }
        }
        
        return {
            resourceType: resourceType,
            initialValue: initialValue,
            initFn: initFn
        };
    }
    
    /**
     * Extract resource type from field
     */
    static function extractResourceType(field:Field):String {
        switch field.kind {
            case FVar(t, _):
                return typeToString(t);
            default:
                return "Dynamic";
        }
    }
    
    /**
     * Extract initial value from field
     */
    static function extractInitialValue(field:Field):Dynamic {
        switch field.kind {
            case FVar(_, e):
                if (e != null) {
                    return evalConfigValue(e);
                }
            default:
        }
        return null;
    }
    
    /**
     * Startup system info
     */
    typedef StartupSystemInfo = {
        var systemType:String;
        var schedule:String;
        var label:Null<String>;
    }
    
    /**
     * Extract startup systems from class fields
     */
    static function extractStartupSystems(fields:Array<Field>):Array<StartupSystemInfo> {
        var systems:Array<StartupSystemInfo> = [];
        
        for (field in fields) {
            for (meta in field.meta) {
                if (meta.name == ":startup") {
                    var startupInfo = extractStartupInfo(field, meta);
                    systems.push(startupInfo);
                }
            }
        }
        
        return systems;
    }
    
    /**
     * Extract startup system info
     */
    static function extractStartupInfo(field:Field, meta:MetadataEntry):StartupSystemInfo {
        var systemType = extractSystemType(field);
        var schedule = "Startup";
        var label:Null<String> = null;
        
        if (meta.params != null) {
            for (param in meta.params) {
                switch param.expr {
                    case EObjectDecl(fields):
                        for (f in fields) {
                            switch f.field {
                                case "schedule":
                                    if (f.expr != null) {
                                        switch f.expr.expr {
                                            case EConst(CIdent(s)):
                                                schedule = s;
                                            default:
                                        }
                                    }
                                case "label":
                                    if (f.expr != null) {
                                        switch f.expr.expr {
                                            case EConst(CString(s)):
                                                label = s;
                                            default:
                                        }
                                    }
                                default:
                            }
                        }
                    default:
                }
            }
        }
        
        return {
            systemType: systemType,
            schedule: schedule,
            label: label
        };
    }
    
    /**
     * Validate module structure
     */
    static function validateModuleStructure(decl:ClassDecl, config:ModuleConfig, plugins:Array<PluginInfo>, systems:Array<SystemInfo>):Void {
        // Check for required register function
        var hasRegister = false;
        for (field in decl.fields) {
            if (field.name == "register" || field.name == "setup") {
                hasRegister = true;
                break;
            }
        }
        
        if (!hasRegister && plugins.length == 0 && systems.length == 0) {
            Context.warning("Module has no register function or system/plugin declarations", Context.currentPos());
        }
        
        // Validate dependencies exist
        for (dep in config.dependencies) {
            // Check that dependency module exists
            try {
                Context.getType(dep);
            } catch (e:Dynamic) {
                Context.warning('Dependency module not found: $dep', Context.currentPos());
            }
        }
    }
    
    /**
     * Generate module descriptor
     */
    static function generateModuleDescriptor(moduleName:String, modulePath:String, config:ModuleConfig):Void {
        var descriptorExpr = macro {
            @:keep static var _moduleDescriptor:haxe.ecs.module.ModuleDescriptor = {
                name: $v{config.name},
                modulePath: $v{modulePath},
                description: ${config.description != null ? macro $v{config.description} : macro null},
                version: $v{config.version},
                isPlugin: $v{config.isPlugin},
                order: $v{config.order},
                dependencies: [
                    $a{config.dependencies.map(d -> macro $v{d})}
                ],
                optional: [
                    $a{config.optional.map(o -> macro $v{o})}
                ]
            };
        };
    }
    
    /**
     * Generate plugin registration code
     */
    static function generatePluginRegistration(moduleName:String, plugins:Array<PluginInfo>):Void {
        for (plugin in plugins) {
            var registrationExpr = macro {
                haxe.ecs.app.AppBuilder.addPlugin($v{plugin.pluginType}, ${
                    plugin.config != null ? macro $v{plugin.config} : macro null
                });
            };
        }
    }
    
    /**
     * Generate system registration code
     */
    static function generateSystemRegistration(moduleName:String, systems:Array<SystemInfo>):Void {
        for (system in systems) {
            var registrationExpr = macro {
                haxe.ecs.app.AppBuilder.addSystem(
                    $v{system.systemType},
                    $v{system.schedule},
                    $v{system.priority}
                );
            };
        }
    }
    
    /**
     * Generate resource registration code
     */
    static function generateResourceRegistration(moduleName:String, resources:Array<ResourceInfo>):Void {
        for (resource in resources) {
            var initExpr:Expr;
            if (resource.initFn != null) {
                initExpr = macro {
                    haxe.ecs.app.AppBuilder.addResourceWithInit(
                        $v{resource.resourceType},
                        function() return ${"resource." + resource.initFn}()
                    );
                };
            } else {
                initExpr = macro {
                    haxe.ecs.app.AppBuilder.addResource(
                        $v{resource.resourceType},
                        $v{resource.initialValue}
                    );
                };
            }
        }
    }
    
    /**
     * Generate startup system registration
     */
    static function generateStartupSystemRegistration(moduleName:String, systems:Array<StartupSystemInfo>):Void {
        for (system in systems) {
            var registrationExpr = macro {
                haxe.ecs.app.AppBuilder.addStartupSystem(
                    $v{system.systemType},
                    $v{system.schedule},
                    ${
                        system.label != null ? macro $v{system.label} : macro null
                    }
                );
            };
        }
    }
    
    /**
     * Add module to registry
     */
    static function addToModuleRegistry(moduleName:String, modulePath:String, config:ModuleConfig):Void {
        var registryExpr = macro {
            haxe.ecs.module.ModuleRegistry.register($v{modulePath}, {
                name: $v{config.name},
                modulePath: $v{modulePath},
                version: $v{config.version},
                isPlugin: $v{config.isPlugin}
            });
        };
    }
    
    /**
     * Generate module entry point
     */
    static function generateModuleEntry(moduleName:String, config:ModuleConfig):Void {
        // Generate a static entry function that can be called to register the module
        var entryExpr = macro {
            static function __registerModule(builder:haxe.ecs.app.AppBuilder):Void {
                // Register dependencies first
                $a{config.dependencies.map(dep -> macro {
                    haxe.ecs.module.ModuleRegistry.get($v{dep})?.register(builder);
                })}
                
                // Register this module's components
                haxe.ecs.reflect.ComponentRegistry.initializeModule($v{moduleName});
                
                // Register this module's systems
                haxe.ecs.SystemRegistry.initializeModule($v{moduleName});
            }
        };
    }
    
    /**
     * Generate plugin implementation
     */
    public static function generatePlugin(className:String, config:ModuleConfig):Array<Field> {
        var pluginFields:Array<Field> = [];
        
        // Generate build method
        pluginFields.push({
            name: "build",
            doc: "Plugin build function called when adding to app",
            meta: [],
            access: [APublic],
            kind: FFun({
                args: [{
                    name: "app",
                    type: macro:haxe.ecs.app.App
                }],
                ret: macro:Void,
                expr: macro {
                    // Override point for custom plugin logic
                }
            }),
            pos: Context.currentPos()
        });
        
        return pluginFields;
    }
}

/**
 * Module initialization context
 */
typedef ModuleContext = {
    var app:haxe.ecs.app.App;
    var world:haxe.ecs.World;
    var resources:haxe.ds.StringMap<Dynamic>;
}
