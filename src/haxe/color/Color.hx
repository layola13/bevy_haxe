package haxe.color;

/**
 * Base color type that can represent any color space.
 * Provides a unified interface for color operations.
 */
abstract Color(ColorData) {
    /**
     * Create from sRGB color
     */
    @:from public static inline function fromSrgba(c:Srgba):Color {
        return new Color(SrgbaType(c));
    }

    /**
     * Create from linear RGB color
     */
    @:from public static inline function fromLinearRgba(c:LinearRgba):Color {
        return new Color(LinearRgbaType(c));
    }

    /**
     * Create from HSL color
     */
    @:from public static inline function fromHsla(c:Hsla):Color {
        return new Color(HslaType(c));
    }

    /**
     * Create sRGB color (0-255 per channel)
     */
    public static function rgb(r:Float, g:Float, b:Float):Color {
        return fromSrgba(Srgba.new(r, g, b, 1.0));
    }

    /**
     * Create sRGB color with alpha
     */
    public static function rgba(r:Float, g:Float, b:Float, a:Float):Color {
        return fromSrgba(Srgba.new(r, g, b, a));
    }

    /**
     * Get sRGB representation
     */
    public var srgba(get, never):Srgba;
    private inline function get_srgba():Srgba {
        return ColorConversion.toSrgba(this);
    }

    /**
     * Get linear RGB representation
     */
    public var linearRgba(get, never):LinearRgba;
    private inline function get_linearRgba():LinearRgba {
        return ColorConversion.toLinearRgba(this);
    }

    /**
     * Get HSL representation
     */
    public var hsla(get, never):Hsla;
    private inline function get_hsla():Hsla {
        return ColorConversion.toHsla(this);
    }

    /**
     * Red component (sRGB)
     */
    public var r(get, never):Float;
    private inline function get_r():Float return srgba.r;

    /**
     * Green component (sRGB)
     */
    public var g(get, never):Float;
    private inline function get_g():Float return srgba.g;

    /**
     * Blue component (sRGB)
     */
    public var b(get, never):Float;
    private inline function get_b():Float return srgba.b;

    /**
     * Alpha component
     */
    public var a(get, never):Float;
    private inline function get_a():Float return srgba.a;

    /**
     * Hue (HSL)
     */
    public var hue(get, never):Float;
    private inline function get_hue():Float return hsla.hue;

    /**
     * Saturation (HSL)
     */
    public var saturation(get, never):Float;
    private inline function get_saturation():Float return hsla.saturation;

    /**
     * Lightness (HSL)
     */
    public var lightness(get, never):Float;
    private inline function get_lightness():Float return hsla.lightness;

    /**
     * Luminance value
     */
    public var luminance(get, never):Float;
    private inline function get_luminance():Float return linearRgba.luminance();

    /**
     * Mix this color with another
     * @param other The other color
     * @param t Interpolation factor (0.0 = this, 1.0 = other)
     */
    public function mix(other:Color, t:Float):Color {
        return fromLinearRgba(linearRgba.mix(other.linearRgba, t));
    }

    /**
     * Blend with another color using multiplication
     */
    public function multiply(other:Color):Color {
        var l1 = linearRgba;
        var l2 = other.linearRgba;
        return fromLinearRgba(new LinearRgba(
            l1.red * l2.red,
            l1.green * l2.green,
            l1.blue * l2.blue,
            l1.alpha * l2.alpha
        ));
    }

    /**
     * Get color with adjusted brightness
     * @param amount Amount to adjust (positive = lighter, negative = darker)
     */
    public function adjustBrightness(amount:Float):Color {
        var l = linearRgba;
        var factor = 1.0 + amount;
        return fromLinearRgba(new LinearRgba(
            l.red * factor,
            l.green * factor,
            l.blue * factor,
            l.alpha
        ));
    }

    /**
     * Get a lighter version of this color
     */
    public function lighter(amount:Float):Color {
        return adjustBrightness(amount);
    }

    /**
     * Get a darker version of this color
     */
    public function darker(amount:Float):Color {
        return adjustBrightness(-amount);
    }

    /**
     * Get color with adjusted hue
     * @param amount Degrees to rotate hue
     */
    public function rotateHue(amount:Float):Color {
        var h = hsla;
        var newHue = (h.hue + amount) % 360.0;
        if (newHue < 0) newHue += 360.0;
        return fromHsla(new Hsla(newHue, h.saturation, h.lightness, h.alpha));
    }

    /**
     * Get color with adjusted saturation
     * @param amount Amount to adjust saturation
     */
    public function adjustSaturation(amount:Float):Color {
        var h = hsla;
        return fromHsla(new Hsla(h.hue, HaxeMath.clamp(h.saturation + amount, 0, 1), h.lightness, h.alpha));
    }

    /**
     * Get grayscale version
     */
    public function grayscale():Color {
        var l = linearRgba.luminance();
        return fromLinearRgba(new LinearRgba(l, l, l, linearRgba.alpha));
    }

    /**
     * Convert to hex string
     */
    public function toHex():String {
        return srgba.toHex();
    }

    /**
     * Create from hex string
     */
    public static function fromHex(hex:String):Color {
        return fromSrgba(Srgba.fromHex(hex));
    }

    /**
     * String representation
     */
    @:to public function toString():String {
        return srgba.toString();
    }

    /**
     * Get hash code for use in maps
     */
    public function hash():Int {
        var s = srgba;
        return Std.int(s.r * 255) ^ (Std.int(s.g * 255) << 8) ^ (Std.int(s.b * 255) << 16) ^ (Std.int(s.a * 255) << 24);
    }
}

/**
 * Internal data representation for Color
 */
enum ColorData {
    SrgbaType(c:Srgba);
    LinearRgbaType(c:LinearRgba);
    HslaType(c:Hsla);
}
