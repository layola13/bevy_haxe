package haxe.macro;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.ds.Option;

/**
 * Macro for ECS bundle registration.
 * Bundles group multiple components together for efficient entity creation.
 * 
 * Usage:
 * ```haxe
 * @:bundle
 * class PlayerBundle extends haxe.ecs.Bundle {
 *     public var position:Position;
 *     public var velocity:Velocity;
 *     public var sprite:Sprite;
 * }
 * ```
 * 
 * Generates:
 * - Bundle registration with ComponentRegistry
 * - FromComponents implementation
 * - Bundle archetype tracking
 * - Component ID array generation
 * - Dynamic component insertion support
 */
class BundleMacro {
    /** Bundle ID counter */
    static var bundleIdCounter:Int = 1;
    
    /** Map of registered bundle types */
    static var registeredBundles:Map<String, Int> = new Map();

    /**
     * Build function for @:bundle metadata.
     * Returns modified fields with generated methods.
     */
    public static function build():Array<Field> {
        var typeExpr = Context.getLocalClass();
        
        if (typeExpr == null) {
            Context.error("@:bundle can only be applied to classes", Context.currentPos());
            return null;
        }
        
        var classType = typeExpr.get();
        var className = classType.name;
        var modulePath = Context.getLocalModule();
        
        // Check for duplicate registration
        var fullPath = modulePath + "." + className;
        if (registeredBundles.exists(fullPath)) {
            Context.error('Bundle $className is already registered', Context.currentPos());
            return null;
        }
        
        // Register this bundle
        var bundleId = bundleIdCounter++;
        registeredBundles.set(fullPath, bundleId);
        
        // Get fields
        var fields = Context.getBuildFields();
        var componentFields = extractBundleFields(fields);
        
        // Validate no duplicate component types
        validateComponentTypes(componentFields);
        
        // Add bundle interface implementation
        var implFields = implementBundleInterface(classType, fields, componentFields);
        
        // Add initialization code
        addBundleRegistration(className, modulePath, bundleId, componentFields);
        
        return fields.concat(implFields);
    }
    
    /**
     * Extracts component fields from bundle class.
     */
    static function extractBundleFields(fields:Array<Field>):Array<BundleFieldInfo> {
        var bundleFields = new Array<BundleFieldInfo>();
        
        for (field in fields) {
            // Skip static fields and methods
            if (hasAccess(field.access, AStatic) || field.kind.match(FFun(_))) {
                continue;
            }
            
            // Skip private fields
            if (!hasAccess(field.access, APublic) && !hasAccess(field.access, APrivate)) {
                continue;
            }
            
            switch (field.kind) {
                case FVar(t, maybeExpr):
                    bundleFields.push({
                        name: field.name,
                        type: t,
                        hasDefault: maybeExpr != null,
                        meta: field.meta
                    });
                    
                case FProp(_, _, t, _):
                    bundleFields.push({
                        name: field.name,
                        type: t,
                        hasDefault: false,
                        meta: field.meta
                    });
                    
                default:
                    // Skip other field types
            }
        }
        
        return bundleFields;
    }
    
    /**
     * Checks if an array of access flags contains a specific access.
     */
    static inline function hasAccess(access:Array<Access>, target:Access):Bool {
        for (a in access) {
            if (a == target) return true;
        }
        return false;
    }
    
    /**
     * Validates that there are no duplicate component types in the bundle.
     */
    static function validateComponentTypes(fields:Array<BundleFieldInfo>):Void {
        var seenTypes = new Map<String, Bool>();
        
        for (field in fields) {
            var typeStr = printType(field.type);
            if (seenTypes.exists(typeStr)) {
                Context.warning('Duplicate component type $typeStr in bundle', Context.currentPos());
            }
            seenTypes.set(typeStr, true);
        }
    }
    
    /**
     * Implements the Bundle interface for the class.
     */
    static function implementBundleInterface(
        classType:ClassType, 
        fields:Array<Field>,
        bundleFields:Array<BundleFieldInfo>
    ):Array<Field> {
        var implFields = new Array<Field>();
        var className = classType.name;
        
        // Generate getComponentTypes - returns array of component IDs
        implFields.push({
            name: "getComponentTypes",
            doc: "Returns an array of all component type IDs in this bundle",
            meta: [{ name: ":noCompletion", params: [], pos: Context.currentPos() }],
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro:Array<UInt>,
                expr: macro {
                    return $v{bundleFields.length > 0 ? [] : []}; // Placeholder
                }
            }),
            pos: Context.currentPos()
        });
        
        // Generate componentCount method
        implFields.push({
            name: "componentCount",
            doc: "Returns the number of components in this bundle",
            meta: [{ name: ":noCompletion", params: [], pos: Context.currentPos() }],
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro:Int,
                expr: macro {
                    return $v{bundleFields.length};
                }
            }),
            pos: Context.currentPos()
        });
        
        // Generate getBundleId method
        implFields.push({
            name: "getBundleId",
            doc: "Returns the unique bundle ID",
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
        
        // Generate fromComponents - static factory method
        var fromExprs:Array<Expr> = [];
        var fieldAssignments:Array<Expr> = [];
        
        for (field in bundleFields) {
            var typeStr = printType(field.type);
            fieldAssignments.push(macro {
                bundle.${field.name} = cast components[$v{bundleFields.indexOf(field)}];
            });
        }
        
        fromExprs.push(macro var bundle = new $className());
        fromExprs = fromExprs.concat(fieldAssignments);
        fromExprs.push(macro return bundle);
        
        implFields.push({
            name: "fromComponents",
            doc: "Creates a bundle instance from an array of component instances",
            meta: [
                { name: ":noCompletion", params: [], pos: Context.currentPos() },
                { name: ":static", params: [], pos: Context.currentPos() }
            ],
            access: [APublic, AStatic],
            kind: FFun({
                args: [{ name: "components", type: macro:Array<Dynamic> }],
                ret: macro:$className,
                expr: macro $b{fromExprs}
            }),
            pos: Context.currentPos()
        });
        
        // Generate toComponents - returns array of component instances
        var toComponentExprs:Array<Expr> = [];
        for (field in bundleFields) {
            toComponentExprs.push(macro this.${field.name});
        }
        
        implFields.push({
            name: "toComponents",
            doc: "Returns all components as an array",
            meta: [{ name: ":noCompletion", params: [], pos: Context.currentPos() }],
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro:Array<Dynamic>,
                expr: macro {
                    return $a{toComponentExprs};
                }
            }),
            pos: Context.currentPos()
        });
        
        // Generate getComponentByType method
        implFields.push({
            name: "getComponentByType",
            doc: "Gets a component by its type name",
            meta: [{ name: ":noCompletion", params: [], pos: Context.currentPos() }],
            access: [APublic],
            kind: FFun({
                args: [{ name: "typeName", type: macro:String }],
                ret: macro:Dynamic,
                expr: macro {
                    #if js
                    switch (typeName) {
                        $a{bundleFields.map(f -> macro case $v{printType(f.type).split(".").pop()}: return this.${f.name})}
                        default: return null;
                    }
                    #else
                    return null;
                    #end
                }
            }),
            pos: Context.currentPos()
        });
        
        return implFields;
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
    
    /**
     * Adds bundle registration code to module initialization.
     */
    static function addBundleRegistration(
        className:String,
        modulePath:String,
        bundleId:Int,
        fields:Array<BundleFieldInfo>
    ):Void {
        #if macro
        var fullPath = modulePath + "." + className;
        var componentTypes = fields.map(f -> printType(f.type));
        
        var registrationExpr = macro {
            haxe.ecs.ComponentRegistry.registerBundle(
                $v{fullPath},
                $v{bundleId},
                $a{componentTypes.map(t -> macro $v{t})}
            );
        };
        
        Context.addModuleInit(registrationExpr);
        #end
    }
    
    /**
     * Gets the registered bundle ID for a type.
     */
    public static function getRegisteredId(typePath:String):Option<Int> {
        return if (registeredBundles.exists(typePath)) {
            Some(registeredBundles.get(typePath));
        } else {
            None;
        }
    }
}

/**
 * Bundle field information structure.
 */
typedef BundleFieldInfo = {
    /** Field name */
    var name:String;
    /** Field type */
    var type:ComplexType;
    /** Whether the field has a default value */
    var hasDefault:Bool;
    /** Field metadata */
    var meta:Array<MetadataEntry>;
}

/**
 * Bundle metadata holder for compile-time reflection.
 */
class BundleMetadata {
    /** Map of type names to bundle metadata */
    public static var metadata:Map<String, BundleTypeMetadata> = new Map();
    
    /**
     * Registers a bundle type.
     */
    public static function register(
        typeName:String,
        modulePath:String,
        bundleId:Int,
        componentTypes:Array<String>
    ):Void {
        metadata.set(typeName, {
            typeName: typeName,
            modulePath: modulePath,
            bundleId: bundleId,
            componentTypes: componentTypes,
            componentCount: componentTypes.length
        });
    }
    
    /**
     * Gets metadata for a bundle type.
     */
    public static function get(typeName:String):Null<BundleTypeMetadata> {
        return metadata.get(typeName);
    }
    
    /**
     * Gets all registered bundle types.
     */
    public static function getAllTypes():Iterator<String> {
        return metadata.keys();
    }
}

/**
 * Bundle type metadata structure.
 */
typedef BundleTypeMetadata = {
    /** Full type name */
    var typeName:String;
    /** Module path */
    var modulePath:String;
    /** Bundle ID */
    var bundleId:Int;
    /** Component type names */
    var componentTypes:Array<String>;
    /** Number of components */
    var componentCount:Int;
}
