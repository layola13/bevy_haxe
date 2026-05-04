package haxe.math;

class Mat4 {
    public var x00:Float; public var x01:Float; public var x02:Float; public var x03:Float;
    public var x10:Float; public var x11:Float; public var x12:Float; public var x13:Float;
    public var x20:Float; public var x21:Float; public var x22:Float; public var x23:Float;
    public var x30:Float; public var x31:Float; public var x32:Float; public var x33:Float;
    
    public inline function new(
        x00:Float = 1, x01:Float = 0, x02:Float = 0, x03:Float = 0,
        x10:Float = 0, x11:Float = 1, x12:Float = 0, x13:Float = 0,
        x20:Float = 0, x21:Float = 0, x22:Float = 1, x23:Float = 0,
        x30:Float = 0, x31:Float = 0, x32:Float = 0, x33:Float = 1
    ) {
        this.x00 = x00; this.x01 = x01; this.x02 = x02; this.x03 = x03;
        this.x10 = x10; this.x11 = x11; this.x12 = x12; this.x13 = x13;
        this.x20 = x20; this.x21 = x21; this.x22 = x22; this.x23 = x23;
        this.x30 = x30; this.x31 = x31; this.x32 = x32; this.x33 = x33;
    }
    
    public static var IDENTITY(get, never):Mat4;
    private static inline function get_IDENTITY():Mat4 return new Mat4();
    
    @:op(A * B) public static function mul(a:Mat4, b:Mat4):Mat4 {
        return new Mat4(
            a.x00*b.x00 + a.x01*b.x10 + a.x02*b.x20 + a.x03*b.x30,
            a.x00*b.x01 + a.x01*b.x11 + a.x02*b.x21 + a.x03*b.x31,
            a.x00*b.x02 + a.x01*b.x12 + a.x02*b.x22 + a.x03*b.x32,
            a.x00*b.x03 + a.x01*b.x13 + a.x02*b.x23 + a.x03*b.x33,
            a.x10*b.x00 + a.x11*b.x10 + a.x12*b.x20 + a.x13*b.x30,
            a.x10*b.x01 + a.x11*b.x11 + a.x12*b.x21 + a.x13*b.x31,
            a.x10*b.x02 + a.x11*b.x12 + a.x12*b.x22 + a.x13*b.x32,
            a.x10*b.x03 + a.x11*b.x13 + a.x12*b.x23 + a.x13*b.x33,
            a.x20*b.x00 + a.x21*b.x10 + a.x22*b.x20 + a.x23*b.x30,
            a.x20*b.x01 + a.x21*b.x11 + a.x22*b.x21 + a.x23*b.x31,
            a.x20*b.x02 + a.x21*b.x12 + a.x22*b.x22 + a.x23*b.x32,
            a.x20*b.x03 + a.x21*b.x13 + a.x22*b.x23 + a.x23*b.x33,
            a.x30*b.x00 + a.x31*b.x10 + a.x32*b.x20 + a.x33*b.x30,
            a.x30*b.x01 + a.x31*b.x11 + a.x32*b.x21 + a.x33*b.x31,
            a.x30*b.x02 + a.x31*b.x12 + a.x32*b.x22 + a.x33*b.x32,
            a.x30*b.x03 + a.x31*b.x13 + a.x32*b.x23 + a.x33*b.x33
        );
    }
    
    @:op(A * B) public static function mulVec(a:Mat4, v:Vec4):Vec4 {
        return new Vec4(
            a.x00*v.x + a.x01*v.y + a.x02*v.z + a.x03*v.w,
            a.x10*v.x + a.x11*v.y + a.x12*v.z + a.x13*v.w,
            a.x20*v.x + a.x21*v.y + a.x22*v.z + a.x23*v.w,
            a.x30*v.x + a.x31*v.y + a.x32*v.z + a.x33*v.w
        );
    }
    
    @:op(A * B) public static function mulVec3Dir(a:Mat4, v:Vec3):Vec3 {
        return new Vec3(
            a.x00*v.x + a.x01*v.y + a.x02*v.z,
            a.x10*v.x + a.x11*v.y + a.x12*v.z,
            a.x20*v.x + a.x21*v.y + a.x22*v.z
        );
    }
    
    public inline function transpose():Mat4 {
        return new Mat4(
            x00, x10, x20, x30,
            x01, x11, x21, x31,
            x02, x12, x22, x32,
            x03, x13, x23, x33
        );
    }
    
    public static function translation(x:Float, y:Float, z:Float):Mat4 {
        return new Mat4(1, 0, 0, x, 0, 1, 0, y, 0, 0, 1, z, 0, 0, 0, 1);
    }
    
    public static function scale(x:Float, y:Float, z:Float):Mat4 {
        return new Mat4(x, 0, 0, 0, 0, y, 0, 0, 0, 0, z, 0, 0, 0, 0, 1);
    }
    
    public static function rotationX(angle:Float):Mat4 {
        var c = Math.cos(angle);
        var s = Math.sin(angle);
        return new Mat4(1, 0, 0, 0, 0, c, -s, 0, 0, s, c, 0, 0, 0, 0, 1);
    }
    
    public static function rotationY(angle:Float):Mat4 {
        var c = Math.cos(angle);
        var s = Math.sin(angle);
        return new Mat4(c, 0, s, 0, 0, 1, 0, 0, -s, 0, c, 0, 0, 0, 0, 1);
    }
    
    public static function rotationZ(angle:Float):Mat4 {
        var c = Math.cos(angle);
        var s = Math.sin(angle);
        return new Mat4(c, -s, 0, 0, s, c, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
    }
    
    public static function perspective(fovY:Float, aspect:Float, near:Float, far:Float):Mat4 {
        var tanHalfFov = Math.tan(fovY / 2);
        var dz = far - near;
        return new Mat4(
            1 / (aspect * tanHalfFov), 0, 0, 0,
            0, 1 / tanHalfFov, 0, 0,
            0, 0, -(far + near) / dz, -1,
            0, 0, -(2 * far * near) / dz, 0
        );
    }
    
    public static function lookAt(eye:Vec3, center:Vec3, up:Vec3):Mat4 {
        var f = (center - eye).normalize();
        var s = f.cross(up).normalize();
        var u = s.cross(f);
        return new Mat4(
            s.x, u.x, -f.x, 0,
            s.y, u.y, -f.y, 0,
            s.z, u.z, -f.z, 0,
            -s.dot(eye), -u.dot(eye), f.dot(eye), 1
        );
    }
    
    public static function orthographic(left:Float, right:Float, bottom:Float, top:Float, near:Float, far:Float):Mat4 {
        var dx = right - left;
        var dy = top - bottom;
        var dz = far - near;
        return new Mat4(
            2/dx, 0, 0, -(right + left) / dx,
            0, 2/dy, 0, -(top + bottom) / dy,
            0, 0, -2/dz, -(far + near) / dz,
            0, 0, 0, 1
        );
    }
    
    public function toString():String {
        return 'Mat4(\n$x00, $x01, $x02, $x03\n$x10, $x11, $x12, $x13\n$x20, $x21, $x22, $x23\n$x30, $x31, $x32, $x33)';
    }
}
