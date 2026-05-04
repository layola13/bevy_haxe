# Implementation Plan: Bevy Math Module Enhancement

## 1. Overview

Improve the `bevy_haxe` math module to more closely match the Rust `bevy_math` crate functionality. This includes enhancing existing vector/matrix types, adding quaternion operations, and implementing primitives/direction types.

**Goals:**
- Enhance Vec2.hx with more utility methods (swizzle, angle, project/reject, etc.)
- Add cross product and more methods to Vec3.hx
- Complete Vec4.hx implementation
- Add Mat4.hx methods (determinant, inverse, transpose)
- Improve Quat.hx with more quaternion operations
- Enhance Direction.hx (Dir2, Dir3)
- Complete Primitives.hx with additional types

**Success Criteria:**
- All types compile without errors
- API is consistent with Bevy where possible
- Using @:structInit for simplified construction

## 2. Prerequisites

- Haxe 4.x with hxcpp target
- Working project structure in `/home/vscode/projects/bevy_haxe`
- Current types in `src/haxe/math/` directory

## 3. Implementation Steps

### Step 1: Enhance Vec2.hx
**Files to modify:** `/home/vscode/projects/bevy_haxe/src/haxe/math/Vec2.hx`

Add methods:
- `NEG_X`, `NEG_Y` static constants
- `lengthSquared()` (already exists)
- `isNormalized()` check
- `isFinite()`, `isNan()` checks
- `angle(other:Vec2):Float` - angle between vectors
- `angleSigned(other:Vec2):Float` - signed angle
- `project(v:Vec2):Vec2` - project onto v
- `reject(v:Vec2):Vec2` - reject from v
- `reflect(normal:Vec2):Vec2` - reflect off normal
- `abs():Vec2` - absolute value
- `floor()`, `round()`, `ceil()` (already exists in Vec3, add here)
- Swizzle: `xx`, `yx`, `yy` (basic)
- `dot()` (already exists)
- `min()`, `max()` (already exists in Vec3)
- `clamp()` (already exists in Vec3)

### Step 2: Enhance Vec3.hx
**Files to modify:** `/home/vscode/projects/bevy_haxe/src/haxe/math/Vec3.hx`

Add methods:
- `NEG_X`, `NEG_Y`, `NEG_Z` static constants
- `cross(other:Vec3):Vec3` - CRITICAL - missing!
- `isNormalized()` check
- `isFinite()`, `isNan()` checks
- `project(v:Vec3):Vec3` - project onto v
- `reject(v:Vec3):Vec3` - reject from v
- `reflect(normal:Vec3):Vec3` - reflect off normal
- `abs():Vec3` - absolute value
- Swizzle methods
- `anyOrthogonal():Vec3` - returns any vector orthogonal to self

### Step 3: Complete Vec4.hx
**Files to modify:** `/home/vscode/projects/bevy_haxe/src/haxe/math/Vec4.hx`

Add methods:
- `NEG_X`, `NEG_Y`, `NEG_Z`, `NEG_W` static constants
- `X`, `Y`, `Z`, `W` axes
- `lengthSquared():Float`
- `isNormalized():Bool`
- `isFinite():Bool`, `isNan():Bool`
- `cross(other:Vec4, other2:Vec4):Vec4` - 4D cross product
- `project(v:Vec4):Vec4`
- `abs():Vec4`
- Swizzle methods

### Step 4: Enhance Mat4.hx
**Files to modify:** `/home/vscode/projects/bevy_haxe/src/haxe/math/Mat4.hx`

Add methods:
- `determinant():Float`
- `inverse():Mat4` (or inverse_unsafe)
- `transpose():Mat4`
- `trace():Float`
- `mulVec3(v:Vec3):Vec3` - transform point
- `mulVec3Dir(v:Vec3):Vec3` - transform direction (no translation)
- `transformPoint3(v:Vec3):Vec3`
- `transformVec3(v:Vec3):Vec3`
- `transformVec3Dir(v:Vec3):Vec3`
- Add column accessors

### Step 5: Improve Quat.hx
**Files to modify:** `/home/vscode/projects/bevy_haxe/src/haxe/math/Quat.hx`

Add methods:
- `inverse():Quat`
- `dot(other:Quat):Float`
- `mulVec3(v:Vec3):Vec3` - rotate vector
- `mulDir3(v:Vec3):Vec3` - rotate direction (no translation)
- `lengthSquared():Float`
- `isNormalized():Bool`
- `angle():Float` - rotation angle
- `axis():Vec3` - rotation axis
- `fromEuler(x:Float, y:Float, z:Float):Quat`
- `toEuler():{x:Float, y:Float, z:Float}`
- `slerp(to:Quat, t:Float):Quat`
- `identity()` static method (already exists)
- Look rotation: `fromTo(from:Vec3, to:Vec3):Quat`
- `lerp()`, `nlerp()` (normalize lerp)

### Step 6: Enhance Direction.hx
**Files to modify:** `/home/vscode/projects/bevy_haxe/src/haxe/math/Direction.hx`

Add:
- `Dir2` type (2D direction)
- Better error handling with `Result<Dir3, InvalidDirectionError>`
- `isNormalized()` method
- `renormalize()` - recalculate normalized value
- Swizzle methods

### Step 7: Complete Primitives.hx
**Files to modify:** `/home/vscode/projects/bevy_haxe/src/haxe/math/Primitives.hx`

Add types:
- `Rect` - move from Rect.hx (x, y, width, height)
- `Circle` - 2D circle (radius)
- `Sphere` - 3D sphere (radius)
- `Capsule` - capsule shape
- `Plane` - infinite plane (normal, dist)
- `Cuboid` / `Box3` - 3D box (half_size)
- `Segment2d` - 2D line segment
- `Segment3d` - 3D line segment

Add methods for each:
- `volume()`, `area()`, `surfaceArea()`
- `closestPoint()`
- `BoundingVolume` traits

### Step 8: Create BoundingBox.hx
**Files to create:** `/home/vscode/projects/bevy_haxe/src/haxe/math/BoundingBox.hx`

Types:
- `Aabb2d` - 2D axis-aligned bounding box (min, max)
- `Aabb3d` - 3D axis-aligned bounding box (min, max)
- `BoundingSphere` - sphere for bounding (center, radius)

Methods:
- `contains()`, `intersects()`
- `merge()`, `intersect()`
- `center()`, `halfSize()`
- `visibleArea()`
- `transform()`

### Step 9: Create Math Prelude
**Files to create:** `/home/vscode/projects/bevy_haxe/src/haxe/math/prelude/MathModule.hx`

Re-export all math types for convenience.

## 4. File Changes Summary

### Modified Files:
- `src/haxe/math/Vec2.hx` - add missing methods
- `src/haxe/math/Vec3.hx` - add cross product, missing methods
- `src/haxe/math/Vec4.hx` - complete implementation
- `src/haxe/math/Mat4.hx` - add determinant, inverse, transpose
- `src/haxe/math/Quat.hx` - add quaternion operations
- `src/haxe/math/Direction.hx` - add Dir2, improve error handling
- `src/haxe/math/Primitives.hx` - complete primitives

### New Files:
- `src/haxe/math/BoundingBox.hx` - Aabb2d, Aabb3d, BoundingSphere
- `src/haxe/math/prelude/MathModule.hx` - re-exports

## 5. Testing Strategy

- Write Haxe test file in `/home/vscode/projects/bevy_haxe/test/math/`
- Test each new method with known expected values
- Test edge cases (zero vectors, identity quaternions, etc.)
- Verify compilation with `haxe build.hxml`

## 6. Rollback Plan

- All changes are additive improvements
- No database migrations required
- If issues arise, revert to previous file versions from git
- Original files can be restored from version control

## 7. Estimated Effort

**Complexity:** Medium
**Estimated Time:** 4-6 hours

Individual file estimates:
- Vec2.hx: 30 minutes
- Vec3.hx: 45 minutes
- Vec4.hx: 45 minutes
- Mat4.hx: 1 hour
- Quat.hx: 1.5 hours
- Direction.hx: 30 minutes
- Primitives.hx: 1 hour
- BoundingBox.hx: 1 hour
- Testing: 1 hour
