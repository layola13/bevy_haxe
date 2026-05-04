# bevy_color 模块完善计划

## 1. Overview

完善 `/home/vscode/projects/bevy_haxe/src/haxe/color/` 目录下的颜色模块，使其与 Rust `bevy_color` 库功能对齐。

**目标：**
- Color 作为统一接口，支持静态工厂方法创建各类型颜色
- Srgba/LinearRgba/Hsla 之间的双向转换
- 支持 alpha 通道
- 正确的 sRGB gamma 校正

**范围：**
- 核心文件：Color.hx, Srgba.hx, LinearRgba.hx, Hsla.hx, ColorConversion.hx
- 辅助文件：HaxeMath.hx (已有)

## 2. Prerequisites

- 检查 Haxe 版本兼容性
- 检查现有文件完整性

## 3. Implementation Steps

### Step 1: 更新 Color.hx
- 添加静态工厂方法 `srgb()`, `srgba()`, `linearRgb()`, `linearRgba()`, `hsl()`, `hsla()`
- 添加 `mix()` 方法
- 添加 `hue`, `saturation`, `lightness` 属性
- 确保与 Rust API 对齐

### Step 2: 更新 Srgba.hx
- 验证 fromHsla(), fromLinearRgba() 转换方法
- 补充 `new()` 构造函数支持常量 (使用 inline 工厂方法)
- 添加 RGB 常量 (RED, GREEN, BLUE, WHITE, BLACK, NONE)

### Step 3: 更新 LinearRgba.hx
- 验证 fromSrgba(), fromHsla() 转换方法
- 补充常量定义
- 确保 gamma 转换正确

### Step 4: 更新 Hsla.hx
- 验证 fromSrgba(), fromLinearRgba() 转换方法
- 添加完整的 `mix()` 实现

### Step 5: 更新 ColorConversion.hx
- 验证 sRGB gamma 校正公式
- 确保所有转换保持 alpha 通道
- 添加批处理转换工具方法

## 4. File Changes Summary

### Modified Files:
| 文件 | 操作 | 说明 |
|------|------|------|
| `src/haxe/color/Color.hx` | 修改 | 添加静态工厂方法和颜色操作 |
| `src/haxe/color/Srgba.hx` | 修改 | 添加常量和验证转换 |
| `src/haxe/color/LinearRgba.hx` | 修改 | 添加常量和验证转换 |
| `src/haxe/color/Hsla.hx` | 修改 | 添加 mix 实现和验证转换 |
| `src/haxe/color/ColorConversion.hx` | 修改 | 完善转换公式 |

## 5. Testing Strategy

手动测试清单：
1. 颜色创建测试
   - `Color.srgb(1, 0, 0)` -> 红色
   - `Color.rgba(1, 0, 0, 0.5)` -> 半透明红色
   - `Color.hsl(0, 1, 0.5)` -> 红色
   
2. 转换测试
   - Srgba -> LinearRgba -> Srgba (往返)
   - Srgba -> Hsla -> Srgba (往返)
   - LinearRgba -> Hsla -> LinearRgba (往返)
   
3. Alpha 测试
   - 所有转换保留 alpha 值

4. Gamma 校正验证
   - 0.5 sRGB 应转换为 ~0.218 linear

## 6. Rollback Plan

使用 git 回滚：
```bash
git checkout HEAD -- src/haxe/color/
```

## 7. Estimated Effort

- **时间**: 约 2 小时
- **复杂度**: 中等
- **风险**: 低 (仅在现有文件基础上修改)
