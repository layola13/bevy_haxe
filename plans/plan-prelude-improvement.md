# Plan: Improve Bevy Haxe Prelude Modules

## 1. Overview

**Goal:** Improve the prelude module system to provide convenient access to all commonly used Bevy Haxe types with zero-cost abstractions using `inline` functions.

**Success Criteria:**
- All prelude modules properly re-export types from their respective modules
- Inline functions provide convenient factory methods with zero runtime overhead
- Main entry point uses prelude for clean, readable code
- project.hxml correctly configured for the prelude system

## 2. Files to Modify/Create

### Created/Modified Files:
1. `src/haxe/prelude/Prelude.hx` - Main prelude with all core types
2. `src/haxe/prelude/MathPrelude.hx` - Math module prelude
3. `src/haxe/prelude/EcsPrelude.hx` - ECS module prelude
4. `src/haxe/prelude/AppPrelude.hx` - App module prelude
5. `project.hxml` - Updated configuration
6. `src/Main.hx` - Updated main entry using preludes

## 3. Implementation Details

### Prelude.hx Structure:
- Re-export Vec2, Vec3, Vec4, Mat4, Quat from haxe.math
- Re-export Color types from haxe.color
- Re-export Entity, Component, World from haxe.ecs
- Re-export App, Plugin, Schedule from haxe.app
- Static inline factory functions for common types
- Static constants for common values

### MathPrelude.hx Structure:
- Vector creation: vec2, vec3, vec4
- Matrix creation: mat4, identity, translation, scaling, rotation
- Quaternion creation: quat, quatIdentity
- Transform helpers: lookAt, perspective, orthographic

### EcsPrelude.hx Structure:
- Entity creation helpers
- Component type helpers
- World query helpers
- Command helpers
- Schedule enums

### AppPrelude.hx Structure:
- App builder pattern helpers
- Plugin registration helpers
- Schedule enums
- System creation helpers

## 4. Testing Strategy

- Compile with `haxe project.hxml`
- Verify all re-exported types are accessible
- Verify inline functions compile correctly

## 5. Effort Estimate

**Time:** ~30 minutes
**Complexity:** Medium
