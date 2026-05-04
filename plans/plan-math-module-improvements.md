# Implementation Plan: bevy_math Module Improvements

## 1. Overview

This plan outlines improvements to the bevy_haxe math module to better align with the Bevy Rust API. The goal is to add missing methods, enhance existing implementations, and add new types for geometric primitives and bounding volumes.

**Files to modify:**
- `src/haxe/math/Vec2.hx`
- `src/haxe/math/Vec3.hx`
- `src/haxe/math/Vec4.hx`
- `src/haxe/math/Mat4.hx`
- `src/haxe/math/Quat.hx`
- `src/haxe/math/Direction.hx`
- `src/haxe/math/Primitives.hx`
- `src/haxe/math/Rect.hx` (enhance)

**Files to create:**
- `src/haxe/math/prelude/MathModule.hx` (math prelude)
- `src/haxe/math/BoundingBox.hx`

## 2. Vec2.hx Improvements

### Add missing methods:
- `NEG_X`, `NEG_Y` static constants
- `lengthSquared()` method (already present but needs verification)
- `isNormalized()` check
- `isFinite()` check
- `any()` / `all()` for boolean operations (simplified)
- Swizzle operations: `xx`, `yy`, `yx`
- `abs()` method
- `sign()` method
- `round()`, `floor()`, `ceil()` already present
- `min()` / `max()` element-wise
- `clamp()` method

### Implementation:
```hx
// Static constants
public static var NEG_X(get, never):Vec2;
public static var NEG_Y(get, never):Vec2;

private static inline function get_NEG_X():Vec2 return new Vec2(-1, 0);
private static inline function get_NEG_Y():Vec2 return new Vec2(0, -1);

// New methods
public inline function isNormalized():Bool {
    return Math.abs(lengthSquared() - 1) < 1e-6;
}

public inline function isFinite():Bool {
    return Math.isFinite(x) && Math.isFinite(y);
}

public inline function abs():Vec2 {
    return new Vec2(Math.abs(x), Math.abs(y));
}

public inline function sign():Vec2 {
    return new Vec2(x < 0 ? -1 : (x > 0 ? 1 : 0), y < 0 ? -1 : (y > 0 ? 1 : 0));
}

public inline function any():Bool {
    return x != 0 || y != 0;
}

public inline function all():Bool {
    return x != 0 && y != 0;
}
```

## 3. Vec3.hx Improvements

### Add missing methods:
- `NEG_X`, `NEG_Y`, `NEG_Z` static constants
- `cross(other:Vec3):Vec3` - already present, verify implementation
- `isNormalized()` check
- `isFinite()` check
- Swizzle operations: `xxx`, `yyy`, `zzz`, `xy`, `xz`, `yz`, `yx`, `zx`, `zy`
- `abs()` method
- `sign()` method
- `minElement()` / `maxElement()` 
- `dot()` already present - verify
- `reflect()` method
- `project()` onto another vector

### Cross product implementation (critical):
```hx
public inline function cross(other:Vec3):Vec3 {
    return new Vec3(
        y * other.z - z * other.y,
        z * other.x - x * other.z,
        x * other.y - y * other.x
    );
}
```

## 4. Vec4.hx Improvements

### Add missing methods:
- `X`, `Y`, `Z`, `NEG_X`, `NEG_Y`, `NEG_Z` static constants
- `lengthSquared()` method
- `isNormalized()` check
- `isFinite()` check
- Swizzle operations
- `abs()` method
- `sign()` method
- `w()` accessor for .w component
- `truncate()` to get Vec3

## 5. Mat4.hx Improvements

### Add missing methods:
- `determinant():Float`
- `inverse():Mat4` (with check for singular matrix)
- `transpose():Mat4`
- `transformPoint3(point:Vec3):Vec3`
- `transformVec3(v:Vec3):Vec3`
- `transformVec4(v:Vec4):Vec4`

### Determinant implementation:
```hx
public inline function determinant():Float {
    var a = x00, b = x01, c = x02, d = x03;
    var e = x10, f = x11, g = x12, h = x13;
    var i = x20, j = x21, k = x22, l = x23;
    var m = x30, n = x31, o = x32, p = x33;
    
    var kplo = k * p - l * o;
    var jpln = j * p - l * n;
    var jokn = j * o - k * n;
    var iplm = i * p - l * m;
    var iokm = i * o - k * m;
    var inhj = i * n - j * m;
    
    return a * (f * kplo - g * jpln + h * jokn)
         - b * (e * kplo - g * iplm + h * iokm)
         + c * (e * jpln - f * iplm + h * inhj)
         - d * (e * jokn - f * iokm + g * inhj);
}
```

### Inverse implementation:
```hx
public function inverse():Mat4 {
    var det = determinant();
    if (Math.abs(det) < 1e-10) {
        return IDENTITY; // or throw error
    }
    var invDet = 1 / det;
    // ... compute adjugate matrix and multiply by invDet
}
```

## 6. Quat.hx Improvements

### Add missing methods:
- `identity` static property (not just function)
- `IDENTITY` static constant
- `lengthSquared()` method
- `isNormalized()` check
- `isFinite()` check
- `dot(other:Quat):Float`
- `inverse():Quat`
- `slerp(other:Quat, t:Float):Quat`
- `mulVec3(v:Vec3):Vec3` - rotate vector by quaternion
- `toEuler():Vec3` - convert to Euler angles
- `fromEuler(x:Float, y:Float, z:Float):Quat`
- `fromMat3(m:Mat3):Quat`
- `toMat4():Mat4`
- `angularVelocity():Vec3`

### Slerp implementation:
```hx
public function slerp(other:Quat, t:Float):Quat {
    var cosHalfTheta = x * other.x + y * other.y + z * other.z + w * other.w;
    if (Math.abs(cosHalfTheta) >= 1.0) return this;
    
    var halfTheta = Math.acos(cosHalfTheta);
    var sinHalfTheta = Math.sqrt(1 - cosHalfTheta * cosHalfTheta);
    
    if (Math.abs(sinHalfTheta) < 0.001) {
        return new Quat(
            (x + other.x) * 0.5,
            (y + other.y) * 0.5,
            (z + other.z) * 0.5,
            (w + other.w) * 0.5
        );
    }
    
    var ratioA = Math.sin((1 - t) * halfTheta) / sinHalfTheta;
    var ratioB = Math.sin(t * halfTheta) / sinHalfTheta;
    
    return new Quat(
        x * ratioA + other.x * ratioB,
        y * ratioA + other.y * ratioB,
        z * ratioA + other.z * ratioB,
        w * ratioA + other.w * ratioB
    );
}
```

## 7. Direction.hx (Dir3) Improvements

### Enhance existing implementation:
- Add `Dir2` type for 2D directions
- Add `new()` method with error handling
- Add `fromVec3Safe()` variants
- Add `renormalize()` method
- Add `isNormalized()` check
- Add `isFinite()` check

## 8. Primitives.hx Improvements

### Add missing primitives:
- **Polygon2d** - 2D polygon from points
- **Polyline2d** - 2D polyline
- **Line2d** - Infinite 2D line
- **Line3d** - Infinite 3D line
- **Segment2d** - Line segment in 2D
- **Segment3d** - Line segment in 3D
- **Triangle2d** - 2D triangle
- **Triangle3d** - 3D triangle
- **Cuboid** - 3D axis-aligned box

### Keep existing:
- Circle
- Sphere
- Capsule
- Plane

### Add methods to existing:
- `Circle`: ` perimeter()`, `bounds()`
- `Sphere`: `bounds()`, `containsPoint()`
- `Capsule`: `bounds()`, `segment()`
- `Plane`: `flip()`, `intersectionPoint()`

## 9. BoundingBox.hx (new file)

### Create BoundingBox types:
```hx
@:structInit
class Aabb3d {
    public var min:Vec3;
    public var max:Vec3;
    
    public inline function center():Vec3 { ... }
    public inline function size():Vec3 { ... }
    public inline function halfSize():Vec3 { ... }
    public inline function surfaceArea():Float { ... }
    public inline function volume():Float { ... }
    public inline function contains(point:Vec3):Bool { ... }
    public inline function containsBox(other:Aabb3d):Bool { ... }
    public inline function intersects(other:Aabb3d):Bool { ... }
    public inline function merge(other:Aabb3d):Aabb3d { ... }
    public inline function intersection(other:Aabb3d):Aabb3d { ... }
    public inline function expand(amount:Float):Aabb3d { ... }
    public inline function closestPoint(point:Vec3):Vec3 { ... }
}

@:structInit  
class BoundingSphere {
    public var center:Vec3;
    public var radius:Float;
    
    public inline function diameter():Float { ... }
    public inline function surfaceArea():Float { ... }
    public inline function volume():Float { ... }
    public inline function contains(point:Vec3):Bool { ... }
    public inline function intersectsSphere(other:BoundingSphere):Bool { ... }
    public inline function merge(other:BoundingSphere):BoundingSphere { ... }
    public inline function closestPoint(point:Vec3):Vec3 { ... }
}
```

## 10. Rect.hx Enhancements

### Add missing methods:
- `fromPoints(points:Array<Vec2>):Rect`
- `fromSpheres(spheres:Array<{center:Vec2, radius:Float}>):Rect`
- Union/intersection operations
- `aspectRatio()` method

## 11. MathModule.hx (prelude)

Create a prelude file that exports all math types:
```hx
package haxe.math.prelude;

@:publicFields
class MathModule {
    // Vector types
    static inline var Vec2 = haxe.math.Vec2;
    static inline var Vec3 = haxe.math.Vec3;
    static inline var Vec4 = haxe.math.Vec4;
    
    // Matrix types  
    static inline var Mat4 = haxe.math.Mat4;
    
    // Quaternion
    static inline var Quat = haxe.math.Quat;
    
    // Direction types
    static inline var Dir2 = haxe.math.Dir2;
    static inline var Dir3 = haxe.math.Dir3;
    
    // Primitives
    static inline var Rect = haxe.math.Rect;
    static inline var Circle = haxe.math.Circle;
    static inline var Sphere = haxe.math.Sphere;
    static inline var Capsule = haxe.math.Capsule;
    static inline var Plane = haxe.math.Plane;
    
    // Bounding volumes
    static inline var Aabb3d = haxe.math.Aabb3d;
    static inline var BoundingSphere = haxe.math.BoundingSphere;
}
```

## 12. Implementation Order

1. **Vec2.hx** - Add missing methods
2. **Vec3.hx** - Add cross product verification and missing methods
3. **Vec4.hx** - Complete implementation
4. **Mat4.hx** - Add determinant, inverse, transpose
5. **Quat.hx** - Add slerp, inverse, more operations
6. **Direction.hx** - Add Dir2, enhance Dir3
7. **Primitives.hx** - Add missing primitives
8. **Rect.hx** - Add missing methods
9. **BoundingBox.hx** - Create new file
10. **MathModule.hx** - Create prelude

## 13. Testing Strategy

- Create test files in `/test/math/` directory
- Test each type's basic operations
- Verify cross-product, determinant, inverse calculations
- Test interpolation (lerp, slerp)
- Test bounding volume operations

## 14. Estimated Effort

- **Vec2, Vec3, Vec4**: 2-3 hours
- **Mat4**: 2 hours
- **Quat**: 2-3 hours  
- **Direction**: 1 hour
- **Primitives**: 2-3 hours
- **BoundingBox**: 1-2 hours
- **Rect, Prelude**: 1 hour

**Total**: ~12-15 hours

## 15. Constraints

- Use `@:structInit` where appropriate for simpler construction
- Keep API consistent with Bevy Rust API naming
- Use abstract types for Vec2, Vec3, Vec4, Quat (value types)
- Use classes with `@:structInit` for primitives and bounding volumes
- All math operations should be `inline` for performance
