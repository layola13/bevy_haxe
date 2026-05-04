# Bevy App Module Enhancement Plan

## Overview

This plan enhances the `bevy_app` module in the Haxe bevy implementation to fully support plugin-based application architecture, matching the Rust bevy_app crate functionality.

### Goals
- Enable chainable API for App class
- Support plugins with optional lifecycle methods
- Implement plugin groups for batch plugin registration
- Define all main schedule labels (First, PreUpdate, Update, PostUpdate, Last, Startup stages)

### Scope
**Included:**
- App class with full chainable API
- Plugin interface with optional methods via base class
- LifecyclePlugin base implementation
- PluginGroup and PluginGroupBuilder for batch operations
- MainSchedule labels and ordering
- App prelude exports

**Excluded:**
- SubApp (multi-window support - future feature)
- Hotpatching support
- TaskPoolPlugin detailed implementation (std-dependent)

---

## Prerequisites

### Dependencies
- `haxe.ecs` module must be available
- `haxe.ds.Map` for internal storage

### No Migrations Required
This module doesn't require database or data migrations.

---

## Implementation Steps

### Step 1: Update Plugin.hx - Add BasePlugin with Optional Methods

**File:** `/home/vscode/projects/bevy_haxe/src/haxe/app/Plugin.hx`

**Changes:**
- Add `BasePlugin` class with default implementations for all lifecycle methods
- Keep `Plugin` as interface for type safety
- Add `SimplePlugin` typedef for function-based plugins

```haxe
// New structure:
// - BasePlugin: abstract class with all optional methods
// - Plugin: interface (implemented by BasePlugin)
// - SimplePlugin: typedef for (App->Void) function-based plugins
```

**Why:** Haxe interfaces cannot have default implementations. We use a base class pattern to achieve optional methods.

---

### Step 2: Update LifecyclePlugin.hx - Extend BasePlugin

**File:** `/home/vscode/projects/bevy_haxe/src/haxe/app/LifecyclePlugin.hx`

**Changes:**
- Extend `BasePlugin` instead of implementing `Plugin` directly
- Keep all existing functionality

---

### Step 3: Update App.hx - Enhance Chainable API

**File:** `/home/vscode/projects/bevy_haxe/src/haxe/app/App.hx`

**Changes:**
1. Remove duplicate Schedule enum - use proper schedule definitions
2. Add `addSystems()` method for adding multiple systems at once
3. Add `addPluginGroup()` method
4. Add `configureSchedule()` method for schedule ordering
5. Add `addDefaultPlugins()` method
6. Improve doc comments

**New Methods:**
- `addSystems(systems:Array<System>, ?schedule:ScheduleLabel):App`
- `addPluginGroup<T:PluginGroup>(group:T):App`
- `configureSchedule(label:ScheduleLabel, configure:Schedule -> Void):App`

---

### Step 4: Create MainSchedule.hx - Proper Schedule Labels

**File:** `/home/vscode/projects/bevy_haxe/src/haxe/app/MainSchedule.hx`

**Changes:**
1. Create self-contained schedule label classes
2. Define all schedule labels:
   - **Startup:** PreStartup, Startup, PostStartup
   - **Main:** First, PreUpdate, Update, PostUpdate, Last
   - **Fixed:** FixedFirst, FixedPreUpdate, FixedUpdate, FixedPostUpdate, FixedLast
3. Create `MainScheduleOrder` class for schedule ordering
4. Remove broken imports

**Schedule Labels:**
```haxe
// Interface for all schedule labels
interface ScheduleLabel {
    function getTypeId():Any;
    function name():String;
}

// Concrete labels as singleton classes
class First implements ScheduleLabel { ... }
class PreUpdate implements ScheduleLabel { ... }
class Update implements ScheduleLabel { ... }
class PostUpdate implements ScheduleLabel { ... }
class Last implements ScheduleLabel { ... }
// Plus Startup variants
```

---

### Step 5: Update PluginGroup.hx - Improve Builder Pattern

**File:** `/home/vscode/projects/bevy_haxe/src/haxe/app/PluginGroup.hx`

**Changes:**
1. Add generic type support to `PluginGroupBuilder`
2. Add `addWithConfig()` method for per-plugin configuration
3. Improve `BuiltPluginGroup` internal storage
4. Add `finish()` and `cleanup()` methods support

---

### Step 6: Create AppPrelude.hx - Module Exports

**File:** `/home/vscode/projects/bevy_haxe/src/haxe/app/prelude/AppPrelude.hx`

**Content:**
```haxe
package haxe.app.prelude;

// Core types
import haxe.app.App;
import haxe.app.Plugin;
import haxe.app.BasePlugin;
import haxe.app.LifecyclePlugin;
import haxe.app.PluginGroup;
import haxe.app.PluginGroupBuilder;

// Schedule labels
import haxe.app.MainSchedule.*;

// Common types
typedef SimplePlugin = haxe.app.SimplePlugin;
```

---

### Step 7: Update Existing Examples

**File:** `/home/vscode/projects/bevy_haxe/examples/`

Update any examples that use the old API to demonstrate:
- Plugin-based architecture
- Chainable API
- Plugin groups

---

## File Changes Summary

### Created Files
1. `/home/vscode/projects/bevy_haxe/src/haxe/app/prelude/AppPrelude.hx` - Module prelude

### Modified Files
1. `/home/vscode/projects/bevy_haxe/src/haxe/app/Plugin.hx` - Add BasePlugin
2. `/home/vscode/projects/bevy_haxe/src/haxe/app/LifecyclePlugin.hx` - Extend BasePlugin
3. `/home/vscode/projects/bevy_haxe/src/haxe/app/App.hx` - Enhance API
4. `/home/vscode/projects/bevy_haxe/src/haxe/app/MainSchedule.hx` - Fix schedule labels
5. `/home/vscode/projects/bevy_haxe/src/haxe/app/PluginGroup.hx` - Improve builder

### No Deleted Files

---

## Testing Strategy

### Unit Tests
1. **Plugin Tests:**
   - Test plugin lifecycle (build, ready, finish, cleanup)
   - Test duplicate plugin detection
   - Test unique plugin flag

2. **App Tests:**
   - Test chainable API returns `this`
   - Test plugin registration
   - Test system registration by schedule

3. **PluginGroup Tests:**
   - Test builder fluent API
   - Test batch plugin addition
   - Test plugin order preservation

### Manual Testing
1. Create test app with plugins
2. Verify lifecycle order
3. Test plugin groups

---

## Rollback Plan

### Reverting Changes
1. All files are in version control, can restore previous versions
2. No database migrations to rollback
3. No configuration changes required

### If Issues Arise
- Check Haxe version compatibility (should be 4.x+)
- Verify all imports are correct
- Ensure type constraints match

---

## Estimated Effort

- **Time:** 3-4 hours
- **Complexity:** Medium
- **Risk:** Low - No breaking changes to existing working code

### Breakdown
- Step 1-2 (Plugin): 45 min
- Step 3 (App): 60 min
- Step 4 (MainSchedule): 45 min
- Step 5 (PluginGroup): 30 min
- Step 6 (Prelude): 15 min
- Step 7 (Examples): 30 min
- Testing: 30 min
