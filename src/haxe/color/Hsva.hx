package haxe.color;

/**
 * HSV (Hue-Saturation-Value) color space with alpha.
 * A cylindrical color space that is intuitive for adjusting colors.
 */
class Hsva {
    /**
     * Hue channel [0.0, 360.0]
     */
    public var hue:Float;

    /**
     * Saturation channel [0.0, 1.0]
     */
    public var saturation:Float;

    /**
     * Value channel [0.0, 1.0]
     */
    public var value:Float;

    /**
     * Alpha channel [0.0, 1.0]
     */
    public var alpha:Float;

    // ==================== Constants ====================
    
    /** Black color (H=0, S=0, V=0) */
    public static inline var BLACK:Float = 0.0;
    
    /** White color (H=0, S=0, V=1) */
    public static inline var WHITE:Float = 1.0;
    
    /** None/transparent color (H=0, S=0, V=0, A=0) */
    public static inline var NONE:Float = 0.0;

    /**
     * Create new HSV color
     */
    public function new(hue:Float, saturation:Float, value:Float, alpha:Float = 1.0) {
        this.hue = hue;
        this.saturation = saturation;
        this.value = value;
        this.alpha = alpha;
    }

    /**
     * Create from h, s, v components (alpha = 1.0)
     */
    public static function hsv(h:Float, s:Float, v:Float):Hsva {
        return new Hsva(h, s, v, 1.0);
    }

    /**
     * Create from h, s, v, a components
     */
    public static function hsva(h:Float, s:Float, v:Float, a:Float):Hsva {
        return new Hsva(h, s, v, a);
    }

    /**
     * Normalize hue to [0, 360) range
     */
    public function normalizeHue():Float {
        var h = hue % 360.0;
        if (h < 0) h += 360.0;
        return h;
    }

    // ==================== Conversions ====================

    /**
     * Convert to Srgba
     */
    public function toSrgba():Srgba {
        return ColorConversion.hsvToSrgba(this);
    }

    /**
     * Convert to LinearRgba
     */
    public function toLinearRgba():LinearRgba {
        return ColorConversion.hsvToLinearRgba(this);
    }

    /**
     * Convert to Hsla
     */
    public function toHsla():Hsla {
        return ColorConversion.hsvToHsla(this);
    }

    /**
     * Create from Srgba
     */
    public static function fromSrgba(srgba:Srgba):Hsva {
        return ColorConversion.srgbaToHsv(srgba);
    }

    /**
     * Create from LinearRgba
     */
    public static function fromLinearRgba(linear:LinearRgba):Hsva {
        return ColorConversion.linearRgbaToHsv(linear);
    }

    /**
     * Create from Hsla
     */
    public static function fromHsla(hsla:Hsla):Hsva {
        return ColorConversion.hslaToHsv(hsla);
    }

    /**
     * Convert to array [r, g, b, a]
     */
    public function toArray():Array<Float> {
        var srgba = toSrgba();
        return [srgba.red, srgba.green, srgba.blue, srgba.alpha];
    }

    // ==================== Component Access ====================

    /**
     * Get component by index (0=h, 1=s, 2=v, 3=a)
     */
    public function getComponent(index:Int):Float {
        return switch(index) {
            case 0: hue;
            case 1: saturation;
            case 2: value;
            case 3: alpha;
            default: 0.0;
        }
    }

    /**
     * Set component by index
     */
    public function setComponent(index:Int, v:Float):Void {
        switch(index) {
            case 0: hue = v;
            case 1: saturation = v;
            case 2: value = v;
            case 3: alpha = v;
            default:
        }
    }

    // ==================== Color Operations ====================

    /**
     * Mix this color with another color (linear interpolation in HSV space)
     */
    public function mix(other:Hsva, factor:Float):Hsva {
        var f = HaxeMath.clamp(factor, 0, 1);
        var hue = HaxeMath.lerpHue(this.hue, other.hue, f);
        return new Hsva(
            hue,
            HaxeMath.lerp(this.saturation, other.saturation, f),
            HaxeMath.lerp(this.value, other.value, f),
            HaxeMath.lerp(this.alpha, other.alpha, f)
        );
    }

    /**
     * Get with new hue
     */
    public function withHue(h:Float):Hsva {
        return new Hsva(h, saturation, value, alpha);
    }

    /**
     * Get with new saturation
     */
    public function withSaturation(s:Float):Hsva {
        return new Hsva(hue, s, value, alpha);
    }

    /**
     * Get with new value
     */
    public function withValue(v:Float):Hsva {
        return new Hsva(hue, saturation, v, alpha);
    }

    /**
     * Get with new alpha
     */
    public function withAlpha(a:Float):Hsva {
        return new Hsva(hue, saturation, value, a);
    }

    /**
     * Get lighter version
     */
    public function lighter(amount:Float):Hsva {
        return new Hsva(
            hue,
            HaxeMath.max(0.0, saturation - amount),
            HaxeMath.min(1.0, value + amount),
            alpha
        );
    }

    /**
     * Get darker version
     */
    public function darker(amount:Float):Hsva {
        return lighter(-amount);
    }

    /**
     * Get grayscale version (value preserved)
     */
    public function grayscale():Hsva {
        return new Hsva(0, 0, value, alpha);
    }

    // ==================== Utility ====================

    /**
     * Check equality with epsilon comparison
     */
    public function equals(other:Hsva, epsilon:Float = 0.0001):Bool {
        return HaxeMath.abs(hue - other.hue) < epsilon &&
               HaxeMath.abs(saturation - other.saturation) < epsilon &&
               HaxeMath.abs(value - other.value) < epsilon &&
               HaxeMath.abs(alpha - other.alpha) < epsilon;
    }

    /**
     * String representation
     */
    public function toString():String {
        return 'Hsva(${HaxeMath.round(hue, 1)}, ${HaxeMath.round(saturation, 3)}, ${HaxeMath.round(value, 3)}, ${HaxeMath.round(alpha, 3)})';
    }

    /**
     * Clone the color
     */
    public function clone():Hsva {
        return new Hsva(hue, saturation, value, alpha);
    }

    // ==================== Operator Overloads ====================

    @:op(A == B) public function eq(other:Hsva):Bool {
        return equals(other);
    }

    @:op(A != B) public function neq(other:Hsva):Bool {
        return !equals(other);
    }
}
