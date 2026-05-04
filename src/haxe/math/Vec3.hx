package haxe.math;

abstract Vec3({x:Float, y:Float, z:Float}) {
    public inline function new(x:Float = 0, y:Float = 0, z:Float = 0) {
        this = {x: x, y: y, z: z};
    }

    public static var ZERO(get, never):Vec3;
    public static var ONE(get, never):Vec3;
    public static var X(get, never):Vec3;
    public static var Y(get, never):Vec3;
    public static var Z(get, never):Vec3;
    public static var NEG_X(get, never):Vec3;
    public static var NEG_Y(get, never):Vec3;
    public static var NEG_Z(get, never):Vec3;

    private static inline function get_ZERO():Vec3 return new Vec3(0, 0, 0);
    private static inline function get_ONE():Vec3 return new Vec3(1, 1, 1);
    private static inline function get_X():Vec3 return new Vec3(1, 0, 0);
    private static inline function get_Y():Vec3 return new Vec3(0, 1, 0);
    private static inline function get_Z():Vec3 return new Vec3(0, 0, 1);
    private static inline function get_NEG_X():Vec3 return new Vec3(-1, 0, 0);
    private static inline function get_NEG_Y():Vec3 return new Vec3(0, -1, 0);
    private static inline function get_NEG_Z():Vec3 return new Vec3(0, 0, -1);

    // Component swizzling (Bevy compatibility)
    public var r(get, set):Float; inline function get_r():Float return x; inline function set_r(v:Float):Float return x = v;
    public var g(get, set):Float; inline function get_g():Float return y; inline function set_g(v:Float):Float return y = v;
    public var b(get, set):Float; inline function get_b():Float return z; inline function set_b(v:Float):Float return z = v;

    @:op(A + B) public static function add(a:Vec3, b:Vec3):Vec3 {
        return new Vec3(a.x + b.x, a.y + b.y, a.z + b.z);
    }

    @:op(A - B) public static function sub(a:Vec3, b:Vec3):Vec3 {
        return new Vec3(a.x - b.x, a.y - b.y, a.z - b.z);
    }

    @:op(A * B) public static function mul(a:Vec3, b:Vec3):Vec3 {
        return new Vec3(a.x * b.x, a.y * b.y, a.z * b.z);
    }

    @:op(A / B) public static function div(a:Vec3, b:Vec3):Vec3 {
        return new Vec3(a.x / b.x, a.y / b.y, a.z / b.z);
    }

    @:op(A * B) public static function scale(a:Vec3, b:Float):Vec3 {
        return new Vec3(a.x * b, a.y * b, a.z * b);
    }

    @:op(A / B) public static function divScalar(a:Vec3, b:Float):Vec3 {
        return new Vec3(a.x / b, a.y / b, a.z / b);
    }

    @:op(-A) public static function neg(a:Vec3):Vec3 {
        return new Vec3(-a.x, -a.y, -a.z);
    }

    public inline function length():Float {
        return Math.sqrt(x * x + y * y + z * z);
    }

    public inline function lengthSquared():Float {
        return x * x + y * y + z * z;
    }

    public inline function dot(other:Vec3):Float {
        return x * other.x + y * other.y + z * other.z;
    }

    public inline function cross(other:Vec3):Vec3 {
        return new Vec3(
            y * other.z - z * other.y,
            z * other.x - x * other.z,
            x * other.y - y * other.x
        );
    }

    public inline function normalize():Vec3 {
        var len = length();
        return len > 0.0001 ? this / len : ZERO;
    }

    public inline function distance(other:Vec3):Float {
        return (this - other).length();
    }

    public inline function distanceSquared(other:Vec3):Float {
        return (this - other).lengthSquared();
    }

    public inline function angleTo(other:Vec3):Float {
        var denom = length() * other.length();
        if (denom < 0.0001) return 0;
        var cos = Math.min(Math.max(dot(other) / denom, -1), 1);
        return Math.acos(cos);
    }

    public inline function lerp(other:Vec3, t:Float):Vec3 {
        return this + (other - this) * t;
    }

    public inline function abs():Vec3 {
        return new Vec3(Math.abs(x), Math.abs(y), Math.abs(z));
    }

    public inline function floor():Vec3 {
        return new Vec3(Math.floor(x), Math.floor(y), Math.floor(z));
    }

    public inline function ceil():Vec3 {
        return new Vec3(Math.ceil(x), Math.ceil(y), Math.ceil(z));
    }

    public inline function round():Vec3 {
        return new Vec3(Math.round(x), Math.round(y), Math.round(z));
    }

    public inline function min(other:Vec3):Vec3 {
        return new Vec3(x < other.x ? x : other.x, y < other.y ? y : other.y, z < other.z ? z : other.z);
    }

    public inline function max(other:Vec3):Vec3 {
        return new Vec3(x > other.x ? x : other.x, y > other.y ? y : other.y, z > other.z ? z : other.z);
    }

    public inline function clamp(minVal:Vec3, maxVal:Vec3):Vec3 {
        return this.max(minVal).min(maxVal);
    }

    public inline function isNormalized():Bool {
        return Math.abs(lengthSquared() - 1) < 0.0001;
    }

    public inline function anyOrthogonal():Vec3 {
        if (Math.abs(y) < 0.9) return new Vec3(0, 1, 0);
        return new Vec3(1, 0, 0);
    }

    @:from public static function fromVec2(v:Vec2, z:Float = 0):Vec3 {
        return new Vec3(v.x, v.y, z);
    }

    public inline function toVec2():Vec2 return new Vec2(x, y);

    public inline function toArray():Array<Float> return [x, y, z];

    public function toString():String return 'Vec3($x, $y, $z)';

    public inline function equals(other:Vec3):Bool {
        return x == other.x && y == other.y && z == other.z;
    }

    public inline function hashCode():Int {
        return Std.int(x * 73856093) ^ Std.int(y * 19349663) ^ Std.int(z * 83492791);
    }
}
