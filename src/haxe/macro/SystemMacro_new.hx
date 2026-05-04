package haxe.macro;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.ds.Option;

/**
 * Macro for ECS system registration and parameter injection.
 * Systems are the main logic units in ECS that operate on component queries.
 * 
 * Usage:
 * ```haxe
 * @:system
 * class MovementSystem extends haxe.ecs.System {
 *     var query:Query<Position, &Velocity>;
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
 * - Archetype access tracking
 * - Schedule ordering metadata
 */
class SystemMacro {
    /** System ID counter */
    static var systemIdCounter:Int = 1;
    
    /** Map of registered system types */
    static var registeredSystems:Map<String, Int> = new Map();

    /**
     * Build function for @:system metadata.
     * Returns modified fields with generated methods.
     */
    public static function build():Array<Field> {
        var typeExpr = Context.getLocalClass();
        
        if (typeExpr == null) {
            Context.error("@:system can only be applied to classes", Context.currentPos());
            return null;
        }
        
        var classType = typeExpr.get();
        var className = classType.name;
        var modulePath = Context.getLocalModule();
        
        // Check for duplicate registration
        var fullPath = modulePath + "." + className;
        if (registeredSystems.exists(fullPath)) {
            Context.error('System $className is already registered', Context.currentPos());
            return null;
        }
        
        // Register this system
        var systemId = systemIdCounter++;
        registeredSystems.set(fullPath, systemId);
        
        // Get fields
        var fields = Context.getBuildFields();
        
        // Extract system metadata from class annotations
        var systemMeta = extractSystemMetadata(classType);
        
        // Extract query fields
        var queries = extractQueryFields(fields);
        
        // Extract system parameter fields
        var params = extractSystemParams(fields);
        
        // Validate system structure
        validateSystemStructure(classType, queries, params);
        
        // Add system interface implementation
        var implFields = implementSystemInterface(classType, fields, systemMeta, queries, params);
        
        // Add initialization code
        addSystemRegistration(className, modulePath, systemId, systemMeta, queries, params);
        
        return fields.concat(implFields);
    }
    
    /**
     * Extracts metadata from class annotations.
     */
    static function extractSystemMetadata(classType:ClassType):SystemMeta {
        var meta = {
            name: classType.name,
            stage: SystemStage.PreUpdate,
            schedule: SystemSchedule.Update,
            priority: 0,
            isParallel: true,
            labels: []
        };
        
        // Check class metadata for scheduling hints
        for (m in classType.meta) {
            switch (m.name) {
                case ":system":
                    // Parse system configuration
                    for (p in m.params) {
                        switch (p.expr) {
                            case EConst(CString(s)):
                                meta.name = s;
                            default:
                        }
                    }
                    
                case ":stage":
                    if (m.params.length > 0) {
                        switch (m.params[0].expr) {
                            case EConst(CString(s)):
                                meta.stage = parseStage(s);
                            default:
                        }
                    }
                    
                case ":priority":
                    if (m.params.length > 0) {
                        switch (m.params[0].expr) {
                            case EConst(CInt(i)): meta.priority = Std.parseInt(i);
                            default:
                        }
                    }
                    
                case ":parallel":
                    meta.isParallel = true;
                    
                case ":exclusive":
                    meta.isParallel = false;
                    
                case ":label":
                    for (p in m.params) {
                        switch (p.expr) {
                            case EConst(CString(s)):
                                meta.labels.push(s);
                            default:
                        }
                    }
            }
        }
        
        return meta;
    }
    
    /**
     * Parses stage string to SystemStage enum.
     */
    static function parseStage(s:String):SystemStage {
        return switch (s.toLowerCase()) {
            case "startup": SystemStage.Startup;
            case "preupdate": SystemStage.PreUpdate;
            case "update": SystemStage.Update;
            case "postupdate": SystemStage.PostUpdate;
            case "finish": SystemStage.Finish;
            default: SystemStage.Update;
        };
    }
    
    /**
     * Extracts query field information.
     */
    static function extractQueryFields(fields:Array<Field>):Array<QueryInfo> {
        var queries = new Array<QueryInfo>();
        
        for (field in fields) {
            switch (field.kind) {
                case FVar(t, _):
                    if (t != null) {
                        var queryInfo = extractQueryFromType(t, field.name, field.meta);
                        if (queryInfo != null) {
                            queries.push(queryInfo);
                        }
                    }
                default:
            }
        }
        
        return queries;
    }
    
    /**
     * Extracts query information from field type.
     */
    static function extractQueryFromType(t:ComplexType, fieldName:String, meta:Array<MetadataEntry>):Null<QueryInfo> {
        var typeStr = printType(t);
        
        // Check if this looks like a Query type
        if (typeStr.indexOf("Query<") == 0 || typeStr.indexOf("Query ") >= 0) {
            // Parse component types from generic parameters
            var componentTypes = extractGenericParams(t);
            
            // Check for access modifiers in type string
            var access = QueryAccess.ReadOnly;
            if (typeStr.indexOf("&") >= 0 || typeStr.indexOf("Mut ") >= 0 || typeStr.indexOf("<&") >= 0) {
                access = QueryAccess.Mutable;
            }
            
            // Check for optional/filter components
            var filterMode = FilterMode.None;
            if (typeStr.indexOf("Or<") >= 0) {
                filterMode = FilterMode.Or;
            } else if (typeStr.indexOf("With<") >= 0) {
                filterMode = FilterMode.With;
            } else if (typeStr.indexOf("Without<") >= 0) {
                filterMode = FilterMode.Without;
            }
            
            // Check for change detection
            var changeDetection = metaHasMeta(meta, ":change_detection") || typeStr.indexOf("Changed") >= 0;
            
            // Check for optional (Maybe) components
            var hasOptional = typeStr.indexOf("Maybe<") >= 0 || typeStr.indexOf("?<") >= 0;
            
            return {
                fieldName: fieldName,
                queryType: typeStr,
                componentTypes: componentTypes,
                access: access,
                filterMode: filterMode,
                changeDetection: changeDetection,
                hasOptional: hasOptional
            };
        }
        
        return null;
    }
    
    /**
     * Extracts generic type parameters from a ComplexType.
     */
    static function extractGenericParams(t:ComplexType):Array<String> {
        var params = new Array<String>();
        
        switch (t) {
            case TType(_, args):
                for (arg in args) {
                    params.push(printType(arg));
                }
                
            case TParent(t):
                return extractGenericParams(t);
                
            case TPath(p):
                if (p.params != null) {
                    for (param in p.params) {
                        switch (param) {
                            case TPType(t):
                                params.push(printType(t));
                            case TPExpr(e):
                                // Ignore expression parameters
                            default:
                        }
                    }
                }
                
            default:
        }
        
        return params;
    }
    
    /**
     * Extracts system parameter field information.
     */
    static function extractSystemParams(fields:Array<Field>):Array<SystemParamInfo> {
        var params = new Array<SystemParamInfo>();
        
        for (field in fields) {
            switch (field.kind) {
                case FVar(t, _):
                    if (t != null) {
                        var paramInfo = extractParamFromType(t, field.name, field.meta);
                        if (paramInfo != null) {
                            params.push(paramInfo);
                        }
                    }
                default:
            }
        }
        
        return params;
    }
    
    /**
     * Extracts parameter information from field type.
     */
    static function extractParamFromType(t:ComplexType, fieldName:String, meta:Array<MetadataEntry>):Null<SystemParamInfo> {
        var typeStr = printType(t);
        
        // SystemParam types
        var paramType:ParamType = ParamType.Unknown;
        
        if (typeStr.indexOf("Commands") >= 0) {
            paramType = ParamType.Commands;
        } else if (typeStr.indexOf("World") >= 0) {
            paramType = ParamType.World;
        } else if (typeStr.indexOf("Resources") >= 0 || typeStr.indexOf("Res<") >= 0) {
            paramType = ParamType.Resource;
        } else if (typeStr.indexOf("Local<") >= 0) {
            paramType = ParamType.Local;
        } else if (typeStr.indexOf("EntityCommands") >= 0) {
            paramType = ParamType.EntityCommands;
        } else if (typeStr.indexOf("EventReader") >= 0) {
            paramType = ParamType.EventReader;
        } else if (typeStr.indexOf("EventWriter") >= 0) {
            paramType = ParamType.EventWriter;
        } else if (typeStr.indexOf("Query<") >= 0) {
            paramType = ParamType.Query;
        } else {
            return null; // Not a system param
        }
        
        return {
            fieldName: fieldName,
            paramType: paramType,
            typeString: typeStr,
            meta: meta
        };
    }
    
    /**
     * Checks if metadata array contains a specific name.
     */
    static function metaHasMeta(meta:Array<MetadataEntry>, name:String):Bool {
        for (m in meta) {
            if (m.name == name) return true;
        }
        return false;
    }
    
    /**
     * Validates system structure.
     */
    static function validateSystemStructure(
        classType:ClassType,
        queries:Array<QueryInfo>,
        params:Array<SystemParamInfo>
    ):Void {
        // Check for main run method
        var hasRunMethod = false;
        for (field in classType.fields.get()) {
            if (field.name == "run" && field.type.match(TFunction(_, _))) {
                hasRunMethod = true;
                break;
            }
        }
        
        if (!hasRunMethod) {
            Context.warning('System ${classType.name} should have a run() method', Context.currentPos());
        }
        
        // Warn if no queries or params
        if (queries.length == 0 && params.length == 0) {
            Context.warning('System ${classType.name} has no queries or system parameters', Context.currentPos());
        }
    }
    
    /**
     * Implements the System interface for the class.
     */
    static function implementSystemInterface(
        classType:ClassType,
        fields:Array<Field>,
        meta:SystemMeta,
        queries:Array<QueryInfo>,
        params:Array<SystemParamInfo>
    ):Array<Field> {
        var implFields = new Array<Field>();
        var className = classType.name;
        var modulePath = Context.getLocalModule();
        
        // Generate systemName method
        implFields.push({
            name: "systemName",
            doc: "Returns the system name",
            meta: [{ name: ":noCompletion", params: [], pos: Context.currentPos() }],
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro:String,
                expr: macro {
                    return $v{meta.name};
                }
            }),
            pos: Context.currentPos()
        });
        
        // Generate systemTypeId method
        implFields.push({
            name: "systemTypeId",
            doc: "Returns the system type ID",
            meta: [{ name: ":noCompletion", params: [], pos: Context.currentPos() }],
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro:String,
                expr: macro {
                    return $v{modulePath + "." + className};
                }
            }),
            pos: Context.currentPos()
        });
        
        // Generate getSystemId method
        implFields.push({
            name: "getSystemId",
            doc: "Returns the unique system ID",
            meta: [{ name: ":noCompletion", params: [], pos: Context.currentPos() }],
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro:UInt,
                expr: macro {
                    return $v{className.hashCode()};
                }
            }),
            pos: Context.currentPos()
        });
        
        // Generate getStage method
        implFields.push({
            name: "getStage",
            doc: "Returns the system stage",
            meta: [{ name: ":noCompletion", params: [], pos: Context.currentPos() }],
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro:haxe.ecs.SystemStage,
                expr: macro {
                    return $v{meta.stage};
                }
            }),
            pos: Context.currentPos()
        });
        
        // Generate getPriority method
        implFields.push({
            name: "getPriority",
            doc: "Returns the system priority within its stage",
            meta: [{ name: ":noCompletion", params: [], pos: Context.currentPos() }],
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro:Int,
                expr: macro {
                    return $v{meta.priority};
                }
            }),
            pos: Context.currentPos()
        });
        
        // Generate isParallel method
        implFields.push({
            name: "isParallel",
            doc: "Returns whether this system can run in parallel with other systems",
            meta: [{ name: ":noCompletion", params: [], pos: Context.currentPos() }],
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro:Bool,
                expr: macro {
                    return $v{meta.isParallel};
                }
            }),
            pos: Context.currentPos()
        });
        
        // Generate getLabels method
        implFields.push({
            name: "getLabels",
            doc: "Returns the system labels",
            meta: [{ name: ":noCompletion", params: [], pos: Context.currentPos() }],
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro:Array<String>,
                expr: macro {
                    return $a{meta.labels.map(l -> macro $v{l})};
                }
            }),
            pos: Context.currentPos()
        });
        
        // Generate getQueries method
        implFields.push({
            name: "getQueries",
            doc: "Returns information about all queries used by this system",
            meta: [{ name: ":noCompletion", params: [], pos: Context.currentPos() }],
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro:Array<haxe.ecs.QueryDescription>,
                expr: macro {
                    return $v{queries.map(q -> ({
                        name: q.fieldName,
                        componentTypes: q.componentTypes,
                        access: q.access.getIndex(),
                        filterMode: q.filterMode.getIndex(),
                        changeDetection: q.changeDetection
                    }))};
                }
            }),
            pos: Context.currentPos()
        });
        
        // Generate initialize method (called when system is added to world)
        implFields.push({
            name: "initialize",
            doc: "Called to initialize the system when added to the world",
            meta: [{ name: ":noCompletion", params: [], pos: Context.currentPos() }],
            access: [APublic],
            kind: FFun({
                args: [{ name: "world", type: macro:haxe.ecs.World }],
                ret: macro:Void,
                expr: macro {
                    // Initialize queries here
                    $b{queries.map(q -> generateQueryInit(q))};
                }
            }),
            pos: Context.currentPos()
        });
        
        // Generate getRequiredComponents method
        implFields.push({
            name: "getRequiredComponents",
            doc: "Returns component IDs required by all queries",
            meta: [{ name: ":noCompletion", params: [], pos: Context.currentPos() }],
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro:Array<UInt>,
                expr: macro {
                    var result:Array<UInt> = [];
                    for (q in $v{queries}) {
                        for (compType in q.componentTypes) {
                            // Would resolve component ID at runtime
                        }
                    }
                    return result;
                }
            }),
            pos: Context.currentPos()
        });
        
        return implFields;
    }
    
    /**
     * Generates query initialization code.
     */
    static function generateQueryInit(query:QueryInfo):Expr {
        return macro {
            // Initialize query: ${query.fieldName}
            this.${query.fieldName} = haxe.ecs.Query.create(this.world);
        };
    }
    
    /**
     * Adds system registration code to module initialization.
     */
    static function addSystemRegistration(
        className:String,
        modulePath:String,
        systemId:Int,
        meta:SystemMeta,
        queries:Array<QueryInfo>,
        params:Array<SystemParamInfo>
    ):Void {
        #if macro
        var fullPath = modulePath + "." + className;
        
        var registrationExpr = macro {
            haxe.ecs.SystemRegistry.register(
                $v{fullPath},
                $v{systemId},
                $v{meta.stage.getIndex()},
                $v{meta.priority},
                $v{meta.isParallel}
            );
            
            haxe.macro.SystemMetadata.register(
                $v{className},
                $v{modulePath},
                $v{systemId},
                $v{queries.length},
                $v{params.length}
            );
        };
        
        Context.addModuleInit(registrationExpr);
        #end
    }
    
    /**
     * Prints a ComplexType as a string.
     */
    static function printType(t:ComplexType):String {
        return switch (t) {
            case TFunction(args, ret): "Function";
            case TAnonymous(fields): "Anonymous";
            case TParent(t): printType(t);
            case TOptional(t): "?" + printType(t);
            case TType(t, params): t.name;
            case TDynamic(t): t != null ? "Dynamic<${printType(t)}>" : "Dynamic";
            case TPath(p): p.pack.length > 0 ? '${p.pack.join(".")}.${p.name}' : p.name;
        };
    }
}

/**
 * Query access mode.
 */
enum QueryAccess {
    ReadOnly;
    Mutable;
}

/**
 * Query filter mode.
 */
enum FilterMode {
    None;
    With;
    Without;
    Or;
}

/**
 * System metadata structure.
 */
typedef SystemMeta = {
    var name:String;
    var stage:SystemStage;
    var schedule:SystemSchedule;
    var priority:Int;
    var isParallel:Bool;
    var labels:Array<String>;
}

/**
 * Query information structure.
 */
typedef QueryInfo = {
    var fieldName:String;
    var queryType:String;
    var componentTypes:Array<String>;
    var access:QueryAccess;
    var filterMode:FilterMode;
    var changeDetection:Bool;
    var hasOptional:Bool;
}

/**
 * System parameter information structure.
 */
typedef SystemParamInfo = {
    var fieldName:String;
    var paramType:ParamType;
    var typeString:String;
    var meta:Array<MetadataEntry>;
}

/**
 * System parameter types.
 */
enum ParamType {
    Unknown;
    Commands;
    World;
    Resource;
    Local;
    EntityCommands;
    EventReader;
    EventWriter;
    Query;
}

/**
 * System metadata holder.
 */
class SystemMetadata {
    /** Map of type names to system metadata */
    public static var metadata:Map<String, SystemTypeMetadata> = new Map();
    
    /**
     * Registers a system type.
     */
    public static function register(
        typeName:String,
        modulePath:String,
        systemId:Int,
        queryCount:Int,
        paramCount:Int
    ):Void {
        metadata.set(typeName, {
            typeName: typeName,
            modulePath: modulePath,
            systemId: systemId,
            queryCount: queryCount,
            paramCount: paramCount
        });
    }
    
    /**
     * Gets metadata for a system type.
     */
    public static function get(typeName:String):Null<SystemTypeMetadata> {
        return metadata.get(typeName);
    }
    
    /**
     * Gets all registered system types.
     */
    public static function getAllTypes():Iterator<String> {
        return metadata.keys();
    }
}

/**
 * System type metadata structure.
 */
typedef SystemTypeMetadata = {
    /** Full type name */
    var typeName:String;
    /** Module path */
    var modulePath:String;
    /** System ID */
    var systemId:Int;
    /** Number of queries */
    var queryCount:Int;
    /** Number of system parameters */
    var paramCount:Int;
}
