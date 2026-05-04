# Bevy Math Module Improvement Plan

## 1. Overview

This plan covers improving the `bevy_math` module for the Haxe Bevy port, adding missing methods and types to match the Rust `bevy_math` crate functionality.

### Goals
- Add missing methods to Vec2, Vec3, Vec4
- Complete Mat4 with determinant, inverse, transpose methods
- Enhance Quat with more quaternion operations
- Improve Direction.hx (Dir3 type)
- Enhance Primitives.hx with more primitives
- Add BoundingBox types (Aabb3d, BoundingSphere)

### Success Criteria
- All types use `@:structInit` where appropriate
- API remains consistent with Bevy Rust API
- All new methods have proper Haxe implementations

## 2. Implementation Steps

### Step 1: Enhance Vec2.hx
- Add `lengthSquared` property if missing
- Add `normalize` safety check
- Add `perpendicular` method
- Add `reflect` method
- Add `abs` and `sign` methods
- Add `clampLength` method
- Add `lerp` safety check

### Step 2: Enhance Vec3.hx
- Add `cross` product (currently missing)
- Add `reflect` method
- Add `abs` and `sign` methods
- Add `clampLength` method
- Add `projectOnto` method
- Add `tryNormalize` method
- Add `isNormalized` check

### Step 3: Enhance Vec4.hx
- Add `lengthSquared` property
- Add `normalize` safety check  
- Add `lerp` safety check
- Add `dot` method (currently missing element-wise)
- Add `projectOnto` method
- Add `w` axis constant
- Add `xAxis`, `yAxis`, `zAxis` constants

### Step 4: Complete Mat4.hx
- Add `determinant` method
- Add `inverse` method
- Add `transpose` method
- Add `trace` method
- Add `transformPoint3` method
- Add `transformVec3` method
- Add `transformPoint2` with w-divide
- Add `transformVec2` (no w-divide)

### Step 5: Improve Quat.hx
- Add `inverse` method
- Add `dot` (dot product)
- Add `angleTo` (angle between quaternions)
- Add `x`, `y`, `z`, `w` axis constants
- Add `fromEuler` method
- Add `mulVec3` rotation method
- Add `lerp` and `slerp` methods
- Add `identity` as static constant

### Step 6: Improve Direction.hx
- Add `NEG_X`, `NEG_Y`, `NEG_Z` constants
- Add `isNormalized` check
- Add `cosAngleTo` method
- Add `anyOrthogonal` method
- Add `newAndLength` factory method
- Add `asVec4` method (w=0 for directions)

### Step 7: Enhance Primitives.hx
- Add `Cuboid` (axis-aligned box)
- Add `Segment2d` and `Segment3d`
- Add `Line2d` and `Line3d`
- Add `Triangle2d` and `Triangle3d`
- Enhance `Plane` with more methods

### Step 8: Add BoundingBox.hx
- Add `Aabb3d` (axis-aligned bounding box 3D)
- Add `BoundingSphere`
- Add `IntersectsVolume` trait/interface
- Add `Bounded3d` interface

### Step 9: Create prelude export
- Create `haxe/math/prelude/MathModule.hx` to export all math types

## 3. File Changes Summary

### Modified Files
- `src/haxe/math/Vec2.hx` - Add missing methods
- `src/haxe/math/Vec3.hx` - Add cross product and methods
- `src/haxe/math/Vec4.hx` - Complete implementation
- `src/haxe/math/Mat4.hx` - Add determinant, inverse, transpose
- `src/haxe/math/Quat.hx` - Add more quaternion operations
- `src/haxe/math/Direction.hx` - Improve Dir3 type
- `src/haxe/math/Primitives.hx` - Add more primitives

### New Files
- `src/haxe/math/BoundingBox.hx` - Aabb3d, BoundingSphere
- `src/haxe/math/prelude/MathModule.hx` - Module exports

## 4. Testing Strategy

- Create test file `test/MathTest.hx`
- Test Vec2 operations: add, sub, scale, normalize, length
- Test Vec3 operations: add, sub, cross product, normalize
- Test Vec4 operations: add, sub, normalize
- Test Mat4: identity, multiply, inverse, determinant
- Test Quat: multiply, conjugate, inverse, angleTo
- Test Primitives: Circle, Sphere, Capsule, Plane, Cuboid
- Test BoundingBox: Aabb3d intersection, contains

## 5. Rollback Plan

If issues arise:
1. Keep backup of original files before modification
2. Revert each file individually if needed
3. All changes are additive (no deletions of working code)

## 6. Estimated Effort

- **Time**: 4-6 hours
- **Complexity**: Medium
- **Risk**: Low (additive changes only)
