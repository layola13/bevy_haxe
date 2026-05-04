package haxe.math;

abstract Vec2({x:Float, y:Float}) {
    public inline function new(x:Float = 0, y:Float = 0) {
        this = {x: x, y: y};
    }
    
    public static var ZERO(get, never):Vec2;
    public static var ONE(get, never):Vec2;
    public static var X(get, never):Vec2;
    public static var Y(get, never):Vec2;
    
    private static inline function get_ZERO():Vec2 return new Vec2(0, 0);
    private static inline function get_ONE():Vec2 return new Vec2(1, 1);
    private static inline function get_X():Vec2 return new Vec2(1, 0);
    private static inline function get_Y():Vec2 return new Vec2(0, 1);
    
    @:op(A + B) public static function add(a:Vec2, b:Vec2):Vec2 {
        return new Vec2(a.x + b.x, a.y + b.y);
    }
    
    @:op(A - B) public static function sub(a:Vec2, b:Vec2):Vec2 {
        return new Vec2(a.x - b.x, a.y - b.y);
    }
    
    @:op(A * B) public static function mul(a:Vec2, b:Vec2):Vec2 {
        return new Vec2(a.x * b.x, a.y * b.y);
    }
    
    @:op(A * B) public static function scale(a:Vec2, b:Float):Vec2 {
        return new Vec2(a.x * b, a.y * b);
    }
    
    @:op(-A) public static function neg(a:Vec2):Vec2 {
        return new Vec2(-a.x, -a.y);
    }
    
    public inline function length():Float {
        return Math.sqrt(x * x + y * y);
    }
    
    public inline function lengthSquared():Float {
        return x * x + y * y;
    }
    
    public inline function dot(other:Vec2):Float {
        return x * other.x + y * other.y;
    }
    
    public inline function cross(other:Vec2):Float {
        return x * other.y - y * other.x;
    }
    
    public inline function normalize():Vec2 {
        var len = length();
        return len > 0.0001 ? this * (1.0 / len) : ZERO;
    }
    
    public inline function distance(other:Vec2):Float {
        return (this - other).length();
    }
    
    public inline function lerp(other:Vec2, t:Float):Vec2 {
        return this + (other - this) * t;
    }
    
    public inline function rotate(angle:Float):Vec2 {
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);
        return new Vec2(x * cos - y * sin, x * sin + y * cos);
    }
    
    public inline function perpendicular():Vec2 {
        return new Vec2(-y, x);
    }
    
    public function toString():String {
        return 'Vec2($x, $y)';
    }
    
    public function equals(other:Vec2):Bool {
        return x == other.x && y == other.y;
    }
    
    public function hashCode():Int {
        return Std.int(x * 73856093) ^ Std.int(y * 19349663);
    }
}
