# Bevy App Module Implementation Plan

## Overview

This plan documents the implementation of the `bevy_app` module in Haxe, converting Rust code from `/home/vscode/projects/bevy/crates/bevy_app/src/` to equivalent Haxe code.

### Goals
- Implement core App functionality with chainable API
- Convert Plugin trait to Haxe interface
- Implement PluginGroup for grouped plugin management
- Create MainSchedule with all standard schedule labels
- Implement @:macro for add_plugins and add_systems

### Success Criteria
- All files compile without errors
- Chainable API pattern consistently implemented
- Plugin lifecycle methods properly defined
- Macro expansion works for multiple plugins/systems

## Files Created/Modified

### 1. `src/haxe/app/Plugin.hx` (Modified)
**Purpose**: Plugin interface definition

**Key Components**:
- `interface Plugin` - Core plugin trait with:
  - `name` - Unique plugin name (getter only)
  - `isUnique` - Whether plugin can be added multiple times
  - `build(app:App):Void` - Configuration callback
  - `ready(app:App):Bool` - Ready check
  - `finish(app:App):Void` - Post-build callback
  - `cleanup(app:App):Void` - Cleanup callback
- `class BasePlugin` - Default implementation base class

### 2. `src/haxe/app/PluginGroup.hx` (Modified)
**Purpose**: Plugin group management

**Key Components**:
- `class PluginGroupBuilder` - Fluent builder for plugin groups
  - `add(plugin)` - Add single plugin
  - `addWithSettings(plugin, settings)` - Add with config
  - `addGroup(group)` - Add nested group
  - `setOrder(order)` - Set execution order
  - `build()` - Build result
- `class BuiltPluginGroup` - Immutable built group
- `interface PluginGroup` - Group trait with `build()` method

### 3. `src/haxe/app/MainSchedule.hx` (Created)
**Purpose**: Schedule labels for main application lifecycle

**Schedule Labels**:
- `Main` - Main schedule container
- `PreStartup` / `Startup` / `PostStartup` - One-time startup
- `First` / `Last` - Frame boundaries
- `PreUpdate` / `Update` / `PostUpdate` - Main loop
- `FixedPreUpdate` / `FixedUpdate` / `FixedPostUpdate` - Fixed timestep
- `FixedFirst` / `FixedLast` - Fixed loop boundaries
- `RunFixedMainLoop` - Fixed loop orchestrator
- `StateTransition` - State changes
- `SpawnScene` - Scene spawning
- `PreRender` / `Render` / `PostRender` - Rendering

**Supporting Classes**:
- `class MainScheduleOrder` - Manages schedule execution order

### 4. `src/haxe/app/App.hx` (Modified)
**Purpose**: Main application structure with chainable API

**Key Features**:
- Chainable API returning `this`
- `addPlugin(plugin)` - Add single plugin
- `addPluginGroup(group)` - Add plugin group
- `addSystem(schedule, fn)` - Add system to schedule
- `addSystemWithApp(schedule, fn)` - System with App context
- `setSchedule(schedule)` - Set default schedule
- `run()` - Execute app
- `update()` - Single update tick

**Internal State**:
- `plugins` - Registered plugins map
- `systems` - Systems by schedule
- `pluginOrder` - Registration order
- `currentSchedule` - Default schedule

### 5. `src/haxe/app/LifecyclePlugin.hx` (Modified)
**Purpose**: Base plugin with lifecycle hooks

**Key Components**:
- `class LifecyclePlugin extends BasePlugin` - Convenient base
- `class PlaceholderPlugin` - Optional plugin placeholder

### 6. `src/haxe/macro/AppMacro.hx` (Created)
**Purpose**: Compile-time code generation

**Macro Functions**:
- `addPlugins(app, plugins)` - Transform multiple plugins to chained calls
- `addSystems(app, schedule, systems)` - Transform to chained addSystem
- `addSystemsWithConfig()` - With ordering/conditions
- `build()` - @:app metadata handler

## Implementation Details

### Chainable API Pattern
```haxe
app.addPlugin(plugin1)
   .addPlugin(plugin2)
   .addSystem(Update, system1)
   .addSystem(PreUpdate, system2)
   .run();
```

### Macro Expansion Example
```haxe
// Source code
app.addPlugins(PluginA, PluginB, PluginC);

// Expanded to:
app.addPlugin(new PluginA())
   .addPlugin(new PluginB())
   .addPlugin(new PluginC());
```

### Plugin Lifecycle
1. `addPlugin()` calls `build()` immediately
2. `run()` waits for all `ready()` to return true
3. `finish()` called for all plugins
4. Main loop executes schedules
5. `cleanup()` called for all plugins

## Testing Strategy

### Unit Tests
1. Test plugin registration and duplication detection
2. Test chainable API return values
3. Test schedule label creation
4. Test plugin group building

### Integration Tests
1. Test complete app lifecycle
2. Test multiple plugins interaction
3. Test system execution order

## Dependencies

### Internal
- `haxe.ecs.Schedule` - Schedule management
- `haxe.ecs.ScheduleLabel` - Schedule labeling
- `haxe.ecs.system.System` - System interface
- `haxe.ecs.world.World` - ECS world
- `haxe.macro.*` - Macro utilities

### External (Haxe std)
- `haxe.ds.Map` - Plugin/system storage
- `haxe.macro.Expr` - Macro expressions
- `haxe.macro.Context` - Compiler context

## Rollback Plan

To revert changes:
1. Restore original `Plugin.hx`, `PluginGroup.hx`, `App.hx` from git
2. Delete `MainSchedule.hx` and `AppMacro.hx`
3. Restore original `LifecyclePlugin.hx`

## Complexity Assessment

**Medium-High**
- Multiple interdependent files
- Macro expansion logic
- Schedule management integration
- Consistent API design across modules

## Effort Estimate

**4-6 hours**
- File structure: 1 hour
- Core interfaces: 2 hours
- App implementation: 2 hours
- Macro implementation: 1-2 hours
- Testing and refinement: 1-2 hours
