package haxe.math;

abstract Quat(Array<Float>) {
    public inline function new(?x:Float = 0, ?y:Float = 0, ?z:Float = 0, ?w:Float = 1) {
        this = [x, y, z, w];
    }

    public var x(get, set):Float; private inline function get_x():Float return this[0]; private inline function set_x(v:Float):Float return this[0] = v;
    public var y(get, set):Float; private inline function get_y():Float return this[1]; private inline function set_y(v:Float):Float return this[1] = v;
    public var z(get, set):Float; private inline function get_z():Float return this[2]; private inline function set_z(v:Float):Float return this[2] = v;
    public var w(get, set):Float; private inline function get_w():Float return this[3]; private inline function set_w(v:Float):Float return this[3] = v;

    public static var IDENTITY(get, never):Quat;
    private static inline function get_IDENTITY():Quat return new Quat(0, 0, 0, 1);

    public static inline function identity():Quat return IDENTITY;

    public static function fromAxisAngle(axis:Vec3, angle:Float):Quat {
        var half = angle * 0.5;
        var s = Math.sin(half);
        return new Quat(axis.x * s, axis.y * s, axis.z * s, Math.cos(half));
    }

    public static function fromEuler(x:Float, y:Float, z:Float):Quat {
        var sx = Math.sin(x * 0.5), cx = Math.cos(x * 0.5);
        var sy = Math.sin(y * 0.5), cy = Math.cos(y * 0.5);
        var sz = Math.sin(z * 0.5), cz = Math.cos(z * 0.5);
        return new Quat(
            sx * cy * cz - cx * sy * sz,
            cx * sy * cz + sx * cy * sz,
            cx * cy * sz - sx * sy * cz,
            cx * cy * cz + sx * sy * sz
        );
    }

    public static function fromRotationMatrix(m:Mat4):Quat {
        var trace = m.x00 + m.x11 + m.x22;
        if (trace > 0) {
            var s = Math.sqrt(trace + 1) * 2;
            return new Quat((m.x21 - m.x12) / s, (m.x02 - m.x20) / s, (m.x10 - m.x01) / s, s * 0.25);
        }
        var a = m.x00 > m.x11 ? (m.x00 > m.x22 ? 0 : 2) : (m.x11 > m.x22 ? 1 : 2);
        var b = (a + 1) % 3;
        var c = (a + 2) % 3;
        var s = Math.sqrt(1 + m['x${a}${a}'] - m['x${b}${b}'] - m['x${c}${c}']) * 2;
        var q = [0, 0, 0, 0];
        q[a] = s * 0.25;
        q[b] = (m['x${b}${a}'] + m['x${a}${b}']) / s;
        q[c] = (m['x${c}${a}'] + m['x${a}${c}']) / s;
        q[3] = (m['x${c}${b}'] - m['x${b}${c}']) / s;
        return new Quat(q[0], q[1], q[2], q[3]);
    }

    @:op(A * B) public static function mul(a:Quat, b:Quat):Quat {
        return new Quat(
            a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
            a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,
            a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w,
            a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z
        );
    }

    @:from public static inline function fromVec4(v:Vec4):Quat return new Quat(v.x, v.y, v.z, v.w);
    @:to public inline function toVec4():Vec4 return new Vec4(x, y, z, w);

    public inline function conjugate():Quat return new Quat(-x, -y, -z, w);

    public inline function length():Float return Math.sqrt(x*x + y*y + z*z + w*w);

    public inline function lengthSquared():Float return x*x + y*y + z*z + w*w;

    public inline function normalize():Quat {
        var len = length();
        return len > 0 ? new Quat(x/len, y/len, z/len, w/len) : IDENTITY;
    }

    public inline function inverse():Quat {
        var lenSq = lengthSquared();
        return lenSq > 0 ? conjugate() / lenSq : IDENTITY;
    }

    public inline function dot(other:Quat):Float return x * other.x + y * other.y + z * other.z + w * other.w;

    public inline function mulVec3(v:Vec3):Vec3 {
        var qv = new Vec3(x, y, z);
        var uv = qv.cross(v).scale(2);
        var uuv = qv.cross(uv);
        return v + uv.scale(w) + uuv;
    }

    public inline function toEuler():Vec3 {
        var sinr_cosp = 2 * (w * x + y * z);
        var cosr_cosp = 1 - 2 * (x * x + y * y);
        var roll = Math.atan2(sinr_cosp, cosr_cosp);

        var sinp = 2 * (w * y - z * x);
        var pitch = Math.abs(sinp) >= 1 ? (sinp > 0 ? Math.PI / 2 : -Math.PI / 2) : Math.asin(sinp);

        var siny_cosp = 2 * (w * z + x * y);
        var cosy_cosp = 1 - 2 * (y * y + z * z);
        var yaw = Math.atan2(siny_cosp, cosy_cosp);

        return new Vec3(roll, pitch, yaw);
    }

    public inline function lerp(other:Quat, t:Float):Quat {
        var cosOmega = dot(other);
        var sign = cosOmega >= 0 ? 1.0 : -1.0;
        return ((this + (other * sign - this) * t) / length()).normalize();
    }

    public inline function angleTo(other:Quat):Float {
        var cosOmega = Math.min(Math.abs(dot(other)), 1);
        return cosOmega > 0.9999 ? 0 : Math.acos(cosOmega) * 2;
    }

    public function toMat4():Mat4 {
        var xx = x * x, xy = x * y, xz = x * z, xw = x * w;
        var yy = y * y, yz = y * z, yw = y * w;
        var zz = z * z, zw = z * w;
        return new Mat4(
            1 - 2*(yy + zz), 2*(xy - zw), 2*(xz + yw), 0,
            2*(xy + zw), 1 - 2*(xx + zz), 2*(yz - xw), 0,
            2*(xz - yw), 2*(yz + xw), 1 - 2*(xx + yy), 0,
            0, 0, 0, 1
        );
    }

    public function toString():String return 'Quat($x, $y, $z, $w)';

    @:op(A / B) public static function divScalar(a:Quat, b:Float):Quat {
        return new Quat(a.x / b, a.y / b, a.z / b, a.w / b);
    }
}
