package haxe.transform;

import haxe.ecs.World;
import haxe.ecs.Entity;

/**
 * TransformSystem - Updates GlobalTransform components from Transform components.
 * 
 * This system propagates transform changes through the entity hierarchy.
 * It must be run every frame to ensure GlobalTransform is up-to-date with Transform.
 * 
 * The propagation order is:
 * 1. Root entities (no Parent) are computed first from their local Transform
 * 2. Child entities are computed by combining their Transform with parent's GlobalTransform
 * 3. The propagation continues recursively through the hierarchy
 * 
 * Usage:
 * ```haxe
 * var world = new World();
 * var system = new TransformSystem();
 * 
 * // In your game loop:
 * system.update(world);
 * ```
 */
class TransformSystem {
    /** Temporary list for traversal order */
    private var traversalBuffer:Array<Int> = [];
    
    /** Cache for parent lookups */
    private var parentCache:Map<Int, Int> = new Map();
    /** Cache for children lookups */
    private var childrenCache:Map<Int, Array<Int>> = new Map();
    
    public function new() {}
    
    /**
     * Update all GlobalTransform components based on Transform components.
     * Call this once per frame, typically at the end of the frame after all
     * Transform modifications are complete.
     */
    public function update(world:World):Void {
        // Clear caches
        parentCache.clear();
        childrenCache.clear();
        
        // Build parent/children caches
        buildHierarchyCache(world);
        
        // Find root entities (entities with Transform but no Parent)
        var roots = findRoots(world);
        
        // Process each root hierarchy
        for (rootId in roots) {
            // If root has Transform, initialize its GlobalTransform
            var rootTransform = world.get(rootId, Transform);
            if (rootTransform != null) {
                var globalTransform = GlobalTransform.fromTransform(rootTransform);
                world.add(rootId, globalTransform);
                propagateToChildren(world, rootId, globalTransform);
            }
        }
        
        // Process orphaned entities (with Transform but no Parent, not roots)
        // These should exist at world origin
        processOrphans(world, roots);
    }
    
    /**
     * Build parent/children cache for efficient hierarchy traversal
     */
    private function buildHierarchyCache(world:World):Void {
        // Build parent cache
        for (entityWith in world.query2(Transform, Parent)) {
            parentCache.set(entityWith.entity.id, entityWith.c2.parentId);
        }
        
        // Build children cache
        for (entityWith in world.query(Children)) {
            childrenCache.set(entityWith.entity.id, entityWith.c1.children.copy());
        }
    }
    
    /**
     * Find entities that are roots of hierarchies
     * (entities with Transform but no Parent)
     */
    private function findRoots(world:World):Array<Int> {
        var roots:Array<Int> = [];
        var transformEntities = world.entitiesWith(Transform);
        var parentEntities = new Map<Int, Bool>();
        
        // Collect all entities that have a parent
        for (entityWith in world.query(Parent)) {
            parentEntities.set(entityWith.entity.id, true);
        }
        
        // Find entities with Transform but no Parent
        for (entityId in transformEntities) {
            if (!parentEntities.exists(entityId)) {
                roots.push(entityId);
            }
        }
        
        return roots;
    }
    
    /**
     * Recursively propagate transforms to children
     */
    private function propagateToChildren(world:World, entityId:Int, parentGlobal:GlobalTransform):Void {
        var children = childrenCache.get(entityId);
        if (children == null || children.length == 0) return;
        
        for (childId in children) {
            var childTransform = world.get(childId, Transform);
            if (childTransform != null) {
                // Combine parent's global transform with child's local transform
                var childGlobal = GlobalTransform.mul(parentGlobal, childTransform);
                world.add(childId, childGlobal);
                
                // Recursively propagate to this child's children
                propagateToChildren(world, childId, childGlobal);
            }
        }
    }
    
    /**
     * Process orphaned entities (with Transform but no valid parent chain)
     */
    private function processOrphans(world:World, roots:Array<Int>):Void {
        var rootSet = new Map<Int, Bool>();
        for (r in roots) rootSet.set(r, true);
        
        // Find all entities with Transform
        for (entityWith in world.query(Transform)) {
            var entityId = entityWith.entity.id;
            
            // Skip if already processed as root
            if (rootSet.exists(entityId)) continue;
            
            // Skip if already has GlobalTransform from propagation
            if (world.has(entityId, GlobalTransform)) continue;
            
            // Check if this entity has a valid parent
            var parentId = parentCache.get(entityId);
            if (parentId != null) {
                // Has parent - if parent's GlobalTransform exists, compute this one
                var parentGlobal = world.get(parentId, GlobalTransform);
                if (parentGlobal != null) {
                    var entityGlobal = GlobalTransform.mul(parentGlobal, entityWith.c1);
                    world.add(entityId, entityGlobal);
                    continue;
                }
            }
            
            // No valid parent - use identity as base
            var baseGlobal = GlobalTransform.identity();
            var entityGlobal = GlobalTransform.mul(baseGlobal, entityWith.c1);
            world.add(entityId, entityGlobal);
        }
    }
    
    /**
     * Mark a specific entity and all its descendants as needing update.
     * Call this when you modify a Transform to trigger recalculation.
     */
    public function markDirty(world:World, entityId:Int):Void {
        // For now, we mark change on the entity
        // The next update() call will propagate the changes
        world.markChanged(entityId, Transform);
        
        // Also mark all descendants dirty
        markDescendantsDirty(world, entityId);
    }
    
    /**
     * Mark all descendants of an entity as dirty
     */
    private function markDescendantsDirty(world:World, entityId:Int):Void {
        var children = childrenCache.get(entityId);
        if (children == null) return;
        
        for (childId in children) {
            world.markChanged(childId, Transform);
            markDescendantsDirty(world, childId);
        }
    }
    
    /**
     * Force update of a specific entity's GlobalTransform.
     * This is useful if you need immediate transform updates.
     */
    public function updateEntity(world:World, entityId:Int):Void {
        var transform = world.get(entityId, Transform);
        if (transform == null) return;
        
        var parentId = parentCache.get(entityId);
        var globalTransform:GlobalTransform;
        
        if (parentId != null) {
            // Has parent - compute from parent's global
            var parentGlobal = world.get(parentId, GlobalTransform);
            if (parentGlobal != null) {
                globalTransform = GlobalTransform.mul(parentGlobal, transform);
            } else {
                // Parent doesn't have global transform yet
                globalTransform = GlobalTransform.fromTransform(transform);
            }
        } else {
            // No parent - use transform directly
            globalTransform = GlobalTransform.fromTransform(transform);
        }
        
        world.add(entityId, globalTransform);
        
        // Propagate to children
        var children = childrenCache.get(entityId);
        if (children != null) {
            for (childId in children) {
                updateEntity(world, childId);
            }
        }
    }
    
    /**
     * Get the global transform of an entity, computing it if necessary.
     * This is useful for one-off queries.
     */
    public function getGlobalTransform(world:World, entityId:Int):GlobalTransform {
        // Check if we have it cached
        var cached = world.get(entityId, GlobalTransform);
        if (cached != null) return cached;
        
        // Compute from parent
        var transform = world.get(entityId, Transform);
        if (transform == null) {
            return GlobalTransform.identity();
        }
        
        var parentId = parentCache.get(entityId);
        var globalTransform:GlobalTransform;
        
        if (parentId != null) {
            var parentGlobal = getGlobalTransform(world, parentId);
            globalTransform = GlobalTransform.mul(parentGlobal, transform);
        } else {
            globalTransform = GlobalTransform.fromTransform(transform);
        }
        
        return globalTransform;
    }
}

/**
 * Helper class for building hierarchies programmatically.
 */
class TransformHierarchy {
    private var world:World;
    
    public function new(world:World) {
        this.world = world;
    }
    
    /**
     * Set the parent of a child entity.
     * Automatically manages the Children component on the parent.
     */
    public function setParent(child:Entity, parent:Entity):Void {
        var childId = child.id;
        var parentId = parent.id;
        
        // Remove from old parent if exists
        var oldParent = world.get(childId, Parent);
        if (oldParent != null) {
            var oldParentChildren = world.get(oldParent.parentId, Children);
            if (oldParentChildren != null) {
                oldParentChildren.remove(childId);
            }
        }
        
        // Set new parent
        world.add(childId, new Parent(parentId));
        
        // Add to new parent's children list
        var children = world.get(parentId, Children);
        if (children == null) {
            children = new Children([childId]);
            world.add(parentId, children);
        } else {
            children.add(childId);
        }
    }
    
    /**
     * Remove parent from an entity (make it a root)
     */
    public function removeParent(child:Entity):Void {
        var childId = child.id;
        var parentComponent = world.get(childId, Parent);
        
        if (parentComponent != null) {
            var parentId = parentComponent.parentId;
            var children = world.get(parentId, Children);
            if (children != null) {
                children.remove(childId);
            }
            world.remove(childId, Parent);
        }
    }
    
    /**
     * Spawn an entity with transform and optional parent
     */
    public function spawnWithTransform(?parent:Entity, ?transform:Transform):Entity {
        var entity = world.spawn();
        
        if (transform != null) {
            world.add(entity, transform);
        } else {
            world.add(entity, Transform.identity());
        }
        
        world.add(entity, GlobalTransform.identity());
        
        if (parent != null) {
            setParent(entity, parent);
        }
        
        return entity;
    }
    
    /**
     * Reparent an entity - change its parent while preserving world position
     */
    public function reparent(entity:Entity, newParent:Entity):Void {
        var entityId = entity.id;
        
        // Get current global transform before reparenting
        var system = new TransformSystem();
        var currentGlobal = system.getGlobalTransform(world, entityId);
        
        // Change parent
        setParent(entity, newParent);
        
        // Compute new local transform that preserves world position
        var newParentGlobal = system.getGlobalTransform(world, newParent.id);
        var newLocal = computeLocalFromGlobal(currentGlobal, newParentGlobal);
        
        // Update local transform
        var transform = world.get(entityId, Transform);
        if (transform != null) {
            world.add(entityId, newLocal);
        }
    }
    
    /**
     * Compute local transform from global transform and parent's global transform
     */
    private function computeLocalFromGlobal(global:GlobalTransform, parentGlobal:GlobalTransform):Transform {
        var parentInverse = parentGlobal.inverse();
        var localMatrix = Mat4.mul(parentInverse.matrix, global.matrix);
        return Transform.fromMatrix(localMatrix);
    }
    
    /**
     * Get all descendants of an entity (children, grandchildren, etc.)
     */
    public function getDescendants(entityId:Int):Array<Int> {
        var result:Array<Int> = [];
        collectDescendants(entityId, result);
        return result;
    }
    
    private function collectDescendants(entityId:Int, result:Array<Int>):Void {
        var children = world.get(entityId, Children);
        if (children == null) return;
        
        for (childId in children) {
            result.push(childId);
            collectDescendants(childId, result);
        }
    }
    
    /**
     * Get all ancestors of an entity (parent, grandparent, etc.)
     */
    public function getAncestors(entityId:Int):Array<Int> {
        var result:Array<Int> = [];
        var current = world.get(entityId, Parent);
        
        while (current != null) {
            result.push(current.parentId);
            current = world.get(current.parentId, Parent);
        }
        
        return result;
    }
}
