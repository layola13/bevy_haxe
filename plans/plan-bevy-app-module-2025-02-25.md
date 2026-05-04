# Implementation Plan: Bevy App Module Enhancement

## 1. Overview

This plan improves the `bevy_app` module in `/home/vscode/projects/bevy_haxe` to better match the Rust Bevy `bevy_app` crate functionality. The goal is to create a complete, functional plugin-based application framework with chainable API, plugin groups, and proper schedule labels.

**Goals:**
- App with chainable API for adding plugins and systems
- Plugin interface with optional lifecycle methods (using abstract pattern)
- PluginGroup for batch plugin registration
- MainSchedule with all standard schedule labels (First, PreUpdate, Update, PostUpdate, Last, etc.)
- Proper prelude exports

**Scope:**
- Update: App.hx, Plugin.hx, LifecyclePlugin.hx, PluginGroup.hx, MainSchedule.hx
- Create: AppPrelude.hx in prelude directory

## 2. Prerequisites

- Haxe 4.x or later
- Understanding of existing ECS types (World, Entity, Component)
- Understanding of schedule system (already exists in ECS)

## 3. Implementation Steps

### Step 1: Update Plugin.hx - Add BasePlugin for optional method support

**Files to modify:** `/home/vscode/projects/bevy_haxe/src/haxe/app/Plugin.hx`

Since Haxe interfaces don't support default implementations, create a `BasePlugin` class that provides empty default implementations, and have `LifecyclePlugin` extend it. The `Plugin` interface will still be the contract.

**Key changes:**
- Add `BasePlugin` class with empty implementations of optional methods
- Update `Plugin` interface documentation
- Add helper method signatures

### Step 2: Update LifecyclePlugin.hx - Extend BasePlugin

**Files to modify:** `/home/vscode/projects/bevy_haxe/src/haxe/app/LifecyclePlugin.hx`

- Remove duplicate field definitions
- Ensure compatibility with new plugin pattern
- Add default plugin categories

### Step 3: Update App.hx - Improve chainable API and integration

**Files to modify:** `/home/vscode/projects/bevy_haxe/src/haxe/app/App.hx`

**Key improvements:**
- Remove duplicate Schedule enum (will use MainSchedule labels)
- Add World field for ECS integration
- Add methods for startup schedules
- Better plugin lifecycle management
- Add system configuration methods
- Improve documentation

### Step 4: Update MainSchedule.hx - Fix imports and add labels

**Files to modify:** `/home/vscode/projects/bevy_haxe/src/haxe/app/MainSchedule.hx`

**Key changes:**
- Remove broken imports from non-existent ECS files
- Create simple self-contained ScheduleLabel interface
- Add all standard schedule labels (First, PreUpdate, Update, PostUpdate, Last, Startup, etc.)
- Add MainScheduleOrder class for schedule ordering
- Add schedule runner plugin

### Step 5: Update PluginGroup.hx - Improve and clean up

**Files to modify:** `/home/vscode/projects/bevy_haxe/src/haxe/app/PluginGroup.hx`

**Key improvements:**
- Remove unused imports
- Ensure Builder returns `this` for chainability
- Add helper methods for plugin settings

### Step 6: Create AppPrelude.hx - Prelude exports

**Files to create:** `/home/vscode/projects/bevy_haxe/src/haxe/app/prelude/AppPrelude.hx`

- Re-export all main app types
- Provide convenience typedefs

## 4. File Changes Summary

### Modified Files:
| File | Change Type |
|------|-------------|
| `src/haxe/app/Plugin.hx` | Modified - Add BasePlugin, update interface |
| `src/haxe/app/LifecyclePlugin.hx` | Modified - Extend BasePlugin |
| `src/haxe/app/App.hx` | Modified - Improve chainable API, remove duplicate Schedule |
| `src/haxe/app/MainSchedule.hx` | Modified - Self-contained schedule labels |
| `src/haxe/app/PluginGroup.hx` | Modified - Clean up, improve builder |

### Created Files:
| File | Change Type |
|------|-------------|
| `src/haxe/app/prelude/AppPrelude.hx` | Created - Prelude exports |

## 5. Testing Strategy

### Manual Testing:
1. Create example using all new features:
   ```haxe
   class TestApp extends App {
       public function new() {
           super();
           addPlugin(new MyPlugin());
           addPluginGroup(new DefaultPlugins());
           addSystem(Update, mySystem);
           run();
       }
   }
   ```

2. Test chainable API:
   ```haxe
   App.new()
       .addPlugin(new TaskPoolPlugin())
       .addSystem(Update, system1)
       .addSystem(PostUpdate, system2)
       .run();
   ```

3. Test plugin group:
   ```haxe
   App.new()
       .addPluginGroup(DefaultPlugins.new()
           .disableRendering())
       .run();
   ```

### Compilation Test:
- Ensure all files compile without errors
- Check import paths are correct

## 6. Rollback Plan

If issues arise:
1. Restore original files from version control
2. Revert to previous working state

## 7. Estimated Effort

- **Time:** ~2-3 hours
- **Complexity:** Medium
- **Risk:** Low - changes are additive and backward compatible
