# Bevy Render Module Improvement Plan

## 1. Overview

This plan improves the `bevy_render` module for Haxe, implementing WebGL-friendly rendering abstractions based on the Rust `bevy_render` crate.

**Goals:**
- Add viewport and render target support to Camera
- Enhance Projection with frustum and depth range support
- Improve Mesh with GPU buffer abstraction and better primitives
- Expand RenderContext with WebGL state management
- Complete RenderModule with plugin lifecycle management

**Scope:**
- Focus on WebGL 2.0 compatible features
- Simplify WGPU-specific concepts for browser deployment
- Keep ECS integration patterns consistent with existing codebase

---

## 2. Prerequisites

**Dependencies:**
- `haxe.math` - Already implemented (Mat4, Vec3, Vec4, etc.)
- `haxe.ecs` - Component components already exist
- `haxe.transform` - Transform component for camera positioning

**Files to modify:**
- `Camera.hx` - Major enhancement
- `Projection.hx` - Minor enhancement with new features
- `Mesh.hx` - Major enhancement
- `RenderContext.hx` - Major enhancement
- `RenderModule.hx` - Minor enhancement

---

## 3. Implementation Steps

### Step 1: Enhance Camera.hx

**Add new features:**
- `Viewport` component for sub-rectangle rendering
- `RenderTarget` enum (Window, Canvas, Texture)
- Camera type enum (2d, 3d)
- View frustum computation
- Camera bundle support
- Proper transform synchronization

**Files to modify:**
- `src/haxe/render/Camera.hx`

### Step 2: Enhance Projection.hx

**Add new features:**
- Frustum computation from projection
- Depth range (NDC to linear conversion)
- Inverse projection matrix support
- Projection mode querying

**Files to modify:**
- `src/haxe/render/Projection.hx`

### Step 3: Enhance Mesh.hx

**Add new features:**
- GPU buffer abstraction layer
- Morph target support with delta buffers
- Better primitive generators (sphere, cylinder, torus)
- Vertex buffer layouts for WebGL
- Index buffer management
- AABB computation helper

**Files to modify:**
- `src/haxe/render/Mesh.hx`

### Step 4: Enhance RenderContext.hx

**Add new features:**
- WebGL state tracker
- Command buffer management
- Render pass abstraction
- Resource management (textures, buffers)
- Camera/view management
- Frustum culling helpers

**Files to modify:**
- `src/haxe/render/RenderContext.hx`

### Step 5: Enhance RenderModule.hx

**Add new features:**
- Plugin interface with lifecycle
- Render schedule management
- System registration helpers
- Asset integration

**Files to modify:**
- `src/haxe/render/RenderModule.hx`

---

## 4. File Changes Summary

### New Files
- None (all existing files will be modified)

### Modified Files
| File | Changes |
|------|---------|
| `Camera.hx` | +80 lines - viewport, render target, frustum, camera types |
| `Projection.hx` | +60 lines - frustum, inverse, depth helpers |
| `Mesh.hx` | +120 lines - GPU buffer, morph targets, more primitives |
| `RenderContext.hx` | +150 lines - WebGL state, command buffer, render passes |
| `RenderModule.hx` | +80 lines - plugin system, lifecycle management |

---

## 5. Testing Strategy

**Unit Tests:**
- Camera projection matrix generation
- Mesh AABB computation
- Frustum point/box intersection

**Manual Testing:**
- Create perspective camera with viewport
- Render mesh with custom material
- Verify orthographic projection in 2D mode

---

## 6. Rollback Plan

All changes are additive improvements. To rollback:
1. Restore original files from git
2. No data migration needed
3. No breaking API changes

---

## 7. Estimated Effort

- **Time:** ~2-3 hours
- **Complexity:** Medium
- **Risk:** Low (additive improvements only)
