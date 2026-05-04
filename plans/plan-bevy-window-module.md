# Bevy Window Module Improvement Plan

## 1. Overview

This plan aims to improve the `bevy_window` module for Haxe, targeting web platform with a simplified but functional implementation. The improvements will align more closely with the Rust `bevy_window` crate while maintaining a Haxe-friendly API.

### Goals
- Enhance `Window.hx` with missing types and methods
- Improve `WindowPlugin.hx` with better system integration
- Add new supporting types: `WindowResolution`, `PrimaryWindow`, etc.

### Scope
- **Included**: Window component, window plugin, related types and systems
- **Excluded**: Platform-specific implementations (handled at runtime), raw handle access

---

## 2. Prerequisites

- Haxe 4.x+
- ECS module already implemented (`haxe.ecs.*`)
- App/Plugin system already implemented (`haxe.app.*`)
- Event system for window events
- No external dependencies required

---

## 3. Implementation Steps

### Step 1: Enhance Window.hx - Add Missing Types and Fields

**File**: `/home/vscode/projects/bevy_haxe/src/haxe/window/Window.hx`

**Changes**:
1. Add `PrimaryWindow` marker component class
2. Add `WindowResolution` class for managing resolution state
3. Add missing window fields from Rust implementation:
   - `name`: Optional window identifier
   - `enabledButtons`: Window buttons that are enabled
   - `transparent`: Whether window is transparent
   - `windowLevel`: Window stacking level
   - `fitCanvasToParent`: Canvas fitting behavior
   - `preventDefaultEventHandling`: Event handling behavior
   - `canvas`: Canvas element reference
   - `windowTheme`: Light/dark theme
   - `skipTaskbar`: Whether to skip taskbar
   - `clipChildren`: Whether to clip children
   - `desiredMaximumFrameLatency`: Max frame latency
4. Add gesture recognition fields:
   - `recognizePinchGesture`
   - `recognizeRotationGesture`
   - `recognizeDoubleTapGesture`
   - `recognizePanGesture`
5. Add iOS-specific fields (for future compatibility)
6. Add methods from Rust implementation:
   - `setMaximized(bool)`
   - `setMinimized(bool)`
   - `startDragMove()`
   - `startDragResize()`
   - `setTitle(String)`
   - `setScaleFactorOverride(Option<Float>)`

### Step 2: Enhance Window.hx - Add Supporting Types

**File**: `/home/vscode/projects/bevy_haxe/src/haxe/window/Window.hx`

**Changes**:
1. Add `WindowResizeConstraints` class with min/max width/height
2. Add `WindowMode` enum: Normal, Fullscreen, BorderlessFullscreen, Minimized
3. Add `PresentMode` enum: AutoVsync, AutoNoVsync, Fifo, Immediate, Mailbox
4. Add `CompositeAlphaMode` enum
5. Add `WindowLevel` enum: Normal, AlwaysOnTop, AlwaysOnBottom
6. Add `MonitorSelection` enum for monitor selection
7. Add `MonitorInfo` class (already exists, enhance if needed)

### Step 3: Improve WindowPlugin.hx - Enhanced Plugin Structure

**File**: `/home/vscode/projects/bevy_haxe/src/haxe/window/WindowPlugin.hx`

**Changes**:
1. Add `CursorOptions` integration
2. Complete `build()` method with proper system setup
3. Add proper resource management:
   - Add `Window` resource on initialization
   - Add `PrimaryWindow` marker entity when primary window exists
4. Enhance system ordering with `Last` schedule
5. Add exit condition handling system
6. Add close requested handling system

### Step 4: Add WindowEvent Types

**File**: `/home/vscode/projects/bevy_haxe/src/haxe/window/WindowEvent.hx` (new)

**Types to add**:
- `WindowResized` - window size changed
- `WindowCloseRequested` - close button pressed
- `WindowClose` - window closed
- `WindowFocused` - window gained/lost focus
- `WindowMoved` - window position changed
- `RequestRedraw` - request redraw
- `FileDragAndDrop` - file drag and drop events
- `CursorEntered` / `CursorLeft` - cursor enter/leave
- `CursorMoved` - cursor position changed

### Step 5: Add System Functions

**File**: `/home/vscode/projects/bevy_haxe/src/haxe/window/WindowSystems.hx` (new)

**Systems to add**:
- `exitOnAllClosed()` - exit when no windows
- `exitOnPrimaryClosed()` - exit when primary window closed
- `closeWhenRequested()` - handle close requests

---

## 4. File Changes Summary

### Files to Create:
| File | Description |
|------|-------------|
| `src/haxe/window/WindowEvent.hx` | Window event types |
| `src/haxe/window/WindowSystems.hx` | Window management systems |

### Files to Modify:
| File | Description |
|------|-------------|
| `src/haxe/window/Window.hx` | Major enhancement with new types and methods |
| `src/haxe/window/WindowPlugin.hx` | Improved plugin with proper system integration |

---

## 5. Testing Strategy

### Unit Tests:
1. Test `Window` creation with default values
2. Test `WindowResolution` calculations
3. Test `WindowResizeConstraints` validation
4. Test enum value conversions

### Integration Tests:
1. Test `WindowPlugin` initialization
2. Test window creation via plugin
3. Test system execution order

### Manual Testing:
1. Create a simple app with `WindowPlugin`
2. Verify window appears on screen
3. Verify resize constraints work

---

## 6. Rollback Plan

To rollback changes:
1. Revert modifications to `Window.hx` and `WindowPlugin.hx`
2. Delete created files `WindowEvent.hx` and `WindowSystems.hx`
3. Restore previous versions from git if available

---

## 7. Estimated Effort

- **Time**: ~2-3 hours
- **Complexity**: Medium
- **Risk**: Low - Adding new features without breaking existing API

---

## 8. Implementation Details

### Window.hx Structure

```haxe
package haxe.window;

// New types
class PrimaryWindow implements Component {}

// Window resolution management
class WindowResolution {
    var physicalWidth:Int;
    var physicalHeight:Int;
    var scaleFactorOverride:Null<Float>;
    var scaleFactor:Float;
    
    // Methods
    public function width():Float;
    public function height():Float;
    public function physicalWidth():Int;
    public function physicalHeight():Int;
}

// Main Window class
class Window implements Component {
    // Existing fields...
    
    // New fields
    public var resolution:WindowResolution;
    public var name:Null<String>;
    public var enabledButtons:WindowButtons;
    public var transparent:Bool;
    public var windowLevel:WindowLevel;
    public var fitCanvasToParent:Bool;
    public var canvas:Dynamic; // JS Canvas element
    public var windowTheme:WindowTheme;
    public var skipTaskbar:Bool;
    public var clipChildren:Bool;
    public var desiredMaximumFrameLatency:Null<Int>;
    
    // New methods
    public function setMaximized(maximized:Bool):Void;
    public function setMinimized(minimized:Bool):Void;
    public function setTitle(title:String):Void;
}
```

### WindowPlugin.hx Structure

```haxe
class WindowPlugin implements Plugin {
    public var primaryWindow:Null<Window>;
    public var primaryCursorOptions:Null<CursorOptions>;
    public var exitCondition:ExitCondition;
    public var closeWhenRequested:Bool;
    
    public function build(app:App):Void {
        // Initialize window resource
        // Add systems to Last schedule
    }
}
```
