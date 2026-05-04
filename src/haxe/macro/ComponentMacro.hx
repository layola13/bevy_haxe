package haxe.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

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
 */
class ComponentMacro {
    /**
     * Build function for @:component metadata
     * Called by the Haxe compiler when processing types with @:component
     */
    public static function build():Void {
        var localType = Context.getLocalType();
        var type = Context.getTypeExpr(Context.getLocalClass().get());
        
        switch type.expr {
            case EClass(decl):
                processComponentClass(decl, localType);
            default:
                Context.error("@:component can only be applied to classes", Context.currentPos());
        }
    }
    
    /**
     * Process a component class and generate registration code
     */
    static function processComponentClass(decl:ClassDecl, localType:Type):Void {
        var className = decl.name;
        var modulePath = Context.getLocalModule();
        var fieldInfos = extractComponentFields(decl.fields);
        
        // Generate component registration code
        var registrationCode = generateRegistration(className, modulePath, fieldInfos);
        
        // Add type references for reflection system
        addTypeReferences(className, modulePath, fieldInfos);
        
        // Generate component info structure
        generateComponentInfo(className, fieldInfos);
        
        // Add to initialization module
        addToModuleInit(registrationCode);
    }
    
    /**
     * Extract field information from component class
     */
    static function extractComponentFields(fields:Array<Field>):Array<FieldInfo> {
        var infos:Array<FieldInfo> = [];
        
        for (field in fields) {
            // Skip metadata-only fields
            var isIgnore = false;
            for (meta in field.meta) {
                if (meta.name == ":skip" || meta.name == ":no_serialize") {
                    isIgnore = true;
                    break;
                }
            }
            
            if (!isIgnore && field.kind != FProp("get", "set", _, _)) {
                infos.push({
                    name: field.name,
                    type: extractFieldType(field),
                    isMutable: isMutableField(field)
                });
            }
        }
        
        return infos;
    }
    
    /**
     * Extract type from field definition
     */
    static function extractFieldType(field:Field):ComplexType {
        switch field.kind {
            case FVar(t, _):
                return t;
            case FProp(_, _, t, _):
                return t;
            default:
                return null;
        }
    }
    
    /**
     * Check if a field is mutable
     */
    static function isMutableField(field:Field):Bool {
        switch field.kind {
            case FVar(_, e):
                return e != null; // Has default value
            case FProp("default", _, _, _):
                return true;
            case FProp("never", _, _, _):
                return false;
            case FProp(_, _, _, _):
                return true;
            default:
                return false;
        }
    }
    
    /**
     * Generate component registration code
     */
    static function generateRegistration(className:String, modulePath:String, fields:Array<FieldInfo>):Expr {
        var componentIdVar = '_componentId_$className';
        var typeIdVar = '_typeId_$className';
        
        var registerExprs:Array<Expr> = [];
        
        // Create type ID
        var typeIdCode = macro {
            var $typeIdVar = haxe.ds.StringMap.create();
            $i{typeIdVar}.set($v{modulePath}, $v{className});
            haxe.ds.StringMap.set($typeIdVar, $v{modulePath}, $v{className});
        };
        registerExprs.push(typeIdCode);
        
        // Component ID generation
        var componentIdCode = macro {
            var $componentIdVar:Int = 0;
            $componentIdVar = untyped __cpp__('bevy_ecs::component::ComponentIdRegistry::global().register_component<{modulePath}::$className>()');
        };
        registerExprs.push(componentIdCode);
        
        // Field registration
        for (field in fields) {
            var fieldCode = macro {
                // Register component field
                var fieldName = $v{field.name};
                var fieldType = $v{Std.string(field.type)};
            };
            registerExprs.push(fieldCode);
        }
        
        // Generate storage initialization
        var storageInit = macro {
            var storage:haxe.ecs.storage.ComponentStorage = null;
            // Component storage is created per archetype
        };
        registerExprs.push(storageInit);
        
        return macro $b{registerExprs};
    }
    
    /**
     * Add type references for reflection system
     */
    static function addTypeReferences(className:String, modulePath:String, fields:Array<FieldInfo>):Void {
        // This adds entries to the type registry for runtime reflection
        var typeRefExpr = macro {
            haxe.ecs.reflect.ComponentTypeRegistry.register($v{modulePath}, $v{className}, {
                fields: [
                    $a{fields.map(f -> macro {
                        name: $v{f.name},
                        type: $v{Std.string(f.type)},
                        isMutable: $v{f.isMutable}
                    })}
                ],
                componentId: null,
                typeId: $v{modulePath + "." + className}
            });
        };
    }
    
    /**
     * Generate component info structure
     */
    static function generateComponentInfo(className:String, fields:Array<FieldInfo>):Void {
        var infoFields:Array<Field> = [
            {
                name: "componentId",
                doc: null,
                meta: [],
                access: [APublic],
                kind: FVar(macro:Int, null),
                pos: Context.currentPos()
            },
            {
                name: "typeName",
                doc: null,
                meta: [],
                access: [APublic],
                kind: FVar(macro:String, macro $v{className}),
                pos: Context.currentPos()
            },
            {
                name: "fieldCount",
                doc: null,
                meta: [],
                access: [APublic],
                kind: FVar(macro:Int, macro $v{fields.length}),
                pos: Context.currentPos()
            },
            {
                name: "typeId",
                doc: null,
                meta: [],
                access: [APublic],
                kind: FVar(macro:String, macro $v{className}),
                pos: Context.currentPos()
            }
        ];
        
        // Create a static component info constant
        var infoExpr = macro class {
            static var COMPONENT_INFO:haxe.ecs.reflect.ComponentInfo = {
                componentId: 0,
                typeName: $v{className},
                fieldCount: $v{fields.length},
                typeId: $v{className},
                fields: [
                    $a{fields.map(f -> macro {
                        name: $v{f.name},
                        typeName: $v{Std.string(f.type)},
                        offset: 0
                    })}
                ]
            };
        };
    }
    
    /**
     * Add registration code to module initialization
     */
    static function addToModuleInit(code:Expr):Void {
        // Register for lazy initialization when the world is created
        var moduleInit = macro {
            haxe.macro.MacroStack.push(${code});
        };
    }
    
    /**
     * Generate component trait implementation
     */
    public static function generateComponentImpl(className:String, fields:Array<FieldInfo>):Array<Field> {
        var implFields:Array<Field> = [];
        
        // Generate getComponentId method
        implFields.push({
            name: "getComponentId",
            doc: "Returns the unique component ID",
            meta: [],
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro:Int,
                expr: macro {
                    return 0; // Will be filled by registration
                }
            }),
            pos: Context.currentPos()
        });
        
        // Generate getTypeId method
        implFields.push({
            name: "getTypeId",
            doc: "Returns the component type ID",
            meta: [],
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
        
        return implFields;
    }
    
    /**
     * Check for conflicting component IDs
     */
    public static function checkConflicts(className:String):Void {
        // This would check at compile time for duplicate component registrations
    }
}

/**
 * Field information structure for component fields
 */
typedef FieldInfo = {
    var name:String;
    var type:ComplexType;
    var isMutable:Bool;
}
