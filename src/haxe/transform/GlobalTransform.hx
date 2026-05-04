package haxe.transform;

import haxe.math.Vec3;
import haxe.math.Quat;
import haxe.math.Mat4;
import haxe.math.Vec4;

/**
 * GlobalTransform represents the absolute world-space transformation of an entity.
 * 
 * This is computed from the entity's Transform component and all ancestor Transforms.
 * You cannot directly modify GlobalTransform - you should modify Transform instead,
 * and the system will automatically update GlobalTransform.
 * 
 * GlobalTransform is computed during the transform propagation system run.
 */
class GlobalTransform implements haxe.ecs.Component {
    /** 4x4 matrix representing the complete transformation */
    public var matrix:Mat4;
    
    public var componentTypeId(get, never):Int;
    private static var _typeId:Int = -1;
    private static function get_componentTypeId():Int {
        if (_typeId < 0) _typeId = haxe.ecs.ComponentType.get(GlobalTransform);
        return _typeId;
    }
    
    public inline function new(?matrix:Mat4) {
        this.matrix = matrix != null ? matrix : Mat4.IDENTITY;
    }
    
    /**
     * Create identity transform
     */
    public static function identity():GlobalTransform {
        return new GlobalTransform(Mat4.IDENTITY);
    }
    
    /**
     * Create from a Transform component
     */
    public static function fromTransform(transform:Transform):GlobalTransform {
        return new GlobalTransform(transform.toMatrix());
    }
    
    /**
     * Create from translation, rotation, and scale
     */
    public static function fromTRS(translation:Vec3, rotation:Quat, scale:Vec3):GlobalTransform {
        return new GlobalTransform(Mat4.fromTransform(translation, rotationToMatrix(rotation), scale));
    }
    
    /**
     * Create from translation only
     */
    public static function fromTranslation(translation:Vec3):GlobalTransform {
        return new GlobalTransform(Mat4.fromTranslation(translation));
    }
    
    /**
     * Create from rotation only
     */
    public static function fromRotation(rotation:Quat):GlobalTransform {
        return new GlobalTransform(Mat4.fromTransform(Vec3.ZERO, rotationToMatrix(rotation), Vec3.ONE));
    }
    
    /**
     * Create from scale only
     */
    public static function fromScale(scale:Vec3):GlobalTransform {
        return new GlobalTransform(Mat4.fromTransform(Vec3.ZERO, Mat4.IDENTITY, scale));
    }
    
    /**
     * Multiply two global transforms (compose them)
     * Order: this * other means apply other first, then this
     */
    @:op(A * B)
    public static function mul(a:GlobalTransform, b:GlobalTransform):GlobalTransform {
        return new GlobalTransform(Mat4.mul(a.matrix, b.matrix));
    }
    
    /**
     * Multiply GlobalTransform by Transform (compose)
     */
    @:op(A * B)
    public static function mulTransform(a:GlobalTransform, b:Transform):GlobalTransform {
        return new GlobalTransform(Mat4.mul(a.matrix, b.toMatrix()));
    }
    
    /**
     * Multiply GlobalTransform by Vec3 (transform point)
     */
    @:op(A * B)
    public static function mulVec3(a:GlobalTransform, v:Vec3):Vec3 {
        return a.transformPoint(v);
    }
    
    /**
     * Transform a point by this global transform
     */
    public function transformPoint(point:Vec3):Vec3 {
        return matrix.transformPoint(point);
    }
    
    /**
     * Transform a direction vector by this global transform (ignores translation)
     */
    public function transformDirection(dir:Vec3):Vec3 {
        return matrix.transformDirection(dir);
    }
    
    /**
     * Get the translation (position) component
     */
    public function translation():Vec3 {
        return new Vec3(matrix.x03, matrix.x13, matrix.x23);
    }
    
    /**
     * Get the scale component
     */
    public function scale():Vec3 {
        var srt = toScaleRotationTranslation();
        return srt.scale;
    }
    
    /**
     * Get the rotation component as quaternion
     */
    public function rotation():Quat {
        var srt2 = toScaleRotationTranslation();
        return srt2.rotation;
    }
    
    /**
     * Decompose into scale, rotation, and translation
     */
    public function toScaleRotationTranslation():{scale:Vec3, rotation:Quat, translation:Vec3} {
        var m = matrix;
        
        // Extract scale
        var scaleX = new Vec3(m.x00, m.x10, m.x20).length();
        var scaleY = new Vec3(m.x01, m.x11, m.x21).length();
        var scaleZ = new Vec3(m.x02, m.x12, m.x22).length();
        var scale = new Vec3(scaleX, scaleY, scaleZ);
        
        // Extract rotation (remove scale)
        var invScaleX = scaleX != 0 ? 1.0 / scaleX : 0;
        var invScaleY = scaleY != 0 ? 1.0 / scaleY : 0;
        var invScaleZ = scaleZ != 0 ? 1.0 / scaleZ : 0;
        
        var rot = new Mat4(
            m.x00 * invScaleX, m.x01 * invScaleY, m.x02 * invScaleZ, 0,
            m.x10 * invScaleX, m.x11 * invScaleY, m.x12 * invScaleZ, 0,
            m.x20 * invScaleX, m.x21 * invScaleY, m.x22 * invScaleZ, 0,
            0, 0, 0, 1
        );
        
        var rotation = matToQuat(rot);
        
        // Extract translation
        var translation = new Vec3(m.x03, m.x13, m.x23);
        
        return {scale: scale, rotation: rotation, translation: translation};
    }
    
    /**
     * Convert to Transform (local transform - loses hierarchy info)
     */
    public function toTransform():Transform {
        var _srt3 = toScaleRotationTranslation();
        return new Transform(_srt3.translation, _srt3.rotation, _srt3.scale);
    }
    
    /**
     * Compute the inverse transform
     */
    public function inverse():GlobalTransform {
        return new GlobalTransform(matrix.inverse());
    }
    
    /**
     * Get the backward direction (-Z in world space)
     */
    public inline function backward():Vec3 {
        return transformDirection(new Vec3(0, 0, -1));
    }
    
    /**
     * Get the forward direction (+Z in world space)
     */
    public inline function forward():Vec3 {
        return transformDirection(new Vec3(0, 0, 1));
    }
    
    /**
     * Get the up direction (+Y in world space)
     */
    public inline function up():Vec3 {
        return transformDirection(new Vec3(0, 1, 0));
    }
    
    /**
     * Get the down direction (-Y in world space)
     */
    public inline function down():Vec3 {
        return transformDirection(new Vec3(0, -1, 0));
    }
    
    /**
     * Get the right direction (+X in world space)
     */
    public inline function right():Vec3 {
        return transformDirection(new Vec3(1, 0, 0));
    }
    
    /**
     * Get the left direction (-X in world space)
     */
    public inline function left():Vec3 {
        return transformDirection(new Vec3(-1, 0, 0));
    }
    
    /**
     * Convert to string representation
     */
    public function toString():String {
        var _srts = toScaleRotationTranslation();
        return 'GlobalTransform(translation: ${_srts.translation}, rotation: ${_srts.rotation}, scale: ${_srts.scale})';
    }
    
    // Helper functions
    
    private static function rotationToMatrix(q:Quat):Mat4 {
        var x2 = q.x * q.x;
        var y2 = q.y * q.y;
        var z2 = q.z * q.z;
        var xy = q.x * q.y;
        var xz = q.x * q.z;
        var yz = q.y * q.z;
        var wx = q.w * q.x;
        var wy = q.w * q.y;
        var wz = q.w * q.z;
        
        return new Mat4(
            1 - 2*(y2 + z2), 2*(xy - wz), 2*(xz + wy), 0,
            2*(xy + wz), 1 - 2*(x2 + z2), 2*(yz - wx), 0,
            2*(xz - wy), 2*(yz + wx), 1 - 2*(x2 + y2), 0,
            0, 0, 0, 1
        );
    }
    
    private static function matToQuat(m:Mat4):Quat {
        var trace = m.x00 + m.x11 + m.x22;
        var q:Quat;
        
        if (trace > 0) {
            var s = Math.sqrt(trace + 1) * 2;
            q = new Quat(
                (m.x21 - m.x12) / s,
                (m.x02 - m.x20) / s,
                (m.x10 - m.x01) / s,
                s / 4
            );
        } else if (m.x00 > m.x11 && m.x00 > m.x22) {
            var s = Math.sqrt(1 + m.x00 - m.x11 - m.x22) * 2;
            q = new Quat(
                s / 4,
                (m.x10 + m.x01) / s,
                (m.x02 + m.x20) / s,
                (m.x21 - m.x12) / s
            );
        } else if (m.x11 > m.x22) {
            var s = Math.sqrt(1 + m.x11 - m.x00 - m.x22) * 2;
            q = new Quat(
                (m.x10 + m.x01) / s,
                s / 4,
                (m.x21 + m.x12) / s,
                (m.x02 - m.x20) / s
            );
        } else {
            var s = Math.sqrt(1 + m.x22 - m.x00 - m.x11) * 2;
            q = new Quat(
                (m.x02 + m.x20) / s,
                (m.x21 + m.x12) / s,
                s / 4,
                (m.x10 - m.x01) / s
            );
        }
        
        return q.normalize();
    }
}
