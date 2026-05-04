# Bevy Color 模块完善计划

## 1. 概述

完善 `/home/vscode/projects/bevy_haxe/src/haxe/color/` 下的颜色模块，参考 Rust `bevy_color` crate 实现。

### 目标
- Color 作为统一接口，支持静态工厂方法
- Srgba/LinearRgba/Hsla 相互转换
- 支持 alpha 通道

### 成功标准
- 所有颜色类型可以相互转换
- Color 抽象类型提供统一访问接口
- 转换公式与 Rust 实现一致

## 2. 当前状态

| 文件 | 状态 | 需要修改 |
|------|------|----------|
| Color.hx | 已有 | 添加静态工厂方法 |
| Srgba.hx | 已有 | 添加 mix() 方法 |
| LinearRgba.hx | 已有 | 添加 mix() 方法 |
| Hsla.hx | 已有 | 添加 mix() 方法 |
| ColorConversion.hx | 已有 | 验证转换公式 |
| HaxeMath.hx | 已有 | 完整 (无需修改) |
| Hsva.hx | 已有 | 完整 (额外) |

## 3. 实现步骤

### Step 1: 更新 Color.hx
添加静态工厂方法:
- `srgb(r, g, b)` - 创建 sRGB 颜色
- `srgbAlpha(r, g, b, a)` - 创建带 alpha 的 sRGB
- `hsl(h, s, l)` - 创建 HSL 颜色
- `hslAlpha(h, s, l, a)` - 创建带 alpha 的 HSL
- `hsv(h, s, v)` - 创建 HSV 颜色

### Step 2: 更新 Srgba.hx
添加 `mix(other, t)` 方法，支持颜色混合

### Step 3: 更新 LinearRgba.hx
添加 `mix(other, t)` 方法，支持颜色混合

### Step 4: 更新 Hsla.hx
添加 `mix(other, t)` 方法，支持颜色混合

### Step 5: 验证 ColorConversion.hx
确保所有转换函数与 Rust 实现一致:
- srgbComponentToLinear
- linearComponentToSrgb
- hslaToSrgba
- hslaToLinear
- srgbaToHsla
- linearToHsla

## 4. 文件变更

### 修改文件
- `src/haxe/color/Color.hx` - 添加静态工厂方法
- `src/haxe/color/Srgba.hx` - 添加 mix 方法
- `src/haxe/color/LinearRgba.hx` - 添加 mix 方法
- `src/haxe/color/Hsla.hx` - 添加 mix 方法

### 不需要修改
- `ColorConversion.hx` - 已完整
- `HaxeMath.hx` - 已完整
- `Hsva.hx` - 已完整

## 5. 测试策略

手动验证:
1. 创建各种颜色类型
2. 转换为其他类型
3. 验证 round-trip 转换精度
4. 测试 mix() 方法
5. 验证 Color 统一接口

## 6. 回滚计划

如需回滚，使用 Git 恢复修改:
```bash
git checkout src/haxe/color/*.hx
```

## 7. 预估工作

- 复杂度: 中等
- 预估时间: 30 分钟
- 修改文件数: 4
