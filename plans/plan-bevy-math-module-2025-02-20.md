# Bevy Math Module Improvement Plan

## 1. Overview

This plan outlines enhancements to the `haxe.math` module in the Bevy Haxe project, improving it to better match the Rust `bevy_math` crate functionality.

### Goals
- Add missing methods to Vec2, Vec3, Vec4 for feature parity
- Complete Mat4 with determinant, inverse, transpose methods
- Expand Quat with more quaternion operations (inverse, mul_vec3, angle_between, etc.)
- Enhance Direction types with validation and more constructors
- Add BoundingBox types (Aabb2d, Aabb3d, BoundingSphere)
- Improve Primitives with more methods

### Scope
- **Included**: Vector math, matrix operations, quaternion operations, directions, primitives, bounding volumes
- **Excluded**: Curves, splines, ray casting (will be separate tasks)

---

## 2. Prerequisites

- Working Haxe 4.3+ with HL/JVM/JS targets
- Existing math types: Vec2, Vec3, Vec4, Mat4, Quat, Dir3
- `@:structInit` metadata for simplified construction

---

## 3. Implementation Steps

### Step 1: Enhance Vec2.hx
**Files**: `/home/vscode/projects/bevy_haxe/src/haxe/math/Vec2.hx`

Add methods:
- `lengthSquared()` - already exists
- `dot()`, `cross()` - already exist
- `normalize()` - already exists
- `distance()`, `distanceSquared()` - add `distanceSquared`
- `lerp()`, `smoothDamp()` - add `smoothDamp`
- `project()`, `reflect()`, `clampLength()` - add these
- `angle()`, `angleTo()` - add angle between vectors
- `perpDot()` - already exists as `cross`
- `abs()`, `round()`, `floor()`, `ceil()` - already have floor/ceil, add abs
- `mulAdd()` - add for FMA-style operation
- Static constants: `NEG_X`, `NEG_Y`

### Step 2: Enhance Vec3.hx
**Files**: `/home/vscode/projects/bevy_haxe/src/haxe/math/Vec3.hx`

Add methods:
- `cross()` - **critical missing method**
- `anyOrthogonal()`, `any_orthogonal()` - find orthogonal vector
- `to_array()`, `into()` - array conversion
- `lerp()`, `lerpColor()` - color lerp support
- `abs()`, `round()`, `sign()` - add sign method
- `mulAdd()` - FMA-style
- `reflect()`, `project()` - projection/reflection
- `angleTo()`, `angleBetween()` - angle between vectors
- `distanceSquared()` - add
- `smoothDamp()` - add

### Step 3: Enhance Vec4.hx
**Files**: `/home/vscode/projects/bevy_haxe/src/haxe/math/Vec4.hx`

Add methods:
- `lengthSquared()` - add
- `distanceSquared()` - add
- `abs()`, `round()`, `floor()`, `ceil()` - add
- `dot()`, `anyOrthogonal()` - add
- `lerp()`, `mulAdd()` - add
- Static: `X`, `Y`, `Z`, `NEG_X`, `NEG_Y`, `NEG_Z`, `NEG_W`

### Step 4: Complete Mat4.hx
**Files**: `/home/vscode/projects/bevy_haxe/src/haxe/math/Mat4.hx`

Add methods:
- `determinant()` - compute 4x4 determinant
- `inverse()` - compute matrix inverse
- `transpose()` - transpose the matrix
- `truncate()` - extract 3x3 rotation/scale portion
- `transform_point3()` - transform point (applies translation)
- `transform_vector3()` - transform vector (no translation)
- `transform_vec2()`, `transform_vec2_offset()` - 2D transforms
- `mul_vec3()`, `mul_vec4()` - vector multiplication
- `to_mat3()` - extract rotation matrix
- Add row accessors: `row0()`, `row1()`, `row2()`, `row3()`
- Add column accessors: `col0()`, `col1()`, `col2()`, `col3()`

### Step 5: Improve Quat.hx
**Files**: `/home/vscode/projects/bevy_haxe/src/haxe/math/Quat.hx`

Add methods:
- `inverse()` - quaternion inverse
- `dot()` - dot product
- `angle_between()`, `angleTo()` - angle between quaternions
- `mul_vec3()` - rotate vector by quaternion
- `mul_vec2()` - 2D rotation
- `xyz()`, `swizzle()` - component access
- `conjugate()` - already exists
- `normalize()` - already exists
- `is_normalized()` - check if unit quaternion
- `is_nan()` - check for NaN
- `from_euler()` - Euler angles to quaternion
- `to_euler()` - quaternion to Euler angles
- `from_axis_angle()` - already exists
- `from_rotation_arc()` - rotation from one direction to another
- `from_rotation_dir()` - from direction vectors
- `lerp()`, `slerp()` - interpolation
- `exp()`, `ln()` - logarithmic operations
- Static: `IDENTITY`, `X`, `Y`, `Z`, `NEG_X`, `NEG_Y`, `NEG_Z`

### Step 6: Add Dir2.hx and Improve Dir3.hx
**Files**: `/home/vscode/projects/bevy_haxe/src/haxe/math/Direction.hx`

Add:
- `Dir2` type (2D direction, similar to Dir3)
- Improve Dir3 with:
  - `new()` constructor with validation (returns Null)
  - `from_xy()` - 2D direction from x,y
  - `is_normalized()` - check
  - `as_ivec3()` - integer conversion
  - `renormalize()` - fix denormalized
  - OpEq: `+`, `-`, `*` (scale by unit)

### Step 7: Add BoundingBox.hx
**Files**: `/home/vscode/projects/bevy_haxe/src/haxe/math/BoundingBox.hx`

Add types:
- `Aabb2d` - 2D axis-aligned bounding box (min/max Vec2)
- `Aabb3d` - 3D axis-aligned bounding box (min/max Vec3)
- `BoundingSphere` - center + radius

For each:
- `new()` constructor
- `center()` - get center point
- `half_size()` - get half-extents
- `contains()` - check if contains other volume
- `merge()` - combine two volumes
- `intersects()` - check intersection
- `closest_point()` - closest point on surface
- `visible_area()` - surface area (volume for spheres)

### Step 8: Improve Primitives.hx
**Files**: `/home/vscode/projects/bevy_haxe/src/haxe/math/Primitives.hx`

Add/Improve:
- `Circle` - perimeter(), is_circle implementation
- `Sphere` - is_sphere implementation
- `Capsule` - more methods
- `Plane` - signed_distance already exists, improve
- Add `Cuboid` - axis-aligned box primitive
- Add `Segment2d`, `Segment3d` - line segments
- Add `Line2d`, `Line3d` - infinite lines

---

## 4. File Changes Summary

### New Files
| File | Description |
|------|-------------|
| `src/haxe/math/BoundingBox.hx` | Aabb2d, Aabb3d, BoundingSphere types |

### Modified Files
| File | Changes |
|------|---------|
| `src/haxe/math/Vec2.hx` | Add missing methods |
| `src/haxe/math/Vec3.hx` | Add cross(), other methods |
| `src/haxe/math/Vec4.hx` | Add lengthSquared, static constants |
| `src/haxe/math/Mat4.hx` | Add determinant, inverse, transpose, transform methods |
| `src/haxe/math/Quat.hx` | Add inverse, mul_vec3, angle methods, lerp/slerp |
| `src/haxe/math/Direction.hx` | Add Dir2, improve Dir3 |
| `src/haxe/math/Primitives.hx` | Add Cuboid, Segments, improve primitives |

---

## 5. Testing Strategy

### Unit Tests
Create `test/math/` with tests for:
- Vector operations: add, sub, scale, dot, cross, normalize
- Matrix operations: multiply, determinant, inverse, transform
- Quaternion operations: rotation, slerp, angle_between
- Direction creation and operations
- Bounding box creation and intersection

### Manual Testing
1. Test all new methods with known inputs
2. Verify inverse operations (e.g., `m.inverse().inverse() == m`)
3. Test interpolation methods (lerp, slerp)
4. Test edge cases (zero vectors, near-zero values)

---

## 6. Rollback Plan

To revert changes:
1. Use `git checkout HEAD -- src/haxe/math/*.hx` to restore original files
2. Delete new files: `BoundingBox.hx`
3. Run existing tests to verify

---

## 7. Estimated Effort

- **Complexity**: Medium-High
- **Time Estimate**: 4-6 hours
- **Files to Modify**: 8 files
- **Files to Create**: 1 file
- **New Lines**: ~600-800 lines

---

## Implementation Notes

### @:structInit Usage
Haxe 4.3+ `@:structInit` allows:
```haxe
@:structInit
class Vec3 {
    public var x:Float;
    public var y:Float;
    public var z:Float;
}

// Usage:
var v = @:privateAccess {x: 1.0, y: 2.0, z: 3.0};
```

### Float Comparisons
Use `MathHelper.floatEquals(a, b, epsilon=1e-6)` for comparisons:
```haxe
inline function floatEquals(a:Float, b:Float, eps:Float = 1e-6):Bool {
    return Math.abs(a - b) < eps;
}
```

### Vector Swizzling
Implement swizzle patterns like `.xx`, `.xy`, `.xyz` for convenience.
