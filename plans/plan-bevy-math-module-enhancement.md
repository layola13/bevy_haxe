# Bevy Math Module Enhancement Plan

## Overview

Improve the `bevy_haxe` math module to match the Rust `bevy_math` crate functionality. This includes enhancing vector types, matrix operations, quaternions, and adding new primitive types with proper `@:structInit` support.

### Goals
- Enhance Vec2/Vec3/Vec4 with missing methods
- Add Mat4 determinant, inverse, transpose methods
- Improve Quat with inverse, MulVec3, fromEuler
- Add Dir2/Dir3 Direction types with error handling
- Add Rect improvements and BoundingBox types
- Use @:structInit for cleaner construction
- Maintain API consistency with Bevy

### Scope
**Included:** Vec2, Vec3, Vec4, Mat4, Quat, Direction, Rect, Primitives, BoundingBox
**Excluded:** Mat3, IVec/U Vec types, curves, splines (future work)

## Implementation Steps

### Step 1: Create Prelude Module
Create `haxe/math/prelude/MathModule.hx` to export all math types.

### Step 2: Enhance Vec2.hx
**File:** `src/haxe/math/Vec2.hx`
Add:
- `NEG_X`, `NEG_Y` static constants
- `lengthSquared()` method (check if exists)
- `distanceSquared()` method
- `reflect()` method
- `perp()` alias for perpendicular
- `angle()` method
- `angleTo()` method
- `rotateAround()` method
- Swizzle-like accessors: `xx`, `yx`, `yy`
- `@:structInit` constructor

### Step 3: Enhance Vec3.hx
**File:** `src/haxe/math/Vec3.hx`
Add:
- `NEG_X`, `NEG_Y`, `NEG_Z` static constants
- `cross()` product (Vec3 x Vec3 = Vec3) - MISSING
- `distanceSquared()` method
- `reflect()` method
- `project()` method
- `rejectFromNormal()` method
- `anyOrthogonal()` method
- Swizzle-like accessors
- Move min/max/clamp to use `@:op` where appropriate

### Step 4: Enhance Vec4.hx
**File:** `src/haxe/math/Vec4.hx`
Add:
- Static constants X, Y, Z, W, NEG_X, etc.
- `lengthSquared()` method
- `distanceSquared()` method
- `dot()` already exists
- Swizzle accessors
- `@:structInit` constructor

### Step 5: Complete Mat4.hx
**File:** `src/haxe/math/Mat4.hx`
Add:
- `determinant()` method
- `inverse()` method
- `transpose()` method
- `extractRotation()` method
- `extractScale()` method
- `transformPoint3()` method
- `transformPoint4()` method
- `transformVec3()` method
- Transform helpers: `transform_f32` pattern
- Add more static factory methods

### Step 6: Improve Quat.hx
**File:** `src/haxe/math/Quat.hx`
Add:
- `inverse()` method
- `mulVec3()` method
- `fromEuler()` static method (Euler angles)
- `toEuler()` method returning Vec3
- `axisAngle()` getter
- `angle()` method
- `identity` as static var
- `fromAxisAngle` already exists
- `isNormalized()` method
- `@:structInit` with better constructor

### Step 7: Improve Direction.hx
**File:** `src/haxe/math/Direction.hx`
Add:
- Dir2 type for 2D directions
- Dir3 error handling with `Result<Dir3, InvalidDirectionError>`
- `new()` factory method with validation
- `newAndLength()` returning both direction and length
- `renormalize()` method
- `isNormalized()` method
- Better cross product handling

### Step 8: Enhance Rect.hx
**File:** `src/haxe/math/Rect.hx`
Already good, add:
- `corners()` method returning 4 corners
- `translate()` method
- `expandToInclude()` method

### Step 9: Expand Primitives.hx
**File:** `src/haxe/math/Primitives.hx`
Add:
- `Segment2d` struct
- `Segment3d` struct  
- `Triangle2d` struct
- `Triangle3d` struct
- `Polyline2d` / `Polyline3d` for line segments
- Ensure Circle, Sphere, Capsule, Plane are complete

### Step 10: Add BoundingBox.hx
**File:** `src/haxe/math/BoundingBox.hx`
Add:
- `BoundingBox3d` (AABB for 3D)
- `BoundingBox2d` (AABB for 2D)
- `contains()` method
- `intersects()` method
- `merge()` method
- `closestPoint()` method
- `center()` property
- `halfSize()` property

## File Changes Summary

### Created Files
| File | Description |
|------|-------------|
| `src/haxe/math/prelude/MathModule.hx` | Prelude exports |
| `src/haxe/math/BoundingBox.hx` | AABB bounding boxes |

### Modified Files
| File | Changes |
|------|---------|
| `src/haxe/math/Vec2.hx` | Add methods, swizzles |
| `src/haxe/math/Vec3.hx` | Add cross product, methods |
| `src/haxe/math/Vec4.hx` | Add methods, constants |
| `src/haxe/math/Mat4.hx` | Add determinant, inverse, transpose |
| `src/haxe/math/Quat.hx` | Add inverse, mulVec3, euler |
| `src/haxe/math/Direction.hx` | Add Dir2, error handling |
| `src/haxe/math/Rect.hx` | Add corners, translate |
| `src/haxe/math/Primitives.hx` | Add more primitives |

## Testing Strategy

1. **Unit Tests** (`test/math/`)
   - Vec2/Vec3/Vec4 operations
   - Mat4 transformations
   - Quat rotations
   - Direction creation
   - Primitives area/volume

2. **Manual Testing**
   - Compile test with `haxe build.hxml`
   - Run examples to verify transformations

## Rollback Plan

All changes are additive - rollback is simply reverting files to previous versions from git history.

## Estimated Effort

- **Time:** 4-6 hours
- **Complexity:** Medium
- **Dependencies:** None (self-contained math types)
