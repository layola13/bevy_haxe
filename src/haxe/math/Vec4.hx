package haxe.math;

abstract Vec4({x:Float, y:Float, z:Float, w:Float}) {
    public inline function new(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 0) {
        this = {x: x, y: y, z: z, w: w};
    }
    
    public static var ZERO(get, never):Vec4;
    public static var ONE(get, never):Vec4;
    
    private static inline function get_ZERO():Vec4 return new Vec4(0, 0, 0, 0);
    private static inline function get_ONE():Vec4 return new Vec4(1, 1, 1, 1);
    
    @:op(A + B) public static function add(a:Vec4, b:Vec4):Vec4 {
        return new Vec4(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w);
    }
    
    @:op(A - B) public static function sub(a:Vec4, b:Vec4):Vec4 {
        return new Vec4(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w);
    }
    
    @:op(A * B) public static function mul(a:Vec4, b:Vec4):Vec4 {
        return new Vec4(a.x * b.x, a.y * b.y, a.z * b.z, a.w * b.w);
    }
    
    @:op(A * B) public static function scale(a:Vec4, b:Float):Vec4 {
        return new Vec4(a.x * b, a.y * b, a.z * b, a.w * b);
    }
    
    @:op(-A) public static function neg(a:Vec4):Vec4 {
        return new Vec4(-a.x, -a.y, -a.z, -a.w);
    }
    
    public inline function length():Float {
        return Math.sqrt(x * x + y * y + z * z + w * w);
    }
    
    public inline function dot(other:Vec4):Float {
        return x * other.x + y * other.y + z * other.z + w * other.w;
    }
    
    public inline function normalize():Vec4 {
        var len = length();
        return len > 0.0001 ? this * (1.0 / len) : ZERO;
    }
    
    public inline function lerp(other:Vec4, t:Float):Vec4 {
        return this + (other - this) * t;
    }
    
    public function toString():String {
        return 'Vec4($x, $y, $z, $w)';
    }
    
    @:from public static function fromVec3(v:Vec3, w:Float = 1):Vec4 {
        return new Vec4(v.x, v.y, v.z, w);
    }
    
    public inline function toVec3():Vec3 {
        return new Vec3(x, y, z);
    }
}
