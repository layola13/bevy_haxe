package haxe.prelude;

/**
 * Unified Prelude for Bevy Haxe Engine.
 * 
 * Import this module to get access to all commonly used types:
 * - Math types: Vec2, Vec3, Vec4, Mat4, Quat
 * - ECS types: Entity, Component, World, Query
 * - App types: App, Plugin, Schedule
 * - Color types: Color, RGBA, HSLA
 * 
 * Usage:
 * ```haxe
 * import haxe.prelude.Prelude;
 * 
 * class MyApp extends App {
 *     override function setup() {
 *         var pos:Vec3 = vec3(1, 2, 3);
 *         var ent = entity(1);
 *     }
 * }
 * ```
 */
class Prelude {
    public function new() {}
}

// =============================================================================
// Type aliases for convenience
// =============================================================================

/** 2D vector type */
typedef Vec2 = haxe.math.Vec2;

/** 3D vector type */
typedef Vec3 = haxe.math.Vec3;

/** 4D vector type */
typedef Vec4 = haxe.math.Vec4;

/** 4x4 matrix type */
typedef Mat4 = haxe.math.Mat4;

/** Quaternion type for rotations */
typedef Quat = haxe.math.Quat;

/** RGBA color type */
typedef Color = haxe.color.Color;
typedef RGBA = haxe.color.RGBA;

/** Entity identifier */
typedef Entity = haxe.ecs.Entity;

// =============================================================================
// Inline factory functions - zero-cost abstractions
// =============================================================================

/**
 * Create a Vec2 with optional x, y components.
 */
@:inline
static function vec2(?x:Float, ?y:Float):Vec2 return new Vec2(x, y);

/**
 * Create a Vec3 with optional x, y, z components.
 */
@:inline
static function vec3(?x:Float, ?y:Float, ?z:Float):Vec3 return new Vec3(x, y, z);

/**
 * Create a Vec4 with optional x, y, z, w components.
 */
@:inline
static function vec4(?x:Float, ?y:Float, ?z:Float, ?w:Float):Vec4 return new Vec4(x, y, z, w);

/**
 * Create a quaternion from components.
 */
@:inline
static function quat(?x:Float, ?y:Float, ?z:Float, ?w:Float):Quat return new Quat(x, y, z, w);

/**
 * Create identity quaternion.
 */
@:inline
static function quatIdentity():Quat return Quat.identity();

/**
 * Create a 4x4 identity matrix.
 */
@:inline
static function mat4():Mat4 return Mat4.identity();

/**
 * Create a translation matrix.
 */
@:inline
static function translation(x:Float, y:Float, z:Float):Mat4 return Mat4.translation(x, y, z);

/**
 * Create a scaling matrix.
 */
@:inline
static function scaling(x:Float, y:Float, z:Float):Mat4 return Mat4.scaling(x, y, z);

/**
 * Create a rotation matrix around X axis.
 */
@:inline
static function rotationX(angle:Float):Mat4 return Mat4.rotationX(angle);

/**
 * Create a rotation matrix around Y axis.
 */
@:inline
static function rotationY(angle:Float):Mat4 return Mat4.rotationY(angle);

/**
 * Create a rotation matrix around Z axis.
 */
@:inline
static function rotationZ(angle:Float):Mat4 return Mat4.rotationZ(angle);

/**
 * Create a perspective projection matrix.
 */
@:inline
static function perspective(fovY:Float, aspect:Float, near:Float, far:Float):Mat4 {
    return Mat4.perspective(fovY, aspect, near, far);
}

/**
 * Create a look-at view matrix.
 */
@:inline
static function lookAt(eye:Vec3, center:Vec3, up:Vec3):Mat4 return Mat4.lookAt(eye, center, up);

/**
 * Create an RGBA color from r, g, b, a components (0-255).
 */
@:inline
static function rgba(r:Int, g:Int, b:Int, ?a:Int = 255):RGBA return new RGBA(r, g, b, a);

/**
 * Create an entity with given id.
 */
@:inline
static function entity(id:Int):Entity return {id: id};
