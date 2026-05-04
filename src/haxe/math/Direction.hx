package haxe.math;

enum InvalidDirectionError {
    Zero;
    Infinite;
    NaN;
}

@:forward(x, y, z)
abstract Dir3({x:Float, y:Float, z:Float}) {
    public inline function new(x:Float, y:Float, z:Float) {
        this = {x: x, y: y, z: z};
    }
    
    public static var X(get, never):Dir3;
    public static var Y(get, never):Dir3;
    public static var Z(get, never):Dir3;
    
    private static inline function get_X():Dir3 {
        return new Dir3(1, 0, 0);
    }
    
    private static inline function get_Y():Dir3 {
        return new Dir3(0, 1, 0);
    }
    
    private static inline function get_Z():Dir3 {
        return new Dir3(0, 0, 1);
    }
    
    @:from public static function fromVec3(v:Vec3):Null<Dir3> {
        var len = v.length();
        if (len < 0.0001) return null;
        if (!Math.isFinite(len)) return null;
        var invLen = 1 / len;
        return new Dir3(v.x * invLen, v.y * invLen, v.z * invLen);
    }
    
    @:to public inline function toVec3():Vec3 {
        return new Vec3(this.x, this.y, this.z);
    }
    
    public inline function length():Float {
        return Math.sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
    }
    
    public inline function dot(other:Dir3):Float {
        return this.x * other.x + this.y * other.y + this.z * other.z;
    }
    
    public inline function cross(other:Dir3):Dir3 {
        return new Dir3(
            this.y * other.z - this.z * other.y,
            this.z * other.x - this.x * other.z,
            this.x * other.y - this.y * other.x
        );
    }
    
    public inline function normalize():Dir3 {
        var len = length();
        if (len > 0) {
            var invLen = 1 / len;
            return new Dir3(this.x * invLen, this.y * invLen, this.z * invLen);
        }
        return X;
    }
    
    public function toString():String {
        return 'Dir3(${this.x}, ${this.y}, ${this.z})';
    }
}
