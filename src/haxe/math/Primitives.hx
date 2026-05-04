package haxe.math;

@:structInit
class Circle {
    public var radius:Float;
    
    public inline function new(radius:Float = 0.5) {
        this.radius = radius;
    }
    
    public inline function diameter():Float {
        return radius * 2;
    }
    
    public inline function circumference():Float {
        return radius * Math.PI * 2;
    }
    
    public inline function area():Float {
        return radius * radius * Math.PI;
    }
    
    public inline function closestPoint(point:Vec2):Vec2 {
        var dx = point.x;
        var dy = point.y;
        var len = Math.sqrt(dx * dx + dy * dy);
        if (len > radius) {
            var invLen = radius / len;
            return new Vec2(dx * invLen, dy * invLen);
        }
        return point;
    }
    
    public function toString():String {
        return 'Circle($radius)';
    }
}

@:structInit
class Sphere {
    public var radius:Float;
    
    public inline function new(radius:Float = 0.5) {
        this.radius = radius;
    }
    
    public inline function diameter():Float {
        return radius * 2;
    }
    
    public inline function surfaceArea():Float {
        return 4 * Math.PI * radius * radius;
    }
    
    public inline function volume():Float {
        return (4 / 3) * Math.PI * radius * radius * radius;
    }
    
    public inline function closestPoint(point:Vec3):Vec3 {
        var lenSq = point.lengthSquared();
        if (lenSq > radius * radius) {
            var invLen = radius / Math.sqrt(lenSq);
            return point * invLen;
        }
        return point;
    }
    
    public function toString():String {
        return 'Sphere($radius)';
    }
}

@:structInit
class Capsule {
    public var radius:Float;
    public var halfSegment:Float;
    
    public inline function new(radius:Float = 0.5, halfSegment:Float = 0.5) {
        this.radius = radius;
        this.halfSegment = halfSegment;
    }
    
    public inline function diameter():Float {
        return radius * 2;
    }
    
    public inline function segment():Float {
        return halfSegment * 2;
    }
    
    public inline function surfaceArea():Float {
        var r = radius;
        var h = segment();
        // Surface area = 2πr(2r + h)
        return 2 * Math.PI * r * (2 * r + h);
    }
    
    public inline function volume():Float {
        var r = radius;
        var h = segment();
        // Volume = πr²(4r/3 + h)
        return Math.PI * r * r * (4 * r / 3 + h);
    }
    
    public function toString():String {
        return 'Capsule($radius, $halfSegment)';
    }
}

@:structInit
class Plane {
    public var normal:Dir3;
    public var dist:Float;
    
    public inline function new(normal:Dir3, dist:Float = 0) {
        this.normal = normal;
        this.dist = dist;
    }
    
    public static inline function fromNormalAndDistance(normal:Vec3, dist:Float):Plane {
        var dir = Dir3.fromVec3(normal);
        return new Plane(dir != null ? dir : Dir3.Y, dist);
    }
    
    public static inline function fromPointNormal(point:Vec3, normal:Vec3):Plane {
        var dir = Dir3.fromVec3(normal);
        return new Plane(dir != null ? dir : Dir3.Y, point.dot(dir != null ? dir : Dir3.Y));
    }
    
    public inline function distance(point:Vec3):Float {
        return normal.x * point.x + normal.y * point.y + normal.z * point.z - dist;
    }
    
    public inline function signedDistance(point:Vec3):Float {
        return distance(point);
    }
    
    public inline function projectPoint(point:Vec3):Vec3 {
        var d = distance(point);
        return point - new Vec3(normal.x * d, normal.y * d, normal.z * d);
    }
    
    public function toString():String {
        return 'Plane(${normal}, $dist)';
    }
}
