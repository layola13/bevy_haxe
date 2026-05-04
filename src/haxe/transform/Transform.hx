package haxe.transform;

import haxe.math.Vec3;
import haxe.math.Quat;
import haxe.math.Mat4;

/**
 * Transform represents the position, rotation, and scale of an entity.
 * 
 * If the entity has a parent, the Transform is relative to its parent's position.
 * If the entity has no parent (no Parent component), the Transform is in world space.
 * 
 * Use GlobalTransform to get the absolute world-space transform.
 */
class Transform implements haxe.ecs.Component {
    public var translation:Vec3;
    public var rotation:Quat;
    public var scale:Vec3;
    
    public var componentTypeId(get, never):Int;
    private static var _typeId:Int = -1;
    private static function get_componentTypeId():Int {
        if (_typeId < 0) _typeId = haxe.ecs.ComponentType.get(Transform);
        return _typeId;
    }
    
    public inline function new(?translation:Vec3, ?rotation:Quat, ?scale:Vec3) {
        this.translation = translation != null ? translation : Vec3.ZERO;
        this.rotation = rotation != null ? rotation : Quat.identity();
        this.scale = scale != null ? scale : Vec3.ONE;
    }
    
    /**
     * Create identity transform
     */
    public static function identity():Transform {
        return new Transform(Vec3.ZERO, Quat.identity(), Vec3.ONE);
    }
    
    /**
     * Create transform with only translation
     */
    public static function fromTranslation(translation:Vec3):Transform {
        return new Transform(translation, Quat.identity(), Vec3.ONE);
    }
    
    /**
     * Create transform with only rotation
     */
    public static function fromRotation(rotation:Quat):Transform {
        return new Transform(Vec3.ZERO, rotation, Vec3.ONE);
    }
    
    /**
     * Create transform with only scale
     */
    public static function fromScale(scale:Vec3):Transform {
        return new Transform(Vec3.ZERO, Quat.identity(), scale);
    }
    
    /**
     * Create transform from a matrix
     */
    public static function fromMatrix(matrix:Mat4):Transform {
        var srt = matrix.toScaleRotationTranslation();
        var scale = srt.scale;
        var rotation = srt.rotation;
        var translation = srt.translation;
        return new Transform(translation, rotation, scale);
    }
    
    /**
     * Apply a translation to this transform
     */
    public inline function withTranslation(translation:Vec3):Transform {
        return new Transform(translation, rotation, scale);
    }
    
    /**
     * Apply a translation offset to this transform
     */
    public inline function translate(offset:Vec3):Transform {
        return new Transform(translation + offset, rotation, scale);
    }
    
    /**
     * Apply a rotation to this transform
     */
    public inline function withRotation(rotation:Quat):Transform {
        return new Transform(translation, rotation, scale);
    }
    
    /**
     * Rotate by an axis-angle
     */
    public inline function rotateBy(axis:Vec3, angle:Float):Transform {
        var q = Quat.fromAxisAngle(axis, angle);
        return new Transform(translation, q * rotation, scale);
    }
    
    /**
     * Apply a scale to this transform
     */
    public inline function withScale(scale:Vec3):Transform {
        return new Transform(translation, rotation, scale);
    }
    
    /**
     * Apply a uniform scale to this transform
     */
    public inline function scaleBy(s:Float):Transform {
        return new Transform(translation, rotation, scale * s);
    }
    
    /**
     * Multiply two transforms (composes them)
     * Transform composition: this * other means apply other first, then this
     */
    @:op(A * B)
    public static function mul(a:Transform, b:Transform):Transform {
        return a.mulTransform(b);
    }
    
    /**
     * Compose this transform with another (apply other first, then this)
     */
    public inline function mulTransform(other:Transform):Transform {
        // Order matters: apply other first (local), then this (parent)
        // Position: parent's rotation/scale affects child's translation
        var newScale = other.scale * scale;
        var newRotation = rotation * other.rotation;
        
        // Translation in parent space, affected by parent's rotation and scale
        var scaledTranslation = other.translation * scale;
        var rotatedTranslation = rotateVec3ByQuat(scaledTranslation, rotation);
        var newTranslation = translation + rotatedTranslation;
        
        return new Transform(newTranslation, newRotation, newScale);
    }
    
    /**
     * Transform a point from local space to local space of this transform
     */
    public inline function transformPoint(point:Vec3):Vec3 {
        var scaled = point * scale;
        var rotated = rotateVec3ByQuat(scaled, rotation);
        return rotated + translation;
    }
    
    /**
     * Transform a direction vector (ignores translation)
     */
    public inline function transformDirection(dir:Vec3):Vec3 {
        var scaled = dir * scale;
        return rotateVec3ByQuat(scaled, rotation);
    }
    
    /**
     * Convert to 4x4 matrix
     */
    public function toMatrix():Mat4 {
        var rotMatrix = rotationToMatrix();
        return Mat4.fromTransform(translation, rotMatrix, scale);
    }
    
    /**
     * Look at a target point
     */
    public function lookAt(target:Vec3, ?up:Vec3):Transform {
        if (up == null) up = Vec3.Y;
        
        var forward = (target - translation).normalize();
        var right = up.cross(forward).normalize();
        var newUp = forward.cross(right);
        
        // Build rotation matrix and convert to quaternion
        var m = new Mat4(
            right.x, newUp.x, forward.x, 0,
            right.y, newUp.y, forward.y, 0,
            right.z, newUp.z, forward.z, 0,
            0, 0, 0, 1
        );
        
        return new Transform(translation, matToQuat(m), scale);
    }
    
    /**
     * Get the backward direction (-Z)
     */
    public inline function backward():Vec3 {
        return rotateDirection(new Vec3(0, 0, -1));
    }
    
    /**
     * Get the forward direction (+Z)
     */
    public inline function forward():Vec3 {
        return rotateDirection(new Vec3(0, 0, 1));
    }
    
    /**
     * Get the up direction (+Y)
     */
    public inline function up():Vec3 {
        return rotateDirection(new Vec3(0, 1, 0));
    }
    
    /**
     * Get the down direction (-Y)
     */
    public inline function down():Vec3 {
        return rotateDirection(new Vec3(0, -1, 0));
    }
    
    /**
     * Get the right direction (+X)
     */
    public inline function right():Vec3 {
        return rotateDirection(new Vec3(1, 0, 0));
    }
    
    /**
     * Get the left direction (-X)
     */
    public inline function left():Vec3 {
        return rotateDirection(new Vec3(-1, 0, 0));
    }
    
    /**
     * Rotate a direction vector by this transform's rotation
     */
    public inline function rotateDirection(dir:Vec3):Vec3 {
        return rotateVec3ByQuat(dir, rotation);
    }
    
    /**
     * Compute the inverse of this transform
     */
    public function inverse():Transform {
        var invRotation = rotation.conjugate().normalize();
        var invScale = new Vec3(
            scale.x != 0 ? 1.0 / scale.x : 0,
            scale.y != 0 ? 1.0 / scale.y : 0,
            scale.z != 0 ? 1.0 / scale.z : 0
        );
        var invTranslation = rotateVec3ByQuat(-translation, invRotation);
        invTranslation = invTranslation * invScale;
        
        return new Transform(invTranslation, invRotation, invScale);
    }
    
    /**
     * Interpolate between two transforms
     */
    public static function lerp(from:Transform, to:Transform, t:Float):Transform {
        return new Transform(
            from.translation.lerp(to.translation, t),
            quatSlerp(from.rotation, to.rotation, t),
            from.scale.lerp(to.scale, t)
        );
    }
    
    /**
     * Convert to a human-readable string
     */
    public function toString():String {
        return 'Transform(translation: $translation, rotation: $rotation, scale: $scale)';
    }
    
    // Helper functions
    
    private inline function rotationToMatrix():Mat4 {
        var x2 = rotation.x * rotation.x;
        var y2 = rotation.y * rotation.y;
        var z2 = rotation.z * rotation.z;
        var xy = rotation.x * rotation.y;
        var xz = rotation.x * rotation.z;
        var yz = rotation.y * rotation.z;
        var wx = rotation.w * rotation.x;
        var wy = rotation.w * rotation.y;
        var wz = rotation.w * rotation.z;
        
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
    
    private static inline function rotateVec3ByQuat(v:Vec3, q:Quat):Vec3 {
        // v' = q * v * q^(-1)
        // Optimized formula
        var ix = q.w * v.x + q.y * v.z - q.z * v.y;
        var iy = q.w * v.y + q.z * v.x - q.x * v.z;
        var iz = q.w * v.z + q.x * v.y - q.y * v.x;
        var iw = -q.x * v.x - q.y * v.y - q.z * v.z;
        
        return new Vec3(
            ix * q.w + iw * -q.x + iy * -q.z - iz * -q.y,
            iy * q.w + iw * -q.y + iz * -q.x - ix * -q.z,
            iz * q.w + iw * -q.z + ix * -q.y - iy * -q.x
        );
    }
    
    private static function quatSlerp(a:Quat, b:Quat, t:Float):Quat {
        var cosHalfAngle = a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w;
        
        // If dot product is negative, negate one quaternion to take shorter path
        var sign:Float = cosHalfAngle >= 0 ? 1 : -1;
        cosHalfAngle = Math.abs(cosHalfAngle);
        
        if (cosHalfAngle >= 0.9999) {
            // Nearly identical, use linear interpolation
            return new Quat(
                a.x + (b.x - a.x) * t * sign,
                a.y + (b.y - a.y) * t * sign,
                a.z + (b.z - a.z) * t * sign,
                a.w + (b.w - a.w) * t * sign
            ).normalize();
        }
        
        var halfAngle = Math.acos(cosHalfAngle);
        var sinHalfAngle = Math.sqrt(1 - cosHalfAngle * cosHalfAngle);
        
        var ratioA = Math.sin((1 - t) * halfAngle) / sinHalfAngle;
        var ratioB = Math.sin(t * halfAngle) / sinHalfAngle * sign;
        
        return new Quat(
            a.x * ratioA + b.x * ratioB,
            a.y * ratioA + b.y * ratioB,
            a.z * ratioA + b.z * ratioB,
            a.w * ratioA + b.w * ratioB
        );
    }
}
