# Bevy Haxe Color System Implementation Plan

## 1. Overview

This implementation provides a complete color system for Haxe, ported from Bevy's `bevy_color` crate. The system supports multiple color spaces with bidirectional conversion capabilities.

### Goals
- Provide sRGB color support for display/output
- Provide Linear RGB for physically accurate lighting calculations
- Provide HSL for intuitive color manipulation
- Support complete color space conversion between all formats
- Include common color operations (mixing, blending, luminance, etc.)

### Scope
**Included:**
- `Color.hx` - Unified color type with generic operations
- `Srgba.hx` - sRGB color space with gamma correction
- `LinearRgba.hx` - Linear RGB for lighting calculations
- `Hsla.hx` - HSL color space for intuitive manipulation
- `ColorConversion.hx` - Complete conversion utilities
- `HaxeMath.hx` - Math utilities for color calculations

**Excluded:**
- HSV color space (not requested)
- HWB color space (not requested)
- LAB/LCH color spaces (not requested)
- Oklaba/Oklcha color spaces (not requested)
- XYZ color space (not requested)

## 2. Prerequisites

- Haxe SDK (tested with 4.x)
- Standard Haxe libraries only (no external dependencies)
- Files must be placed in `src/haxe/color/` directory

## 3. Implementation Steps

### Step 1: Create HaxeMath.hx
- Math utilities required by color calculations
- Cross-platform math function support
- Functions: abs, min, max, clamp, pow, sqrt, round, floor, lerp, etc.

### Step 2: Create Srgba.hx
- Standard RGB color with gamma correction
- Properties: red, green, blue, alpha (all 0.0-1.0)
- Factory methods: rgb(), rgba(), rgbU8(), rgbaU8(), fromHex()
- Constants: BLACK, WHITE, RED, GREEN, BLUE, YELLOW, CYAN, MAGENTA, etc.
- Methods: mix(), clamp(), toLinear(), toHsla(), luminance(), toHex()

### Step 3: Create LinearRgba.hx
- Linear RGB without gamma correction
- Properties: red, green, blue, alpha (all 0.0-1.0)
- Factory methods: rgb(), rgba(), rgbU8(), rgbaU8()
- Constants: BLACK, WHITE, RED, GREEN, BLUE, etc.
- Methods: mix(), clamp(), toSrgb(), toHsla(), luminance()
- Blend modes: multiply(), screenBlend(), overlayBlend(), etc.

### Step 4: Create Hsla.hx
- HSL (Hue-Saturation-Lightness) color space
- Properties: hue (0-360), saturation (0-1), lightness (0-1), alpha (0-1)
- Factory methods: hsl(), hsla()
- Methods: mix(), lighter(), darker(), rotateHue(), adjustSaturation()
- Color harmony: complement(), triadic(), tetradic(), analogous()

### Step 5: Create ColorConversion.hx
- Complete conversion utilities
- sRGB ↔ Linear RGB conversion with proper gamma correction
- RGB ↔ HSL conversion
- Color abstraction conversion support
- Utility functions: blend(), lerp(), distance(), luminance()

### Step 6: Create Color.hx
- Unified color type using Haxe abstract
- Automatic conversion from Srgba, LinearRgba, Hsla
- Convenience methods: mix(), multiply(), lighter(), darker()
- Hue/saturation adjustment, grayscale, hex conversion

## 4. File Changes Summary

| File | Action | Description |
|------|--------|-------------|
| `src/haxe/color/Color.hx` | Created | Unified color type (abstract) |
| `src/haxe/color/Srgba.hx` | Created | sRGB color space |
| `src/haxe/color/LinearRgba.hx` | Created | Linear RGB color space |
| `src/haxe/color/Hsla.hx` | Created | HSL color space |
| `src/haxe/color/ColorConversion.hx` | Created | Conversion utilities |
| `src/haxe/color/HaxeMath.hx` | Created | Math utilities |

## 5. Testing Strategy

### Unit Tests
1. **Color Conversion Tests**
   - sRGB → Linear → sRGB round-trip accuracy
   - HSL → RGB → HSL round-trip accuracy
   - Verify round-trip preserves values within epsilon (0.0001)

2. **Factory Method Tests**
   - fromHex() parsing (3, 4, 6, 8 character formats)
   - rgbU8/rgbaU8 bounds checking
   - Named color constants verification

3. **Color Operation Tests**
   - mix() interpolation correctness
   - lighter()/darker() brightness adjustment
   - rotateHue() wrapping at 0/360 boundary

### Manual Testing Steps
```haxe
// Basic usage example
var red = Srgba.RED;
var linear = red.toLinear();
var hsl = red.toHsla();
var backToSrgb = hsl.toSrgba();

// Mix two colors
var mixed = red.mix(Srgba.BLUE, 0.5);

// Get lighter/darker versions
var light = red.lighter(0.2);
var dark = red.darker(0.2);

// Hue rotation
var rotated = hsl.rotateHue(90);
```

## 6. Rollback Plan

To remove the color system:
```bash
rm src/haxe/color/Color.hx
rm src/haxe/color/Srgba.hx
rm src/haxe/color/LinearRgba.hx
rm src/haxe/color/Hsla.hx
rm src/haxe/color/ColorConversion.hx
rm src/haxe/color/HaxeMath.hx
```

No database migrations or configuration changes required.

## 7. Estimated Effort

- **Time**: 2-3 hours
- **Complexity**: Medium
- **Dependencies**: None (pure Haxe implementation)

## 8. Color Space Conversion Matrix

```
        ┌──────────┐     ┌──────────┐     ┌──────────┐
        │  Srgba   │ ←→ │ LinearRgba│ ←→ │  Hsla   │
        └──────────┘     └──────────┘     └──────────┘
              ↓               ↓               ↓
         gamma from         linear         hsl
         correction       space only      conversion
```
