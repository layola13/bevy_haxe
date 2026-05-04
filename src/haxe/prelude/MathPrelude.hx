package haxe.prelude;

/**
 * Math module prelude.
 * Provides convenient access to all math types.
 */
class MathPrelude {
    public function new() {}

    // Vector creators
    public static inline function vec2(?x:Float, ?y:Float):Vec2 return new Vec2(x, y);
    public static inline function vec3(?x:Float, ?y:Float, ?z:Float):Vec3 return new Vec3(x, y, z);
    public static inline function vec4(?x:Float, ?y:Float, ?z:Float, ?w:Float):Vec4 return new Vec4(x, y, z, w);

    // Matrix creators
    public static inline function mat4():Mat4 return Mat4.IDENTITY;

    // Quaternion creators
    public static inline function quat(?x:Float, ?y:Float, ?z:Float, ?w:Float):Quat return new Quat(x, y, z, w);
    public static inline function quatIdentity():Quat return Quat.identity();

    // Transform helpers
    public static inline function translation(x:Float, y:Float, z:Float):Mat4 return Mat4.translation(x, y, z);
    public static inline function scaling(x:Float, y:Float, z:Float):Mat4 return Mat4.scaling(x, y, z);
    public static inline function rotationX(angle:Float):Mat4 return Mat4.rotationX(angle);
    public static inline function rotationY(angle:Float):Mat4 return Mat4.rotationY(angle);
    public static inline function rotationZ(angle:Float):Mat4 return Mat4.rotationZ(angle);
    public static inline function perspective(fovY:Float, aspect:Float, near:Float, far:Float):Mat4 {
        return Mat4.perspective(fovY, aspect, near, far);
    }
    public static inline function lookAt(eye:Vec3, center:Vec3, up:Vec3):Mat4 return Mat4.lookAt(eye, center, up);
}
