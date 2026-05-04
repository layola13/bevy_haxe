# Math Module Implementation Plan

## Overview

Create a complete Haxe math module with `@:structInit` and `inline` functions for optimal performance, matching the Bevy engine's math API.

## Files to Update

### 1. Vec2.hx
- 2D vector class with `@:structInit`
- All operators: `+`, `-`, `*`, `/`, `-A` (negation)
- Methods: `dot`, `cross`, `normalize`, `length`, `lengthSquared`, `distance`, `distanceSquared`, `lerp`, `rotate`, `perpendicular`, `floor`, `ceil`, `round`, `abs`, `min`, `max`, `clamp`, `projectOnto`, `reflect`, `angle`, `angleTo`, `isZero`
- Static constants: `ZERO`, `ONE`, `X`, `Y`

### 2. Vec3.hx
- 3D vector class with `@:structInit`
- Same operations as Vec2 plus `cross` (3D cross product returns Vec3)
- Additional constants: `UP`, `DOWN`, `LEFT`, `RIGHT`, `FORWARD`, `BACK`
- Converters: `fromVec2`, `toVec2`

### 3. Vec4.hx
- 4D vector class with `@:structInit`
- All basic operations (no cross product for 4D)
- Converters: `fromVec3`, `toVec3`

### 4. Mat4.hx
- 4x4 matrix with column-major layout
- Operations: `mul` (matrix-matrix), `mulVec`, `mulPoint`, `mulDirection`
- Methods: `transpose`, `determinant`, `inverse`
- Factory methods: `lookAt`, `perspective`, `orthographic`, `translation`, `scaling`, `rotationX`, `rotationY`, `rotationZ`
- Helper methods: `col0-3`, `getTranslation`, `getScale`

## Key Design Decisions

1. **@:structInit**: Allows `var v:Vec2 = {x: 1, y: 2}` syntax
2. **inline functions**: All math operations are `inline` for performance
3. **Platform-specific constructors**: `#if hl` conditional for HashLink compatibility
4. **Column-major matrix**: GPU-compatible memory layout

## Usage Examples

```haxe
// Vec2
var v1:Vec2 = {x: 1, y: 2};
var v2 = v1.add({x: 3, y: 4});  // {x: 4, y: 6}
var len = v1.length();
var normalized = v1.normalize();

// Vec3 with cross product
var a:Vec3 = {x: 1, y: 0, z: 0};
var b:Vec3 = {x: 0, y: 1, z: 0};
var c = a.cross(b);  // {x: 0, y: 0, z: 1}

// Mat4 operations
var m = Mat4.lookAt({x: 0, y: 0, z: 5}, Vec3.ZERO, Vec3.UP);
var proj = Mat4.perspective(Math.PI / 4, 16/9, 0.1, 100.0);
```

## Testing

1. Vector operations correctness
2. Matrix multiplication correctness
3. Inverse matrix verification (M * M.inverse() ≈ IDENTITY)
4. Performance benchmarks
