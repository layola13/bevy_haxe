package haxe.color;

/**
 * Math utilities for color calculations.
 * Haxe doesn't have a built-in math library as comprehensive as some other languages,
 * so this provides the functions needed for color math.
 */
class HaxeMath {
    /**
     * Calculate absolute value
     */
    public static function abs(x:Float):Float {
        return x < 0 ? -x : x;
    }

    /**
     * Calculate the minimum of two values
     */
    public static function min(a:Float, b:Float):Float {
        return a < b ? a : b;
    }

    /**
     * Calculate the maximum of two values
     */
    public static function max(a:Float, b:Float):Float {
        return a > b ? a : b;
    }

    /**
     * Clamp a value between min and max
     */
    public static function clamp(value:Float, minVal:Float, maxVal:Float):Float {
        if (value < minVal) return minVal;
        if (value > maxVal) return maxVal;
        return value;
    }

    /**
     * Calculate power
     */
    public static function pow(base:Float, exponent:Float):Float {
        #if cpp
        return cpp.Lib.pow(base, exponent);
        #elseif java
        return java.lang.Math.pow(base, exponent);
        #elseif python
        return python.lib.Math.pow(base, exponent);
        #elseif js
        return untyped __js__("Math.pow")(base, exponent);
        #elseif neko
        return neko.NekoMath.pow(base, exponent);
        #else
        // Fallback using logarithm for other targets
        if (base <= 0) return 0;
        return Math.exp(exponent * Math.log(base));
        #end
    }

    /**
     * Calculate square root
     */
    public static function sqrt(x:Float):Float {
        #if cpp
        return cpp.Lib.sqrt(x);
        #elseif java
        return java.lang.Math.sqrt(x);
        #elseif python
        return python.lib.Math.sqrt(x);
        #elseif js
        return untyped __js__("Math.sqrt")(x);
        #elseif neko
        return neko.NekoMath.sqrt(x);
        #else
        return Math.sqrt(x);
        #end
    }

    /**
     * Calculate natural logarithm
     */
    public static function log(x:Float):Float {
        #if cpp
        return cpp.Lib.log(x);
        #elseif java
        return java.lang.Math.log(x);
        #elseif python
        return python.lib.Math.log(x);
        #elseif js
        return untyped __js__("Math.log")(x);
        #elseif neko
        return neko.NekoMath.log(x);
        #else
        return Math.log(x);
        #end
    }

    /**
     * Calculate exponential (e^x)
     */
    public static function exp(x:Float):Float {
        #if cpp
        return cpp.Lib.exp(x);
        #elseif java
        return java.lang.Math.exp(x);
        #elseif python
        return python.lib.Math.exp(x);
        #elseif js
        return untyped __js__("Math.exp")(x);
        #elseif neko
        return neko.NekoMath.exp(x);
        #else
        return Math.exp(x);
        #end
    }

    /**
     * Round to nearest integer
     */
    public static function round(x:Float):Int {
        return x >= 0 ? Std.int(x + 0.5) : Std.int(x - 0.5);
    }

    /**
     * Round to specified decimal places
     */
    public static function roundDecimal(x:Float, decimals:Int):Float {
        var factor = pow(10, decimals);
        return round(x * factor) / factor;
    }

    /**
     * Floor (round down)
     */
    public static function floor(x:Float):Int {
        return x >= 0 ? Std.int(x) : Std.int(x) - 1;
    }

    /**
     * Ceiling (round up)
     */
    public static function ceil(x:Float):Int {
        return x == Std.int(x) ? Std.int(x) : Std.int(x) + 1;
    }

    /**
     * Linear interpolation between two values
     */
    public static function lerp(a:Float, b:Float, t:Float):Float {
        return a + (b - a) * t;
    }

    /**
     * Map a value from one range to another
     */
    public static function map(value:Float, inMin:Float, inMax:Float, outMin:Float, outMax:Float):Float {
        return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
    }

    /**
     * Smooth step interpolation (cubic Hermite interpolation)
     */
    public static function smoothstep(edge0:Float, edge1:Float, x:Float):Float {
        var t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
        return t * t * (3.0 - 2.0 * t);
    }

    /**
     * Sine function
     */
    public static function sin(x:Float):Float {
        #if cpp
        return cpp.Lib.sin(x);
        #elseif java
        return java.lang.Math.sin(x);
        #elseif python
        return python.lib.Math.sin(x);
        #elseif js
        return untyped __js__("Math.sin")(x);
        #elseif neko
        return neko.NekoMath.sin(x);
        #else
        return Math.sin(x);
        #end
    }

    /**
     * Cosine function
     */
    public static function cos(x:Float):Float {
        #if cpp
        return cpp.Lib.cos(x);
        #elseif java
        return java.lang.Math.cos(x);
        #elseif python
        return python.lib.Math.cos(x);
        #elseif js
        return untyped __js__("Math.cos")(x);
        #elseif neko
        return neko.NekoMath.cos(x);
        #else
        return Math.cos(x);
        #end
    }

    /**
     * Arc tangent function
     */
    public static function atan(x:Float):Float {
        #if cpp
        return cpp.Lib.atan(x);
        #elseif java
        return java.lang.Math.atan(x);
        #elseif python
        return python.lib.Math.atan(x);
        #elseif js
        return untyped __js__("Math.atan")(x);
        #elseif neko
        return neko.NekoMath.atan(x);
        #else
        return Math.atan(x);
        #end
    }

    /**
     * Arc tangent function with two parameters
     */
    public static function atan2(y:Float, x:Float):Float {
        #if cpp
        return cpp.Lib.atan2(y, x);
        #elseif java
        return java.lang.Math.atan2(y, x);
        #elseif python
        return python.lib.Math.atan2(y, x);
        #elseif js
        return untyped __js__("Math.atan2")(y, x);
        #elseif neko
        return neko.NekoMath.atan2(y, x);
        #else
        return Math.atan2(y, x);
        #end
    }

    /**
     * Degrees to radians
     */
    public static inline function degreesToRadians(degrees:Float):Float {
        return degrees * 0.017453292519943295;
    }

    /**
     * Radians to degrees
     */
    public static inline function radiansToDegrees(radians:Float):Float {
        return radians * 57.29577951308232;
    }
}
