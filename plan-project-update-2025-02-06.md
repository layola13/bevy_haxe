# Bevy Haxe - Implementation Plan
# Updated: 2025-02-06

## Overview

This plan covers updating project configuration, documentation, and cleaning up temporary files for the Bevy Haxe game engine project.

## Goals

1. Fix `project.hxml` compilation configuration
2. Create comprehensive `README.md` documentation
3. Create `todo.md` development roadmap
4. Clean up temporary files (`*Updated.hx`, `*_new.hx`)
5. Ensure proper project organization

## Scope

### Included
- Fixed `project.hxml` with correct Haxe syntax
- Complete `README.md` with project info, usage, examples
- `todo.md` with development priorities
- Deletion of temporary staging files

### Excluded
- Major code refactoring (out of scope)
- New feature implementation

---

## Step 1: Update project.hxml

**Files to modify:** `/home/vscode/projects/bevy_haxe/project.hxml`

Current issues:
- Uses `:` syntax instead of `-` for Haxe flags
- References non-existent `haxe.macro.Modules` entry point
- Missing proper module definition

**New content:**
```hxml
# Bevy Haxe - Game Engine in Haxe
# Haxe compilation configuration

-main Main
-dce full
-js bin/main.js
-src src

# Debug options
-debug

# Conditional compilation
-define debug
```

---

## Step 2: Create README.md

**File to create:** `/home/vscode/projects/bevy_haxe/README.md`

Content sections:
- Project title and description
- Features list
- Installation instructions
- Quick start guide
- Example usage
- Project structure
- Contributing

---

## Step 3: Create todo.md

**File to create:** `/home/vscode/projects/bevy_haxe/todo.md`

Content:
- High priority: ECS module completion
- Medium priority: Rendering system
- Low priority: Asset system enhancement
- Future: Platform-specific backends

---

## Step 4: Clean up temporary files

**Files to delete:**
1. `/home/vscode/projects/bevy_haxe/src/MainUpdated.hx`
2. `/home/vscode/projects/bevy_haxe/src/haxe/prelude/PreludeUpdated.hx`
3. `/home/vscode/projects/bevy_haxe/src/haxe/ecs/Entity_new.hx`
4. `/home/vscode/projects/bevy_haxe/examples/HelloWorldUpdated.hx`
5. `/home/vscode/projects/bevy_haxe/examples/QueryExampleUpdated.hx`

---

## Step 5: Update Main.hx

**File to modify:** `/home/vscode/projects/bevy_haxe/src/Main.hx`

Merge useful code from `MainUpdated.hx` if needed.

---

## File Changes Summary

### Modified:
- `project.hxml` - Fixed Haxe syntax and entry point
- `src/Main.hx` - Keep as simple entry point

### Created:
- `README.md` - Project documentation
- `todo.md` - Development roadmap

### Deleted:
- `src/MainUpdated.hx`
- `src/haxe/prelude/PreludeUpdated.hx`
- `src/haxe/ecs/Entity_new.hx`
- `examples/HelloWorldUpdated.hx`
- `examples/QueryExampleUpdated.hx`

---

## Testing Strategy

1. Run `haxe project.hxml` to verify compilation
2. Check that `bin/main.js` is generated
3. Verify no compilation errors

## Rollback Plan

1. Revert `project.hxml` to previous version
2. Restore deleted files from git (if available)
3. Remove created documentation files

---

## Estimated Effort

- **Time:** 15-20 minutes
- **Complexity:** Low
- **Risk:** Low (mostly cleanup and documentation)
