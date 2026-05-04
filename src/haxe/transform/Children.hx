package haxe.transform;

/**
 * Children component - holds references to all child entities.
 * 
 * This is the counterpart to Parent. If an entity has a Parent component,
 * it should have exactly one parent. If an entity has a Children component,
 * it can have zero or more children.
 * 
 * The Children component is optional and is mainly used for:
 * 1. Efficient iteration over children during transform propagation
 * 2. Maintaining the hierarchy structure for operations like reparenting
 */
class Children implements haxe.ecs.Component {
    /** List of child entity IDs */
    public var children:Array<Int>;
    
    public var componentTypeId(get, never):Int;
    private static var _typeId:Int = -1;
    private static function get_componentTypeId():Int {
        if (_typeId < 0) _typeId = haxe.ecs.ComponentType.get(Children);
        return _typeId;
    }
    
    public inline function new(?children:Array<Int>) {
        this.children = children != null ? children : [];
    }
    
    /**
     * Get the number of children
     */
    public var length(get, never):Int;
    private inline function get_length():Int return children.length;
    
    /**
     * Check if this entity has any children
     */
    public var hasChildren(get, never):Bool;
    private inline function get_hasChildren():Bool return children.length > 0;
    
    /**
     * Add a child entity
     */
    public function add(childId:Int):Void {
        if (!children.has(childId)) {
            children.push(childId);
        }
    }
    
    /**
     * Remove a child entity
     */
    public function remove(childId:Int):Bool {
        return children.remove(childId);
    }
    
    /**
     * Check if this entity has a specific child
     */
    public function hasChild(childId:Int):Bool {
        return children.has(childId);
    }
    
    /**
     * Get iterator over children
     */
    public function iterator():Iterator<Int> {
        return children.iterator();
    }
    
    /**
     * Get child at index
     */
    public inline function get(index:Int):Int {
        return children[index];
    }
    
    /**
     * Clear all children
     */
    public inline function clear():Void {
        children = [];
    }
    
    /**
     * Set children list directly
     */
    public function set(children:Array<Int>):Void {
        this.children = children;
    }
}
