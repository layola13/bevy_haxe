package haxe.color;

/**
 * Standard RGB color space (sRGB) with gamma correction.
 * This is the most common color space for displays and images.
 */
class Srgba {
    /**
     * Red component [0.0, 1.0]
     */
    public var red:Float;

    /**
     * Green component [0.0, 1.0]
     */
    public var green:Float;

    /**
     * Blue component [0.0, 1.0]
     */
    public var blue:Float;

    /**
     * Alpha component [0.0, 1.0]
     */
    public var alpha:Float;

    /**
     * Create new sRGB color
     */
    public function new(red:Float, green:Float, blue:Float, alpha:Float = 1.0) {
        this.red = red;
        this.green = green;
        this.blue = blue;
        this.alpha = alpha;
    }

    /**
     * Create from r, g, b components (alpha = 1.0)
     */
    public static function rgb(r:Float, g:Float, b:Float):Srgba {
        return new Srgba(r, g, b, 1.0);
    }

    /**
     * Create from r, g, b, a components
     */
    public static function rgba(r:Float, g:Float, b:Float, a:Float):Srgba {
        return new Srgba(r, g, b, a);
    }

    /**
     * Create from u8 values (0-255)
     */
    public static function rgbU8(r:Int, g:Int, b:Int):Srgba {
        return new Srgba(r / 255.0, g / 255.0, b / 255.0, 1.0);
    }

    /**
     * Create from u8 values with alpha
     */
    public static function rgbaU8(r:Int, g:Int, b:Int, a:Int):Srgba {
        return new Srgba(r / 255.0, g / 255.0, b / 255.0, a / 255.0);
    }

    /**
     * Create from hex string (e.g., "#FF5733" or "FF5733")
     */
    public static function fromHex(hex:String):Srgba {
        var h = hex.replace("#", "");
        
        if (h.length == 3) {
            // Expand short form: RGB -> RRGGBB
            h = h.charAt(0) + h.charAt(0) + h.charAt(1) + h.charAt(1) + h.charAt(2) + h.charAt(2);
        }
        
        if (h.length == 4) {
            // Expand short form with alpha: RGBA -> RRGGBBAA
            h = h.charAt(0) + h.charAt(0) + h.charAt(1) + h.charAt(1) + h.charAt(2) + h.charAt(2) + h.charAt(3) + h.charAt(3);
        }
        
        if (h.length == 6) {
            h += "FF";
        }
        
        if (h.length != 8) {
            return new Srgba(0, 0, 0, 1.0);
        }
        
        var r = Std.parseInt("0x" + h.substr(0, 2));
        var g = Std.parseInt("0x" + h.substr(2, 2));
        var b = Std.parseInt("0x" + h.substr(4, 2));
        var a = Std.parseInt("0x" + h.substr(6, 2));
        
        return rgbaU8(r, g, b, a);
    }

    // Pre-defined colors
    public static var BLACK(default, null):Srgba = new Srgba(0.0, 0.0, 0.0, 1.0);
    public static var WHITE(default, null):Srgba = new Srgba(1.0, 1.0, 1.0, 1.0);
    public static var RED(default, null):Srgba = new Srgba(1.0, 0.0, 0.0, 1.0);
    public static var GREEN(default, null):Srgba = new Srgba(0.0, 1.0, 0.0, 1.0);
    public static var BLUE(default, null):Srgba = new Srgba(0.0, 0.0, 1.0, 1.0);
    public static var YELLOW(default, null):Srgba = new Srgba(1.0, 1.0, 0.0, 1.0);
    public static var CYAN(default, null):Srgba = new Srgba(0.0, 1.0, 1.0, 1.0);
    public static var MAGENTA(default, null):Srgba = new Srgba(1.0, 0.0, 1.0, 1.0);
    public static var ORANGE(default, null):Srgba = new Srgba(1.0, 0.5, 0.0, 1.0);
    public static var PINK(default, null):Srgba = new Srgba(1.0, 0.0, 0.5, 1.0);
    public static var PURPLE(default, null):Srgba = new Srgba(0.5, 0.0, 0.5, 1.0);
    public static var TEAL(default, null):Srgba = new Srgba(0.0, 0.5, 0.5, 1.0);
    public static var LIME(default, null):Srgba = new Srgba(0.5, 1.0, 0.0, 1.0);
    public static var INDIGO(default, null):Srgba = new Srgba(0.3, 0.0, 0.5, 1.0);
    public static var VIOLET(default, null):Srgba = new Srgba(0.5, 0.0, 1.0, 1.0);
    public static var GOLD(default, null):Srgba = new Srgba(1.0, 0.8, 0.0, 1.0);
    public static var SILVER(default, null):Srgba = new Srgba(0.75, 0.75, 0.75, 1.0);
    public static var GRAY(default, null):Srgba = new Srgba(0.5, 0.5, 0.5, 1.0);
    public static var DARK_GRAY(default, null):Srgba = new Srgba(0.25, 0.25, 0.25, 1.0);
    public static var LIGHT_GRAY(default, null):Srgba = new Srgba(0.75, 0.75, 0.75, 1.0);
    public static var NONE(default, null):Srgba = new Srgba(0.0, 0.0, 0.0, 0.0);
    public static var TRANSPARENT(default, null):Srgba = new Srgba(0.0, 0.0, 0.0, 0.0);

    /**
     * Get component by index (0=r, 1=g, 2=b, 3=a)
     */
    public function getComponent(index:Int):Float {
        return switch(index) {
            case 0: red;
            case 1: green;
            case 2: blue;
            case 3: alpha;
            default: 0.0;
        }
    }

    /**
     * Set component by index
     */
    public function setComponent(index:Int, value:Float):Void {
        switch(index) {
            case 0: red = value;
            case 1: green = value;
            case 2: blue = value;
            case 3: alpha = value;
        }
    }

    /**
     * Convert to LinearRgba
     */
    public function toLinear():LinearRgba {
        return ColorConversion.srgbaToLinear(this);
    }

    /**
     * Convert to Hsla
     */
    public function toHsla():Hsla {
        return ColorConversion.srgbaToHsla(this);
    }

    /**
     * Mix with another color
     * @param other The other color
     * @param t Interpolation factor (0.0 = this, 1.0 = other)
     */
    public function mix(other:Srgba, t:Float):Srgba {
        var t1 = HaxeMath.clamp(t, 0, 1);
        var t2 = 1.0 - t1;
        return new Srgba(
            red * t2 + other.red * t1,
            green * t2 + other.green * t1,
            blue * t2 + other.blue * t1,
            alpha * t2 + other.alpha * t1
        );
    }

    /**
     * Clamp all components to valid range [0.0, 1.0]
     */
    public function clamp():Srgba {
        return new Srgba(
            HaxeMath.clamp(red, 0, 1),
            HaxeMath.clamp(green, 0, 1),
            HaxeMath.clamp(blue, 0, 1),
            HaxeMath.clamp(alpha, 0, 1)
        );
    }

    /**
     * Calculate luminance (perceptual brightness)
     */
    public function luminance():Float {
        return linearRgba().luminance();
    }

    /**
     * Get linear RGB for luminance calculation
     */
    public function linearRgba():LinearRgba {
        return toLinear();
    }

    /**
     * Blend with another color using screen blend mode
     */
    public function screenBlend(other:Srgba):Srgba {
        return 1.0 - (1.0 - this) * (1.0 - other);
    }

    /**
     * Convert to hex string
     */
    public function toHex():String {
        var r = Std.int(HaxeMath.clamp(red, 0, 1) * 255);
        var g = Std.int(HaxeMath.clamp(green, 0, 1) * 255);
        var b = Std.int(HaxeMath.clamp(blue, 0, 1) * 255);
        var a = Std.int(HaxeMath.clamp(alpha, 0, 1) * 255);
        
        if (a < 255) {
            return StringTools.hex(r, 2) + StringTools.hex(g, 2) + StringTools.hex(b, 2) + StringTools.hex(a, 2);
        }
        return StringTools.hex(r, 2) + StringTools.hex(g, 2) + StringTools.hex(b, 2);
    }

    /**
     * Create a copy with modified values
     */
    public function withRed(r:Float):Srgba {
        return new Srgba(r, green, blue, alpha);
    }

    public function withGreen(g:Float):Srgba {
        return new Srgba(red, g, blue, alpha);
    }

    public function withBlue(b:Float):Srgba {
        return new Srgba(red, green, b, alpha);
    }

    public function withAlpha(a:Float):Srgba {
        return new Srgba(red, green, blue, a);
    }

    /**
     * Check equality (with epsilon tolerance)
     */
    public function equals(other:Srgba, epsilon:Float = 0.0001):Bool {
        return HaxeMath.abs(red - other.red) < epsilon
            && HaxeMath.abs(green - other.green) < epsilon
            && HaxeMath.abs(blue - other.blue) < epsilon
            && HaxeMath.abs(alpha - other.alpha) < epsilon;
    }

    /**
     * String representation
     */
    public function toString():String {
        return 'Srgba(${HaxeMath.round(red, 3)}, ${HaxeMath.round(green, 3)}, ${HaxeMath.round(blue, 3)}, ${HaxeMath.round(alpha, 3)})';
    }

    /**
     * Clone the color
     */
    public function clone():Srgba {
        return new Srgba(red, green, blue, alpha);
    }

    // Operator overloads for Haxe
    @:op(A + B) public function add(other:Srgba):Srgba {
        return new Srgba(red + other.red, green + other.green, blue + other.blue, alpha + other.alpha);
    }

    @:op(A - B) public function sub(other:Srgba):Srgba {
        return new Srgba(red - other.red, green - other.green, blue - other.blue, alpha - other.alpha);
    }

    @:op(A * B) public function mul(other:Srgba):Srgba {
        return new Srgba(red * other.red, green * other.green, blue * other.blue, alpha * other.alpha);
    }

    @:op(A * B) public function mulScalar(s:Float):Srgba {
        return new Srgba(red * s, green * s, blue * s, alpha * s);
    }

    @:op(A / B) public function div(other:Srgba):Srgba {
        return new Srgba(red / other.red, green / other.green, blue / other.blue, alpha / other.alpha);
    }

    @:op(A / B) public function divScalar(s:Float):Srgba {
        return new Srgba(red / s, green / s, blue / s, alpha / s);
    }

    @:op(-A) public function negate():Srgba {
        return new Srgba(1.0 - red, 1.0 - green, 1.0 - blue, alpha);
    }

    @:op(A == B) public function eq(other:Srgba):Bool {
        return equals(other);
    }

    @:op(A != B) public function neq(other:Srgba):Bool {
        return !equals(other);
    }
}
