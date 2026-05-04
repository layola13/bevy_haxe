# Implementation Plan: bevy_transform Module Enhancement

## 1. Overview

This plan improves the bevy_transform Haxe module to better align with the Rust Bevy transform system. The goal is to provide a complete, efficient transform hierarchy implementation with proper parent-child relationships and global transform propagation.

**Files to be modified:**
- `src/haxe/transform/Transform.hx` - Enhanced with more transform operations
- `src/haxe/transform/GlobalTransform.hx` - Enhanced with better decomposition and hierarchy methods
- `src/haxe/transform/Parent.hx` - Improved with better API consistency
- `src/haxe/transform/Children.hx` - Enhanced with utility methods
- `src/haxe/transform/TransformSystem.hx` - Complete rewrite for proper hierarchy propagation

## 2. Prerequisites

- Haxe 4.x or later
- Math module with Vec3, Quat, Mat4, Vec4 types (already exists)
- ECS module with World, Entity, Component types (already exists)

## 3. Implementation Steps

### Step 1: Enhance Transform.hx

**File:** `src/haxe/transform/Transform.hx`

**Changes:**
- Add `lookingAt(target:Vec3, up:Vec3)` method for camera-style look-at transforms
- Add transform multiplication: `Transform * Transform` returns Transform
- Add point transformation: `transform.transformPoint(Vec3)` returns Vec3
- Add `TransformTreeChanged` marker component support
- Improve Euler angle handling (XYZ, YXZ, ZXY formats)
- Add interpolation methods: `lerp`, `slerp`

### Step 2: Enhance GlobalTransform.hx

**File:** `src/haxe/transform/GlobalTransform.hx`

**Changes:**
- Add `reparentedTo(parentGlobal:GlobalTransform)` method
- Add `computeTransform():Transform` to extract local transform
- Add `transformDirection(dir:Vec3):Vec3` method
- Add `to_scale_rotation_translation()` tuple
- Improve matrix decomposition

### Step 3: Enhance Parent.hx

**File:** `src/haxe/transform/Parent.hx`

**Changes:**
- Add `hasParent():Bool` check
- Add static factory method from Entity
- Add toString() method

### Step 4: Enhance Children.hx

**File:** `src/haxe/transform/Children.hx`

**Changes:**
- Add `push(child:Int)` alias for `add()`
- Add `contains(childId:Int):Bool` as alias for `hasChild()`
- Add batch operations: `addAll(children:Array<Int>)`

### Step 5: Rewrite TransformSystem.hx

**File:** `src/haxe/transform/TransformSystem.hx`

**Changes:**
Complete rewrite for proper transform hierarchy propagation:
- `TransformTreeChanged` marker component for dirty detection
- Proper parent-child transform propagation
- Change detection support

## 4. File Changes Summary

| File | Action | Description |
|------|--------|-------------|
| Transform.hx | Modify | Add lookingAt, mul operators, point transform |
| GlobalTransform.hx | Modify | Add reparentedTo, computeTransform, transform ops |
| Parent.hx | Modify | Add hasParent, improve API |
| Children.hx | Modify | Add batch operations, helper methods |
| TransformSystem.hx | Rewrite | Complete rewrite with proper hierarchy propagation |

## 5. Testing Strategy

### Unit Tests
- Transform tests: identity, translation, rotation, scale, lookingAt, mul_transform, transformPoint
- GlobalTransform tests: identity, fromTransform, reparentedTo, computeTransform, transformDirection
- Hierarchy tests: parentChildPropagation, deepHierarchy, orphanDetection

## 6. Rollback Plan

To rollback changes:
1. Revert individual files to previous versions
2. Keep backup copies before modification

## 7. Estimated Effort

- **Time:** 2-3 hours
- **Complexity:** Medium
- **Risk:** Low (additive improvements, existing tests should still pass)
