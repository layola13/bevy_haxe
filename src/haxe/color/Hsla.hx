package haxe.color;

/**
 * HSL (Hue-Saturation-Lightness) color space with alpha.
 * A cylindrical color space that is intuitive for human perception.
 */
class Hsla {
    /**
     * Hue channel [0.0, 360.0]
     */
    public var hue:Float;

    /**
     * Saturation channel [0.0, 1.0]
     */
    public var saturation:Float;

    /**
     * Lightness channel [0.0, 1.0]
     */
    public var lightness:Float;

    /**
     * Alpha channel [0.0, 1.0]
     */
    public var alpha:Float;

    /**
     * Create new HSL color
     */
    public function new(hue:Float, saturation:Float, lightness:Float, alpha:Float = 1.0) {
        this.hue = hue;
        this.saturation = saturation;
        this.lightness = lightness;
        this.alpha = alpha;
    }

    /**
     * Create from h, s, l components (alpha = 1.0)
     */
    public static function hsl(h:Float, s:Float, l:Float):Hsla {
        return new Hsla(h, s, l, 1.0);
    }

    /**
     * Create from h, s, l, a components
     */
    public static function hsla(h:Float, s:Float, l:Float, a:Float):Hsla {
        return new Hsla(h, s, l, a);
    }

    /**
     * Normalize hue to [0, 360) range
     */
    public function normalizeHue():Float {
        var h = hue % 360.0;
        if (h < 0) h += 360.0;
        return h;
    }

    /**
     * Get component by index (0=h, 1=s, 2=l, 3=a)
     */
    public function getComponent(index:Int):Float {
        return switch(index) {
            case 0: hue;
            case 1: saturation;
            case 2: lightness;
            case 3: alpha;
            default: 0.0;
        }
    }

    /**
     * Set component by index
     */
    public function setComponent(index:Int, value:Float):Void {
        switch(index) {
            case 0: hue = value;
            case 1: saturation = value;
            case 2: lightness = value;
            case 3: alpha = value;
        }
    }

    /**
     * Convert to Srgba
     */
    public function toSrgba():Srgba {
        return ColorConversion.hslaToSrgba(this);
    }

    /**
     * Convert to LinearRgba
     */
    public function toLinearRgba():LinearRgba {
        return ColorConversion.hslaToLinearRgba(this);
    }

    /**
     * Mix with another color (handling hue correctly)
     * @param other The other color
     * @param t Interpolation factor (0.0 = this, 1.0 = other)
     */
    public function mix(other:Hsla, t:Float):Hsla {
        var t1 = HaxeMath.clamp(t, 0, 1);
        var t2 = 1.0 - t1;
        
        // Interpolate hue using shortest path on circle
        var h1 = normalizeHue();
        var h2 = other.normalizeHue();
        var diff = h2 - h1;
        
        if (diff > 180) diff -= 360;
        if (diff < -180) diff += 360;
        
        var newHue = (h1 + diff * t1) % 360.0;
        if (newHue < 0) newHue += 360.0;
        
        return new Hsla(
            newHue,
            HaxeMath.clamp(saturation * t2 + other.saturation * t1, 0, 1),
            HaxeMath.clamp(lightness * t2 + other.lightness * t1, 0, 1),
            HaxeMath.clamp(alpha * t2 + other.alpha * t1, 0, 1)
        );
    }

    /**
     * Clamp all components to valid ranges
     */
    public function clamp():Hsla {
        return new Hsla(
            normalizeHue(),
            HaxeMath.clamp(saturation, 0, 1),
            HaxeMath.clamp(lightness, 0, 1),
            HaxeMath.clamp(alpha, 0, 1)
        );
    }

    /**
     * Get lighter version
     * @param amount Amount to lighten (0.0-1.0)
     */
    public function lighter(amount:Float):Hsla {
        return new Hsla(
            hue,
            saturation,
            HaxeMath.clamp(lightness + amount, 0, 1),
            alpha
        );
    }

    /**
     * Get darker version
     * @param amount Amount to darken (0.0-1.0)
     */
    public function darker(amount:Float):Hsla {
        return new Hsla(
            hue,
            saturation,
            HaxeMath.clamp(lightness - amount, 0, 1),
            alpha
        );
    }

    /**
     * Rotate hue
     * @param degrees Degrees to rotate (can be negative)
     */
    public function rotateHue(degrees:Float):Hsla {
        var newHue = (hue + degrees) % 360.0;
        if (newHue < 0) newHue += 360.0;
        return new Hsla(newHue, saturation, lightness, alpha);
    }

    /**
     * Adjust saturation
     * @param amount Amount to adjust (positive = more saturated, negative = less)
     */
    public function adjustSaturation(amount:Float):Hsla {
        return new Hsla(
            hue,
            HaxeMath.clamp(saturation + amount, 0, 1),
            lightness,
            alpha
        );
    }

    /**
     * Adjust lightness
     * @param amount Amount to adjust (positive = lighter, negative = darker)
     */
    public function adjustLightness(amount:Float):Hsla {
        return new Hsla(
            hue,
            saturation,
            HaxeMath.clamp(lightness + amount, 0, 1),
            alpha
        );
    }

    /**
     * Get grayscale version (desaturate completely)
     */
    public function grayscale():Hsla {
        return new Hsla(hue, 0.0, lightness, alpha);
    }

    /**
     * Get complement color (opposite hue, 180 degrees away)
     */
    public function complement():Hsla {
        return rotateHue(180);
    }

    /**
     * Get triadic colors (120 degrees apart)
     */
    public function triadic():Array<Hsla> {
        return [
            new Hsla(hue, saturation, lightness, alpha),
            rotateHue(120),
            rotateHue(240)
        ];
    }

    /**
     * Get tetradic/analogous colors (90 degrees apart)
     */
    public function tetradic():Array<Hsla> {
        return [
            new Hsla(hue, saturation, lightness, alpha),
            rotateHue(90),
            rotateHue(180),
            rotateHue(270)
        ];
    }

    /**
     * Get analogous colors (30 degrees apart)
     */
    public function analogous(includeSelf:Bool = true):Array<Hsla> {
        if (includeSelf) {
            return [
                rotateHue(-30),
                new Hsla(hue, saturation, lightness, alpha),
                rotateHue(30)
            ];
        }
        return [rotateHue(-30), rotateHue(30)];
    }

    /**
     * Calculate luminance (from linear conversion)
     */
    public function luminance():Float {
        return toLinearRgba().luminance();
    }

    /**
     * Create a copy with modified values
     */
    public function withHue(h:Float):Hsla {
        return new Hsla(h, saturation, lightness, alpha);
    }

    public function withSaturation(s:Float):Hsla {
        return new Hsla(hue, s, lightness, alpha);
    }

    public function withLightness(l:Float):Hsla {
        return new Hsla(hue, saturation, l, alpha);
    }

    public function withAlpha(a:Float):Hsla {
        return new Hsla(hue, saturation, lightness, a);
    }

    /**
     * Check equality (with epsilon tolerance)
     */
    public function equals(other:Hsla, epsilon:Float = 0.0001):Bool {
        var h1 = normalizeHue();
        var h2 = other.normalizeHue();
        var hueDiff = HaxeMath.abs(h1 - h2);
        if (hueDiff > 180) hueDiff = 360 - hueDiff;
        
        return hueDiff < epsilon
            && HaxeMath.abs(saturation - other.saturation) < epsilon
            && HaxeMath.abs(lightness - other.lightness) < epsilon
            && HaxeMath.abs(alpha - other.alpha) < epsilon;
    }

    /**
     * Get sequential colors for discrete data
     * @param index The index of the color
     * @param length Total number of colors
     */
    public static function sequential(index:Int, length:Int):Hsla {
        var hue = (index / length) * 360.0;
        return hsl(hue, 0.8, 0.5);
    }

    /**
     * Get sequential dispersed colors for discrete data
     * @param index The index of the color
     */
    public static function sequentialDispersed(index:UInt):Hsla {
        // Use golden ratio for even distribution
        var hue = (index * 137.508) % 360.0; // 360 / golden_ratio
        if (hue < 0) hue += 360.0;
        return hsl(hue, 0.8, 0.5);
    }

    /**
     * String representation
     */
    public function toString():String {
        return 'Hsla(${HaxeMath.round(hue, 1)}, ${HaxeMath.round(saturation, 3)}, ${HaxeMath.round(lightness, 3)}, ${HaxeMath.round(alpha, 3)})';
    }

    /**
     * Clone the color
     */
    public function clone():Hsla {
        return new Hsla(hue, saturation, lightness, alpha);
    }

    // Operator overloads for Haxe
    @:op(A + B) public function add(other:Hsla):Hsla {
        return mix(other, 0.5);
    }

    @:op(A == B) public function eq(other:Hsla):Bool {
        return equals(other);
    }

    @:op(A != B) public function neq(other:Hsla):Bool {
        return !equals(other);
    }
}
