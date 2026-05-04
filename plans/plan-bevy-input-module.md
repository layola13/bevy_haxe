# Bevy Input Module Improvement Plan

## 1. Overview

### Description
Improve the `bevy_input` Haxe module to match Bevy's Rust Input API more closely, providing a unified input handling system for keyboard, mouse, and gamepad devices.

### Goals
- Implement `Input<T>` generic input manager similar to Rust's `ButtonInput<T>`
- Add complete `Mouse.hx` with mouse button, motion, and scroll handling
- Add complete `Keyboard.hx` with full KeyCode enum (W3C standard)
- Add `Gamepad.hx` with gamepad connection, axis, and button support
- Add `InputPlugin.hx` as Bevy plugin for input system registration
- Support `ButtonState` enum (Pressed/Released)
- Maintain cross-platform compatibility (JS/web, native)

### Scope Boundaries
**Included:**
- Generic `Input<T>` class with full button state tracking
- Complete keyboard input with W3C key codes
- Complete mouse input with buttons, position, scroll
- Gamepad input with deadzone support
- Input plugin for system registration

**Excluded:**
- Touch input (separate module)
- Gesture recognition
- Platform-specific native implementations

---

## 2. Prerequisites

### Dependencies
- `haxe.ds.Map` - for storing input state
- `haxe.ds.StringMap` - for gamepad registry
- `haxe.math.Vec2` - for 2D positions and deltas
- `haxe.ds.Option` - for optional axis values

### Environment Requirements
- Haxe 4.0+
- Target: JS (web) and NME/CPP (native)

---

## 3. Implementation Steps

### Step 1: Create ButtonState.hx
**File:** `src/haxe/input/ButtonState.hx` (NEW)

Defines the button state enum used across all input types.

```haxe
package haxe.input;

/**
    The current "press" state of an element.
*/
enum ButtonState {
    /** The button is pressed. */
    Pressed;
    /** The button is not pressed. */
    Released;
}

/**
    Extension methods for ButtonState.
*/
class ButtonStateExtensions {
    /** Returns true if this state is Pressed. */
    public static inline function isPressed(state:ButtonState):Bool {
        return state == Pressed;
    }
}
```

### Step 2: Create Input.hx
**File:** `src/haxe/input/Input.hx` (REPLACE)

Generic button input class with full state tracking.

**Key Methods:**
- `press(input:T, ?strength:Float)` - Register press
- `release(input:T)` - Register release
- `pressed(input:T):Bool` - Currently held
- `justPressed(input:T):Bool` - Just pressed this frame
- `justReleased(input:T):Bool` - Just released this frame
- `getStrength(input:T):Option<Float>` - Press strength
- `pressedAny():Bool` - Any button pressed
- `justPressedAny():Bool` - Any button just pressed
- `clear()` - Clear just_* states
- `reset()` - Full reset
- `getPressed():Iterator<T>` - All pressed buttons
- `buttonsPressedComparison(inputs:Array<T>):Bool` - Check multiple

### Step 3: Create Mouse.hx
**File:** `src/haxe/input/Mouse.hx` (REPLACE)

Mouse input handling with button, motion, and scroll.

**Components:**
- `MouseButton` enum (Left, Right, Middle, Extra1, Extra2)
- `MouseButtonInput` class (button, state, window)
- `MouseWheel` class (x, y, unit)
- `MouseScrollUnit` enum (Line, Pixel)
- `MouseMotion` class (delta)
- `AccumulatedMouseMotion` class (delta)
- `AccumulatedMouseScroll` class (delta, unit)
- `MousePosition` class (x, y, toVec2)
- `MouseInputHandler` class (DOM event handlers, conditional JS)
- `Mouse` class extends `Input<MouseButton>` with position tracking

### Step 4: Create Keyboard.hx
**File:** `src/haxe/input/Keyboard.hx` (REPLACE)

Complete W3C-compliant keyboard input with 200+ key codes.

**Key Components:**
- Full `KeyCode` enum based on W3C UI Events Code values
- `KeyboardInput` class (key, state, window)
- `KeyboardInputHandler` class (DOM event handlers)
- `Keyboard` class extends `Input<KeyCode>` with text input support

### Step 5: Create Gamepad.hx
**File:** `src/haxe/input/Gamepad.hx` (REPLACE)

Gamepad input with deadzone and connection management.

**Components:**
- `GamepadButton` enum (standard gamepad buttons)
- `GamepadAxis` enum (stick axes, triggers)
- `GamepadConnectionState` enum (Connected, Disconnected)
- `GamepadEvent` enum (Connection, Button, Axis)
- `GamepadSettings` class (deadzone configuration)
- `GamepadAxisPair` class (left/right stick)
- `GamepadInput` class with full gamepad management

### Step 6: Create InputPlugin.hx
**File:** `src/haxe/input/InputPlugin.hx` (REPLACE)

Bevy-style plugin for registering input systems.

**Features:**
- Plugin pattern matching Bevy API
- Resource registration in world
- Update cycle integration
- Common conditions for systems

### Step 7: Create InputConditions.hx
**File:** `src/haxe/input/InputConditions.hx` (NEW)

Common run conditions for input checking in systems.

---

## 4. File Changes Summary

### Created Files
| File | Description |
|------|-------------|
| `src/haxe/input/ButtonState.hx` | Button state enum and extensions |
| `src/haxe/input/InputConditions.hx` | Input condition helpers |

### Modified Files
| File | Action |
|------|--------|
| `src/haxe/input/Input.hx` | Replace with complete implementation |
| `src/haxe/input/Mouse.hx` | Replace with complete implementation |
| `src/haxe/input/Keyboard.hx` | Replace with complete implementation |
| `src/haxe/input/Gamepad.hx` | Replace with complete implementation |
| `src/haxe/input/InputPlugin.hx` | Replace with complete implementation |

### Deleted Files (backup old versions)
| File |
|------|
| `src/haxe/input/Input_new.hx` |
| `src/haxe/input/Mouse_new.hx` |
| `src/haxe/input/Keyboard_new.hx` |
| `src/haxe/input/Input_complete.hx` |
| `src/haxe/input/Gamepad_new.hx` |

---

## 5. Testing Strategy

### Unit Tests
1. **Input Tests:**
   - Test press/release cycle
   - Test justPressed/justReleased state
   - Test clear and reset
   - Test strength values
   - Test button comparison

2. **Mouse Tests:**
   - Test button state transitions
   - Test position delta calculation
   - Test scroll accumulation

3. **Keyboard Tests:**
   - Test key code mapping
   - Test modifier key detection

4. **Gamepad Tests:**
   - Test deadzone application
   - Test connection state
   - Test axis values

### Manual Testing
1. Build for JS target
2. Test in browser with keyboard/mouse
3. Connect gamepad and test input
4. Verify clear() behavior between frames

---

## 6. Rollback Plan

1. **Backup existing files** before modification
2. **Git operations** if in git repository:
   ```bash
   git checkout -- src/haxe/input/
   ```
3. **Revert plan:**
   - Remove new/modified files
   - Restore backup copies with `_backup` suffix

---

## 7. Estimated Effort

### Time Estimate
- **Phase 1:** ButtonState.hx, Input.hx - 2 hours
- **Phase 2:** Mouse.hx - 1.5 hours
- **Phase 3:** Keyboard.hx - 2 hours
- **Phase 4:** Gamepad.hx - 2 hours
- **Phase 5:** InputPlugin.hx - 1 hour
- **Phase 6:** Testing and cleanup - 1.5 hours

**Total:** ~10 hours

### Complexity Assessment
**Medium-High**

Key challenges:
- Haxe doesn't support generic `class Input<T>` as cleanly as Rust
- Must simulate type-level constraints for `T: Hash`
- DOM event handling is JS-specific, requires conditional compilation
- Gamepad API has different browser implementations

---

## 8. API Comparison (Rust vs Haxe)

| Rust API | Haxe Equivalent | Notes |
|----------|----------------|-------|
| `ButtonInput<T>` | `Input<T>` | Generic input class |
| `Axis<T>` | `GamepadInput.axis` | Map-based axis storage |
| `ButtonState` | `ButtonState` | Identical enum |
| `ButtonInput::pressed()` | `Input.pressed()` | Same semantics |
| `ButtonInput::just_pressed()` | `Input.justPressed()` | Different naming |
| `ButtonInput::get_strength()` | `Input.getStrength()` | Same semantics |
| `MouseButton` | `MouseButton` | Same enum |
| `KeyCode` | `KeyCode` | W3C compliant |
| `GamepadButton` | `GamepadButton` | Similar mapping |
| `InputPlugin` | `InputPlugin` | Plugin pattern |
