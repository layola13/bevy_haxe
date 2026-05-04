package haxe.math;

@:structInit
abstract Quat({x:Float, y:Float, z:Float, w:Float}) {
    public inline function new(?x:Float = 0, ?y:Float = 0, ?z:Float = 0, ?w:Float = 1) {
        this = {x: x, y: y, z: z, w: w};
    }
    
    public static inline function identity():Quat {
        return new Quat(0, 0, 0, 1);
    }
    
    public static inline function fromAxisAngle(axis:Vec3, angle:Float):Quat {
        var half = angle * 0.5;
        var s = Math.sin(half);
        return new Quat(axis.x * s, axis.y * s, axis.z * s, Math.cos(half));
    }
    
    @:op(A * B) public static function mul(a:Quat, b:Quat):Quat {
        return new Quat(
            a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
            a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,
            a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w,
            a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z
        );
    }
    
    @:from public static inline function fromVec4(v:Vec4):Quat {
        return new Quat(v.x, v.y, v.z, v.w);
    }
    
    @:to public inline function toVec4():Vec4 {
        return new Vec4(x, y, z, w);
    }
    
    public inline function conjugate():Quat {
        return new Quat(-x, -y, -z, w);
    }
    
    public inline function length():Float {
        return Math.sqrt(x * x + y * y + z * z + w * w);
    }
    
    public inline function lengthSquared():Float {
        return x * x + y * y + z * z + w * w;
    }
    
    public inline function normalized():Quat {
        var len = length();
        return len > 0 ? new Quat(x / len, y / len, z / len, w / len) : identity();
    }
    
    public inline function dot(other:Quat):Float {
        return x * other.x + y * other.y + z * other.z + w * other.w;
    }
    
    public inline function toMat4():Mat4 {
        var xx = x * x, yy = y * y, zz = z * z;
        var xy = x * y, xz = x * z, yz = y * z;
        var wx = w * x, wy = w * y, wz = w * z;
        
        return new Mat4(
            1 - 2 * (yy + zz), 2 * (xy + wz),     2 * (xz - wy),     0,
            2 * (xy - wz),     1 - 2 * (xx + zz), 2 * (yz + wx),     0,
            2 * (xz + wy),     2 * (yz - wx),     1 - 2 * (xx + yy), 0,
            0,                 0,                 0,                 1
        );
    }
    
    public function toString():String {
        return 'Quat($x, $y, $z, $w)';
    }
}
