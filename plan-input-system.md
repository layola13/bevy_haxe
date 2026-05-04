# Input System Implementation Plan

## 1. Overview

Create an input system for the Bevy Haxe engine targeting Web (JavaScript). The system manages keyboard, mouse, and gamepad input states with support for just-pressed, pressed, and just-released detection patterns.

### Goals
- Implement generic `Input<T>` class for button state management
- Create keyboard input with KeyCode enum based on W3C standards
- Create mouse input with MouseButton and scroll wheel support
- Create gamepad input with button and axis support
- Provide InputPlugin for system initialization and event processing
- Support Web platform via JavaScript DOM events

### Scope
- **Included**: Input.hx, Mouse.hx, Keyboard.hx, Gamepad.hx, InputPlugin.hx
- **Excluded**: Touch input (future enhancement)

---

## 2. Prerequisites

- Haxe 4.x with JavaScript target
- `haxe.ds.Map` for hash maps
- `js.html.*` APIs for Web platform event handling

---

## 3. Implementation Steps

### Step 1: Create Input.hx (Generic Input State Management)
- Define `ButtonState` enum (Pressed/Released)
- Define `Input<T>` class with:
  - `pressed` HashSet for currently pressed buttons
  - `justPressed` HashSet for buttons pressed this frame
  - `justReleased` HashSet for buttons released this frame
  - Methods: `press()`, `release()`, `clearJustPressed()`, `clearJustReleased()`, `clear()`, `pressed()`, `justPressed()`, `justReleased()`

### Step 2: Create Mouse.hx (Mouse Input)
- Define `MouseButton` enum (Left, Right, Middle, Extra1, Extra2)
- Define `MouseWheel` class with x, y delta
- Define `MouseMotion` class with dx, dy delta
- Define `MouseButtonInput` class with button and state
- Define `Mouse` class extending `Input<MouseButton>`
- Register Web DOM mouse event listeners

### Step 3: Create Keyboard.hx (Keyboard Input)
- Define `KeyCode` enum based on W3C UI Events spec
- Define `Key` enum for logical key representation
- Define `KeyboardInput` class with key code, scan code, state
- Define `Keyboard` class extending `Input<KeyCode>`
- Register Web DOM keyboard event listeners (keydown, keyup)

### Step 4: Create Gamepad.hx (Gamepad Input)
- Define `GamepadButton` enum (Start, Select, A, B, X, Y, L1, R1, L2, R2, L3, R3, DPadUp, DPadDown, DPadLeft, DPadRight)
- Define `GamepadAxis` enum (LeftStick, RightStick, L2, R2)
- Define `Gamepad` class with id, index, connected status
- Define `GamepadInput` class extending `Input<GamepadButton>`
- Register Gamepad API event listeners

### Step 5: Create InputPlugin.hx (Plugin)
- Define `InputPlugin` class implementing `Plugin`
- Implement `build()` method to register systems and resources
- Add `Keyboard` and `Mouse` resources
- Add gamepad connection handling

---

## 4. File Changes Summary

### Created Files
- `/home/vscode/projects/bevy_haxe/src/haxe/input/Input.hx`
- `/home/vscode/projects/bevy_haxe/src/haxe/input/Mouse.hx`
- `/home/vscode/projects/bevy_haxe/src/haxe/input/Keyboard.hx`
- `/home/vscode/projects/bevy_haxe/src/haxe/input/Gamepad.hx`
- `/home/vscode/projects/bevy_haxe/src/haxe/input/InputPlugin.hx`

---

## 5. Testing Strategy

### Manual Testing
1. Create a test scene with keyboard/mouse input handling
2. Verify key press/release detection
3. Verify mouse button and wheel detection
4. Test gamepad connection/disconnection

---

## 6. Rollback Plan

- Simply delete the created files if issues arise
- No database migrations or data changes required

---

## 7. Estimated Effort

- **Time**: 2-3 hours
- **Complexity**: Medium
- **Dependencies**: None (standalone module)
