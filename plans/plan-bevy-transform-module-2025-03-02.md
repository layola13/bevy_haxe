# bevy_transform Module Implementation Plan

## 1. Overview

Complete the `bevy_transform` module in the Haxe bevy port, following the Rust `bevy_transform` crate as reference. The module provides position, rotation, and scale transformations for entities with automatic world-space transform computation through a hierarchy system.

### Goals
- Transform component with translation, rotation, scale
- GlobalTransform for computed world-space transforms
- Parent/Children hierarchy for transform propagation
- Automatic GlobalTransform updates when Transform changes
- Efficient transform propagation through entity hierarchies

### Scope
**Included:**
- Transform component (local transform)
- GlobalTransform component (world-space transform)
- Parent component (parent entity reference)
- Children component (list of child entities)
- ChildOf component (alternative relationship marker)
- TransformSystem for transform propagation
- TransformHelper for on-demand transform computation
- TransformPlugin for system registration
- TransformBundle for common component combinations

**Excluded:**
- Direct Rust FFI bindings
- Serialization/deserialization (planned separately)
- Reflect system integration (planned separately)

---

## 2. Prerequisites

### Dependencies
- `haxe.math.Vec3` - 3D vector
- `haxe.math.Quat` - Quaternion rotation
- `haxe.math.Mat4` - 4x4 transformation matrix
- `haxe.ecs.Component` - Base component interface
- `haxe.ecs.World` - Entity world
- `haxe.ecs.Entity` - Entity identifier
- `haxe.ecs.Query` - Component query system

### File Structure
```
src/haxe/transform/
├── Transform.hx          # Local transform component
├── GlobalTransform.hx    # World-space transform
├── Parent.hx             # Parent entity component
├── Children.hx          # Children list component
├── ChildOf.hx            # Child relationship marker (new)
├── TransformSystem.hx    # Transform propagation system
├── TransformHelper.hx    # On-demand transform helper (new)
├── TransformPlugin.hx    # Plugin for system registration (new)
├── TransformBundle.hx    # Common component bundle (new)
└── prelude/             # Transform prelude exports
```

---

## 3. Implementation Steps

### Step 1: Create ChildOf.hx
**File:** `src/haxe/transform/ChildOf.hx`

Create the ChildOf component, which is Rust's primary parent-child relationship marker.

**Key features:**
- Single `parentId:Int` field
- Implements `haxe.ecs.Component`
- Static factory method from Entity
- Comparable to Rust's `ChildOf` relationship component

### Step 2: Update Transform.hx
**File:** `src/haxe/transform/Transform.hx`

Enhance existing Transform component with additional utility methods.

**Changes:**
- Add `lookAt(target, up)` method
- Add `transformPoint(point)` method
- Add `mul` operator for Transform composition
- Add `reparentedTo` method for relative transforms
- Add `toMatrix4x4` alias for consistency
- Add documentation improvements

### Step 3: Update GlobalTransform.hx
**File:** `src/haxe/transform/GlobalTransform.hx`

Enhance with additional computation methods.

**Changes:**
- Add `transformPoint(point:Vec3):Vec3` method
- Add `lookAt(eye, target, up)` static method
- Add `right()`, `up()`, `forward()` direction methods
- Add `isIdentity()` check
- Add `readMatrix()` for raw matrix access
- Improve documentation

### Step 4: Update Parent.hx
**File:** `src/haxe/transform/Parent.hx`

Minor enhancements to existing Parent component.

**Changes:**
- Add `equals(other:Parent):Bool` method
- Improve hashCode for Map usage
- Add documentation for hierarchy usage

### Step 5: Update Children.hx
**File:** `src/haxe/transform/Children.hx`

Minor enhancements to existing Children component.

**Changes:**
- Add `equals(other:Children):Bool` method
- Add `indexOf(childId:Int):Int` method
- Improve documentation

### Step 6: Create TransformHelper.hx
**File:** `src/haxe/transform/TransformHelper.hx`

Create helper class for on-demand global transform computation.

**Key features:**
- `computeGlobalTransform(entityId:Int, world:World):GlobalTransform`
- Handles hierarchy traversal
- Returns computed result or throws error
- Used for late-frame transform queries

### Step 7: Update TransformSystem.hx
**File:** `src/haxe/transform/TransformSystem.hx`

Complete rewrite with improved transform propagation.

**Key features:**
- Change detection using `changedEntities` set
- Efficient hierarchy traversal
- Support for both Parent and ChildOf relationships
- Batch processing for performance
- Clear separation of concerns

**Methods:**
- `update(world:World)` - Main system update
- `propagateTransforms(world:World)` - Core propagation
- `markDirtyTrees(world:World)` - Mark affected hierarchies
- `syncSimpleTransforms(world:World)` - Sync orphaned transforms
- `computeGlobalTransform(entityId:Int, world:World):GlobalTransform`

### Step 8: Create TransformPlugin.hx
**File:** `src/haxe/transform/TransformPlugin.hx`

Create plugin to register transform systems with App.

**Key features:**
- Implements `haxe.app.Plugin` interface
- Registers `TransformSystem` with schedule
- Adds to PostStartup and PostUpdate schedules
- Automatic GlobalTransform initialization

### Step 9: Create TransformBundle.hx
**File:** `src/haxe/transform/TransformBundle.hx`

Create bundle for common component combinations.

**Bundles:**
- `TransformBundle` - Transform + GlobalTransform
- `TransformAndParentBundle` - Transform + GlobalTransform + Parent
- `HierarchyBundle` - Transform + GlobalTransform + Parent + Children

### Step 10: Create TransformPrelude.hx
**File:** `src/haxe/transform/prelude/TransformPrelude.hx`

Create prelude for convenient imports.

**Exports:**
- Transform, GlobalTransform, Parent, Children, ChildOf
- TransformSystem, TransformPlugin, TransformHelper
- TransformBundle variants
- Static helper methods

---

## 4. File Changes Summary

### Created Files (New)
| File | Description |
|------|-------------|
| `src/haxe/transform/ChildOf.hx` | Child relationship marker component |
| `src/haxe/transform/TransformHelper.hx` | On-demand transform computation helper |
| `src/haxe/transform/TransformPlugin.hx` | Plugin for system registration |
| `src/haxe/transform/TransformBundle.hx` | Common component bundles |
| `src/haxe/transform/prelude/TransformPrelude.hx` | Prelude exports |

### Modified Files (Existing)
| File | Changes |
|------|---------|
| `src/haxe/transform/Transform.hx` | Add utility methods, improve API |
| `src/haxe/transform/GlobalTransform.hx` | Add direction methods, improve computation |
| `src/haxe/transform/Parent.hx` | Minor enhancements |
| `src/haxe/transform/Children.hx` | Minor enhancements |
| `src/haxe/transform/TransformSystem.hx` | Complete rewrite with better propagation |

### Deleted Files
None

---

## 5. Testing Strategy

### Unit Tests
1. **Transform Tests**
   - Identity transform creation
   - Transform composition (mul)
   - Point transformation
   - From/To matrix conversion

2. **GlobalTransform Tests**
   - Identity transform
   - Transform from Transform component
   - Matrix multiplication order
   - Point transformation
   - Direction extraction (forward, up, right)

3. **Hierarchy Tests**
   - Parent/Children relationship
   - Transform propagation through hierarchy
   - Nested hierarchy computation
   - Root entity handling

4. **TransformSystem Tests**
   - Dirty tree marking
   - Simple transform sync
   - Full hierarchy propagation
   - Multiple root handling

### Integration Tests
1. Create parent-child hierarchy with transforms
2. Verify GlobalTransform matches expected world position
3. Modify child transform, verify propagation
4. Reparent entity, verify correct update

### Manual Testing Steps
1. Run existing examples to verify no regressions
2. Create test scene with nested transforms
3. Verify visual positions match computed transforms

---

## 6. Rollback Plan

### Reverting Changes
If issues arise, rollback by:
1. Restore original file versions from git
2. Revert any new files in `src/haxe/transform/`

### Data Migration
No persistent data migration needed - all transforms are computed at runtime.

### Recovery Steps
```bash
git checkout src/haxe/transform/
```

---

## 7. Estimated Effort

### Time Estimate
- **ChildOf.hx**: 15 minutes
- **Transform enhancements**: 30 minutes
- **GlobalTransform enhancements**: 30 minutes
- **TransformHelper.hx**: 20 minutes
- **TransformSystem rewrite**: 45 minutes
- **TransformPlugin.hx**: 15 minutes
- **TransformBundle.hx**: 15 minutes
- **TransformPrelude.hx**: 10 minutes
- **Testing**: 30 minutes

**Total**: ~3.5 hours

### Complexity Assessment
**Medium** - Transform systems are well-understood patterns with clear Rust reference implementation. The main challenge is Haxe syntax limitations and ensuring proper change detection integration.

---

## 8. Implementation Notes

### Transform Composition
In Bevy (and this Haxe port), transforms compose from right to left:
```haxe
// t1 * t2 means: apply t2 first, then t1
var worldTransform = parentTransform * childTransform;
```

### Change Detection
The system uses a `changedEntities` set to track which transforms have been modified since the last update. This allows efficient propagation - only affected subtrees need recalculation.

### Hierarchy Performance
- Parent lookups: O(1) using map cache
- Children lookups: O(1) using map cache  
- Transform propagation: O(n) where n = entities with changed transforms

### Thread Safety Considerations
This implementation is single-threaded. For multi-threaded support, additional synchronization would be needed (planned for future).
