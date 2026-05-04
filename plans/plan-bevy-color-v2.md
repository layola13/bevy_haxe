# Bevy Color Module Improvement Plan

## Overview

Improve the `haxe.color` module to better match Bevy's Color API, implementing additional color spaces and comprehensive color operations.

### Goals
- Add HSV color space support (Hsva.hx)
- Add HWB color space support (Hwba.hx)
- Enhance Color.hx with all color space constructors and operations
- Improve ColorConversion.hx with complete conversions
- Enhance HaxeMath.hx with additional math utilities
- Ensure API consistency with Bevy Color module

### Scope
- **Included**: Color.hx, Srgba.hx, LinearRgba.hx, Hsla.hx, Hsva.hx, Hwba.hx, ColorConversion.hx, HaxeMath.hx
- **Excluded**: Laba, Lcha, Oklaba, Oklcha, Xyza (future enhancement)

---

## Prerequisites

- Haxe 4.x or later
- Working bevy_haxe project structure in `/home/vscode/projects/bevy_haxe`

---

## Implementation Steps

### Step 1: Enhance HaxeMath.hx
- Add lerp() function
- Add lerpHue() function for circular hue interpolation
- Add sign() function
- Add isFinite(), isInfinite(), isNaN() functions
- Add exp(), log(), log10() functions
- Add fract() function

### Step 2: Create Hsva.hx (new file)
- HSV (Hue-Saturation-Value) color space
- Constructor methods: new(), hsv(), hsva()
- Conversion to/from Srgba, LinearRgba, Hsla
- Constants: BLACK, WHITE, NONE, RED, GREEN, BLUE

### Step 3: Create Hwba.hx (new file)
- HWB (Hue-Whiteness-Blackness) color space
- Constructor methods: new(), hwb(), hwba()
- Conversion to/from Srgba, Hsva

### Step 4: Enhance Srgba.hx
- Add HSV constructor: Srgba.hsv(h, s, v)
- Add HSV with alpha: Srgba.hsva(h, s, v, a)
- Add HWB constructor: Srgba.hwb(h, w, b)
- Add HWB with alpha: Srgba.hwba(h, w, b, a)
- Add toHsva() and toHwba() methods

### Step 5: Enhance LinearRgba.hx
- Add toHsva() and toHwba() methods

### Step 6: Enhance Hsla.hx
- Add toHsva() and toHwba() methods
- Add withHue(), withSaturation(), withLightness() methods

### Step 7: Enhance Color.hx
- Add hsva and hwba properties
- Add hsv(), hsva() static constructors
- Add hwb(), hwba() static constructors
- Add adjustHue() method

### Step 8: Enhance ColorConversion.hx
- Add HSV conversions
- Add HWB conversions

---

## File Changes Summary

### New Files
- `src/haxe/color/Hsva.hx` - HSV color space
- `src/haxe/color/Hwba.hx` - HWB color space

### Modified Files
- `src/haxe/color/Color.hx`
- `src/haxe/color/Srgba.hx`
- `src/haxe/color/LinearRgba.hx`
- `src/haxe/color/Hsla.hx`
- `src/haxe/color/ColorConversion.hx`
- `src/haxe/color/HaxeMath.hx`

---

## Estimated Effort

- **Time**: 4-6 hours
- **Complexity**: Medium
- **Risk**: Low (additive improvements, no breaking changes)
