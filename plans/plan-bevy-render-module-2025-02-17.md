# Bevy Render Module Improvement Plan

## 1. Overview

This plan improves the bevy_render Haxe module for WebGL-based rendering. The module provides camera, mesh, projection, and render context functionality suitable for browser-based game development.

**Goals:**
- Enhance Camera.hx with view frustum culling and projection matrix caching
- Add Projection.hx with camera exposure and frustum support
- Enhance Mesh.hx with GPU buffer representation and morph targets
- Add RenderContext.hx with WebGL state management and command encoding
- Improve RenderModule.hx with better documentation and module structure

**Scope:**
- Focus on WebGL 2.0 compatible features
- Simplify WGSL shaders to GLSL equivalents
- Maintain ECS-compatible architecture

---

## 2. Prerequisites

**Dependencies:**
- haxe.math.Mat4, Vec2, Vec3, Vec4, Quat
- haxe.ecs.Component, Resource, World, Entity
- haxe.transform.Transform, GlobalTransform
- haxe.color.Color types
- haxe.window.Window

**Files to modify:**
- `/home/vscode/projects/bevy_haxe/src/haxe/render/Camera.hx`
- `/home/vscode/projects/bevy_haxe/src/haxe/render/Projection.hx`
- `/home/vscode/projects/bevy_haxe/src/haxe/render/Mesh.hx`
- `/home/vscode/projects/bevy_haxe/src/haxe/render/RenderContext.hx`
- `/home/vscode/projects/bevy_haxe/src/haxe/render/RenderModule.hx`

---

## 3. Implementation Steps

### Step 1: Enhance Camera.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/render/Camera.hx`

**Changes:**
1. Add `cameraType` enum (Perspective, Orthographic, Projection2d, Projection3d)
2. Add `outputMode` enum for render target handling
3. Add `exposure` property for HDR rendering
4. Add `frustum` field using Bevy's frustum representation
5. Add cached view/projection matrices with dirty flag
6. Add `buildProjectionMatrix()` with automatic caching
7. Add `getViewMatrix()` method
8. Add viewport scaling support
9. Add clear color configuration

### Step 2: Add Projection.hx Enhancements
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/render/Projection.hx`

**Changes:**
1. Add `cameraType` property to Projection enum
2. Add `frustumCorners()` method to get view frustum corners
3. Add `compute_frustum()` method to build frustum for culling
4. Add `updateAspect()` method for dynamic aspect ratio changes
5. Add `recomputeProjection()` method
6. Enhance PerspectiveProjection with exposure support
7. Add depth computation helpers

### Step 3: Enhance Mesh.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/render/Mesh.hx`

**Changes:**
1. Add `GpuMesh` representation for GPU-ready data
2. Add `MeshId` type alias
3. Add `MorphTarget` GPU buffer support
4. Add `computeTangents()` method
5. Add `generate_normals()` method for procedural meshes
6. Add `transformPositions()` method
7. Add ` VertexAttribute` methods for GPU layout
8. Add `MorphTargetAttributes` for animation
9. Add `Indices` enum for Uint16/Uint32

### Step 4: Add RenderContext.hx Enhancements
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/render/RenderContext.hx`

**Changes:**
1. Add `RenderInstance` for per-draw-call data
2. Add `RenderQueue` for command buffering
3. Add `TrackedRenderPass` for state tracking
4. Add WebGL state cache with dirty tracking
5. Add `beginPass()` / `endPass()` methods
6. Add `drawMesh()` with instance support
7. Add `setViewProjection()` combined matrix setter
8. Add `pushDebugGroup()` / `popDebugGroup()` for debugging

### Step 5: Improve RenderModule.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/render/RenderModule.hx`

**Changes:**
1. Add module constants (MAX_CAMERAS, MAX_LIGHTS, etc.)
2. Add RenderSystem schedule constants
3. Add helper functions for quick setup
4. Add example documentation

---

## 4. File Changes Summary

| File | Action | Description |
|------|--------|-------------|
| Camera.hx | Modify | Enhanced camera component with frustum, exposure, caching |
| Projection.hx | Modify | Added frustum computation, exposure, aspect update |
| Mesh.hx | Modify | Added GPU buffers, tangents, morph targets |
| RenderContext.hx | Modify | Added state tracking, command encoding |
| RenderModule.hx | Modify | Added constants, helpers, documentation |

---

## 5. Testing Strategy

**Unit Tests:**
1. Test perspective projection matrix computation
2. Test orthographic projection matrix computation
3. Test camera view matrix from transform
4. Test frustum corner extraction
5. Test mesh AABB computation
6. Test mesh tangents generation

**Integration Tests:**
1. Test camera setup with different projection types
2. Test render context state management
3. Test mesh drawing with transforms

**Manual Testing:**
1. Create demo scene with multiple cameras
2. Verify depth rendering order
3. Test orthographic vs perspective switch

---

## 6. Rollback Plan

**Revert Steps:**
1. Restore original file contents from git history
2. Run existing tests to verify no breakage

**Data Migration:**
- No persistent data changes
- Only runtime component modifications

---

## 7. Estimated Effort

**Time:** ~4-6 hours
**Complexity:** Medium

**Breakdown:**
- Camera.hx: 1.5 hours
- Projection.hx: 1 hour  
- Mesh.hx: 1.5 hours
- RenderContext.hx: 1.5 hours
- RenderModule.hx: 0.5 hours
- Testing: 1 hour

---

## 8. Implementation Notes

### WebGL Compatibility
- Use WebGL 2.0 feature set where available
- Provide fallback for WebGL 1.0
- GLSL version 300 es for shaders

### Performance Considerations
- Cache projection matrices until dirty
- Use typed arrays for vertex data
- Minimize object allocation in hot paths

### API Design
- Follow Bevy naming conventions
- Use method chaining where appropriate
- Provide builder pattern for complex setup
