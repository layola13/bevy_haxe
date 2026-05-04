# Implementation Plan: bevy_transform Module Enhancement

## 1. Overview

This plan outlines the improvements to the bevy_transform module in the Haxe Bevy port. The goal is to bring the implementation closer to the Rust Bevy API while maintaining Haxe's idiomatic patterns.

**Goals:**
- Add `TransformTreeChanged` marker for transform hierarchy change detection optimization
- Add `ChildOf` component (Bevy's canonical parent-child relationship)
- Improve `TransformSystem` with better change detection
- Create `TransformPlugin` for automatic system registration
- Create `TransformHelper` for on-demand global transform computation
- Create `BuildChildrenTransformExt` commands extension

**Success Criteria:**
- Transform hierarchy propagation works correctly
- Change detection optimizes unnecessary updates
- API matches Rust Bevy's transform module structure

## 2. Prerequisites

- Haxe 4.x or later
- Existing bevy_ecs module with World, Entity, Component, Query support
- Existing bevy_math module with Vec3, Quat, Mat4 support

## 3. Implementation Steps

### Step 1: Update Transform.hx
- **Add**: `TransformTreeChanged` marker component for change detection optimization
- **Add**: `compute_transform()` method to convert back to Transform
- **Improve**: Documentation comments

### Step 2: Update Parent.hx
- **Add**: `ChildOf` component (the canonical parent relationship in Rust Bevy)
- **Keep**: `Parent` component for simpler use cases
- **Add**: `ChildOf` uses the parent's entity directly

### Step 3: Improve TransformSystem.hx
- **Add**: Change detection tracking
- **Add**: `TransformSystems` enum for system set configuration
- **Improve**: Use `ChildOf` for hierarchy detection
- **Add**: Static optimization support

### Step 4: Create TransformPlugin.hx
- **Create**: Plugin class for automatic system registration
- **Register**: TransformSystem in PostUpdate schedule

### Step 5: Create TransformHelper.hx
- **Create**: Helper class for on-demand global transform computation
- **Add**: `computeGlobalTransform(entity)` method

### Step 6: Create Commands.hx
- **Create**: `BuildChildrenTransformExt` extension for Commands
- **Add**: `pushChildren`, `popChildren`, `addChild` methods

## 4. File Changes Summary

### Modified Files:
1. `src/haxe/transform/Transform.hx` - Add TransformTreeChanged marker
2. `src/haxe/transform/Parent.hx` - Add ChildOf component
3. `src/haxe/transform/TransformSystem.hx` - Major improvements

### Created Files:
1. `src/haxe/transform/TransformPlugin.hx` - Plugin for automatic system registration
2. `src/haxe/transform/TransformHelper.hx` - On-demand transform computation
3. `src/haxe/transform/Commands.hx` - Hierarchy building commands extension

## 5. Testing Strategy

### Unit Tests:
1. Test Transform creation and manipulation
2. Test GlobalTransform computation
3. Test Parent/Child hierarchy creation
4. Test transform propagation through hierarchy
5. Test change detection optimization

### Integration Tests:
1. Create nested hierarchy and verify GlobalTransform computation
2. Test reparenting scenarios
3. Test orphan handling

## 6. Rollback Plan

- All changes are additive - no breaking changes to existing API
- Rollback by reverting file modifications
- No database or data migration needed

## 7. Estimated Effort

- **Time**: 2-3 hours
- **Complexity**: Medium
- **Risk**: Low (additive changes only)
