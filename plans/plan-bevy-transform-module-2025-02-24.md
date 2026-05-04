# Bevy Transform Module Implementation Plan

## 1. Overview

This plan covers the完善 (completion/enhancement) of the `bevy_transform` module in the Haxe Bevy port. The goal is to fully implement transform components and systems that mirror the functionality of the Rust `bevy_transform` crate.

**Goals:**
- Implement `Transform` for local-space position, rotation, and scale
- Implement `GlobalTransform` for computed world-space transforms
- Implement `Parent`/`ChildOf` for hierarchy relationships
- Implement `Children` for efficient child enumeration
- Implement `TransformSystem` for automatic GlobalTransform propagation
- Add `TransformHelper` for on-demand transform computation
- Add `TransformPlugin` for system registration

**Success Criteria:**
- All transform components correctly store and compute transformations
- Parent-child hierarchy correctly propagates transforms
- GlobalTransform is automatically updated when Transform changes
- The module works seamlessly with the existing ECS

## 2. Prerequisites

- Haxe 4.x with haxe.ecs module already implemented
- haxe.math module with Vec3, Quat, Mat4 already implemented
- Understanding of ECS pattern (Components, Entities, World)

## 3. Implementation Steps

### Step 1: Create ChildOf.hx (New File)
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/transform/ChildOf.hx`

The `ChildOf` relationship component is the primary way to establish parent-child relationships in Bevy. It mirrors Rust's `ChildOf` implementation.

Key features:
- Stores reference to parent entity
- Works with Children component for bi-directional hierarchy
- Auto-updates parent's Children component when inserted/removed

### Step 2: Update Parent.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/transform/Parent.hx`

Enhance the existing Parent component:
- Add `transform` field for accessing the parent's transform conveniently
- Add static factory method `of(entity:Entity)`
- Add `equals(other:Parent)` comparison method

### Step 3: Update Children.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/transform/Children.hx`

Enhance the Children component:
- Add `numChildren` property
- Add `getChild(index:Int):Int` method
- Add `contains(childId:Int):Bool` method
- Add `indexOf(childId:Int):Int` method
- Add `push(child:Entity):Void` convenience method

### Step 4: Update Transform.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/transform/Transform.hx`

Enhance the Transform component:
- Add `lookAt(target:Vec3, ?up:Vec3):Transform` method
- Add `forward:Vec3` computed property
- Add `right:Vec3` computed property  
- Add `up:Vec3` computed property
- Add `backward:Vec3` computed property
- Add `transformVector(vec:Vec3):Vec3` method
- Add multiplication operators with GlobalTransform

### Step 5: Update GlobalTransform.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/transform/GlobalTransform.hx`

Enhance GlobalTransform:
- Add `translation:Vec3` property
- Add `rotation:Quat` property
- Add `scale:Vec3` property
- Add `forward:Vec3` computed property
- Add `right:Vec3` computed property
- Add `up:Vec3` computed property
- Add `transformPoint(point:Vec3):Vec3` method
- Add `transformVector(vec:Vec3):Vec3` method
- Add `inverse():GlobalTransform` method
- Add `reparentedTo(parent:GlobalTransform):Transform` method
- Add multiplication operators

### Step 6: Create TransformHelper.hx (New File)
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/transform/TransformHelper.hx`

Create a helper class for on-demand transform computation:
- `computeGlobalTransform(entity:Entity, world:World):GlobalTransform`
- Walks up the hierarchy computing world-space transform
- Used when you need immediate transform values before the system runs

### Step 7: Update TransformSystem.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/transform/TransformSystem.hx`

Complete rewrite with:
- Change detection integration
- Proper hierarchy traversal
- `markDirty(entityId:Int)` for manual dirty marking
- `propagateTransform(entityId:Int, parentGlobal:GlobalTransform)` method
- Integration with `TransformTreeChanged` marker

### Step 8: Create TransformPlugin.hx (New File)
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/transform/TransformPlugin.hx`

Create the plugin for automatic system registration:
- `TransformSystems` enum with `Propagate` system set
- `TransformPlugin` class implementing `Plugin` interface
- Auto-registers `TransformSystem` in PostUpdate schedule
- Initializes `StaticTransformOptimizations` resource

### Step 9: Create TransformPrelude.hx (New File)
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/transform/TransformPrelude.hx`

Create a prelude with commonly used types:
- `Transform`
- `GlobalTransform`
- `Parent`
- `Children`
- `ChildOf`
- `TransformSystem`
- `TransformPlugin`
- `TransformHelper`
- `TransformSystems`

### Step 10: Update TransformSystem with StaticTransformOptimizations
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/transform/TransformSystem.hx`

Add static transform optimization support:
- `StaticTransformOptimizations` resource class
- Cache for entities with fixed transforms
- Skip unnecessary propagation for static entities

## 4. File Changes Summary

### Created Files:
1. `src/haxe/transform/ChildOf.hx` - ChildOf relationship component
2. `src/haxe/transform/TransformHelper.hx` - Transform computation helper
3. `src/haxe/transform/TransformPlugin.hx` - Plugin for system registration
4. `src/haxe/transform/TransformPrelude.hx` - Type re-exports

### Modified Files:
1. `src/haxe/transform/Transform.hx` - Enhanced with lookAt, direction vectors, operators
2. `src/haxe/transform/GlobalTransform.hx` - Enhanced with properties and methods
3. `src/haxe/transform/Parent.hx` - Enhanced with additional methods
4. `src/haxe/transform/Children.hx` - Enhanced with additional methods
5. `src/haxe/transform/TransformSystem.hx` - Complete rewrite with full functionality

### Deleted Files:
None

## 5. Testing Strategy

### Unit Tests:
1. **Transform Tests:**
   - Test identity creation
   - Test translation/rotation/scale creation
   - Test lookAt method
   - Test direction vectors (forward, right, up, backward)
   - Test transform multiplication

2. **GlobalTransform Tests:**
   - Test creation from Transform
   - Test matrix operations
   - Test transform point
   - Test inverse computation
   - Test reparented transform calculation

3. **Hierarchy Tests:**
   - Test parent-child relationship creation
   - Test Children component management
   - Test transform propagation through hierarchy

4. **TransformSystem Tests:**
   - Test single entity transform propagation
   - Test multi-level hierarchy propagation
   - Test transform change detection

### Manual Testing:
1. Create entity with Transform, verify GlobalTransform auto-created
2. Set parent-child relationship, verify propagation
3. Modify Transform, verify GlobalTransform updates
4. Test performance with large hierarchies

## 6. Rollback Plan

If issues arise:
1. Keep backups of original files before modification
2. Each step can be reverted independently
3. The module can fall back to basic Transform/GlobalTransform only

## 7. Estimated Effort

- **Complexity:** Medium-High
- **Time Estimate:** 4-6 hours
- **Lines of Code:** ~1500 new/modified lines
- **Risk Level:** Medium (depends on ECS and Math module stability)

## 8. Implementation Notes

### Transform Composition Order:
In Bevy, transforms compose from right to left:
- `parentGlobal * childTransform` means apply child transform first, then parent
- This matches standard 3D graphics convention

### Hierarchy Implementation:
The implementation uses:
- `Parent.parentId` for upward reference
- `Children.children:Array<Int>` for downward references
- `ChildOf` as an alternative relationship marker

### Change Detection:
TransformSystem tracks which entities have changed Transform since last update to minimize unnecessary GlobalTransform recalculation.
