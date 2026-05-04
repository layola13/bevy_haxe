# Bevy Math Module Improvement Plan

## 1. Overview

Improve the `haxe.math` module to match Bevy's math API more closely, adding missing methods and new types.

**Goals:**
- Add missing vector operations (swizzle, angle, reflect, etc.)
- Implement matrix determinant, inverse, and transpose
- Add quaternion operations (slerp, to/from euler, etc.)
- Create Direction types with proper validation
- Add primitive shapes and bounding box types

**Scope:**
- Files: Vec2.hx, Vec3.hx, Vec4.hx, Mat4.hx, Quat.hx, Direction.hx, Primitives.hx
- Using `@:structInit` for cleaner construction
- Match Bevy API patterns where possible

---

## 2. Implementation Steps

### Step 1: Enhance Vec2.hx
**Files to modify:** `src/haxe/math/Vec2.hx`

Add missing methods:
- `NEG_X`, `NEG_Y` static constants
- `lengthSquared()` (exists, verify)
- `normalize()` (exists, verify)
- `distanceSquared()`
- `angle()`
- `angleTo()`
- `dot()` (exists, verify)
- `cross()` (exists, verify)
- `reflect()`
- `abs()`
- `clampLength()`
- `tryNormalize()` returning nullable
- Swizzle accessors

### Step 2: Enhance Vec3.hx
**Files to modify:** `src/haxe/math/Vec3.hx`

Add missing methods:
- `NEG_X`, `NEG_Y`, `NEG_Z` static constants
- `cross()` - vector cross product (not scalar)
- `distanceSquared()`
- `angle()`
- `angleTo()`
- `reflect()`
- `abs()`
- `clampLength()`
- `tryNormalize()` returning nullable
- `projectOn()`
- `rejectFrom()`
- Swizzle accessors (xxx, yyy, etc.)

### Step 3: Enhance Vec4.hx
**Files to modify:** `src/haxe/math/Vec4.hx`

Add:
- Static constants: `X`, `Y`, `Z`, `NEG_X`, `NEG_Y`, `NEG_Z`
- `lengthSquared()`
- `distanceSquared()`
- `normalize()` (exists, verify)
- `dot()` (exists, verify)
- Swizzle accessors

### Step 4: Enhance Mat4.hx
**Files to modify:** `src/haxe/math/Mat4.hx`

Add methods:
- `determinant()`
- `inverse()`
- `transpose()`
- `tr()` (trace)
- `transformPoint3()`
- `transformVec3()`
- `transformPoint()` (alias with w=1)
- `transformDirection()`
- `mulVec4()`
- Column/row accessors

### Step 5: Enhance Quat.hx
**Files to modify:** `src/haxe/math/Quat.hx`

Add methods:
- `lengthSquared()`
- `normalize()` (exists, verify)
- `dot()`
- `slerp()`
- `toEuler()` / `fromEuler()`
- `toAxisAngle()` / `fromAxisAngle()` (exists, verify)
- `conjugate()` (exists, verify)
- `inverse()`
- `mulVec3()`
- `mulDirection()`
- Static factories: `fromRotationX()`, `fromRotationY()`, `fromRotationZ()`
- `isNormalized()`
- `angleTo()`

### Step 6: Improve Direction.hx
**Files to modify:** `src/haxe/math/Direction.hx`

Add:
- `Dir2` type for 2D directions
- `Dir4` type for 4D directions
- Proper error type `InvalidDirectionError`
- `new()` static method with error checking (not just @:from)
- `fastRenormalize()` for performance-critical code
- `isNormalized()` method

### Step 7: Add BoundingBox.hx
**Files to create:** `src/haxe/math/BoundingBox.hx`

Create:
- `Aabb2d` - 2D axis-aligned bounding box
- `Aabb3d` - 3D axis-aligned bounding box  
- `BoundingSphere` - bounding sphere
- Methods: `center()`, `contains()`, `merge()`, `intersects()`

### Step 8: Enhance Primitives.hx
**Files to modify:** `src/haxe/math/Primitives.hx`

Add/complete:
- `Cuboid` class
- `Segment2d`, `Segment3d`
- `Triangle2d`, `Triangle3d`
- `Line2d`, `Line3d`
- `Polyline2d`, `Polyline3d`

---

## 3. File Changes Summary

### New Files
- `src/haxe/math/BoundingBox.hx` (new)

### Modified Files
- `src/haxe/math/Vec2.hx`
- `src/haxe/math/Vec3.hx`
- `src/haxe/math/Vec4.hx`
- `src/haxe/math/Mat4.hx`
- `src/haxe/math/Quat.hx`
- `src/haxe/math/Direction.hx`
- `src/haxe/math/Primitives.hx`

---

## 4. Testing Strategy

1. Create test file: `test/MathTests.hx`
2. Test vector operations
3. Test matrix operations
4. Test quaternion operations
5. Test primitives
6. Verify Haxe compilation with `haxe --version` and `haxe -hxml project.hxml --interp`

---

## 5. Rollback Plan

- All files under version control (git)
- Rollback by restoring original files
- No database or migration needed

---

## 6. Estimated Effort

- **Time:** ~3-4 hours
- **Complexity:** Medium
- **Dependencies:** None (pure Haxe math library)

---

## 7. Implementation Order

1. Vec2.hx - foundation
2. Vec3.hx - core 3D types
3. Vec4.hx - 4D vector
4. Mat4.hx - matrix ops
5. Quat.hx - quaternion ops
6. Direction.hx - direction types
7. Primitives.hx - 2D/3D shapes
8. BoundingBox.hx - bounding volumes
