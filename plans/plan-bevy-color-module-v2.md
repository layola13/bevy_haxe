# Bevy Color Module Improvement Plan

## 1. Overview

Improve the bevy_color Haxe port to better match the Rust bevy_color API. The goal is to add missing color spaces (HSV, HWB), enhance existing implementations with more factory methods, improve color operations, and add comprehensive color palettes.

### Goals and Success Criteria
- Add HSVa color space with full conversion support
- Add Hwba color space (Hue-White-Black)
- Add more named colors and palettes
- Implement missing color operations (Hue, Saturation, Brightness adjustments)
- Improve Color abstraction with more factory methods
- Add missing math utilities

### Scope
- **Included**: Srgba, LinearRgba, Hsla, Color, ColorConversion, HaxeMath
- **Not included**: Lab/LCh, Oklab/OkLch, XYZ (future enhancements)

## 2. Prerequisites

No external dependencies required. All math utilities will be included in HaxeMath.

## 3. Implementation Steps

### Step 1: Enhance HaxeMath.hx
Add comprehensive math utilities needed for color calculations:
- Sign function
- Floor/ceil/round functions  
- Fraction function
- lerp helper
- Improved trig functions with cross-platform support

### Step 2: Enhance Srgba.hx
Add missing components and methods:
- Add toHsva() conversion
- Add toHwba() conversion
- Add brighter() method
- Add CSS color names palette
- Add sequential palette methods
- Improve u8 array conversions

### Step 3: Enhance LinearRgba.hx
Add missing components and methods:
- Add toSrgba() gamma encoding
- Add toHsva() conversion
- Add toHwba() conversion
- Add brighter() method
- Add sequential palette methods
- Improve u8 array conversions

### Step 4: Enhance Hsla.hx
Add missing components and methods:
- Add toSrgba() conversion
- Add toHsva() conversion
- Add toHwba() conversion
- Add toLinearRgba() conversion
- Add brighter() method
- Add complement() method
- Improve sequential palette

### Step 5: Add Hsva.hx (New)
Create new HSVa color space class:
- Components: hue, saturation, value, alpha
- Factory methods: hsv(), hsva(), fromSrgba(), fromLinearRgba(), fromHsla()
- Conversion methods: toSrgba(), toHsla(), toLinearRgba()
- Color operations: mix, withHue, withSaturation, withValue
- Luminance operations: darker, lighter, withLuminance

### Step 6: Add Hwba.hx (New)
Create new Hwba color space class:
- Components: hue, whiteness, blackness, alpha
- Factory methods: hwb(), hwba(), fromSrgba()
- Conversion methods: toSrgba(), toHsla(), toHsva()

### Step 7: Enhance ColorConversion.hx
Add missing conversion methods:
- Add HSV conversions
- Add HWB conversions
- Add palette generation utilities

### Step 8: Enhance Color.hx
Add missing factory methods and operations:
- Add hsv(), hsva() factory methods
- Add hwb(), hwba() factory methods
- Add fromHsva(), fromHwba() conversions
- Add property accessors: h, s, l, v, brightness
- Add adjustment methods: adjustHue, adjustBrightness
- Add sequential color palettes

## 4. File Changes Summary

### New Files
- `src/haxe/color/Hsva.hx` - HSV color space
- `src/haxe/color/Hwba.hx` - HWB color space

### Modified Files
- `src/haxe/color/HaxeMath.hx` - Add math utilities
- `src/haxe/color/Srgba.hx` - Add conversions, palettes
- `src/haxe/color/LinearRgba.hx` - Add conversions, palettes
- `src/haxe/color/Hsla.hx` - Add conversions, palettes
- `src/haxe/color/ColorConversion.hx` - Add HSV/HWB conversions
- `src/haxe/color/Color.hx` - Add factory methods, operations

## 5. Testing Strategy

Manual verification through compilation and example usage:
- Test color conversions between all spaces
- Test color operations (mix, brighter, darker)
- Test palette generation
- Test CSS named colors
- Test hex string parsing/formatting

## 6. Rollback Plan

Simply restore the original files from version control if needed.

## 7. Estimated Effort

- **Time**: ~2-3 hours
- **Complexity**: Medium
- **Risk**: Low (additive changes, no breaking modifications)
