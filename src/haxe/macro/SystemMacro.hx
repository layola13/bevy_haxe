package haxe.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

/**
 * Macro for ECS system registration and parameter injection.
 * Systems are the main logic units in ECS that operate on component queries.
 * 
 * Usage:
 * ```haxe
 * @:system
 * class MovementSystem extends haxe.ecs.System {
 *     var query:Query<Position, Velocity>;
 *     
 *     function run() {
 *         for (entity in query) {
 *             entity.position.x += entity.velocity.dx;
 *             entity.position.y += entity.velocity.dy;
 *         }
 *     }
 * }
 * ```
 * 
 * Generates:
 * - System registration with scheduling
 * - Query construction and management
 * - SystemParam injection
 * - archetype access tracking
 * - Schedule ordering metadata
 */
class SystemMacro {
    /**
     * Build function for @:system metadata
     */
    public static function build():Void {
        var type = Context.getTypeExpr(Context.getLocalClass().get());
        
        switch type.expr {
            case EClass(decl):
                processSystemClass(decl);
            default:
                Context.error("@:system can only be applied to classes", Context.currentPos());
        }
    }
    
    /**
     * Process system class and generate registration code
     */
    static function processSystemClass(decl:ClassDecl):Void {
        var className = decl.name;
        var modulePath = Context.getLocalModule();
        
        // Extract system metadata
        var systemMeta = extractSystemMeta(decl.meta);
        var queries = extractQueryFields(decl.fields);
        var params = extractSystemParams(decl.fields);
        
        // Validate system structure
        validateSystemStructure(decl, queries, params);
        
        // Generate system registration
        generateSystemRegistration(className, modulePath, systemMeta, queries, params);
        
        // Generate query initialization
        generateQueryInitialization(className, queries);
        
        // Generate param injection
        generateParamInjection(className, params);
        
        // Generate archetype tracking
        generateArchetypeTracking(className, queries);
        
        // Generate schedule ordering
        generateScheduleOrdering(className, systemMeta);
        
        // Add to system registry
        addToSystemRegistry(className, modulePath, systemMeta, queries);
    }
    
    /**
     * System metadata extracted from class
     */
    typedef SystemMeta = {
        var name:String;
        var schedule:ScheduleType;
        var stage:String;
        var before:Array<String>;
        var after:Array<String>;
        var runCondition:Null<String>;
        var priority:Int;
        var isParallel:Bool;
        var isExclusive:Bool;
    }
    
    /**
     * Schedule types for systems
     */
    enum ScheduleType {
        PreUpdate;
        Update;
        PostUpdate;
        Startup;
        Simulation;
        Render;
    }
    
    /**
     * Extract system metadata from class
     */
    static function extractSystemMeta(meta:Array<MetadataEntry>):SystemMeta {
        var systemMeta:SystemMeta = {
            name: null,
            schedule: Update,
            stage: "default",
            before: [],
            after: [],
            runCondition: null,
            priority: 0,
            isParallel: true,
            isExclusive: false
        };
        
        for (entry in meta) {
            switch entry.name {
                case ":system":
                    processSystemMeta(entry, systemMeta);
                case ":name":
                    if (entry.params != null && entry.params.length > 0) {
                        switch entry.params[0].expr {
                            case EConst(CString(s)):
                                systemMeta.name = s;
                            default:
                        }
                    }
            }
        }
        
        return systemMeta;
    }
    
    /**
     * Process @:system metadata parameters
     */
    static function processSystemMeta(entry:MetadataEntry, meta:SystemMeta):Void {
        if (entry.params == null) return;
        
        for (param in entry.params) {
            switch param.expr {
                case EObjectDecl(fields):
                    for (field in fields) {
                        switch field.field {
                            case "schedule":
                                if (field.expr != null) {
                                    meta.schedule = parseScheduleType(field.expr);
                                }
                            case "stage":
                                if (field.expr != null) {
                                    switch field.expr.expr {
                                        case EConst(CString(s)):
                                            meta.stage = s;
                                        default:
                                    }
                                }
                            case "before":
                                meta.before = extractStringArray(field.expr);
                            case "after":
                                meta.after = extractStringArray(field.expr);
                            case "condition":
                                if (field.expr != null) {
                                    switch field.expr.expr {
                                        case EConst(CString(s)):
                                            meta.runCondition = s;
                                        default:
                                    }
                                }
                            case "priority":
                                if (field.expr != null) {
                                    switch field.expr.expr {
                                        case EConst(CInt(i)):
                                            meta.priority = Std.parseInt(i);
                                        default:
                                    }
                                }
                            case "parallel":
                                if (field.expr != null) {
                                    switch field.expr.expr {
                                        case EConst(CIdent("false")):
                                            meta.isParallel = false;
                                        default:
                                            meta.isParallel = true;
                                    }
                                }
                            case "exclusive":
                                if (field.expr != null) {
                                    switch field.expr.expr {
                                        case EConst(CIdent("true")):
                                            meta.isExclusive = true;
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
     * Parse schedule type from expression
     */
    static function parseScheduleType(expr:Expr):ScheduleType {
        switch expr.expr {
            case EConst(CIdent("PreUpdate")):
                return PreUpdate;
            case EConst(CIdent("PostUpdate")):
                return PostUpdate;
            case EConst(CIdent("Startup")):
                return Startup;
            case EConst(CIdent("Simulation")):
                return Simulation;
            case EConst(CIdent("Render")):
                return Render;
            default:
                return Update;
        }
    }
    
    /**
     * Extract string array from expression
     */
    static function extractStringArray(expr:Expr):Array<String> {
        var result:Array<String> = [];
        switch expr.expr {
            case EArrayDecl(exprs):
                for (e in exprs) {
                    switch e.expr {
                        case EConst(CString(s)):
                            result.push(s);
                        default:
                    }
                }
            default:
        }
        return result;
    }
    
    /**
     * Extract query fields from system
     */
    static function extractQueryFields(fields:Array<Field>):Array<QueryInfo> {
        var queries:Array<QueryInfo> = [];
        
        for (field in fields) {
            var queryMeta = getQueryMeta(field);
            if (queryMeta != null) {
                var typeInfo = extractQueryType(field.type);
                if (typeInfo != null) {
                    queries.push({
                        fieldName: field.name,
                        queryType: typeInfo,
                        meta: queryMeta,
                        isMutable: isFieldMutable(field),
                        changeFilter: getChangeFilter(field)
                    });
                }
            }
        }
        
        return queries;
    }
    
    /**
     * Get query metadata from field
     */
    static function getQueryMeta(field:Field):Null<QueryMeta> {
        var meta:QueryMeta = null;
        
        for (entry in field.meta) {
            if (entry.name == ":query" || entry.name == ":queryRead" || entry.name == ":queryWrite") {
                meta = {
                    access: parseQueryAccess(entry),
                    filterMode: FilterMode.None,
                    changeDetection: false
                };
                
                // Process additional query options
                if (entry.params != null) {
                    for (param in entry.params) {
                        switch param.expr {
                            case EObjectDecl(fields):
                                for (f in fields) {
                                    switch f.field {
                                        case "filter":
                                            meta.filterMode = parseFilterMode(f.expr);
                                        case "changed":
                                            if (f.expr != null) {
                                                switch f.expr.expr {
                                                    case EConst(CIdent("true")):
                                                        meta.changeDetection = true;
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
            }
        }
        
        return meta;
    }
    
    /**
     * Query access types
     */
    enum QueryAccess {
        Read;
        Write;
        ReadWrite;
    }
    
    /**
     * Filter mode for queries
     */
    enum FilterMode {
        None;
        With;
        Without;
    }
    
    /**
     * Parse query access type
     */
    static function parseQueryAccess(entry:MetadataEntry):QueryAccess {
        switch entry.name {
            case ":queryRead":
                return Read;
            case ":queryWrite":
                return Write;
            default:
                return ReadWrite;
        }
    }
    
    /**
     * Parse filter mode
     */
    static function parseFilterMode(expr:Expr):FilterMode {
        switch expr.expr {
            case EConst(CIdent("With")):
                return With;
            case EConst(CIdent("Without")):
                return Without;
            default:
                return None;
        }
    }
    
    /**
     * Extract query type from field type
     */
    static function extractQueryType(type:ComplexType):QueryTypeInfo {
        switch type {
            case TPath(p):
                // Expecting Query<T1, T2, ...>
                if (p.name == "Query" && p.params != null && p.params.length > 0) {
                    var componentTypes:Array<String> = [];
                    for (param in p.params) {
                        switch param {
                            case TPType(t):
                                componentTypes.push(typeToString(t));
                            default:
                        }
                    }
                    return {componentTypes: componentTypes};
                }
            default:
        }
        return null;
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
     * Check if field is mutable
     */
    static function isFieldMutable(field:Field):Bool {
        switch field.kind {
            case FVar(_, e):
                return e != null;
            case FProp("default", _, _, _):
                return true;
            case FProp(_, _, _, _):
                return true;
            default:
                return false;
        }
    }
    
    /**
     * Get change filter for query
     */
    static function getChangeFilter(field:Field):Null<String> {
        for (entry in field.meta) {
            if (entry.name == ":changed") {
                if (entry.params != null && entry.params.length > 0) {
                    switch entry.params[0].expr {
                        case EConst(CString(s)):
                            return s;
                        case EConst(CIdent(i)):
                            return i;
                        default:
                    }
                }
            }
        }
        return null;
    }
    
    /**
     * Query metadata
     */
    typedef QueryMeta = {
        var access:QueryAccess;
        var filterMode:FilterMode;
        var changeDetection:Bool;
    }
    
    /**
     * Query type information
     */
    typedef QueryTypeInfo = {
        var componentTypes:Array<String>;
    }
    
    /**
     * Query field information
     */
    typedef QueryInfo = {
        var fieldName:String;
        var queryType:QueryTypeInfo;
        var meta:QueryMeta;
        var isMutable:Bool;
        var changeFilter:Null<String>;
    }
    
    /**
     * Extract system parameters
     */
    static function extractSystemParams(fields:Array<Field>):Array<ParamInfo> {
        var params:Array<ParamInfo> = [];
        
        for (field in fields) {
            var paramMeta = getParamMeta(field);
            if (paramMeta != null) {
                params.push({
                    fieldName: field.name,
                    paramType: extractParamType(field),
                    meta: paramMeta
                });
            }
        }
        
        return params;
    }
    
    /**
     * Get parameter metadata from field
     */
    static function getParamMeta(field:Field):Null<ParamMeta> {
        for (entry in field.meta) {
            if (entry.name == ":param" || entry.name == ":resource" || entry.name == ":commands" || entry.name == ":world") {
                return {
                    paramKind: entry.name,
                    mutable: isFieldMutable(field)
                };
            }
        }
        return null;
    }
    
    /**
     * Parameter metadata
     */
    typedef ParamMeta = {
        var paramKind:String;
        var mutable:Bool;
    }
    
    /**
     * Parameter info
     */
    typedef ParamInfo = {
        var fieldName:String;
        var paramType:String;
        var meta:ParamMeta;
    }
    
    /**
     * Extract parameter type from field
     */
    static function extractParamType(field:Field):String {
        switch field.kind {
            case FVar(t, _):
                return typeToString(t);
            case FProp(_, _, t, _):
                return typeToString(t);
            default:
                return "Dynamic";
        }
    }
    
    /**
     * Validate system structure
     */
    static function validateSystemStructure(decl:ClassDecl, queries:Array<QueryInfo>, params:Array<ParamInfo>):Void {
        // Check for run method
        var hasRunMethod = false;
        for (field in decl.fields) {
            if (field.name == "run" || field.name == "update") {
                hasRunMethod = true;
                break;
            }
        }
        
        // Systems can have no run method if they only use commands
        if (!hasRunMethod && queries.length == 0 && params.length == 0) {
            Context.warning("System has no queries or parameters", Context.currentPos());
        }
        
        // Validate query access conflicts
        var writeQueries = queries.filter(q -> q.meta.access == Write || q.meta.access == ReadWrite);
        if (writeQueries.length > 1) {
            Context.warning("Multiple write queries may cause conflicts", Context.currentPos());
        }
    }
    
    /**
     * Generate system registration code
     */
    static function generateSystemRegistration(className:String, modulePath:String, meta:SystemMeta, queries:Array<QueryInfo>, params:Array<ParamInfo>):Void {
        var registrationExpr = macro {
            haxe.ecs.SystemRegistry.register($v{className}, {
                name: $v{meta.name != null ? meta.name : className},
                modulePath: $v{modulePath},
                schedule: $v{Std.string(meta.schedule)},
                stage: $v{meta.stage},
                before: $a{meta.before.map(s -> macro $v{s})},
                after: $a{meta.after.map(s -> macro $v{s})},
                condition: ${meta.runCondition != null ? macro $v{meta.runCondition} : macro null},
                priority: $v{meta.priority},
                isParallel: $v{meta.isParallel},
                isExclusive: $v{meta.isExclusive}
            });
        };
    }
    
    /**
     * Generate query initialization
     */
    static function generateQueryInitialization(className:String, queries:Array<QueryInfo>):Void {
        for (query in queries) {
            var initExpr = macro {
                // Query initialization for ${query.fieldName}
                var queryDescriptor = haxe.ecs.query.QueryDescriptor.create(
                    $v{className},
                    $v{query.fieldName},
                    [
                        $a{query.queryType.componentTypes.map(t -> macro $v{t})}
                    ],
                    {
                        access: $v{Std.string(query.meta.access)},
                        filterMode: $v{Std.string(query.meta.filterMode)},
                        changeDetection: $v{query.meta.changeDetection}
                    }
                );
            };
        }
    }
    
    /**
     * Generate parameter injection
     */
    static function generateParamInjection(className:String, params:Array<ParamInfo>):Void {
        for (param in params) {
            var injectionExpr = macro {
                haxe.ecs.SystemParamInjector.register(
                    $v{className},
                    $v{param.fieldName},
                    {
                        paramType: $v{param.paramType},
                        paramKind: $v{param.meta.paramKind},
                        mutable: $v{param.meta.mutable}
                    }
                );
            };
        }
    }
    
    /**
     * Generate archetype tracking
     */
    static function generateArchetypeTracking(className:String, queries:Array<QueryInfo>):Void {
        for (query in queries) {
            var archetypeExpr = macro {
                // Track archetype requirements for query
                $a{query.queryType.componentTypes.map(type -> macro {
                    haxe.ecs.archetype.ArchetypeTracker.addRequirement($v{className}, $v{type});
                })}
            };
        }
    }
    
    /**
     * Generate schedule ordering
     */
    static function generateScheduleOrdering(className:String, meta:SystemMeta):Void {
        // Generate ordering constraints
        for (beforeSystem in meta.before) {
            var orderExpr = macro {
                haxe.ecs.schedule.ScheduleBuilder.orderBefore($v{className}, $v{beforeSystem});
            };
        }
        
        for (afterSystem in meta.after) {
            var orderExpr = macro {
                haxe.ecs.schedule.ScheduleBuilder.orderAfter($v{className}, $v{afterSystem});
            };
        }
        
        // Add to schedule
        var scheduleExpr = macro {
            haxe.ecs.schedule.Scheduler.addSystem($v{className}, $v{Std.string(meta.schedule)}, $v{meta.priority});
        };
    }
    
    /**
     * Add to system registry
     */
    static function addToSystemRegistry(className:String, modulePath:String, meta:SystemMeta, queries:Array<QueryInfo>):Void {
        var registryExpr = macro {
            haxe.ecs.SystemRegistry.addSystem(
                $v{className},
                {
                    className: $v{className},
                    modulePath: $v{modulePath},
                    queryCount: $v{queries.length},
                    paramCount: 0,
                    archetypeRequirements: [
                        $a{queries.flatMap(q -> q.queryType.componentTypes.map(t -> macro $v{t}))}
                    ]
                }
            );
        };
    }
    
    /**
     * Generate system instance creation
     */
    public static function generateSystemInstance(className:String, queries:Array<QueryInfo>, params:Array<ParamInfo>):Expr {
        var createExprs:Array<Expr> = [];
        
        createExprs.push(macro {
            var system = new $className();
        });
        
        // Initialize queries
        for (query in queries) {
            createExprs.push(macro {
                system.${query.fieldName} = haxe.ecs.query.QueryBuilder.create(
                    $a{query.queryType.componentTypes.map(t -> macro haxe.ecs.reflect.ComponentRegistry.getId($v{t}))}
                );
            });
        }
        
        createExprs.push(macro {
            return system;
        });
        
        return macro $b{createExprs};
    }
}

/**
 * Query metadata
 */
typedef QueryMeta = {
    var access:QueryAccess;
    var filterMode:FilterMode;
    var changeDetection:Bool;
}
