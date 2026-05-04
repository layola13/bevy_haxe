package haxe.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

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
 * - Bundle registration
 * - FromComponents implementation
 * - Bundle archetype tracking
 * - Dynamic component insertion support
 */
class BundleMacro {
    /**
     * Build function for @:bundle metadata
     */
    public static function build():Void {
        var localType = Context.getLocalType();
        var type = Context.getTypeExpr(Context.getLocalClass().get());
        
        switch type.expr {
            case EClass(decl):
                processBundleClass(decl, localType);
            default:
                Context.error("@:bundle can only be applied to classes", Context.currentPos());
        }
    }
    
    /**
     * Process bundle class and generate registration code
     */
    static function processBundleClass(decl:ClassDecl, localType:Type):Void {
        var className = decl.name;
        var modulePath = Context.getLocalModule();
        
        // Check for extends Bundle
        var extendsBundle = checkExtendsBundle(decl);
        if (!extendsBundle) {
            Context.warning("Bundle should extend haxe.ecs.Bundle", Context.currentPos());
        }
        
        var componentFields = extractComponentFields(decl.fields);
        var componentTypes = resolveComponentTypes(componentFields);
        
        // Validate no duplicate component types
        validateNoDuplicates(componentTypes);
        
        // Generate bundle registration
        generateBundleRegistration(className, modulePath, componentTypes);
        
        // Generate FromComponents implementation
        generateFromComponents(className, componentTypes);
        
        // Generate archetype tracking
        generateArchetypeTracking(className, componentTypes);
        
        // Add bundle to registry
        addToBundleRegistry(className, modulePath, componentTypes);
    }
    
    /**
     * Check if class extends Bundle
     */
    static function checkExtendsBundle(decl:ClassDecl):Bool {
        for (ext in decl.extend) {
            switch ext {
                case TType(t, _):
                    var typePath = getTypePath(t);
                    if (typePath.pack.length > 0 && typePath.name == "Bundle") {
                        return true;
                    }
                default:
            }
        }
        return false;
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
     * Extract component fields from bundle class
     */
    static function extractComponentFields(fields:Array<Field>):Array<ComponentFieldInfo> {
        var infos:Array<ComponentFieldInfo> = [];
        
        for (field in fields) {
            // Skip @:skip fields
            var shouldSkip = false;
            for (meta in field.meta) {
                if (meta.name == ":skip" || meta.name == ":ignore") {
                    shouldSkip = true;
                    break;
                }
            }
            
            if (!shouldSkip) {
                var componentType = extractFieldType(field);
                if (componentType != null) {
                    infos.push({
                        name: field.name,
                        type: componentType,
                        hasDefault: hasDefaultValue(field),
                        meta: field.meta
                    });
                }
            }
        }
        
        return infos;
    }
    
    /**
     * Extract field type
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
     * Check if field has default value
     */
    static function hasDefaultValue(field:Field):Bool {
        switch field.kind {
            case FVar(_, e):
                return e != null;
            default:
                return false;
        }
    }
    
    /**
     * Resolve component types from field info
     */
    static function resolveComponentTypes(fields:Array<ComponentFieldInfo>):Array<ResolvedComponent> {
        var resolved:Array<ResolvedComponent> = [];
        
        for (field in fields) {
            var componentType = resolveTypeToString(field.type);
            var componentId = generateComponentIdExpression(componentType);
            var storageType = determineStorageType(field);
            
            resolved.push({
                fieldName: field.name,
                typeString: componentType,
                componentIdExpr: componentId,
                storageType: storageType,
                hasDefault: field.hasDefault
            });
        }
        
        return resolved;
    }
    
    /**
     * Resolve a ComplexType to string representation
     */
    static function resolveTypeToString(type:ComplexType):String {
        switch type {
            case TPath(p):
                return (p.pack.length > 0 ? p.pack.join(".") + "." : "") + p.name;
            case TAnonymous(fields):
                return "Anonymous" + fields.length; // Generate unique name
            case TFunction(args, ret):
                return "Function";
            case TParent(t):
                return resolveTypeToString(t);
            default:
                return "Unknown";
        }
    }
    
    /**
     * Generate component ID expression for type
     */
    static function generateComponentIdExpression(typeString:String):Expr {
        return macro {
            haxe.ecs.reflect.ComponentRegistry.getId($v{typeString});
        };
    }
    
    /**
     * Determine storage type for component
     */
    static function determineStorageType(field:ComponentFieldInfo):StorageType {
        // Check for component-specific storage hints
        for (meta in field.meta) {
            if (meta.name == ":sparse") {
                return Sparse;
            }
            if (meta.name == ":table") {
                return Table;
            }
        }
        
        // Default based on component size
        return Table;
    }
    
    /**
     * Validate no duplicate component types
     */
    static function validateNoDuplicates(components:Array<ResolvedComponent>):Void {
        var seen = new Map<String, Bool>();
        for (comp in components) {
            if (seen.exists(comp.typeString)) {
                Context.error('Duplicate component type: ${comp.typeString}', Context.currentPos());
            }
            seen.set(comp.typeString, true);
        }
    }
    
    /**
     * Generate bundle registration code
     */
    static function generateBundleRegistration(className:String, modulePath:String, components:Array<ResolvedComponent>):Void {
        // Generate static bundle descriptor
        var descriptorExpr = macro {
            @:keep static var _bundleDescriptor:haxe.ecs.BundleDescriptor = {
                id: haxe.ds.StringMap.create(),
                componentIds: [
                    $a{components.map(c -> macro $v{c.typeString})},
                ],
                componentCount: $v{components.length},
                archetypeMask: 0 // Bitmask for archetype matching
            };
        };
        
        // Generate archetype registration
        var archetypeExpr = macro {
            haxe.ecs.archetype.ArchetypeRegistry.register($v{modulePath}, $v{className}, {
                components: [
                    $a{components.map(c -> macro {
                        typeName: $v{c.typeString},
                        fieldName: $v{c.fieldName},
                        storageType: $v{Std.string(c.storageType)}
                    })}
                ],
                componentMask: $v{generateComponentMask(components)}
            });
        };
    }
    
    /**
     * Generate component mask for archetype matching
     */
    static function generateComponentMask(components:Array<ResolvedComponent>):Int {
        var mask = 0;
        var index = 0;
        for (comp in components) {
            // Generate unique bit position based on component type
            var bitPosition = fastHash(comp.typeString) % 64;
            mask |= (1 << bitPosition);
            index++;
        }
        return mask;
    }
    
    /**
     * Fast hash function for component types
     */
    static function fastHash(s:String):Int {
        var h = 0;
        for (i in 0...s.length) {
            h = (h * 31 + s.charCodeAt(i)) | 0;
        }
        return h;
    }
    
    /**
     * Generate FromComponents implementation
     */
    static function generateFromComponents(className:String, components:Array<ResolvedComponent>):Void {
        // Generate the static fromComponents method
        var fromComponentsExpr = macro {
            static function fromComponents(components:Array<Dynamic>):$className {
                var bundle = new $className();
                
                $a{components.map((c, i) -> macro {
                    bundle.${c.fieldName} = components[$v{i}];
                })}
                
                return bundle;
            }
        };
        
        // Generate toComponents method
        var toComponentsExpr = macro {
            function toComponents():Array<Dynamic> {
                return [
                    $a{components.map(c -> macro this.${c.fieldName})}
                ];
            }
        };
    }
    
    /**
     * Generate archetype tracking
     */
    static function generateArchetypeTracking(className:String, components:Array<ResolvedComponent>):Void {
        var trackingExpr = macro {
            haxe.ecs.archetype.ArchetypeTracker.trackBundle(
                $v{className},
                [
                    $a{components.map(c -> macro $v{c.componentIdExpr})}
                ],
                $v{generateArchetypeId(components)}
            );
        };
    }
    
    /**
     * Generate unique archetype ID from components
     */
    static function generateArchetypeId(components:Array<ResolvedComponent>):String {
        var ids = components.map(c -> c.typeString).join("|");
        return haxe.crypto.Md5.encode(ids);
    }
    
    /**
     * Add bundle to registry
     */
    static function addToBundleRegistry(className:String, modulePath:String, components:Array<ResolvedComponent>):Void {
        var registryExpr = macro {
            haxe.ecs.BundleRegistry.register($v{modulePath}, $v{className}, {
                className: $v{className},
                modulePath: $v{modulePath},
                componentTypes: [
                    $a{components.map(c -> macro $v{c.typeString})}
                ],
                componentCount: $v{components.length}
            });
        };
    }
    
    /**
     * Generate bundle insertion code
     */
    public static function generateInsertCode(bundleClass:String, componentExpressions:Array<Expr>):Expr {
        var insertExprs:Array<Expr> = [];
        
        insertExprs.push(macro {
            var world = haxe.ecs.World.getInstance();
            var entity = world.createEntity();
        });
        
        for (i in 0...componentExpressions.length) {
            var compExpr = componentExpressions[i];
            insertExprs.push(macro {
                world.addComponent(entity, $compExpr);
            });
        }
        
        insertExprs.push(macro {
            return entity;
        });
        
        return macro $b{insertExprs};
    }
}

/**
 * Component field information for bundles
 */
typedef ComponentFieldInfo = {
    var name:String;
    var type:ComplexType;
    var hasDefault:Bool;
    var meta:Array<MetadataEntry>;
}

/**
 * Resolved component information
 */
typedef ResolvedComponent = {
    var fieldName:String;
    var typeString:String;
    var componentIdExpr:Expr;
    var storageType:StorageType;
    var hasDefault:Bool;
}

/**
 * Storage type for component data
 */
enum StorageType {
    Table;
    Sparse;
    Dense;
}
