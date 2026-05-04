# Bevy Input Module Improvement Plan

## 1. Overview

This plan implements a comprehensive input system for the Haxe Bevy engine, inspired by Rust's `bevy_input` crate. The module provides unified input handling for keyboard, mouse, and gamepad devices with support for pressed/just-pressed/just-released states.

### Goals
- Implement `Input<T>` generic input state manager (similar to Rust's `ButtonInput<T>`)
- Implement `Mouse` input with position, motion, and scroll tracking
- Implement `Keyboard` with complete KeyCode enum (W3C standard)
- Implement `Gamepad` with axis, button, and connection handling
- Implement `InputPlugin` to integrate with the Bevy app lifecycle
- Support `ButtonState` enum (Pressed/Released)

### Success Criteria
- Input states work correctly (pressed, just_pressed, just_released)
- Platform-specific handlers for JS (web browser) environment
- Clean API matching Bevy's input patterns
- Extensible design for future input devices

---

## 2. Implementation Steps

### Step 1: Create Input.hx (Generic Input State Manager)
**File:** `src/haxe/input/Input.hx`

Features:
- Generic `Input<T>` class for tracking button states
- Internal maps for pressed buttons and just-pressed/released tracking
- Methods: `press()`, `release()`, `pressed()`, `justPressed()`, `justReleased()`
- Methods: `anyPressed()`, `anyJustPressed()`, `anyJustReleased()`, `getStrength()`
- Methods: `clicked()`, `clear()`, `reset()`
- `ButtonState` enum with `isPressed()` extension
- `Axis<T>` class for analog axis values

### Step 2: Create Mouse.hx (Mouse Input Handler)
**File:** `src/haxe/input/Mouse.hx`

Features:
- `MouseButton` enum (Left, Right, Middle, Extra1, Extra2)
- `MouseButtonInput` event class
- `MouseWheel` event class
- `MouseScrollUnit` enum (Line, Pixel)
- `MouseMotion` event class
- `AccumulatedMouseMotion` and `AccumulatedMouseScroll` resources
- `MouseInputHandler` class for DOM event handling (JS-only)
- Extension of `Input<MouseButton>` for button state

### Step 3: Create Keyboard.hx (Keyboard Input Handler)
**File:** `src/haxe/input/Keyboard.hx`

Features:
- Complete `KeyCode` enum (W3C UI Events standard)
- `KeyboardInput` event class
- `KeyboardLayoutIndependent` enum for logical keys
- `KeyboardInputHandler` class for DOM event handling (JS-only)
- Extension of `Input<KeyCode>` for key state

### Step 4: Create Gamepad.hx (Gamepad Input Handler)
**File:** `src/haxe/input/Gamepad.hx`

Features:
- `GamepadButton` enum (standard gamepad buttons)
- `GamepadAxis` enum (analog stick and trigger axes)
- `GamepadConnectionState` enum
- `Gamepad` class for individual gamepad state
- `GamepadInput` class managing all connected gamepads
- Methods: `getAxis()`, `getLeftStick()`, `getRightStick()`
- Deadzone support for analog inputs
- `GamepadSettings` for configuration

### Step 5: Create InputPlugin.hx (Input Plugin Integration)
**File:** `src/haxe/input/InputPlugin.hx`

Features:
- `InputPlugin` class implementing `Plugin` interface
- Initializes keyboard, mouse, and gamepad resources
- Registers update systems
- `InputConditions` class for run conditions
- Integration with Bevy app lifecycle

---

## 3. File Changes Summary

### New Files
| File | Description |
|------|-------------|
| `src/haxe/input/Input.hx` | Generic input state manager with ButtonState |
| `src/haxe/input/Mouse.hx` | Mouse input with button, wheel, motion tracking |
| `src/haxe/input/Keyboard.hx` | Keyboard with complete KeyCode enum |
| `src/haxe/input/Gamepad.hx` | Gamepad input with axis and button support |
| `src/haxe/input/InputPlugin.hx` | Plugin integration for Bevy app |

### Files to Delete
| File | Reason |
|------|--------|
| `src/haxe/input/Input_new.hx` | Superseded by Input.hx |
| `src/haxe/input/Mouse_new.hx` | Superseded by Mouse.hx |
| `src/haxe/input/Keyboard_new.hx` | Superseded by Keyboard.hx |
| `src/haxe/input/Gamepad_new.hx` | Superseded by Gamepad.hx |
| `src/haxe/input/Input_complete.hx` | Redundant with Input.hx |

---

## 4. Testing Strategy

### Unit Tests
1. **Input Tests**
   - Test press/release cycle
   - Test justPressed detection
   - Test justReleased detection
   - Test clear functionality
   - Test anyPressed with multiple inputs

2. **Mouse Tests**
   - Test button press/release
   - Test scroll accumulation
   - Test position delta calculation

3. **Keyboard Tests**
   - Test key press/release
   - Test KeyCode parsing from DOM events

4. **Gamepad Tests**
   - Test axis value clamping
   - Test deadzone application
   - Test gamepad connection/disconnection

### Integration Tests
- Create a test scene with input systems
- Verify input state propagates through system schedule

---

## 5. Rollback Plan

### Revert Steps
1. Delete new files in `src/haxe/input/`
2. Restore original files from git history if needed
3. Revert any changes to `src/haxe/prelude/Prelude.hx`

### No Database Migrations Required
This module does not modify persistent data.

---

## 6. Estimated Effort

| Task | Complexity | Estimated Time |
|------|------------|----------------|
| Input.hx | Medium | 2 hours |
| Mouse.hx | Medium | 1.5 hours |
| Keyboard.hx | Low | 1 hour |
| Gamepad.hx | Medium | 2 hours |
| InputPlugin.hx | Low | 0.5 hours |
| Testing | Medium | 2 hours |
| **Total** | - | **~9 hours** |

---

## 7. API Design Notes

### Input<T> Core API
```haxe
// Create input state for a button type
var keyboard = new Input<KeyCode>();

// Press and check states
keyboard.press(KeyCode.Space);
keyboard.pressed(KeyCode.Space);      // true
keyboard.justPressed(KeyCode.Space);  // true (this frame only)

// Release and check
keyboard.release(KeyCode.Space);
keyboard.pressed(KeyCode.Space);       // false
keyboard.justReleased(KeyCode.Space);  // true (this frame only)

// Get strength (for analog buttons)
keyboard.press(KeyCode.L1, 0.5);
keyboard.getStrength(KeyCode.L1);  // 0.5

// Clear just pressed state
keyboard.clearJustPressed();

// Check any button
keyboard.anyJustPressed();
```

### Mouse API
```haxe
// Mouse button state
mouse.pressed(MouseButton.Left);
mouse.justPressed(MouseButton.Right);

// Position tracking
mouse.position.x;        // current x
mouse.position.y;       // current y
mouse.positionDelta;    // delta since last frame
mouse.scrollDelta;     // scroll delta this frame
```

### Gamepad API
```haxe
// Get gamepad by index
var gp = gamepad.getGamepad(0);

// Button state
gp.pressed(GamepadButton.A);

// Axis values
gp.getAxis(LeftStickX);  // -1.0 to 1.0
gp.getAxis(L2Trigger);   // 0.0 to 1.0

// Convenience stick methods
gamepad.getLeftStick(0);   // {x: Float, y: Float}
gamepad.getRightStick(0);  // {x: Float, y: Float}
```
