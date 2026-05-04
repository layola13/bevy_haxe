package haxe.math;

abstract Quat(Array<Float>) {
    public inline function new(?x:Float = 0, ?y:Float = 0, ?z:Float = 0, ?w:Float = 1) {
        this = [x, y, z, w];
    }
    
    public var x(get, set):Float;
    public var y(get, set):Float;
    public var z(get, set):Float;
    public var w(get, set):Float;
    
    private inline function get_x():Float return this[0];
    private inline function set_x(v:Float):Float return this[0] = v;
    private inline function get_y():Float return this[1];
    private inline function set_y(v:Float):Float return this[1] = v;
    private inline function get_z():Float return this[2];
    private inline function set_z(v:Float):Float return this[2] = v;
    private inline function get_w():Float return this[3];
    private inline function set_w(v:Float):Float return this[3] = v;
    
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
        return Math.sqrt(x*x + y*y + z*z + w*w);
    }
    
    public inline function normalize():Quat {
        var len = length();
        return len > 0 ? new Quat(x/len, y/len, z/len, w/len) : identity();
    }
    
    public function toString():String {
        return 'Quat($x, $y, $z, $w)';
    }
}
