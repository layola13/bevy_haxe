# Bevy App Module Implementation Plan

## Overview

Complete and improve the `bevy_app` Haxe module by aligning it with the Rust Bevy `bevy_app` crate, supporting:
- Chainable App API
- Plugin interface with optional lifecycle methods
- PluginGroup for batch plugin management
- Main schedule labels (First, PreUpdate, Update, PostUpdate, Last)

## Files to Modify/Create

### 1. `src/haxe/app/App.hx` - Major Update
- Remove duplicate `Schedule` enum (defined twice)
- Keep existing chainable API
- Add `addPlugins()` for batch plugin addition
- Integrate with existing ECS Schedule classes

### 2. `src/haxe/app/Plugin.hx` - Major Update
- Change to abstract/interface hybrid
- Add default implementations using static extensions pattern
- Keep optional methods: `ready()`, `finish()`, `cleanup()`

### 3. `src/haxe/app/LifecyclePlugin.hx` - Keep as-is
- Already provides good base implementation
- Acts as default implementation for Plugin interface

### 4. `src/haxe/app/PluginGroup.hx` - Minor Cleanup
- Add convenience static factory methods
- Improve documentation

### 5. `src/haxe/app/MainSchedule.hx` - Fix Broken Imports
- Remove references to non-existent `haxe.ecs.schedule.*` classes
- Use local schedule labels that work standalone
- Add all required schedule labels from Rust version

### 6. `src/haxe/app/prelude/AppPrelude.hx` - Create
- Re-export all app module types
- Provide convenience imports

## Implementation Steps

### Step 1: Update MainSchedule.hx
Remove broken imports and create self-contained schedule system:

```haxe
// ScheduleLabel interface
interface ScheduleLabel {
    function getTypeId():Any;
    function name():String;
}

// Schedule labels: First, PreUpdate, Update, PostUpdate, Last
// Also: PreStartup, Startup, PostStartup for startup phases
```

### Step 2: Update App.hx
- Remove duplicate Schedule enum
- Add `addPlugins()` method for batch operations
- Add `configureSchedule()` method

### Step 3: Update Plugin.hx
- Convert to use abstract with static inline implementations
- Or use typedef for optional methods pattern

### Step 4: Create AppPrelude.hx
Export all relevant types from the app module

## File Changes Summary

| File | Action |
|------|--------|
| `src/haxe/app/App.hx` | Modify |
| `src/haxe/app/Plugin.hx` | Modify |
| `src/haxe/app/LifecyclePlugin.hx` | Keep |
| `src/haxe/app/PluginGroup.hx` | Modify (minor) |
| `src/haxe/app/MainSchedule.hx` | Modify (fix imports) |
| `src/haxe/app/prelude/AppPrelude.hx` | Create |

## Testing Strategy

1. Compile check with `haxe -cs src`
2. Verify chainable API: `app.addPlugin(p).addSystem(s).run()`
3. Test PluginGroup batch adding
4. Verify all schedule labels work

## Rollback Plan

Keep git commits clean:
```bash
git add -A && git commit -m "bevy_app module improvement"
```

To rollback:
```bash
git reset --hard HEAD~1
```

## Estimated Effort

- **Time**: 30-45 minutes
- **Complexity**: Medium
- **Risk**: Low (isolated module changes)
