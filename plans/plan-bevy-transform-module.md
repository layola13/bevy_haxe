# bevy_transform Module Implementation Plan

## 1. Overview

Create a complete transform module for the Haxe Bevy port that mirrors the Rust `bevy_transform` crate. This module provides transform components for entities in a hierarchical scene graph.

**Goals:**
- Transform component with translation, rotation, scale
- GlobalTransform for world-space transforms
- Parent/Children components for hierarchy
- Transform propagation system

**Scope:**
- Transform.hx - Local transform component
- GlobalTransform.hx - Computed world transform
- Parent.hx - Parent entity reference
- Children.hx - Child entity list
- TransformSystem.hx - Transform propagation (existing)

## 2. Implementation Details

### 2.1 Transform.hx
Complete local transform with:
- `translation: Vec3` - Position (default: ZERO)
- `rotation: Quat` - Rotation (default: identity)
- `scale: Vec3` - Scale (default: ONE)

Static factories:
- `identity()` - Identity transform
- `fromTranslation()` - Translation only
- `fromRotation()` - Rotation only  
- `fromScale()` - Scale only
- `fromMatrix()` - From Mat4

Instance methods:
- `withTranslation()`, `withRotation()`, `withScale()` - Chainable setters
- `translate()`, `rotateBy()`, `scaleBy()` - Offset methods
- `mul()` - Transform composition
- `transformPoint()`, `transformVec3()` - Point/vector transformation
- `toMatrix()` - Convert to Mat4
- `lookAt()` - Look at target
- `backward()`, `forward()`, `left()`, `right()`, `up()`, `down()` - Directions
- `lerp()` - Interpolation
- `compute_transform()` - Alias for cloning

### 2.2 GlobalTransform.hx
Computed world-space transform:
- `matrix: Mat4` - 4x4 transformation matrix

Static factories:
- `identity()` - Identity
- `fromTransform()` - From local Transform
- `fromTRS()` - From translation, rotation, scale
- `fromTranslation()`, `fromRotation()`, `fromScale()`
- `fromMatrix()`

Instance methods:
- `mul()` - Transform composition
- `transformPoint()`, `transformVec3()` - Transform points
- `inverse()` - Inverse transformation
- `toMatrix()` - Get matrix
- `reparentedTo()` - Compute relative transform
- `translation`, `rotation`, `scale` - Decompose

### 2.3 Parent.hx
Parent component for hierarchy:
- `parentId: Int` - Parent entity ID

Methods:
- `parent()` - Get as Entity
- `of()` - Create from Entity

### 2.4 Children.hx
Children component for hierarchy:
- `children: Array<Int>` - List of child IDs

Methods:
- `length`, `hasChildren` - Queries
- `add()`, `remove()`, `has()` - Manipulation
- `iterator()`, `get()` - Access
- `clear()`, `set()` - Bulk operations

## 3. Files Status

### Files in `/home/vscode/projects/bevy_haxe/src/haxe/transform/`
All required files already exist and are complete:

| File | Status | Description |
|------|--------|-------------|
| Transform.hx | ✅ Complete | Local transform with all required methods |
| GlobalTransform.hx | ✅ Complete | World-space transform |
| Parent.hx | ✅ Complete | Parent entity reference |
| Children.hx | ✅ Complete | Children list management |
| TransformSystem.hx | ✅ Complete | Transform propagation system |

## 4. Dependencies

Required Haxe modules (already exist):
- `haxe.math.Vec3`
- `haxe.math.Quat`
- `haxe.math.Mat4`
- `haxe.math.Vec4`
- `haxe.ecs.Component`
- `haxe.ecs.Entity`

## 5. Testing Strategy

Manual verification:
- Compile check with `haxe project.hxml`
- Verify all methods are accessible
- Test transform composition
- Test hierarchy propagation

## 6. Effort Estimate

**Complexity:** Medium  
**Time:** Already implemented

## 7. Next Steps

1. Verify compilation with `haxe project.hxml`
2. Add unit tests for Transform operations
3. Add examples demonstrating hierarchy usage
