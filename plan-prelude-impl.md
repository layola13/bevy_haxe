# Bevy Haxe - Unified Prelude Implementation Plan

## 1. Overview

Create unified prelude modules for the Bevy Haxe game engine to provide convenient access to all core types with a consistent API.

**Goals:**
- Create `Prelude.hx` - main prelude exporting all core types (math, color, utils)
- Create `MathPrelude.hx` - specialized prelude for math types with factory functions
- Create `EcsPrelude.hx` - ECS module prelude with entity/component helpers
- Create `AppPrelude.hx` - App module prelude with configuration types
- Update `Main.hx` - entry point with App base class
- Create `HelloWorld.hx` - example demonstrating prelude usage

## 2. Prerequisites

- Haxe SDK installed
- Existing math types: `Vec2`, `Vec3`, `Vec4`, `Mat4`, `Quat`
- Existing or placeholder color/utils modules

## 3. Implementation Steps

### Step 1: Create MathPrelude.hx
- **File:** `/home/vscode/projects/bevy_haxe/src/haxe/prelude/MathPrelude.hx`
- Factory functions for vectors, matrices, quaternions
- Transform helper functions (translation, rotation, scaling, perspective)

### Step 2: Create EcsPrelude.hx
- **File:** `/home/vscode/projects/bevy_haxe/src/haxe/prelude/EcsPrelude.hx`
- Entity and Component type definitions
- System function signature typedefs
- Query filter typedef

### Step 3: Create AppPrelude.hx
- **File:** `/home/vscode/projects/bevy_haxe/src/haxe/prelude/AppPrelude.hx`
- AppConfig typedef
- StartupStage and MainLoopStage enums

### Step 4: Create Prelude.hx
- **File:** `/home/vscode/projects/bevy_haxe/src/haxe/prelude/Prelude.hx`
- Imports all core modules
- Main Prelude class with convenience factory methods

### Step 5: Update Main.hx
- **File:** `/home/vscode/projects/bevy_haxe/src/Main.hx`
- Add App base class with setup/update/render lifecycle
- Add quickStart helper function

### Step 6: Create HelloWorld example
- **File:** `/home/vscode/projects/bevy_haxe/examples/HelloWorld.hx`
- Demonstrates prelude imports
- Shows vector/math operations
- Demonstrates entity creation

## 4. File Changes Summary

| File | Action |
|------|--------|
| `src/haxe/prelude/Prelude.hx` | Created |
| `src/haxe/prelude/MathPrelude.hx` | Created |
| `src/haxe/prelude/EcsPrelude.hx` | Created |
| `src/haxe/prelude/AppPrelude.hx` | Created |
| `src/Main.hx` | Created |
| `examples/HelloWorld.hx` | Created |

## 5. Testing Strategy

1. **Compilation Test:** Run `haxe --cwd /home/vscode/projects/bevy_haxe -main Main --js bin/main.js` to verify compilation
2. **Import Test:** Check all imports resolve correctly
3. **Example Test:** Compile and run HelloWorld example

## 6. Rollback Plan

Simply delete the created files:
```bash
rm src/haxe/prelude/Prelude.hx
rm src/haxe/prelude/MathPrelude.hx
rm src/haxe/prelude/EcsPrelude.hx
rm src/haxe/prelude/AppPrelude.hx
rm src/Main.hx
rm examples/HelloWorld.hx
```

## 7. Estimated Effort

- **Time:** ~15 minutes
- **Complexity:** Low
- **Risk:** Minimal - no existing files modified
