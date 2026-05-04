package haxe.color;

/**
 * Linear RGB color space without gamma correction.
 * Used for physically accurate lighting calculations.
 */
class LinearRgba {
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
     * Create new linear RGB color
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
    public static function rgb(r:Float, g:Float, b:Float):LinearRgba {
        return new LinearRgba(r, g, b, 1.0);
    }

    /**
     * Create from r, g, b, a components
     */
    public static function rgba(r:Float, g:Float, b:Float, a:Float):LinearRgba {
        return new LinearRgba(r, g, b, a);
    }

    /**
     * Create from u8 values (0-255)
     */
    public static function rgbU8(r:Int, g:Int, b:Int):LinearRgba {
        var rf = r / 255.0;
        var gf = g / 255.0;
        var bf = b / 255.0;
        return new LinearRgba(
            ColorConversion.srgbComponentToLinear(rf),
            ColorConversion.srgbComponentToLinear(gf),
            ColorConversion.srgbComponentToLinear(bf),
            1.0
        );
    }

    /**
     * Create from u8 values with alpha
     */
    public static function rgbaU8(r:Int, g:Int, b:Int, a:Int):LinearRgba {
        var rf = r / 255.0;
        var gf = g / 255.0;
        var bf = b / 255.0;
        var af = a / 255.0;
        return new LinearRgba(
            ColorConversion.srgbComponentToLinear(rf),
            ColorConversion.srgbComponentToLinear(gf),
            ColorConversion.srgbComponentToLinear(bf),
            af
        );
    }

    // Pre-defined colors
    public static var BLACK(default, null):LinearRgba = new LinearRgba(0.0, 0.0, 0.0, 1.0);
    public static var WHITE(default, null):LinearRgba = new LinearRgba(1.0, 1.0, 1.0, 1.0);
    public static var RED(default, null):LinearRgba = new LinearRgba(1.0, 0.0, 0.0, 1.0);
    public static var GREEN(default, null):LinearRgba = new LinearRgba(0.0, 1.0, 0.0, 1.0);
    public static var BLUE(default, null):LinearRgba = new LinearRgba(0.0, 0.0, 1.0, 1.0);
    public static var YELLOW(default, null):LinearRgba = new LinearRgba(1.0, 1.0, 0.0, 1.0);
    public static var CYAN(default, null):LinearRgba = new LinearRgba(0.0, 1.0, 1.0, 1.0);
    public static var MAGENTA(default, null):LinearRgba = new LinearRgba(1.0, 0.0, 1.0, 1.0);
    public static var NONE(default, null):LinearRgba = new LinearRgba(0.0, 0.0, 0.0, 0.0);
    public static var TRANSPARENT(default, null):LinearRgba = new LinearRgba(0.0, 0.0, 0.0, 0.0);

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
     * Convert to Srgba
     */
    public function toSrgb():Srgba {
        return ColorConversion.linearToSrgba(this);
    }

    /**
     * Convert to Hsla
     */
    public function toHsla():Hsla {
        return ColorConversion.linearRgbaToHsla(this);
    }

    /**
     * Mix with another color (linear interpolation)
     * @param other The other color
     * @param t Interpolation factor (0.0 = this, 1.0 = other)
     */
    public function mix(other:LinearRgba, t:Float):LinearRgba {
        var t1 = HaxeMath.clamp(t, 0, 1);
        var t2 = 1.0 - t1;
        return new LinearRgba(
            red * t2 + other.red * t1,
            green * t2 + other.green * t1,
            blue * t2 + other.blue * t1,
            alpha * t2 + other.alpha * t1
        );
    }

    /**
     * Clamp all components to valid range [0.0, 1.0]
     */
    public function clamp():LinearRgba {
        return new LinearRgba(
            HaxeMath.clamp(red, 0, 1),
            HaxeMath.clamp(green, 0, 1),
            HaxeMath.clamp(blue, 0, 1),
            HaxeMath.clamp(alpha, 0, 1)
        );
    }

    /**
     * Calculate luminance (perceptual brightness)
     * Uses sRGB coefficients for luminance
     */
    public function luminance():Float {
        return 0.2126 * red + 0.7152 * green + 0.0722 * blue;
    }

    /**
     * Get grayscale version
     */
    public function grayscale():LinearRgba {
        var l = luminance();
        return new LinearRgba(l, l, l, alpha);
    }

    /**
     * Blend with another color using multiplication (in linear space)
     */
    public function multiply(other:LinearRgba):LinearRgba {
        return new LinearRgba(
            red * other.red,
            green * other.green,
            blue * other.blue,
            alpha * other.alpha
        );
    }

    /**
     * Blend using screen mode
     */
    public function screenBlend(other:LinearRgba):LinearRgba {
        return 1.0 - (1.0 - this) * (1.0 - other);
    }

    /**
     * Blend using overlay mode
     */
    public function overlayBlend(other:LinearRgba):LinearRgba {
        var result = new LinearRgba(0, 0, 0, alpha);
        
        // Red channel
        if (red < 0.5) {
            result.red = 2.0 * red * other.red;
        } else {
            result.red = 1.0 - 2.0 * (1.0 - red) * (1.0 - other.red);
        }
        
        // Green channel
        if (green < 0.5) {
            result.green = 2.0 * green * other.green;
        } else {
            result.green = 1.0 - 2.0 * (1.0 - green) * (1.0 - other.green);
        }
        
        // Blue channel
        if (blue < 0.5) {
            result.blue = 2.0 * blue * other.blue;
        } else {
            result.blue = 1.0 - 2.0 * (1.0 - blue) * (1.0 - other.blue);
        }
        
        result.alpha = alpha * other.alpha;
        return result;
    }

    /**
     * Blend using soft light mode
     */
    public function softLightBlend(other:LinearRgba):LinearRgba {
        var result = new LinearRgba(0, 0, 0, alpha);
        
        for (i in 0...3) {
            var base = getComponent(i);
            var blend = other.getComponent(i);
            var r:Float;
            
            if (blend < 0.5) {
                r = 2.0 * base * blend + base * base * (1.0 - 2.0 * blend);
            } else {
                r = HaxeMath.sqrt(base) - 2.0 * base * (blend - 0.5) + 2.0 * base * blend;
            }
            
            result.setComponent(i, HaxeMath.clamp(r, 0, 1));
        }
        
        result.alpha = alpha;
        return result;
    }

    /**
     * Blend using hard light mode
     */
    public function hardLightBlend(other:LinearRgba):LinearRgba {
        var result = new LinearRgba(0, 0, 0, alpha);
        
        for (i in 0...3) {
            var base = getComponent(i);
            var blend = other.getComponent(i);
            var r:Float;
            
            if (blend < 0.5) {
                r = 2.0 * base * blend;
            } else {
                r = 1.0 - 2.0 * (1.0 - base) * (1.0 - blend);
            }
            
            result.setComponent(i, HaxeMath.clamp(r, 0, 1));
        }
        
        result.alpha = alpha * other.alpha;
        return result;
    }

    /**
     * Blend using color dodge mode
     */
    public function colorDodgeBlend(other:LinearRgba):LinearRgba {
        var result = new LinearRgba(0, 0, 0, alpha);
        
        for (i in 0...3) {
            var base = getComponent(i);
            var blend = other.getComponent(i);
            var r:Float;
            
            if (blend >= 1.0) {
                r = 1.0;
            } else {
                r = HaxeMath.min(base / (1.0 - blend), 1.0);
            }
            
            result.setComponent(i, r);
        }
        
        result.alpha = alpha * other.alpha;
        return result;
    }

    /**
     * Blend using color burn mode
     */
    public function colorBurnBlend(other:LinearRgba):LinearRgba {
        var result = new LinearRgba(0, 0, 0, alpha);
        
        for (i in 0...3) {
            var base = getComponent(i);
            var blend = other.getComponent(i);
            var r:Float;
            
            if (blend <= 0.0) {
                r = 0.0;
            } else {
                r = HaxeMath.max(1.0 - (1.0 - base) / blend, 0.0);
            }
            
            result.setComponent(i, r);
        }
        
        result.alpha = alpha * other.alpha;
        return result;
    }

    /**
     * Blend using difference mode
     */
    public function differenceBlend(other:LinearRgba):LinearRgba {
        return HaxeMath.abs(this - other);
    }

    /**
     * Blend using exclusion mode
     */
    public function exclusionBlend(other:LinearRgba):LinearRgba {
        return this + other - 2.0 * this * other;
    }

    /**
     * Get lighter version
     * @param amount Amount to lighten (0.0-1.0)
     */
    public function lighter(amount:Float):LinearRgba {
        var factor = 1.0 + HaxeMath.clamp(amount, 0, 1);
        return new LinearRgba(
            HaxeMath.clamp(red * factor, 0, 1),
            HaxeMath.clamp(green * factor, 0, 1),
            HaxeMath.clamp(blue * factor, 0, 1),
            alpha
        );
    }

    /**
     * Get darker version
     * @param amount Amount to darken (0.0-1.0)
     */
    public function darker(amount:Float):LinearRgba {
        var factor = 1.0 - HaxeMath.clamp(amount, 0, 1);
        return new LinearRgba(
            red * factor,
            green * factor,
            blue * factor,
            alpha
        );
    }

    /**
     * Create a copy with modified values
     */
    public function withRed(r:Float):LinearRgba {
        return new LinearRgba(r, green, blue, alpha);
    }

    public function withGreen(g:Float):LinearRgba {
        return new LinearRgba(red, g, blue, alpha);
    }

    public function withBlue(b:Float):LinearRgba {
        return new LinearRgba(red, green, b, alpha);
    }

    public function withAlpha(a:Float):LinearRgba {
        return new LinearRgba(red, green, blue, a);
    }

    /**
     * Check equality (with epsilon tolerance)
     */
    public function equals(other:LinearRgba, epsilon:Float = 0.0001):Bool {
        return HaxeMath.abs(red - other.red) < epsilon
            && HaxeMath.abs(green - other.green) < epsilon
            && HaxeMath.abs(blue - other.blue) < epsilon
            && HaxeMath.abs(alpha - other.alpha) < epsilon;
    }

    /**
     * Distance squared to another color (Euclidean)
     */
    public function distanceSquared(other:LinearRgba):Float {
        var dr = red - other.red;
        var dg = green - other.green;
        var db = blue - other.blue;
        var da = alpha - other.alpha;
        return dr * dr + dg * dg + db * db + da * da;
    }

    /**
     * Distance to another color (Euclidean)
     */
    public function distance(other:LinearRgba):Float {
        return HaxeMath.sqrt(distanceSquared(other));
    }

    /**
     * String representation
     */
    public function toString():String {
        return 'LinearRgba(${HaxeMath.round(red, 3)}, ${HaxeMath.round(green, 3)}, ${HaxeMath.round(blue, 3)}, ${HaxeMath.round(alpha, 3)})';
    }

    /**
     * Clone the color
     */
    public function clone():LinearRgba {
        return new LinearRgba(red, green, blue, alpha);
    }

    // Operator overloads for Haxe
    @:op(A + B) public function add(other:LinearRgba):LinearRgba {
        return new LinearRgba(red + other.red, green + other.green, blue + other.blue, alpha + other.alpha);
    }

    @:op(A - B) public function sub(other:LinearRgba):LinearRgba {
        return new LinearRgba(red - other.red, green - other.green, blue - other.blue, alpha - other.alpha);
    }

    @:op(A * B) public function mul(other:LinearRgba):LinearRgba {
        return new LinearRgba(red * other.red, green * other.green, blue * other.blue, alpha * other.alpha);
    }

    @:op(A * B) public function mulScalar(s:Float):LinearRgba {
        return new LinearRgba(red * s, green * s, blue * s, alpha * s);
    }

    @:op(A / B) public function div(other:LinearRgba):LinearRgba {
        return new LinearRgba(red / other.red, green / other.green, blue / other.blue, alpha / other.alpha);
    }

    @:op(A / B) public function divScalar(s:Float):LinearRgba {
        return new LinearRgba(red / s, green / s, blue / s, alpha / s);
    }

    @:op(-A) public function negate():LinearRgba {
        return new LinearRgba(1.0 - red, 1.0 - green, 1.0 - blue, alpha);
    }

    @:op(A == B) public function eq(other:LinearRgba):Bool {
        return equals(other);
    }

    @:op(A != B) public function neq(other:LinearRgba):Bool {
        return !equals(other);
    }
}
