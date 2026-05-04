package haxe.color;

/**
 * Color conversion utilities for transforming between color spaces.
 * Provides bidirectional conversion between sRGB, Linear RGB, and HSL.
 */
class ColorConversion {
    // sRGB gamma correction parameters
    private static inline var SRGB_ALPHA:Float = 0.055;
    private static inline var GAMMA:Float = 2.4;
    private static inline var INV_GAMMA:Float = 1.0 / GAMMA;
    
    // sRGB to Linear RGB conversion threshold
    private static inline var LINEAR_THRESHOLD:Float = 0.04045;
    private static inline var LINEAR_DIVISOR:Float = 12.92;

    /**
     * Convert sRGB component to linear RGB
     */
    public static function srgbComponentToLinear(value:Float):Float {
        if (value <= 0.04045) {
            return value / LINEAR_DIVISOR;
        }
        return HaxeMath.pow((value + SRGB_ALPHA) / (1.0 + SRGB_ALPHA), GAMMA);
    }

    /**
     * Convert linear RGB component to sRGB
     */
    public static function linearComponentToSrgb(value:Float):Float {
        if (value <= LINEAR_THRESHOLD / LINEAR_DIVISOR) {
            return value * LINEAR_DIVISOR;
        }
        return (1.0 + SRGB_ALPHA) * HaxeMath.pow(value, INV_GAMMA) - SRGB_ALPHA;
    }

    // ==================== Srgba Conversions ====================

    /**
     * Convert Srgba to LinearRgba
     */
    public static function toLinearRgba(srgba:Srgba):LinearRgba {
        return srgbaToLinear(srgba);
    }

    /**
     * Convert Srgba to LinearRgba
     */
    public static function srgbaToLinear(srgba:Srgba):LinearRgba {
        return new LinearRgba(
            srgbComponentToLinear(srgba.red),
            srgbComponentToLinear(srgba.green),
            srgbComponentToLinear(srgba.blue),
            srgba.alpha
        );
    }

    /**
     * Convert Srgba to Hsla
     */
    public static function toHsla(srgba:Srgba):Hsla {
        return srgbaToHsla(srgba);
    }

    /**
     * Convert Srgba to Hsla
     */
    public static function srgbaToHsla(srgba:Srgba):Hsla {
        var linear = srgbaToLinear(srgba);
        return linearRgbaToHsla(linear);
    }

    // ==================== LinearRgba Conversions ====================

    /**
     * Convert LinearRgba to Srgba
     */
    public static function toSrgba(linear:LinearRgba):Srgba {
        return linearToSrgba(linear);
    }

    /**
     * Convert LinearRgba to Srgba
     */
    public static function linearToSrgba(linear:LinearRgba):Srgba {
        return new Srgba(
            linearComponentToSrgb(linear.red),
            linearComponentToSrgb(linear.green),
            linearComponentToSrgb(linear.blue),
            linear.alpha
        );
    }

    /**
     * Convert LinearRgba to Hsla
     */
    public static function linearRgbaToHsla(linear:LinearRgba):Hsla {
        var r = linear.red;
        var g = linear.green;
        var b = linear.blue;
        var a = linear.alpha;

        var maxVal = HaxeMath.max(r, HaxeMath.max(g, b));
        var minVal = HaxeMath.min(r, HaxeMath.min(g, b));
        var delta = maxVal - minVal;

        // Calculate lightness
        var lightness = (maxVal + minVal) / 2.0;

        // If achromatic (no saturation)
        if (delta < 0.00001) {
            return new Hsla(0.0, 0.0, lightness, a);
        }

        // Calculate saturation
        var saturation:Float;
        if (lightness < 0.5) {
            saturation = delta / (maxVal + minVal);
        } else {
            saturation = delta / (2.0 - maxVal - minVal);
        }

        // Calculate hue
        var hue:Float;
        if (maxVal == r) {
            hue = ((g - b) / delta) + (g < b ? 6.0 : 0.0);
        } else if (maxVal == g) {
            hue = ((b - r) / delta) + 2.0;
        } else {
            hue = ((r - g) / delta) + 4.0;
        }
        hue *= 60.0;

        return new Hsla(hue, saturation, lightness, a);
    }

    // ==================== Hsla Conversions ====================

    /**
     * Convert Hsla to Srgba
     */
    public static function hslaToSrgba(hsla:Hsla):Srgba {
        var linear = hslaToLinearRgba(hsla);
        return linearToSrgba(linear);
    }

    /**
     * Convert Hsla to LinearRgba
     */
    public static function hslaToLinearRgba(hsla:Hsla):LinearRgba {
        var h = hsla.hue;
        var s = hsla.saturation;
        var l = hsla.lightness;
        var a = hsla.alpha;

        // Normalize hue
        h = h % 360.0;
        if (h < 0) h += 360.0;

        // If achromatic (no saturation)
        if (s < 0.00001) {
            return new LinearRgba(l, l, l, a);
        }

        // Calculate chroma
        var chroma = (1.0 - HaxeMath.abs(2.0 * l - 1.0)) * s;

        // Calculate hue segment
        var hSegment = h / 60.0;
        var hSegmentFloor = HaxeMath.floor(hSegment);
        var hSegmentFrac = hSegment - hSegmentFloor;

        // Second largest component
        var secondLargest = chroma * (1.0 - HaxeMath.abs(hSegmentFrac * 2.0 - 1.0));

        // RGB offsets based on hue
        var r:Float, g:Float, b:Float;
        var offset = l - chroma / 2.0;

        switch(Std.int(hSegmentFloor) % 6) {
            case 0:
                r = chroma; g = secondLargest; b = 0.0;
            case 1:
                r = secondLargest; g = chroma; b = 0.0;
            case 2:
                r = 0.0; g = chroma; b = secondLargest;
            case 3:
                r = 0.0; g = secondLargest; b = chroma;
            case 4:
                r = secondLargest; g = 0.0; b = chroma;
            case 5:
                r = chroma; g = 0.0; b = secondLargest;
            default:
                r = 0.0; g = 0.0; b = 0.0;
        }

        return new LinearRgba(r + offset, g + offset, b + offset, a);
    }

    // ==================== Color Abstraction Conversions ====================

    /**
     * Convert Color to Srgba
     */
    public static function toSrgba(color:Color):Srgba {
        return switch(color) {
            case Color(SrgbaType(s)): s;
            case Color(LinearRgbaType(l)): linearToSrgba(l);
            case Color(HslaType(h)): hslaToSrgba(h);
        }
    }

    /**
     * Convert Color to LinearRgba
     */
    public static function toLinearRgba(color:Color):LinearRgba {
        return switch(color) {
            case Color(SrgbaType(s)): srgbaToLinear(s);
            case Color(LinearRgbaType(l)): l;
            case Color(HslaType(h)): hslaToLinearRgba(h);
        }
    }

    /**
     * Convert Color to Hsla
     */
    public static function toHsla(color:Color):Hsla {
        return switch(color) {
            case Color(SrgbaType(s)): srgbaToHsla(s);
            case Color(LinearRgbaType(l)): linearRgbaToHsla(l);
            case Color(HslaType(h)): h;
        }
    }

    // ==================== Utility Functions ====================

    /**
     * Blend two colors using the given mode
     */
    public static function blend(color1:LinearRgba, color2:LinearRgba, mode:BlendMode):LinearRgba {
        return switch(mode) {
            case Normal: color2;
            case Multiply: color1.multiply(color2);
            case Screen: color1.screenBlend(color2);
            case Overlay: color1.overlayBlend(color2);
            case SoftLight: color1.softLightBlend(color2);
            case HardLight: color1.hardLightBlend(color2);
            case ColorDodge: color1.colorDodgeBlend(color2);
            case ColorBurn: color1.colorBurnBlend(color2);
            case Difference: color1.differenceBlend(color2);
            case Exclusion: color1.exclusionBlend(color2);
        }
    }

    /**
     * Lerp between two colors
     */
    public static function lerp(color1:Color, color2:Color, t:Float):Color {
        var l1 = toLinearRgba(color1);
        var l2 = toLinearRgba(color2);
        return Color.fromLinearRgba(l1.mix(l2, t));
    }

    /**
     * Calculate Euclidean distance between two colors
     */
    public static function distance(color1:Color, color2:Color):Float {
        var l1 = toLinearRgba(color1);
        var l2 = toLinearRgba(color2);
        return l1.distance(l2);
    }

    /**
     * Calculate distance squared between two colors (faster, for comparisons)
     */
    public static function distanceSquared(color1:Color, color2:Color):Float {
        var l1 = toLinearRgba(color1);
        var l2 = toLinearRgba(color2);
        return l1.distanceSquared(l2);
    }

    /**
     * Get luminance of a color
     */
    public static function luminance(color:Color):Float {
        return toLinearRgba(color).luminance();
    }

    /**
     * Get grayscale version of a color
     */
    public static function grayscale(color:Color):Color {
        return Color.fromLinearRgba(toLinearRgba(color).grayscale());
    }

    /**
     * Get complement (opposite) color
     */
    public static function complement(color:Color):Color {
        var h = toHsla(color);
        var comp = h.complement();
        return Color.fromHsla(comp);
    }
}

/**
 * Blend modes for color operations
 */
enum BlendMode {
    Normal;
    Multiply;
    Screen;
    Overlay;
    SoftLight;
    HardLight;
    ColorDodge;
    ColorBurn;
    Difference;
    Exclusion;
}
