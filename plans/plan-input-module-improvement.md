# Bevy Input Module Improvement Plan

## 1. Overview

Improve the `bevy_input` module to more closely match the Rust Bevy Input API. This includes enhancing the generic `Input<T>` class, adding proper mouse/keyboard/gamepad support, and implementing the InputPlugin as a proper Bevy plugin.

### Goals
- Match Rust Bevy's `ButtonInput<T>` (renamed to `Input<T>`) API closely
- Support `ButtonState` enum with `isPressed()` method
- Implement full mouse input handling with position, scroll, and accumulated motion
- Implement comprehensive keyboard input with W3C standard KeyCodes
- Implement gamepad support with axis, buttons, and connection management
- Create a proper InputPlugin that integrates with Bevy's app system

### Scope
**Included:**
- `Input.hx` - Generic input resource (ButtonInput<T> equivalent)
- `Mouse.hx` - Mouse input types and mouse button input resource
- `Keyboard.hx` - Keyboard input types and keyboard input resource
- `Gamepad.hx` - Gamepad types and gamepad input resource
- `InputPlugin.hx` - Input plugin for Bevy

**Excluded:**
- Touch input (separate module)
- Gesture support (separate module)
- Platform-specific implementations (handled via conditional compilation)

## 2. Prerequisites

### Dependencies
- `haxe.ds.Map` - For storing input states
- `haxe.ds.HashMap` or custom hash implementation
- `haxe.math.Vec2` - For mouse position/scroll
- `haxe.ecs.World` - For resource management
- `haxe.app.App` - For app integration

### Haxe Version
- Haxe 4.x or later (for enum matching improvements)

## 3. Implementation Steps

### Step 1: Enhance Input.hx (Generic Input<T>)
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/input/Input.hx`

Replace the minimal implementation with a full `Input<T>` class:

```haxe
class Input<T> {
    // Internal state maps
    // Methods: press, release, pressed, justPressed, justReleased
    // Methods: getStrength, clear, reset, pressedAny, justPressedAny, justReleasedAny
    // Methods: getPressed, getJustPressed, getJustReleased
    // Methods: clearJustPressed, clearJustReleased
}
```

Key features:
- `pressed<T>(input:T)` - Check if input is currently pressed
- `justPressed<T>(input:T)` - Check if input was just pressed this frame
- `justReleased<T>(input:T)` - Check if input was just released this frame
- `getStrength<T>(input:T)` - Get press strength (0.0 to 1.0)
- `clear()` - Clear just pressed/released states
- `reset<T>(input:T)` - Reset specific input
- Batch operations: `pressedAny`, `justPressedAny`, `justReleasedAny`

### Step 2: Enhance Mouse.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/input/Mouse.hx`

Add/enhance these types:
- `MouseButton` enum - Left, Right, Middle, Extra1, Extra2
- `MouseButtonInput` class - Event with button, state, window
- `MouseWheel` class - x, y scroll values, unit
- `MouseMotion` class - delta vector
- `AccumulatedMouseMotion` class - Frame accumulated motion
- `AccumulatedMouseScroll` class - Frame accumulated scroll
- `MousePosition` class - x, y coordinates
- `Input<MouseButton>` subclass for mouse button state

### Step 3: Enhance Keyboard.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/input/Keyboard.hx`

Add/enhance these types:
- Complete W3C `KeyCode` enum (130+ keys)
- `KeyboardInput` class extending `Input<KeyCode>`
- `KeyboardInputHandler` for DOM event handling (JS target)
- Support for `Key` (logical) vs `KeyCode` (physical) distinction

### Step 4: Enhance Gamepad.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/input/Gamepad.hx`

Add/enhance these types:
- `GamepadButton` enum - All standard gamepad buttons
- `GamepadAxis` enum - LeftStick, RightStick, L2/R2 triggers
- `GamepadConnectionState` enum - Connected, Disconnected
- `Gamepad` class - Individual gamepad state
- `GamepadSettings` class - Deadzone, sensitivity settings
- `Axis<T>` generic class for axis values
- `GamepadInput` class for managing multiple gamepads

### Step 5: Enhance InputPlugin.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/input/InputPlugin.hx`

Transform into a proper Bevy plugin:
- Implement `Plugin` interface
- Register input resources to world
- Provide update method for clearing frame states
- Add conditions for common input checks

## 4. File Changes Summary

### New Files
None - all files already exist

### Modified Files
| File | Changes |
|------|---------|
| `src/haxe/input/Input.hx` | Complete rewrite with Input<T> class |
| `src/haxe/input/Mouse.hx` | Add MouseInput class, enhance existing types |
| `src/haxe/input/Keyboard.hx` | Add KeyboardInput class, enhance existing types |
| `src/haxe/input/Gamepad.hx` | Add Axis class, enhance gamepad support |
| `src/haxe/input/InputPlugin.hx` | Make proper plugin with resource registration |

### Delete Files
- `Input_new.hx` (merged into Input.hx)
- `Mouse_new.hx` (merged into Mouse.hx)
- `Keyboard_new.hx` (merged into Keyboard.hx)
- `Input_complete.hx` (obsolete)

## 5. Testing Strategy

### Unit Tests
1. **Input<T> Tests**
   - Test press/release cycle
   - Test justPressed/justReleased detection
   - Test clear() method
   - Test batch operations

2. **Mouse Tests**
   - Test mouse button input processing
   - Test scroll accumulation
   - Test position delta calculation

3. **Keyboard Tests**
   - Test key code mapping
   - Test input state changes

4. **Gamepad Tests**
   - Test axis values with deadzone
   - Test button press detection
   - Test connection/disconnection

### Integration Tests
- Test InputPlugin initialization
- Test resource registration to World
- Test frame-by-frame update cycle

## 6. Rollback Plan

To rollback changes:
1. Restore original files from git history:
   ```bash
   git checkout HEAD -- src/haxe/input/
   ```
2. Remove the `Input_new.hx`, `Mouse_new.hx`, `Keyboard_new.hx` merges if not wanted

## 7. Estimated Effort

- **Time:** 4-6 hours
- **Complexity:** Medium-High
- **Risk:** Low - Adding features, not breaking existing API

## 8. API Comparison (Rust vs Haxe)

### Rust ButtonInput<T>
```rust
pub struct ButtonInput<T> {
    pressed: HashSet<T>,
    just_pressed: HashSet<T>,
    just_released: HashSet<T>,
}
```

### Haxe Input<T>
```haxe
class Input<T> {
    private var _pressed:Map<T, Float>;
    private var _justPressed:Map<T, Float>;
    private var _justReleased:Map<T, Float>;
}
```

Key difference: Haxe version uses Map with Float strength values for analog input support.
