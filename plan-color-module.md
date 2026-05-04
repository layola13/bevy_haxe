# bevy_color 模块完善计划

## 1. Overview

完善 Haxe 版本的 bevy_color 模块，对标 Rust 版本 crates/bevy_color/src/ 的实现。

### Goals
- Color 作为统一接口，提供静态工厂方法
- Srgba/LinearRgba/Hsla 相互转换 (gamma 转换正确)
- 支持 alpha 通道
- 实现 Rust 版本的核心功能

### Scope
**Included:**
- Color.hx - 统一接口
- Srgba.hx - sRGB 颜色
- LinearRgba.hx - 线性 RGB
- Hsla.hx - HSL 颜色
- ColorConversion.hx - 颜色转换核心

**Excluded:**
- Hsva.hx (已有，超出范围)
- HaxeMath.hx (已有，超出范围)
- 测试文件

---

## 2. Prerequisites

- Haxe 4.x+
- Math 库支持 (内置或自定义 HaxeMath)
- 已有 HaxeMath 工具类

---

## 3. Implementation Steps

### Step 1: 更新 Srgba.hx

**目标:** 完善 sRGB 颜色类

**修改内容:**
- 添加预设常量 (BLACK, WHITE, NONE, RED, GREEN, BLUE, YELLOW, CYAN, MAGENTA)
- 验证 `linearToSrgb` gamma 转换公式
- 完善 `mix` 方法使用线性插值

**文件:** `/home/vscode/projects/bevy_haxe/src/haxe/color/Srgba.hx`

```haxe
// 添加预设常量
public static var BLACK(default, never):Srgba = new Srgba(0, 0, 0, 1);
public static var WHITE(default, never):Srgba = new Srgba(1, 1, 1, 1);
public static var NONE(default, never):Srgba = new Srgba(0, 0, 0, 0);
public static var RED(default, never):Srgba = new Srgba(1, 0, 0, 1);
public static var GREEN(default, never):Srgba = new Srgba(0, 1, 0, 1);
public static var BLUE(default, never):Srgba = new Srgba(0, 0, 1, 1);

// 添加 mix 方法
public function mix(other:Srgba, t:Float):Srgba {
    var tClamped = HaxeMath.clamp(t, 0, 1);
    return new Srgba(
        HaxeMath.lerp(this.red, other.red, tClamped),
        HaxeMath.lerp(this.green, other.green, tClamped),
        HaxeMath.lerp(this.blue, other.blue, tClamped),
        HaxeMath.lerp(this.alpha, other.alpha, tClamped)
    );
}

// 添加 lighter/darker
public function lighter(amount:Float):Srgba {
    var lin = ColorConversion.srgbaToLinear(this);
    var lighter = lin.lighter(amount);
    return ColorConversion.linearToSrgba(lighter);
}

public function darker(amount:Float):Srgba {
    var lin = ColorConversion.srgbaToLinear(this);
    var darker = lin.darker(amount);
    return ColorConversion.linearToSrgba(darker);
}
```

---

### Step 2: 更新 LinearRgba.hx

**目标:** 完善线性 RGB 颜色类

**修改内容:**
- 添加预设常量 (BLACK, WHITE, NONE, RED, GREEN, BLUE)
- 完善 `mix`, `lighter`, `darker` 方法

**文件:** `/home/vscode/projects/bevy_haxe/src/haxe/color/LinearRgba.hx`

```haxe
// 添加预设常量
public static var BLACK(default, never):LinearRgba = new LinearRgba(0, 0, 0, 1);
public static var WHITE(default, never):LinearRgba = new LinearRgba(1, 1, 1, 1);
public static var NONE(default, never):LinearRgba = new LinearRgba(0, 0, 0, 0);
public static var RED(default, never):LinearRgba = new LinearRgba(1, 0, 0, 1);
public static var GREEN(default, never):LinearRgba = new LinearRgba(0, 1, 0, 1);
public static var BLUE(default, never):LinearRgba = new LinearRgba(0, 0, 1, 1);

// 添加 mix 方法 (在 Linear 空间混合)
public function mix(other:LinearRgba, t:Float):LinearRgba {
    var tClamped = HaxeMath.clamp(t, 0, 1);
    return new LinearRgba(
        HaxeMath.lerp(this.red, other.red, tClamped),
        HaxeMath.lerp(this.green, other.green, tClamped),
        HaxeMath.lerp(this.blue, other.blue, tClamped),
        HaxeMath.lerp(this.alpha, other.alpha, tClamped)
    );
}

// 添加 lighter/darker (在 Linear 空间操作)
public function lighter(amount:Float):LinearRgba {
    var factor = 1.0 + amount;
    return new LinearRgba(
        HaxeMath.min(red * factor, 1.0),
        HaxeMath.min(green * factor, 1.0),
        HaxeMath.min(blue * factor, 1.0),
        alpha
    );
}

public function darker(amount:Float):LinearRgba {
    var factor = 1.0 - amount;
    return new LinearRgba(
        red * factor,
        green * factor,
        blue * factor,
        alpha
    );
}
```

---

### Step 3: 更新 Hsla.hx

**目标:** 完善 HSL 颜色类

**修改内容:**
- 添加预设常量 (BLACK, WHITE, NONE, RED, GREEN, BLUE)
- 添加 `mix` 方法 (考虑色相环绕)
- 添加 `lighter`, `darker` 方法

**文件:** `/home/vscode/projects/bevy_haxe/src/haxe/color/Hsla.hx`

```haxe
// 添加预设常量
public static var BLACK(default, never):Hsla = new Hsla(0, 0, 0, 1);
public static var WHITE(default, never):Hsla = new Hsla(0, 0, 1, 1);
public static var NONE(default, never):Hsla = new Hsla(0, 0, 0, 0);
public static var RED(default, never):Hsla = new Hsla(0, 1, 0.5, 1);
public static var GREEN(default, never):Hsla = new Hsla(120, 1, 0.5, 1);
public static var BLUE(default, never):Hsla = new Hsla(240, 1, 0.5, 1);

// 添加 mix 方法 (处理色相环绕)
public function mix(other:Hsla, t:Float):Hsla {
    var tClamped = HaxeMath.clamp(t, 0, 1);
    
    // 处理色相环绕 - 选择最短路径
    var h1 = normalizeHue();
    var h2 = other.normalizeHue();
    var diff = h2 - h1;
    
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    
    var hue = normalizeHue() + diff * tClamped;
    if (hue < 0) hue += 360;
    if (hue >= 360) hue -= 360;
    
    return new Hsla(
        hue,
        HaxeMath.lerp(this.saturation, other.saturation, tClamped),
        HaxeMath.lerp(this.lightness, other.lightness, tClamped),
        HaxeMath.lerp(this.alpha, other.alpha, tClamped)
    );
}

// 添加 lighter/darker
public function lighter(amount:Float):Hsla {
    return new Hsla(hue, saturation, HaxeMath.min(lightness + amount, 1.0), alpha);
}

public function darker(amount:Float):Hsla {
    return new Hsla(hue, saturation, HaxeMath.max(lightness - amount, 0.0), alpha);
}
```

---

### Step 4: 更新 ColorConversion.hx

**目标:** 完善颜色空间转换

**修改内容:**
- 验证并修正 sRGB gamma 转换公式
- 确保 `linearToSrgba` 使用正确的公式
- 添加 `Color` 类型的综合转换

**文件:** `/home/vscode/projects/bevy_haxe/src/haxe/color/ColorConversion.hx`

关键修正 - `linearComponentToSrgb`:
```haxe
public static function linearComponentToSrgb(value:Float):Float {
    // Rust 实现: (1.055) * pow(value, 1/2.4) - 0.055
    if (value <= 0.0031308) {
        return value * 12.92;
    }
    return 1.055 * HaxeMath.pow(value, 1.0 / 2.4) - 0.055;
}
```

---

### Step 5: 更新 Color.hx

**目标:** 完善统一接口

**修改内容:**
- 添加静态工厂方法 (srgb, hsl, hex, u8 等)
- 添加预设颜色常量 (RED, GREEN, BLUE, WHITE, BLACK)
- 实现 `mix`, `lighter`, `darker` 方法

**文件:** `/home/vscode/projects/bevy_haxe/src/haxe/color/Color.hx`

```haxe
// 添加预设常量
public static var RED(default, never):Color = fromSrgba(Srgba.RED);
public static var GREEN(default, never):Color = fromSrgba(Srgba.GREEN);
public static var BLUE(default, never):Color = fromSrgba(Srgba.BLUE);
public static var WHITE(default, never):Color = fromSrgba(Srgba.WHITE);
public static var BLACK(default, never):Color = fromSrgba(Srgba.BLACK);

// 添加静态工厂方法
public static function srgb(r:Float, g:Float, b:Float):Color {
    return fromSrgba(new Srgba(r, g, b, 1.0));
}

public static function srgbA(r:Float, g:Float, b:Float, a:Float):Color {
    return fromSrgba(new Srgba(r, g, b, a));
}

public static function hsl(hue:Float, sat:Float, light:Float):Color {
    return fromHsla(new Hsla(hue, sat, light, 1.0));
}

public static function hsla(hue:Float, sat:Float, light:Float, a:Float):Color {
    return fromHsla(new Hsla(hue, sat, light, a));
}

// 添加 mix 方法
public function mix(other:Color, t:Float):Color {
    return Color.fromLinearRgba(this.linearRgba.mix(other.linearRgba, t));
}

// 添加 lighter/darker
public function lighter(amount:Float):Color {
    return Color.fromLinearRgba(this.linearRgba.lighter(amount));
}

public function darker(amount:Float):Color {
    return Color.fromLinearRgba(this.linearRgba.darker(amount));
}
```

---

## 4. File Changes Summary

| 操作 | 文件路径 |
|------|----------|
| Modified | `/home/vscode/projects/bevy_haxe/src/haxe/color/Srgba.hx` |
| Modified | `/home/vscode/projects/bevy_haxe/src/haxe/color/LinearRgba.hx` |
| Modified | `/home/vscode/projects/bevy_haxe/src/haxe/color/Hsla.hx` |
| Modified | `/home/vscode/projects/bevy_haxe/src/haxe/color/ColorConversion.hx` |
| Modified | `/home/vscode/projects/bevy_haxe/src/haxe/color/Color.hx` |

---

## 5. Testing Strategy

### 单元测试检查项

1. **Srgba 转换测试**
   - `srgbToLinear` 和 `linearToSrgb` 是互逆的
   - 预设颜色常量正确

2. **LinearRgba 运算测试**
   - `mix` 在两颜色间正确插值
   - `lighter(0.1)` + `lighter(0.1)` ≈ `lighter(0.2)`
   - `darker` 同上

3. **Hsla 转换测试**
   - `srgbToHsla` 后 `hslaToSrgba` 颜色不变
   - `mix` 正确处理色相环绕 (如 350° 和 10° 应选择 0° 路径)

4. **Color 集成测试**
   - `Color.rgb(1, 0, 0)` == `Color.RED`
   - `Color.rgb(1, 1, 1)` == `Color.WHITE`

---

## 6. Rollback Plan

如需回滚：
- 使用 git checkout 恢复原始文件
- 或手动删除新增的常量和方法

---

## 7. Estimated Effort

- **时间:** 2-3 小时
- **复杂度:** Medium
- **主要工作量:**
  - Gamma 转换公式验证 (需对照 Rust)
  - 色相环绕的 mix 处理
  - 预设常量添加
