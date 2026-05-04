# Bevy Haxe Window Module Improvement Plan

## 1. Overview

### Description
改进 `bevy_haxe` 项目中的 `bevy_window` 模块，增强窗口管理功能并添加 WindowPlugin 支持，参考 Rust 版 `bevy_window` crate 的设计。

### Goals
1. 增强 `Window.hx` - 添加更完整的窗口属性、方法和管理功能
2. 添加 `WindowPlugin.hx` - 实现窗口插件系统
3. 添加窗口事件系统 - 窗口大小改变、焦点变化等事件
4. 添加窗口命令系统 - 用于窗口操作的 Systems
5. 添加窗口组件 - PrimaryWindow、ClosingWindow 等标记组件

### Scope
**Included:**
- Window 类的增强属性和方法
- WindowPlugin 插件实现
- 窗口相关事件类型
- 窗口操作命令函数
- WindowResolution、WindowMode 等辅助类型
- Monitor 和 VideoMode 类型

**Excluded:**
- 直接平台特定实现（通过 JS/HTML5 间接实现）
- Raw window handle（Web 目标不需要）

---

## 2. Prerequisites

### Dependencies
- `haxe.ecs.Component` - 组件基类
- `haxe.app.Plugin` - 插件接口
- `haxe.app.App` - 应用主类
- `haxe.math.Vec2` - 向量数学

### Environment
- Haxe 4.x+
- JavaScript 目标（用于 Web 平台）

---

## 3. Implementation Steps

### Step 1: 创建 prelude 文件 `WindowModule.hx`

创建统一的导出模块，提供 window 包中所有公共类型的便捷访问。

**文件:** `/home/vscode/projects/bevy_haxe/src/haxe/window/WindowModule.hx`

### Step 2: 增强 `Window.hx`

保留现有结构，增强以下内容：

**新增属性:**
- `name:Null<String>` - 窗口名称标识
- `presentMode:PresentMode` - 呈现模式（垂直同步）
- `mode:WindowMode` - 窗口模式（全屏、窗口化等）
- `position:WindowPosition` - 窗口位置
- `resolution:WindowResolution` - 窗口分辨率对象
- `transparent:Bool` - 透明窗口支持
- `windowLevel:WindowLevel` - 窗口层级
- `imeEnabled:Bool` - IME 输入法启用
- `imePosition:Vec2` - IME 光标位置
- `enabledButtons:EnabledButtons` - 启用哪些鼠标按钮

**新增方法:**
- `setMaximized(maximized:Bool)` - 设置最大化
- `setMinimized(minimized:Bool)` - 设置最小化
- `setFocused(focused:Bool)` - 设置焦点
- `setTitle(title:String)` - 设置标题
- `setSize(width:Float, height:Float)` - 设置大小
- `setPosition(x:Float, y:Float)` - 设置位置
- `close()` - 请求关闭窗口

**新增类型:**
- `PresentMode` - 枚举：Fifo, Immediate, Mailbox, AutoVsync, AutoNoVsync
- `WindowMode` - 枚举：Windowed, Fullscreen, FullscreenExclusive, BorderlessFullscreen
- `WindowLevel` - 枚举：Normal, AlwaysOnBottom, AlwaysOnTop
- `WindowPosition` - 枚举：Automatic, Centered, At(x, y)
- `WindowResolution` - 类：管理物理/逻辑像素和缩放因子
- `EnabledButtons` - 标志：Left, Right, Middle
- `PrimaryWindow` - 标记组件
- `ClosingWindow` - 标记组件

**文件:** `/home/vscode/projects/bevy_haxe/src/haxe/window/Window.hx`

### Step 3: 创建窗口事件 `WindowEvents.hx`

创建窗口相关事件类型。

**事件类型:**
- `WindowResized` - 窗口大小改变
- `WindowMoved` - 窗口位置改变
- `WindowCloseRequested` - 请求关闭窗口
- `WindowClose` - 窗口已关闭
- `WindowFocused` - 窗口获得焦点
- `WindowUnfocused` - 窗口失去焦点
- `WindowScaleFactorChanged` - 缩放因子改变
- `FileDragAndDrop` - 文件拖放
- `CursorEntered` - 光标进入窗口
- `CursorLeft` - 光标离开窗口
- `CursorMoved` - 光标移动
- `RequestRedraw` - 请求重绘

**文件:** `/home/vscode/projects/bevy_haxe/src/haxe/window/WindowEvents.hx`

### Step 4: 创建窗口命令系统 `WindowCommands.hx`

创建窗口操作的静态方法，作为 Systems 函数。

**命令函数:**
- `exitOnAllClosed` - 所有窗口关闭时退出
- `exitOnPrimaryClosed` - 主窗口关闭时退出
- `closeWhenRequested` - 响应窗口关闭请求
- `applyWindowAttributes` - 应用窗口属性到 Canvas
- `applyPendingWindowUpdates` - 应用待处理的窗口更新

**文件:** `/home/vscode/projects/bevy_haxe/src/haxe/window/WindowCommands.hx`

### Step 5: 增强 `WindowPlugin.hx`

改进插件实现，添加更多配置选项。

**新增内容:**
- `ExitCondition` 枚举：OnPrimaryClosed, OnAllClosed, DontExit
- `primaryCursorOptions:Null<CursorOptions>` - 主窗口光标选项
- 完整的 `build()` 方法实现
- 窗口初始化逻辑
- 窗口命令系统注册

**文件:** `/home/vscode/projects/bevy_haxe/src/haxe/window/WindowPlugin.hx`

### Step 6: 创建 Monitor 和 VideoMode 类型

**文件:** `/home/vscode/projects/bevy_haxe/src/haxe/window/Monitor.hx`

---

## 4. File Changes Summary

### New Files
| 文件路径 | 描述 |
|---------|------|
| `src/haxe/window/WindowModule.hx` | 统一导出模块 |
| `src/haxe/window/WindowEvents.hx` | 窗口事件类型 |
| `src/haxe/window/WindowCommands.hx` | 窗口命令系统 |
| `src/haxe/window/Monitor.hx` | 显示器信息类型 |

### Modified Files
| 文件路径 | 修改内容 |
|---------|---------|
| `src/haxe/window/Window.hx` | 大量增强：新增属性、方法、类型 |
| `src/haxe/window/WindowPlugin.hx` | 增强插件实现 |

---

## 5. Testing Strategy

### Unit Tests
- 测试 Window 类的属性设置和获取
- 测试 WindowResolution 的物理/逻辑像素转换
- 测试 PresentMode 和 WindowMode 枚举值
- 测试 WindowPlugin 默认配置

### Integration Tests
- 测试窗口创建和初始化流程
- 测试窗口事件触发和接收
- 测试退出条件逻辑

### Manual Testing (Web)
- 在浏览器中测试窗口创建
- 测试 Canvas 大小调整
- 测试全屏/窗口化切换

---

## 6. Rollback Plan

如果需要回滚更改：
1. 从 Git 历史恢复 `Window.hx` 和 `WindowPlugin.hx`
2. 删除新创建的文件
3. 删除未使用的 import

---

## 7. Estimated Effort

**Time Estimate:** 4-6 小时

**Complexity:** Medium

**Key Challenges:**
- 正确处理 Window 和 Component 接口的关系
- 在 Haxe 中实现 Rust 风格的枚举和结构体
- 协调窗口事件系统和 ECS

---

## 8. Reference: Rust Types

### Window fields from Rust (crates/bevy_window/src/window.rs):
- title, name, present_mode, mode, position, resolution
- resize_constraints, ime_enabled, ime_position
- resizable, decorations, transparent, focused
- window_level, fit_canvas_to_parent, visible

### Enums needed:
- WindowMode: Fullscreen, BorderlessFullscreen, Windowed, Minimized
- PresentMode: AutoNoVsync, AutoVsync, Fifo, Immediate, Mailbox
- WindowLevel: Normal, AlwaysOnTop, AlwaysOnBottom
- CompositeAlphaMode: Opaque, PreMultiplied, PostMultiplied, AlphaMix
- ExitCondition: OnPrimaryClosed, OnAllClosed, DontExit

### Event types from Rust (crates/bevy_window/src/event.rs):
- WindowResized, WindowMoved, WindowCloseRequested, WindowClose
- CursorEntered, CursorLeft, CursorMoved
- FileDragAndDrop, Ime

### Monitor types (crates/bevy_window/src/monitor.rs):
- MonitorInfo (already exists, may enhance)
- VideoMode (already exists)

---

## 9. Implementation Code Examples

### Window.hx 增强后结构:

```haxe
package haxe.window;

class PrimaryWindow implements Component {}
class ClosingWindow implements Component {}

enum PresentMode {
    AutoNoVsync;
    AutoVsync;
    Fifo;
    Immediate;
    Mailbox;
}

enum WindowMode {
    Windowed;
    Fullscreen;
    FullscreenExclusive(videoMode:VideoMode);
    BorderlessFullscreen;
}

enum WindowLevel {
    Normal;
    AlwaysOnBottom;
    AlwaysOnTop;
}

class WindowResolution {
    public var physicalWidth:Int;
    public var physicalHeight:Int;
    public var scaleFactorOverride:Null<Float>;
    public var scaleFactor:Float;
    
    public function width():Float;
    public function height():Float;
    public function physicalWidth():Int;
    public function physicalHeight():Int;
}

class Window implements Component {
    public var title:String;
    public var name:Null<String>;
    public var width:Float;
    public var height:Float;
    public var x:Float;
    public var y:Float;
    public var scaleFactor:Float;
    public var vsync:VsyncMode;
    public var resizable:Bool;
    public var decorations:Bool;
    public var maximized:Bool;
    public var visible:Bool;
    public var focused:Bool;
    public var resizeConstraints:WindowResizeConstraints;
    public var cursor:CursorIcon;
    public var cursorVisible:Bool;
    public var cursorGrabbed:Bool;
    
    // New fields
    public var presentMode:PresentMode;
    public var mode:WindowMode;
    public var position:WindowPosition;
    public var resolution:WindowResolution;
    public var transparent:Bool;
    public var windowLevel:WindowLevel;
    public var imeEnabled:Bool;
    public var imePosition:Vec2;
    public var enabledButtons:EnabledButtons;
    
    // New methods
    public function setMaximized(maximized:Bool):Void;
    public function setMinimized(minimized:Bool):Void;
    public function setFocused(focused:Bool):Void;
    public function setTitle(title:String):Void;
    public function setSize(width:Float, height:Float):Void;
    public function setPosition(x:Float, y:Float):Void;
    public function close():Void;
}
```

### WindowPlugin.hx 增强后结构:

```haxe
package haxe.window;

enum ExitCondition {
    OnPrimaryClosed;
    OnAllClosed;
    DontExit;
}

class WindowPlugin implements Plugin {
    public var primaryWindow:Null<Window>;
    public var primaryCursorOptions:Null<CursorOptions>;
    public var exitCondition:ExitCondition;
    public var closeWhenRequested:Bool;
    
    public function build(app:App):Void;
    public static function withDefaults():WindowPlugin;
    public static function withoutPrimary():WindowPlugin;
}
```
