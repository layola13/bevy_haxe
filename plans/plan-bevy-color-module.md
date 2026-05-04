# Bevy Color Module Implementation Plan

## Overview

Create a complete `bevy_color` module for Haxe that mirrors Bevy's Rust color crate. The implementation will use Haxe's abstract types to provide proper operator overloading (+, -, *) for color arithmetic, matching Bevy's API.

## Scope

### Included
- `Color.hx` - Color enum/abstract base type with all color space variants
- `Srgba.hx` - sRGB color space (non-linear, gamma corrected)
- `LinearRgba.hx` - Linear RGB color space (for lighting calculations)
- `Hsla.hx` - HSL color space (hue, saturation, lightness)
- `ColorConversion.hx` - Color conversion functions between color spaces

### Color Operations
- Addition, subtraction, scalar multiplication for all color types
- Color mixing (interpolation)
- Hue, saturation, lightness adjustment
- Color difference/distance calculations
- Luminance calculations

## Implementation Details

### 1. Srgba.hx (Abstract Type)
- Underlying type: `{red:Float, green:Float, blue:Float, alpha:Float}`
- Constants: BLACK, WHITE, RED, GREEN, BLUE, YELLOW, CYAN, MAGENTA, NONE, TRANSPARENT
- Factory methods: `new()`, `rgb()`, `rgba()`, `rgbU8()`, `rgbaU8()`, `hex()`, `srgb()`
- Operators: `+`, `-`, `*` (scalar), `/` (scalar)
- Methods: `toLinearRgba()`, `toHsla()`, `luminance()`, `grayscale()`, etc.

### 2. LinearRgba.hx (Abstract Type)
- Underlying type: `{red:Float, green:Float, blue:Float, alpha:Float}`
- Constants: BLACK, WHITE, RED, GREEN, BLUE, YELLOW, CYAN, MAGENTA, NONE, TRANSPARENT
- Factory methods: `new()`, `rgb()`, `rgba()`, `rgbU8()`, `rgbaU8()`, `linear()`
- Operators: `+`, `-`, `*` (scalar), `/` (scalar)
- Methods: `toSrgba()`, `toHsla()`, `luminance()`, `grayscale()`, etc.

### 3. Hsla.hx (Abstract Type)
- Underlying type: `{hue:Float, saturation:Float, lightness:Float, alpha:Float}`
- Constants: BLACK, WHITE, RED, GREEN, BLUE, etc.
- Factory methods: `new()`, `hsl()`, `hsla()`, `sequential()`, `sequentialDispersed()`
- Operators: `+` (mix-like behavior for hue interpolation)
- Methods: `toSrgba()`, `toLinearRgba()`, `withHue()`, `withSaturation()`, etc.

### 4. Color.hx (Abstract Type with Enum)
- Color enum data: `SrgbaType`, `LinearRgbaType`, `HslaType`
- Conversion properties: `srgba`, `linearRgba`, `hsla`
- Component accessors: `r`, `g`, `b`, `a`
- Static factory methods: `srgb()`, `rgb()`, `rgba()`, `hsl()`, `hsla()`, `hex()`
- Color operations: `mix()`, `hue()`, `adjustHue()`, `lightness()`, `adjustLightness()`, etc.

### 5. ColorConversion.hx
- `srgbComponentToLinear()` - sRGB gamma to linear
- `linearComponentToSrgb()` - linear to sRGB gamma
- `srgbaToLinear()` - full color conversion
- `linearToSrgba()` - full color conversion
- `srgbaToHsla()` - sRGB to HSL
- `hslaToSrgba()` - HSL to sRGB
- `linearToHsla()` - LinearRGB to HSL
- `hslaToLinear()` - HSL to LinearRGB

## Files to Create

```
src/haxe/color/
├── Srgba.hx          (rewritten with abstract)
├── LinearRgba.hx     (rewritten with abstract)
├── Hsla.hx           (rewritten with abstract)
├── Color.hx          (rewritten with abstract)
└── ColorConversion.hx (kept, may add enhancements)
```

## Testing

- Create a test file that exercises all color operations
- Verify operator overloading works correctly
- Test color space conversions
- Test luminance and distance calculations

## Rollback Plan

- Keep backups of existing files in a `backup/` directory
- Can restore originals if issues arise

## Effort

- Estimated time: 2-3 hours
- Complexity: Medium
- Main challenge: Implementing proper abstract types with operator overloading
