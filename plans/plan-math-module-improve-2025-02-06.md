# Bevy Math Module Improvement Plan

## Overview

This plan improves the bevy_math Haxe implementation to match the Rust bevy_math crate. The goal is to add missing methods, improve type safety, and ensure API consistency with the original Bevy engine.

## Current State Analysis

- **Vec2.hx**: Basic implementation with vector operations, needs min/max/clamp methods
- **Vec3.hx**: Missing cross product method, needs swizzle operations
- **Vec4.hx**: Basic implementation, needs more operations
- **Mat4.hx**: Missing determinant, inverse, transpose methods
- **Quat.hx**: Basic quaternion, needs Euler angles, to/from matrix, inverse
- **Direction.hx**: Partial Dir3 implementation, needs Dir2 and better validation
- **Primitives.hx**: Circle, Sphere, Capsule, Plane present; needs Cuboid, Line, Segment, Triangle, Plane improvements
- **Rect.hx**: Separate file, should be merged into Primitives

## Implementation Steps

### Step 1: Enhance Vec2.hx
Add missing methods from Rust Vec2:
- `NEG_X`, `NEG_Y` static constants
- `angle()` - angle from x-axis
- `angleTo()` - angle to another vector
- `isNormalized()` check
- `abs()` - component-wise absolute value
- `ceil()`, `floor()`, `round()`
- `min()`, `max()`, `clamp()`
- `project()` - project onto another vector
- `reflect()` - reflect off a normal
- `try_normalize()` - nullable normalize
- Swizzle operations: `xx`, `yx`, `yy`

### Step 2: Enhance Vec3.hx
Add missing methods:
- `NEG_X`, `NEG_Y`, `NEG_Z` static constants
- `cross()` - cross product (currently missing!)
- `isNormalized()` check
- `abs()` - component-wise absolute value
- `ceil()`, `floor()`, `round()`
- `min()`, `max()`, `clamp()`
- `any()`, `all()` (for boolean checks)
- Swizzle operations: `xx`, `xy`, `xz`, `yx`, `yy`, `yz`, `zx`, `zy`, `zz`, `xxx`, `yyy`, `zzz`, `xxy`, etc.
- `try_normalize()` - nullable normalize

### Step 3: Enhance Vec4.hx
Add missing methods:
- `NEG_X`, `NEG_Y`, `NEG_Z`, `NEG_W` static constants
- `lengthSquared()` method
- `isNormalized()` check
- `abs()` - component-wise absolute value
- Swizzle operations: `xxx`, `yyy`, `zzz`, `www`, `xyzw`, etc.
- `try_normalize()` - nullable normalize

### Step 4: Enhance Mat4.hx
Add missing methods:
- `determinant()` - compute matrix determinant
- `inverse()` - compute matrix inverse (or tryInverse for nullable)
- `transpose()` - transpose the matrix
- `toNormalMatrix()` - extract 3x3 normal matrix
- `transform_point3()` - point transformation with perspective divide
- `transform_vector3()` - vector transformation (no translation)
- `mul_vec3()` - multiply by Vec3
- `right()`, `up()`, `forward()`, `left()`, `down()`, `back()` - axis getters

### Step 5: Improve Quat.hx
Add missing quaternion operations:
- `inverse()` - quaternion inverse
- `dot()` - dot product with another quaternion
- `angle_between()` - angle between quaternions
- `to_matrix()` - convert to rotation matrix (Mat3)
- `from_matrix()` - create from rotation matrix
- `from_euler()` - create from Euler angles
- `to_euler()` - extract Euler angles
- `lerp()`, `slerp()` - interpolation
- `mul_vec3()` - rotate a vector
- `isNormalized()` check
- `lengthSquared()` method
- Error handling for invalid quaternions

### Step 6: Enhance Direction.hx (Dir3)
Improve Dir3:
- Add proper error handling with `InvalidDirectionError`
- Add `new()` static method with error checking
- Add `new_and_length()` method
- Add `fast_renormalize()` for performance-critical use
- Add `is_normalized()` check
- Add `to_angle()` and `to_radians()` for 2D direction support
- Add NEG_X, NEG_Y, NEG_Z constants
- Add Dir2 for 2D directions

### Step 7: Improve Primitives.hx
Add missing primitives:
- **Cuboid** - axis-aligned box with min/max
- **Line2d**, **Line3d** - infinite lines
- **Segment2d**, **Segment3d** - line segments
- **Triangle2d**, **Triangle3d** - triangles
- **Plane3d** improvements - more construction methods
- **Disk** - 2D filled circle
- **Annulus** - ring shape

### Step 8: Add BoundingBox.hx
Add 3D bounding volumes:
- **Aabb3d** - Axis-Aligned Bounding Box 3D
  - `min`, `max` Vec3 properties
  - `center()` - geometric center
  - `size()` - full size
  - `half_size()` - half extents
  - `contains()` - check if contains another AABB
  - `merge()` - combine two AABBs
  - `intersects()` - check intersection
  - `closest_point()` - closest point to a point
- **BoundingSphere** - sphere for bounding
  - `center`, `radius` properties
  - Same operations as Aabb3d

### Step 9: Create Math Prelude
Create `prelude/MathModule.hx` that exports all math types for easy importing.

## File Changes Summary

### Modified Files
1. `src/haxe/math/Vec2.hx` - Add missing vector methods
2. `src/haxe/math/Vec3.hx` - Add cross product and swizzle
3. `src/haxe/math/Vec4.hx` - Add missing methods and swizzle
4. `src/haxe/math/Mat4.hx` - Add determinant, inverse, transpose
5. `src/haxe/math/Quat.hx` - Add quaternion operations
6. `src/haxe/math/Direction.hx` - Improve Dir3, add Dir2
7. `src/haxe/math/Primitives.hx` - Add more primitives
8. `src/haxe/math/Rect.hx` - Will be superseded by Primitives

### New Files
1. `src/haxe/math/BoundingBox.hx` - Aabb3d, BoundingSphere
2. `src/haxe/math/prelude/MathModule.hx` - Math prelude exports

## Testing Strategy

1. Create `test/MathTest.hx` with test cases for:
   - Vector operations (add, sub, scale, normalize)
   - Matrix multiplication
   - Quaternion rotations
   - Direction validation
   - Primitive intersections
   - Bounding box operations

2. Run tests with: `haxe test.hxml`

## Rollback Plan

All changes are additive and non-breaking:
- Backup existing files before modification
- Use git for version control
- Changes preserve existing API signatures

## Estimated Effort

- **Time**: ~4-6 hours
- **Complexity**: Medium
- **Risk**: Low - all changes are additive improvements

## References

Rust source files:
- `/home/vscode/projects/bevy/crates/bevy_math/src/`
- Vec2/Vec3/Vec4 are in glam crate (re-exported by bevy_math)
- Mat4 methods in glam::Mat4
- Quat methods in glam::Quat
