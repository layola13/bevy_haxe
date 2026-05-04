package haxe.prelude;

/**
 * Main prelude for Bevy Haxe engine.
 * Provides unified access to all core types and modules.
 * Use `-D haxe Libya.prelude.Prelude` in hxml to enable.
 */

// Math module
import haxe.math.Vec2;
import haxe.math.Vec3;
import haxe.math.Vec4;
import haxe.math.Mat4;
import haxe.math.Quat;

// Color module
import haxe.color.Color;
import haxe.color.RGBA;
import haxe.color.HSLA;

// Utils module
import haxe.utils.Ref;

/**
 * Prelude provides convenient access to all commonly used types.
 * Instead of importing individual modules, import this prelude:
 * ```haxe
 * import haxe.prelude.Prelude;
 * ```
 */
class Prelude {
    public function new() {}

    // Math types are exposed via static inline functions for zero-cost abstraction
    public static inline function vec2(?x:Float, ?y:Float):Vec2 return new Vec2(x, y);
    public static inline function vec3(?x:Float, ?y:Float, ?z:Float):Vec3 return new Vec3(x, y, z);
    public static inline function vec4(?x:Float, ?y:Float, ?z:Float, ?w:Float):Vec4 return new Vec4(x, y, z, w);
    public static inline function quat(?x:Float, ?y:Float, ?z:Float, ?w:Float):Quat return new Quat(x, y, z, w);
    public static inline function mat4():Mat4 return Mat4.IDENTITY;
    public static inline function identity():Quat return Quat.identity();
}
