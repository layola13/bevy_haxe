package haxe.math;

@:structInit
abstract Rect({x:Float, y:Float, width:Float, height:Float}) {
    public inline function new(?x:Float = 0, ?y:Float = 0, ?width:Float = 0, ?height:Float = 0) {
        this = {x: x, y: y, width: width, height: height};
    }
    
    public static inline function fromMinMax(min:Vec2, max:Vec2):Rect {
        return new Rect(min.x, min.y, max.x - min.x, max.y - min.y);
    }
    
    public static inline function fromCenterSize(center:Vec2, size:Vec2):Rect {
        var half = size * 0.5;
        return new Rect(center.x - half.x, center.y - half.y, size.x, size.y);
    }
    
    public var min(get, never):Vec2;
    public var max(get, never):Vec2;
    public var halfSize(get, never):Vec2;
    
    private inline function get_min():Vec2 return new Vec2(x, y);
    private inline function get_max():Vec2 return new Vec2(x + width, y + height);
    private inline function get_halfSize():Vec2 return new Vec2(width * 0.5, height * 0.5);
    
    public inline function center():Vec2 {
        return new Vec2(x + width * 0.5, y + height * 0.5);
    }
    
    public inline function area():Float {
        return width * height;
    }
    
    public inline function contains(point:Vec2):Bool {
        return point.x >= x && point.x <= x + width &&
               point.y >= y && point.y <= y + height;
    }
    
    public inline function containsRect(other:Rect):Bool {
        return other.x >= x && other.x + other.width <= x + width &&
               other.y >= y && other.y + other.height <= y + height;
    }
    
    public inline function intersects(other:Rect):Bool {
        return x < other.x + other.width && x + width > other.x &&
               y < other.y + other.height && y + height > other.y;
    }
    
    public inline function merge(other:Rect):Rect {
        var minX = x < other.x ? x : other.x;
        var minY = y < other.y ? y : other.y;
        var maxX = (x + width) > (other.x + other.width) ? (x + width) : (other.x + other.width);
        var maxY = (y + height) > (other.y + other.height) ? (y + height) : (other.y + other.height);
        return new Rect(minX, minY, maxX - minX, maxY - minY);
    }
    
    public inline function intersect(other:Rect):Rect {
        var minX = x > other.x ? x : other.x;
        var minY = y > other.y ? y : other.y;
        var maxX = (x + width) < (other.x + other.width) ? (x + width) : (other.x + other.width);
        var maxY = (y + height) < (other.y + other.height) ? (y + height) : (other.y + other.height);
        if (minX > maxX || minY > maxY) {
            return new Rect(maxX, maxY, 0, 0);
        }
        return new Rect(minX, minY, maxX - minX, maxY - minY);
    }
    
    public inline function inflate(amount:Float):Rect {
        return new Rect(x - amount, y - amount, width + amount * 2, height + amount * 2);
    }
    
    public inline function isEmpty():Bool {
        return width <= 0 || height <= 0;
    }
    
    public function toString():String {
        return 'Rect($x, $y, $width, $height)';
    }
}
