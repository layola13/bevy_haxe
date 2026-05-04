package haxe.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

/**
 * Macro for generating optimized query types.
 * Queries provide filtered access to component data in systems.
 * 
 * Usage:
 * ```haxe
 * @:query
 * var positions:Query<Position>;
 * 
 * @:queryWrite
 * var velocities:Query<Velocity, &mut Position>; // With mutable access
 * 
 * @:query(With(Transform), Without(Camera))
 * var worldPositions:Query<GlobalTransform>;
 * ```
 * 
 * Generates:
 * - Query descriptor
 * - archetype matcher
 * - Change detection setup
 * - Iterator implementation hints
 * - Query state management
 */
class QueryMacro {
    /**
     * Build function for @:query metadata on type definitions
     */
    public static function buildType():Void {
        var type = Context.getLocalType();
        var typeExpr = Context.getTypeExpr(Context.getLocalClass().get());
        
        switch typeExpr.expr {
            case EClass(decl):
                processQueryType(decl);
            default:
                Context.error("@:query on type requires a valid query definition", Context.currentPos());
        }
    }
    
    /**
     * Process query type definition
     */
    static function processQueryType(decl:ClassDecl):Void {
        var className = decl.name;
        
        // Extract generic parameters (component types)
        var componentTypes = extractGenericParams(decl);
        
        if (componentTypes.length == 0) {
            Context.error("Query must have at least one component type", Context.currentPos());
        }
        
        // Generate query descriptor class
        generateQueryDescriptor(className, componentTypes);
        
        // Generate query item type
        generateQueryItem(className, componentTypes);
        
        // Generate query state type
        generateQueryState(className, componentTypes);
        
        // Register with query system
        registerQueryType(className, componentTypes);
    }
    
    /**
     * Extract generic parameters from class
     */
    static function extractGenericParams(decl:ClassDecl):Array<String> {
        var types:Array<String> = [];
        
        // Look for Query<...> pattern
        // In Haxe, this would be processed from the type parameters
        for (ext in decl.extend) {
            switch ext {
                case TType(t, params):
                    var typePath = getTypePath(t);
                    if (typePath.name == "Query" && params != null) {
                        for (p in params) {
                            switch p {
                                case TPType(t):
                                    types.push(typeToString(t));
                                default:
                            }
                        }
                    }
                default:
            }
        }
        
        return types;
    }
    
    /**
     * Get type path from type
     */
    static function getTypePath(t:Type):TypePath {
        switch t {
            case TPath(p):
                return p;
            default:
                return {pack: [], name: "", params: []};
        }
    }
    
    /**
     * Convert type to string
     */
    static function typeToString(type:Type):String {
        switch type {
            case TPath(p):
                return (p.pack.length > 0 ? p.pack.join(".") + "." : "") + p.name;
            case TInst(c, _):
                return c.get().name;
            default:
                return "Unknown";
        }
    }
    
    /**
     * Query descriptor for runtime
     */
    typedef QueryDescriptor = {
        var componentIds:Array<Int>;
        var accessMode:QueryAccessMode;
        var filterMode:QueryFilterMode;
        var archetypeMask:Int;
        var isSorted:Bool;
        var changeFilter:Null<Int>;
    }
    
    /**
     * Query access mode
     */
    enum QueryAccessMode {
        ReadOnly;
        WriteOnly;
        ReadWrite;
    }
    
    /**
     * Query filter mode
     */
    enum QueryFilterMode {
        None;
        With;
        Without;
    }
    
    /**
     * Generate query descriptor class
     */
    static function generateQueryDescriptor(className:String, componentTypes:Array<String>):Void {
        var descriptorFields:Array<Field> = [
            {
                name: "componentIds",
                doc: "Component IDs for this query",
                meta: [],
                access: [APublic],
                kind: FVar(macro:Array<Int>, macro []),
                pos: Context.currentPos()
            },
            {
                name: "accessMode",
                doc: "Access mode for this query",
                meta: [],
                access: [APublic],
                kind: FVar(macro:haxe.ecs.query.QueryAccessMode, macro ReadOnly),
                pos: Context.currentPos()
            },
            {
                name: "filterMode",
                doc: "Filter mode for this query",
                meta: [],
                access: [APublic],
                kind: FVar(macro:haxe.ecs.query.QueryFilterMode, macro None),
                pos: Context.currentPos()
            },
            {
                name: "archetypeMask",
                doc: "Archetype bitmask for matching",
                meta: [],
                access: [APublic],
                kind: FVar(macro:Int, macro 0),
                pos: Context.currentPos()
            }
        ];
    }
    
    /**
     * Generate query item type
     * Query items are returned when iterating over query results
     */
    static function generateQueryItem(className:String, componentTypes:Array<String>):Void {
        // Generate item type that references each component
        var itemFields:Array<Field> = [];
        
        for (i in 0...componentTypes.length) {
            var fieldName = 'component${i}';
            itemFields.push({
                name: fieldName,
                doc: 'Component $i',
                meta: [],
                access: [APublic],
                kind: FVar(macro:Dynamic, null), // Type will be resolved at compile time
                pos: Context.currentPos()
            });
        }
        
        // Generate entity reference
        itemFields.push({
            name: "entity",
            doc: "Entity ID for this item",
            meta: [],
            access: [APublic],
            kind: FVar(macro:haxe.ecs.Entity, null),
            pos: Context.currentPos()
        });
    }
    
    /**
     * Generate query state type
     * State tracks runtime query information like matched archetypes
     */
    static function generateQueryState(className:String, componentTypes:Array<String>):Void {
        var stateFields:Array<Field> = [
            {
                name: "descriptor",
                doc: "Query descriptor",
                meta: [],
                access: [APublic],
                kind: FVar(macro:haxe.ecs.query.QueryDescriptor, null),
                pos: Context.currentPos()
            },
            {
                name: "matchedArchetypes",
                doc: "Archetypes matched by this query",
                meta: [],
                access: [APublic],
                kind: FVar(macro:Array<haxe.ecs.archetype.ArchetypeId>, macro []),
                pos: Context.currentPos()
            },
            {
                name: "matchedEntities",
                doc: "Entities matched by this query",
                meta: [],
                access: [APublic],
                kind: FVar(macro:haxe.ds.Vector<haxe.ecs.Entity>, macro null),
                pos: Context.currentPos()
            },
            {
                name: "lastUpdateTick",
                doc: "Last update tick for change detection",
                meta: [],
                access: [APublic],
                kind: FVar(macro:Int, macro 0),
                pos: Context.currentPos()
            }
        ];
    }
    
    /**
     * Register query type with query system
     */
    static function registerQueryType(className:String, componentTypes:Array<String>):Void {
        var registerExpr = macro {
            haxe.ecs.query.QueryRegistry.register($v{className}, {
                componentTypes: [
                    $a{componentTypes.map(t -> macro $v{t})}
                ],
                componentCount: $v{componentTypes.length}
            });
        };
    }
    
    /**
     * Process field-level @:query metadata
     * This is called from SystemMacro when processing system fields
     */
    public static function processQueryField(field:Field, fieldType:ComplexType):QueryFieldInfo {
        var meta = extractQueryMeta(field);
        var componentTypes = extractComponentTypes(fieldType);
        var filters = extractFilters(field);
        
        return {
            fieldName: field.name,
            componentTypes: componentTypes,
            accessMode: meta.access,
            filters: filters,
            changeDetection: meta.changeDetection,
            changeFilter: meta.changeFilter,
            sorting: meta.sorting
        };
    }
    
    /**
     * Query field information
     */
    typedef QueryFieldInfo = {
        var fieldName:String;
        var componentTypes:Array<String>;
        var accessMode:QueryAccessMode;
        var filters:Array<QueryFilter>;
        var changeDetection:Bool;
        var changeFilter:Null<String>;
        var sorting:Null<SortingInfo>;
    }
    
    /**
     * Query filter information
     */
    typedef QueryFilter = {
        var filterType:FilterType;
        var componentType:String;
    }
    
    /**
     * Filter types
     */
    enum FilterType {
        With;
        Without;
    }
    
    /**
     * Sorting information
     */
    typedef SortingInfo = {
        var fieldName:String;
        var ascending:Bool;
    }
    
    /**
     * Extract query metadata from field
     */
    static function extractQueryMeta(field:Field):QueryFieldMeta {
        var result:QueryFieldMeta = {
            access: QueryAccessMode.ReadOnly,
            changeDetection: false,
            changeFilter: null,
            sorting: null
        };
        
        for (entry in field.meta) {
            switch entry.name {
                case ":query":
                    processQueryMeta(entry, result);
                case ":queryRead":
                    result.access = QueryAccessMode.ReadOnly;
                case ":queryWrite":
                    result.access = QueryAccessMode.ReadWrite;
                case ":queryMut":
                    result.access = QueryAccessMode.WriteOnly;
                case ":changed":
                    result.changeDetection = true;
                    if (entry.params != null && entry.params.length > 0) {
                        switch entry.params[0].expr {
                            case EConst(CString(s)):
                                result.changeFilter = s;
                            default:
                        }
                    }
            }
        }
        
        return result;
    }
    
    /**
     * Query field metadata
     */
    typedef QueryFieldMeta = {
        var access:QueryAccessMode;
        var changeDetection:Bool;
        var changeFilter:Null<String>;
        var sorting:Null<SortingInfo>;
    }
    
    /**
     * Process @:query metadata parameters
     */
    static function processQueryMeta(entry:MetadataEntry, meta:QueryFieldMeta):Void {
        if (entry.params == null) return;
        
        for (param in entry.params) {
            switch param.expr {
                case EObjectDecl(fields):
                    for (field in fields) {
                        switch field.field {
                            case "changed":
                                meta.changeDetection = true;
                            case "sortedBy":
                                if (field.expr != null) {
                                    meta.sorting = parseSortingInfo(field.expr);
                                }
                            default:
                        }
                    }
                default:
            }
        }
    }
    
    /**
     * Parse sorting info from expression
     */
    static function parseSortingInfo(expr:Expr):SortingInfo {
        var ascending = true;
        var fieldName = "";
        
        switch expr.expr {
            case EConst(CIdent(name)):
                fieldName = name;
            case ECall(f, args):
                switch f.expr {
                    case EConst(CIdent(name)):
                        fieldName = name;
                    default:
                }
                if (args.length > 0) {
                    switch args[0].expr {
                        case EConst(CIdent("Ascending")):
                            ascending = true;
                        case EConst(CIdent("Descending")):
                            ascending = false;
                        default:
                    }
                }
            default:
        }
        
        return {fieldName: fieldName, ascending: ascending};
    }
    
    /**
     * Extract component types from field type
     */
    static function extractComponentTypes(type:ComplexType):Array<String> {
        var types:Array<String> = [];
        
        switch type {
            case TPath(p):
                if (p.name == "Query" && p.params != null) {
                    for (param in p.params) {
                        switch param {
                            case TPType(t):
                                types.push(extractTypeString(t));
                            default:
                        }
                    }
                } else {
                    // Single component type
                    types.push((p.pack.length > 0 ? p.pack.join(".") + "." : "") + p.name);
                }
            case TParent(t):
                types = extractComponentTypes(t);
            default:
        }
        
        return types;
    }
    
    /**
     * Extract type string from type
     */
    static function extractTypeString(type:TypeParam):String {
        switch type {
            case TPType(t):
                switch t {
                    case TPath(p):
                        return (p.pack.length > 0 ? p.pack.join(".") + "." : "") + p.name;
                    default:
                        return "Unknown";
                }
            default:
                return "Unknown";
        }
    }
    
    /**
     * Extract filters from field metadata
     */
    static function extractFilters(field:Field):Array<QueryFilter> {
        var filters:Array<QueryFilter> = [];
        
        for (entry in field.meta) {
            switch entry.name {
                case ":with":
                    if (entry.params != null && entry.params.length > 0) {
                        switch entry.params[0].expr {
                            case EConst(CIdent(name)):
                                filters.push({filterType: With, componentType: name});
                            default:
                        }
                    }
                case ":without":
                    if (entry.params != null && entry.params.length > 0) {
                        switch entry.params[0].expr {
                            case EConst(CIdent(name)):
                                filters.push({filterType: Without, componentType: name});
                            default:
                        }
                    }
            }
        }
        
        return filters;
    }
    
    /**
     * Generate query initialization code
     */
    public static function generateQueryInit(fieldName:String, componentTypes:Array<String>, meta:QueryFieldMeta):Expr {
        var initExprs:Array<Expr> = [];
        
        // Create query builder
        initExprs.push(macro {
            var builder = haxe.ecs.query.QueryBuilder.create();
        });
        
        // Add component types
        for (type in componentTypes) {
            initExprs.push(macro {
                builder.addComponent(haxe.ecs.reflect.ComponentRegistry.getId($v{type}));
            });
        }
        
        // Set access mode
        var modeExpr = switch meta.access {
            case ReadOnly:
                macro builder.setReadOnly();
            case WriteOnly:
                macro builder.setWriteOnly();
            case ReadWrite:
                macro builder.setReadWrite();
        };
        initExprs.push(modeExpr);
        
        // Add filters
        for (filter in meta.filters) {
            var filterExpr = macro {
                builder.addFilter($v{Std.string(filter.filterType)}, $v{filter.componentType});
            };
            initExprs.push(filterExpr);
        }
        
        // Set change detection
        if (meta.changeDetection) {
            initExprs.push(macro {
                builder.enableChangeDetection();
            });
        }
        
        // Add sorting
        if (meta.sorting != null) {
            initExprs.push(macro {
                builder.sortBy($v{meta.sorting.fieldName}, $v{meta.sorting.ascending});
            });
        }
        
        initExprs.push(macro {
            return builder.build();
        });
        
        return macro $b{initExprs};
    }
    
    /**
     * Generate archetype mask for query
     */
    public static function generateArchetypeMask(componentTypes:Array<String>, filters:Array<QueryFilter>):Int {
        var mask = 0;
        
        // Add component bits
        for (type in componentTypes) {
            var bit = hashComponent(type) % 64;
            mask |= (1 << bit);
        }
        
        // Add filter bits
        for (filter in filters) {
            var bit = hashComponent(filter.componentType) % 64;
            if (filter.filterType == With) {
                mask |= (1 << bit);
            } else {
                mask |= (1 << (bit + 32)); // Separate bits for without
            }
        }
        
        return mask;
    }
    
    /**
     * Hash component type for mask generation
     */
    static function hashComponent(type:String):Int {
        var h = 0;
        for (i in 0...type.length) {
            h = (h * 31 + type.charCodeAt(i)) | 0;
        }
        return h;
    }
}

/**
 * Query filter type
 */
enum FilterType {
    With;
    Without;
}
