# Bevy Input 模块改进计划

## 1. Overview

基于 Rust `bevy_input` crate 的 API 设计，改进 Haxe 版本的输入模块，使其与 Bevy Input API 保持一致。

### Goals
- 增强 `Input<T>` 泛型输入类，实现完整的 `ButtonInput` 功能
- 实现 `Mouse` 鼠标输入模块
- 实现 `Keyboard` 键盘输入模块
- 实现 `Gamepad` 手柄输入模块
- 实现 `InputPlugin` 输入插件

### Success Criteria
- API 与 Bevy Input 保持一致
- 支持 `ButtonState` (Pressed/Released)
- 支持 `just_pressed`, `just_released`, `pressed` 检测
- 支持轴输入 (Axis)

## 2. Prerequisites

- Haxe 4.x
- 已有 `haxe/ecs/Resource.hx` 资源系统
- 已有 `haxe/math/Vec2.hx` 数学库

## 3. Implementation Steps

### Step 1: 增强 Input.hx - 泛型 Input<T>

创建 `ButtonInput<T>` 类，包含:
- `pressed: Map<T, ButtonState>` - 当前按下状态
- `justPressed: Map<T, Bool>` - 刚按下的键
- `justReleased: Map<T, Bool>` - 刚释放的键

方法:
- `press(input: T)` - 按下
- `release(input: T)` - 释放
- `pressed(input: T): Bool` - 是否按下
- `justPressed(input: T): Bool` - 是否刚按下
- `justReleased(input: T): Bool` - 是否刚释放
- `clear()` - 清除 just 状态
- `reset(input: T)` - 重置单个输入
- `getPressed(): Array<T>` - 获取所有按下的键

### Step 2: 改进 Mouse.hx

包含:
- `MouseButton` 枚举 (Left, Right, Middle, Extra1, Extra2)
- `MouseButtonInput` 事件类
- `MouseMotion` 事件
- `MouseWheel` 事件
- `MouseScrollUnit` 枚举 (Line, Pixel)
- `MousePosition` 位置信息
- `AccumulatedMouseMotion` 累积鼠标移动
- `AccumulatedMouseScroll` 累积滚动

### Step 3: 改进 Keyboard.hx

包含:
- `KeyCode` 枚举 - W3C UI Events Code 值
- `Key` 枚举 - 可打印字符键
- `KeyboardInput` 事件类
- `KeyboardFocusLost` 事件

### Step 4: 改进 Gamepad.hx

包含:
- `GamepadButton` 枚举
- `GamepadAxis` 枚举
- `GamepadConnectionState` 枚举
- `Gamepad` 类
- `GamepadInput` 管理器
- `Axis<GamepadButton>` 和 `Axis<GamepadAxis>`
- Deadzone 支持

### Step 5: 改进 InputPlugin.hx

- 注册所有输入资源
- 提供系统更新方法
- 提供常用条件函数

## 4. File Changes Summary

### Modified Files
- `src/haxe/input/Input.hx` - 完全重写
- `src/haxe/input/Mouse.hx` - 增强
- `src/haxe/input/Keyboard.hx` - 增强
- `src/haxe/input/Gamepad.hx` - 增强
- `src/haxe/input/InputPlugin.hx` - 增强

### New Files
- None (全部基于现有文件改进)

## 5. Testing Strategy

- 编译测试: `haxe --cwd /home/vscode/projects/bevy_haxe build.hxml`
- 手动测试: 创建示例验证输入功能

## 6. Rollback Plan

- Git 回滚: `git checkout <file>` 恢复原始文件
- 备份现有文件到 `plans/` 目录

## 7. Estimated Effort

- **Time**: 2-3 小时
- **Complexity**: Medium
- **Files**: 5 个核心文件
