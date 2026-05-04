# Bevy Input Module Improvement Plan

## 1. Overview

This plan outlines the improvements to the `bevy_input` Haxe module, mirroring the functionality of the Rust `bevy_input` crate. The goal is to create a robust, type-safe input handling system that maintains API consistency with Bevy while being idiomatic to Haxe.

### Goals and Success Criteria
- Implement generic `Input<T>` class for button-style inputs
- Add comprehensive `Mouse` class with button, motion, and scroll support
- Add `Keyboard` class with full KeyCode enum based on W3C standards
- Add `Gamepad` class with axis and button support
- Create `InputPlugin` to integrate with the Bevy Haxe app lifecycle
- Support `ButtonState` enum with Pressed/Released states
- All classes should work as ECS resources/components

### Scope Boundaries
**Included:**
- Core input types and classes
- Mouse, Keyboard, Gamepad input handling
- Platform-specific implementations (js/web)
- Plugin integration

**Excluded:**
- Touch input (future enhancement)
- Gesture recognition (future enhancement)

---

## 2. Prerequisites

### Required Dependencies
- `haxe.ds.Map` for hash maps
- `haxe.ds.Option` for optional values
- `haxe.ds.ArraySort` for sorting
- `haxe.math.Vec2` for 2D vectors
- `haxe.ecs` module for ECS integration
- `haxe.app` module for plugin system

### Environment Requirements
- Haxe 4.x or later
- Target: JavaScript (primary), NME (future)

---

## 3. Implementation Steps

### Step 1: Create `ButtonState.hx`
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/input/ButtonState.hx`

Create the ButtonState enum with extension methods:
- `ButtonState` enum: `Pressed`, `Released`
- `isPressed()` extension method
- Mirror Rust's `ButtonState` API

### Step 2: Create `Input.hx` (Generic ButtonInput)
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/input/Input.hx`

Implement the generic `Input<T>` class:
- Generic type parameter `T` for button type
- Internal state maps: `_pressed`, `_justPressed`, `_justReleased`
- Methods:
  - `press(input:T, ?strength:Float)` - Register button press
  - `release(input:T)` - Register button release
  - `pressed(input:T):Bool` - Check if currently pressed
  - `justPressed(input:T):Bool` - Check if just pressed this frame
  - `justReleased(input:T):Bool` - Check if just released this frame
  - `getStrength(input:T):Null<Float>` - Get press strength
  - `anyPressed():Bool` - Check if any button pressed
  - `anyJustPressed():Bool` - Check if any just pressed
  - `anyJustReleased():Bool` - Check if any just released
  - `getPressed():Array<T>` - Get all pressed buttons
  - `clear()` - Clear just pressed/released
  - `reset()` - Full reset

### Step 3: Create `Mouse.hx`
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/input/Mouse.hx`

Implement mouse input handling:
- `MouseButton` enum: `Left`, `Right`, `Middle`, `Extra1`, `Extra2`
- `MouseButtonInput` class for events
- `MouseWheel` class for scroll events
- `MouseScrollUnit` enum: `Line`, `Pixel`
- `MouseMotion` class for cursor movement
- `MousePosition` class for position tracking
- `AccumulatedMouseMotion` class
- `AccumulatedMouseScroll` class
- `MouseInputHandler` class for DOM events (js only)

### Step 4: Create `Keyboard.hx`
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/input/Keyboard.hx`

Implement keyboard input handling:
- `KeyCode` enum with full W3C UI Events Code values
  - Misc keys, numbers, letters, function keys
  - Modifiers, arrows, numpad
  - Media keys, TV keys, etc.
- `KeyboardInput` class for keyboard input events
- `Key` enum for logical key representation
- `KeyboardInputHandler` class for DOM events (js only)

### Step 5: Create `Gamepad.hx`
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/input/Gamepad.hx`

Implement gamepad input handling:
- `GamepadButton` enum
- `GamepadAxis` enum
- `GamepadConnectionState` enum
- `Gamepad` class representing a single gamepad
- `GamepadSettings` class for configuration
- `GamepadInput` class for managing multiple gamepads
- `GamepadEvent` types

### Step 6: Create `InputPlugin.hx`
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/input/InputPlugin.hx`

Implement the input plugin:
- Extend `Plugin` class
- Register resources: `Input<KeyCode>`, `Input<MouseButton>`, etc.
- Add update systems
- Support platform-specific initialization
- `InputConditions` class for system run conditions

---

## 4. File Changes Summary

### New Files to Create:
| File | Description |
|------|-------------|
| `src/haxe/input/ButtonState.hx` | ButtonState enum and extensions |
| `src/haxe/input/Input.hx` | Generic Input<T> class (main implementation) |
| `src/haxe/input/Mouse.hx` | Mouse input handling |
| `src/haxe/input/Keyboard.hx` | Keyboard input handling |
| `src/haxe/input/Gamepad.hx` | Gamepad input handling |
| `src/haxe/input/InputPlugin.hx` | Input plugin for app integration |

### Files to Update:
| File | Changes |
|------|---------|
| `src/haxe/input/Input_complete.hx` | Delete (redundant) |
| `src/haxe/input/Input_new.hx` | Delete (redundant) |
| `src/haxe/input/Mouse_new.hx` | Delete (redundant) |
| `src/haxe/input/Keyboard_new.hx` | Delete (redundant) |
| `src/haxe/input/Gamepad_new.hx` | Delete (redundant) |

---

## 5. Testing Strategy

### Unit Tests to Write
1. **Input Tests:**
   - Test press/release cycle
   - Test justPressed/justReleased behavior
   - Test strength values
   - Test anyPressed/anyJustPressed/anyJustReleased
   - Test clear and reset functionality

2. **Mouse Tests:**
   - Test button press/release
   - Test scroll accumulation
   - Test motion delta

3. **Keyboard Tests:**
   - Test key press/release
   - Test KeyCode parsing

4. **Gamepad Tests:**
   - Test axis values with deadzone
   - Test button press/release
   - Test connection state

### Manual Testing Steps
1. Create a test app with input listeners
2. Verify keyboard input works
3. Verify mouse input works
4. Verify gamepad input works
5. Verify input conditions work in systems

---

## 6. Rollback Plan

### Revert Steps
1. Keep backup of old files before deletion
2. If issues arise, restore from backup
3. If Input.hx has problems, revert to Input_complete.hx

### Data Migration
- No persistent data migration needed
- Input state is transient (per-frame)

---

## 7. Estimated Effort

### Time Estimate
- **Phase 1 (Core types):** 2-3 hours
- **Phase 2 (Mouse/Keyboard):** 3-4 hours
- **Phase 3 (Gamepad):** 2-3 hours
- **Phase 4 (Plugin integration):** 1-2 hours
- **Total:** 8-12 hours

### Complexity Assessment
**Medium-High**

Key challenges:
- Generic type handling in Haxe
- DOM event integration for web
- Consistent API with Rust Bevy

---

## 8. API Reference

### ButtonState
```haxe
enum ButtonState {
    Pressed;
    Released;
}

extension ButtonState {
    static function isPressed(state:ButtonState):Bool;
}
```

### Input<T>
```haxe
class Input<T> {
    function new():Void;
    function press(input:T, ?strength:Float):Void;
    function release(input:T):Void;
    function pressed(input:T):Bool;
    function justPressed(input:T):Bool;
    function justReleased(input:T):Bool;
    function getStrength(input:T):Null<Float>;
    function anyPressed():Bool;
    function anyJustPressed():Bool;
    function anyJustReleased():Bool;
    function getPressed():Array<T>;
    function clear():Void;
    function reset():Void;
    function resetInput(input:T):Void;
}
```

### InputPlugin
```haxe
class InputPlugin extends Plugin {
    var keyboard:KeyboardInput;
    var mouse:MouseInput;
    var gamepad:GamepadInput;
    
    function new():Void;
    function build(app:App):Void;
    function update():Void;
}
```
