# Bevy Math Module Improvement Plan

## Overview

This plan covers the improvement of the `haxe.math` module to better match the Bevy Rust API. The goal is to add missing methods, improve type safety, and use `@:structInit` for cleaner constructors.

## Files to Modify/Create

### 1. Modify: Vec2.hx
- Add `abs()`, `sign()` methods
- Add `clampLength()`, `clampLengthMax()`, `clampLengthMin()`
- Add `projectOnto()`, `rejectFrom()`
- Add comparison helpers
- Add `toArray()`, `fromArray()`
- Add `NEG_X`, `NEG_Y` static constants

### 2. Modify: Vec3.hx
- Add `cross()` - already exists but needs to verify
- Add `clampLength()`, `clampLengthMax()`, `clampLengthMin()`
- Add `projectOnto()`, `rejectFrom()`
- Add `any()`, `all()` boolean checks
- Add `NEG_X`, `NEG_Y`, `NEG_Z` static constants
- Add `toArray()`, `fromArray()`
- Add swizzle methods: `xxx`, `yyy`, `zzz`, `xx`, `yy`, `zz`, `xy`, `xz`, `yz`
- Add `mul3()` for component-wise multiply

### 3. Modify: Vec4.hx
- Add `lengthSquared()` 
- Add `cross()` (3D cross product ignoring w)
- Add `clampLength()`, `clampLengthMax()`, `clampLengthMin()`
- Add static constants: `X`, `Y`, `Z`, `W`, `NEG_X`, `NEG_Y`, `NEG_Z`, `NEG_W`
- Add swizzle methods
- Add `truncate()` to convert to Vec3

### 4. Modify: Mat4.hx
- Add `determinant()` method
- Add `inverse()` method (with safe handling for singular matrices)
- Add `transpose()` method
- Add `transformPoint3()`, `transformPoint4()` 
- Add `transformVector3()`, `transformVector4()`
- Add `transform_dir3()` for Direction3 transformation
- Add column/row accessors
- Add `toArray()`, `fromArray()`

### 5. Modify: Quat.hx
- Convert to use `@:structInit` pattern
- Add `lengthSquared()` method
- Add `dot()` for quaternion dot product
- Add `inverse()` method
- Add `mulVec3()` for rotating vectors
- Add `fromEuler()` for Euler angle construction
- Add `toEuler()` for getting Euler angles (XYZ order)
- Add `slerp()` for spherical interpolation
- Add `fromRotationX/Y/Z()` static methods
- Add `fromRotationBetween()` for axis-to-axis rotation
- Add static constants: `IDENTITY`
- Add `isNormalized()`, `isIdentity()` checks

### 6. Modify: Direction.hx (Dir3)
- Add `Dir2` type for 2D directions
- Add error handling with `Result<Dir3, InvalidDirectionError>`
- Add `new()` constructor that returns Result
- Add `newAndLength()` returning direction and length
- Add `renormalize()` method
- Add `-` operator for negation
- Add `isNormalized()` check
- Add support for Vec3A (if applicable)

### 7. Enhance: Primitives.hx
- Add `Cuboid` (3D box) with min/max constructors
- Add `Segment2d`, `Segment3d`
- Add `Triangle2d`, `Triangle3d`
- Add `Polyline2d`, `Polyline3d`
- Add `Polygon` (2D)
- Add more helper methods

### 8. Create: BoundingBox.hx (or enhance Primitives)
- Add `Aabb3d` - Axis-Aligned Bounding Box 3D
- Add `Aabb2d` - Axis-Aligned Bounding Box 2D
- Add `BoundingSphere`
- Add `BoundingBox` - generic bounding box
- Add intersection/containment methods

### 9. Create: prelude/MathModule.hx
- Re-export all math types for easy importing

## Implementation Order

1. Vec2.hx - Foundation vector types
2. Vec3.hx - Extended for 3D operations
3. Vec4.hx - Quaternions and homogeneous coords
4. Direction.hx - Type-safe directions
5. Mat4.hx - Matrix operations
6. Quat.hx - Quaternion operations
7. Primitives.hx - Geometric primitives
8. BoundingBox.hx - Bounding volumes
9. prelude/MathModule.hx - Clean exports

## Technical Notes

### Haxe Abstract Limitations
- Cannot easily override `==` operator on abstracts
- Use `equals()` method for comparisons
- `hashCode()` needs proper implementation

### @:structInit Pattern
```haxe
@:structInit
abstract Vec2({x:Float, y:Float}) {
    // Direct construction: new Vec2({x: 1, y: 2})
}
```

### Error Handling
For Direction, use nullable returns or Result pattern:
```haxe
@:from public static function fromVec3(v:Vec3):Null<Dir3>
```

## Testing Strategy

1. Write simple test files for each module
2. Verify vector math operations
3. Test matrix multiplication order
4. Test quaternion slerp interpolation
5. Test direction validation

## Estimated Effort

- Vec2.hx: 1 hour
- Vec3.hx: 1.5 hours
- Vec4.hx: 1 hour
- Direction.hx: 1 hour
- Mat4.hx: 2 hours
- Quat.hx: 2 hours
- Primitives.hx: 1.5 hours
- BoundingBox.hx: 1.5 hours
- prelude: 0.5 hour

Total: ~11 hours
