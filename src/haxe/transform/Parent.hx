package haxe.transform;

import haxe.ecs.Entity;

/**
 * Parent component - indicates this entity is a child of another entity.
 * 
 * This establishes a parent-child relationship in the transform hierarchy.
 * The child's Transform is relative to the parent's Transform.
 * 
 * The GlobalTransform of a child is computed by combining its Transform
 * with its parent's GlobalTransform.
 */
class Parent implements haxe.ecs.Component {
    /** The parent entity's ID */
    public var parentId:Int;
    
    public var componentTypeId(get, never):Int;
    private static var _typeId:Int = -1;
    private static function get_componentTypeId():Int {
        if (_typeId < 0) _typeId = haxe.ecs.ComponentType.get(Parent);
        return _typeId;
    }
    
    public inline function new(parentId:Int) {
        this.parentId = parentId;
    }
    
    /**
     * Get parent as Entity type
     */
    public function parent():Entity {
        return new Entity(parentId);
    }
    
    /**
     * Create from Entity
     */
    public static function of(entity:Entity):Parent {
        return new Parent(entity.id);
    }
}
