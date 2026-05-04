package haxe.macro;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.ds.Option;

/**
 * Macro for automatically registering ECS components.
 * Generates component registration code and implements required traits.
 * 
 * Usage:
 * ```haxe
 * @:component
 * class Position {
 *     public var x:Float;
 *     public var y:Float;
 * }
 * ```
 * 
 * This will generate:
 * - Component registration in the ECS world
 * - Implementation of IComponent interface
 * - ComponentInfo creation
 * - TypeId registration
 * - Field accessors for runtime reflection
 */
class ComponentMacro {
    /** Component ID counter for compile-time registration */
    static var componentIdCounter:Int = 1;
    
    /** Map of registered component types */
    static var registeredComponents:Map<String, Int> = new Map();

    /**
     * Build function for @:component metadata.
     * Called by the Haxe compiler when processing types with @:component.
     * Returns modified fields with generated methods added.
     */
    public static function build():Array<Field> {
        var localType = Context.getLocalType();
        var typeExpr = Context.getLocalClass();
        
        if (typeExpr == null) {
            Context.error("@:component can only be applied to classes", Context.currentPos());
            return null;
        }
        
        var classType = typeExpr.get();
        
        // Check for duplicate registration
        var className = classType.name;
        var modulePath = Context.getLocalModule();
        
        if (registeredComponents.exists(modulePath + "." + className)) {
            Context.error('Component $className is already registered', Context.currentPos());
            return null;
        }
        
        // Register this component
        var componentId = componentIdCounter++;
        registeredComponents.set(modulePath + "." + className, componentId);
        
        // Process fields
        var fields = Context.getBuildFields();
        var componentFields = extractComponentFields(fields);
        
        // Generate component metadata
        generateComponentMetadata(className, modulePath, componentId, componentFields);
        
        // Add component interface implementation
        var implFields = implementComponentInterface(classType, fields);
        
        // Generate field info for reflection
        generateFieldInfo(className, componentFields);
        
        // Add initialization code
        addComponentRegistration(className, modulePath, componentId, componentFields);
        
        return fields.concat(implFields);
    }
    
    /**
     * Extracts component fields from class fields.
     */
    static function extractComponentFields(fields:Array<Field>):Array<ComponentFieldInfo> {
        var componentFields = new Array<ComponentFieldInfo>();
        
        for (field in fields) {
            // Skip static fields and methods
            if (hasAccess(field.access, AStatic) || field.kind.match(FFun(_))) {
                continue;
            }
            
            // Skip private fields (unless they're component data)
            if (!hasAccess(field.access, APublic) && !hasAccess(field.access, APrivate)) {
                continue;
            }
            
            switch (field.kind) {
                case FVar(t, maybeExpr):
                    var isMutable = hasAccess(field.access, AVar);
                    var fieldType = t != null ? t : (maybeExpr != null ? inferType(maybeExpr) : macro:Dynamic);
                    
                    componentFields.push({
                        name: field.name,
                        type: fieldType,
                        isMutable: isMutable,
                        hasDefault: maybeExpr != null,
                        meta: field.meta
                    });
                    
                case FProp(_, _, t, _):
                    // Property fields are also considered
                    componentFields.push({
                        name: field.name,
                        type: t,
                        isMutable: true,
                        hasDefault: false,
                        meta: field.meta
                    });
                    
                default:
                    // Skip other field types
            }
        }
        
        return componentFields;
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
     * Infers type from expression (for default values).
     */
    static function inferType(expr:Expr):ComplexType {
        return switch (expr.expr) {
            case EConst(CInt(_)): macro:Int;
            case EConst(CFloat(_)): macro:Float;
            case EConst(CString(_)): macro:String;
            case EConst(CBool(_)): macro:Bool;
            case EArrayDecl(_): macro:Array<Dynamic>;
            case EObjectDecl(_): macro:Dynamic;
            default: macro:Dynamic;
        };
    }
    
    /**
     * Generates component metadata at compile time.
     */
    static function generateComponentMetadata(
        className:String, 
        modulePath:String, 
        componentId:Int,
        fields:Array<ComponentFieldInfo>
    ):Void {
        #if macro
        // Generate type hash for archetype matching
        var typeHash = generateTypeHash(modulePath + "." + className);
        
        // Log registration info
        Context.info('Registering component: $className (id: $componentId, hash: $typeHash, fields: ${fields.length})', Context.currentPos());
        #end
    }
    
    /**
     * Generates a stable hash for the component type.
     */
    static function generateTypeHash(typeName:String):Int {
        var hash = 0;
        for (i in 0...typeName.length) {
            hash = ((hash << 5) - hash) + typeName.charCodeAt(i);
            hash = hash & 0xFFFFFFFF;
        }
        return hash;
    }
    
    /**
     * Implements the Component interface for the class.
     */
    static function implementComponentInterface(classType:ClassType, fields:Array<Field>):Array<Field> {
        var implFields = new Array<Field>();
        var className = classType.name;
        var modulePath = Context.getLocalModule();
        
        // Generate getComponentId method - returns unique component ID
        implFields.push({
            name: "getComponentId",
            doc: "Returns the unique component ID for this component type",
            meta: [{ name: ":noCompletion", params: [], pos: Context.currentPos() }],
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro:UInt,
                expr: macro {
                    return haxe.ecs.ComponentRegistry.getId(Type.getClass(this));
                }
            }),
            pos: Context.currentPos()
        });
        
        // Generate getTypeName method - returns the type name
        implFields.push({
            name: "getTypeName",
            doc: "Returns the component type name",
            meta: [{ name: ":noCompletion", params: [], pos: Context.currentPos() }],
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro:String,
                expr: macro {
                    return $v{className};
                }
            }),
            pos: Context.currentPos()
        });
        
        // Generate getModulePath method - returns full module path
        implFields.push({
            name: "getModulePath",
            doc: "Returns the full module path",
            meta: [{ name: ":noCompletion", params: [], pos: Context.currentPos() }],
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro:String,
                expr: macro {
                    return $v{modulePath};
                }
            }),
            pos: Context.currentPos()
        });
        
        // Generate getFieldCount method
        implFields.push({
            name: "getFieldCount",
            doc: "Returns the number of data fields in this component",
            meta: [{ name: ":noCompletion", params: [], pos: Context.currentPos() }],
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro:Int,
                expr: macro {
                    return $v{fields.length};
                }
            }),
            pos: Context.currentPos()
        });
        
        // Generate getFieldNames method for reflection
        var fieldNames = fields.map(f -> macro $v{f.name});
        implFields.push({
            name: "getFieldNames",
            doc: "Returns all field names for this component (for reflection)",
            meta: [{ name: ":noCompletion", params: [], pos: Context.currentPos() }],
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro:Array<String>,
                expr: macro {
                    return $a{fieldNames};
                }
            }),
            pos: Context.currentPos()
        });
        
        // Generate getFieldValue method for runtime access
        implFields.push({
            name: "getFieldValue",
            doc: "Gets a field value by name at runtime",
            meta: [{ name: ":noCompletion", params: [], pos: Context.currentPos() }],
            access: [APublic],
            kind: FFun({
                args: [{ name: "fieldName", type: macro:String }],
                ret: macro:Dynamic,
                expr: macro {
                    #if js
                    return js.lib.Reflection.getProperty(this, fieldName);
                    #elseif neko
                    return neko.vm.Reflect.getProperty(this, fieldName);
                    #else
                    return null;
                    #end
                }
            }),
            pos: Context.currentPos()
        });
        
        // Generate setFieldValue method for runtime mutation
        implFields.push({
            name: "setFieldValue",
            doc: "Sets a field value by name at runtime",
            meta: [{ name: ":noCompletion", params: [], pos: Context.currentPos() }],
            access: [APublic],
            kind: FFun({
                args: [
                    { name: "fieldName", type: macro:String },
                    { name: "value", type: macro:Dynamic }
                ],
                ret: macro:Void,
                expr: macro {
                    #if js
                    js.lib.Reflection.setProperty(this, fieldName, value);
                    #elseif neko
                    neko.vm.Reflect.setProperty(this, fieldName, value);
                    #end
                }
            }),
            pos: Context.currentPos()
        });
        
        // Generate clone method for component copying
        implFields.push({
            name: "clone",
            doc: "Creates a deep copy of this component",
            meta: [{ name: ":noCompletion", params: [], pos: Context.currentPos() }],
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro:haxe.ecs.Component,
                expr: macro {
                    var copy = Type.createInstance(Type.getClass(this), []);
                    for (fieldName in $v{fieldNames}) {
                        Reflect.setField(copy, fieldName, Reflect.getProperty(this, fieldName));
                    }
                    return copy;
                }
            }),
            pos: Context.currentPos()
        });
        
        return implFields;
    }
    
    /**
     * Generates field info for compile-time reflection.
     */
    static function generateFieldInfo(className:String, fields:Array<ComponentFieldInfo>):Void {
        #if macro
        for (field in fields) {
            Context.info(
                '  Field: ${field.name} (${printType(field.type)}, mutable: ${field.isMutable})',
                Context.currentPos()
            );
        }
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
    
    /**
     * Adds component registration code to the module initialization.
     */
    static function addComponentRegistration(
        className:String, 
        modulePath:String, 
        componentId:Int,
        fields:Array<ComponentFieldInfo>
    ):Void {
        #if macro
        var fullPath = modulePath + "." + className;
        var fieldTypes = fields.map(f -> printType(f.type));
        
        var registrationExpr = macro {
            haxe.ecs.ComponentRegistry.register(
                $v{fullPath},
                $v{componentId}
            );
            
            // Store field metadata
            haxe.macro.ComponentMetadata.register(
                $v{className},
                $v{modulePath},
                $v{componentId},
                $v{fields.length},
                false // isSparse - can be set via @:sparse metadata
            );
        };
        
        // Add to initialization
        Context.addModuleInit(registrationExpr);
        #end
    }
    
    /**
     * Gets the registered component ID for a type.
     */
    public static function getRegisteredId(typePath:String):Option<Int> {
        return if (registeredComponents.exists(typePath)) {
            Some(registeredComponents.get(typePath));
        } else {
            None;
        }
    }
    
    /**
     * Checks if a type is registered as a component.
     */
    public static function isRegistered(typePath:String):Bool {
        return registeredComponents.exists(typePath);
    }
    
    /**
     * Checks if a field should be included in component registration.
     */
    static function shouldIncludeField(field:Field):Bool {
        // Check for skip metadata
        for (meta in field.meta) {
            if (meta.name == ":skip" || meta.name == ":no_serialize" || meta.name == ":no_component") {
                return false;
            }
        }
        return true;
    }
}

/**
 * Field information structure for component fields.
 */
typedef ComponentFieldInfo = {
    /** Field name */
    var name:String;
    /** Field type */
    var type:ComplexType;
    /** Whether the field is mutable */
    var isMutable:Bool;
    /** Whether the field has a default value */
    var hasDefault:Bool;
    /** Field metadata */
    var meta:Array<MetadataEntry>;
}

/**
 * Metadata holder for compile-time component information.
 * Used by the reflection system to access component metadata.
 */
class ComponentMetadata {
    /** Map of type names to metadata */
    public static var metadata:Map<String, ComponentTypeMetadata> = new Map();
    
    /**
     * Stores metadata for a component type.
     */
    public static function register(
        typeName:String,
        modulePath:String,
        componentId:Int,
        fieldCount:Int,
        isSparse:Bool
    ):Void {
        metadata.set(typeName, {
            typeName: typeName,
            modulePath: modulePath,
            componentId: componentId,
            fieldCount: fieldCount,
            isSparse: isSparse
        });
    }
    
    /**
     * Gets metadata for a component type.
     */
    public static function get(typeName:String):Null<ComponentTypeMetadata> {
        return metadata.get(typeName);
    }
    
    /**
     * Gets all registered component types.
     */
    public static function getAllTypes():Iterator<String> {
        return metadata.keys();
    }
}

/**
 * Component type metadata structure.
 */
typedef ComponentTypeMetadata = {
    /** Full type name */
    var typeName:String;
    /** Module path */
    var modulePath:String;
    /** Component ID */
    var componentId:Int;
    /** Number of fields */
    var fieldCount:Int;
    /** Whether this is a sparse component */
    var isSparse:Bool;
}
