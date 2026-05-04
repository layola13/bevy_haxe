# Implementation Plan: Bevy Render Module Improvements

**Date:** 2025-01-XX  
**Project:** /home/vscode/projects/bevy_haxe  
**Reference:** /home/vscode/projects/bevy/crates/bevy_render/src/

## 1. Overview

### Description
Improve the bevy_render Haxe module with WebGL-optimized implementations, enhancing Camera, adding Projection, Mesh enhancements, RenderContext, and RenderModule.

### Goals
- Add missing camera features (viewport, render target, visibility)
- Enhance projection system with view matrix support
- Expand mesh functionality with GPU buffer management
- Create simplified render context for WebGL
- Document the module with proper examples

### Scope
**Included:**
- Camera.hx: Add viewport, visibility, render target support
- Projection.hx: Add view matrix computation
- Mesh.hx: Add GPU buffer abstraction, more primitive shapes
- RenderContext.hx: Add command encoder, render pass management
- RenderModule.hx: Add complete module documentation

**Excluded:**
- WGPU-specific implementations (WebGL only)
- Advanced batching/gpu_preprocessing features
- Texture/sampler management (separate module)

## 2. Prerequisites

### Required Files
- haxe/math/Mat4.hx
- haxe/math/Vec3.hx, Vec4.hx
- haxe/ecs/Component.hx
- haxe/ecs/Resource.hx
- haxe/transform/Transform.hx
- haxe/transform/GlobalTransform.hx

### Dependencies
- No external dependencies for core implementation
- WebGL interop planned for future

## 3. Implementation Steps

### Step 1: Enhance Camera.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/render/Camera.hx`

**Changes:**
- Add viewport management (x, y, width, height)
- Add RenderTarget enum (Window, Texture)
- Add visibility masks for render layers
- Add camera output mode (Primary, Secondary)
- Add manual texture view support
- Add exposure/HDR settings
- Add projection change tracking
- Add frustum computation
- Add camera system helper methods

**Key Additions:**
```haxe
// Viewport management
public var viewport:RenderViewport;

// Render target
public var outputMode:CameraOutputMode;
public var target:RenderTarget;

// Visibility
public var visibilityMask:Int;
public var mainTextureUsages:TextureUsageFlags;

// Projection tracking
public var projectionMatrix(get, never):Mat4;
public var viewMatrix(get, never):Mat4;
public var frustum(get, never):Frustum;
```

### Step 2: Enhance Projection.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/render/Projection.hx`

**Changes:**
- Add inverse projection matrix computation
- Add view matrix computation for each projection type
- Add frustum extraction
- Add projection comparison methods
- Add projection bounds validation
- Add frustum corner extraction

**Key Additions:**
```haxe
class PerspectiveProjection {
    // Existing fields...
    
    public function getInverseProjection(aspectRatio:Float, near:Float, far:Float):Mat4;
    public function getViewMatrix(transform:Transform):Mat4;
    public function getFrustum(transform:Transform, aspectRatio:Float, near:Float, far:Float):Frustum;
}

class OrthographicProjection {
    // Existing fields...
    
    public function getInverseProjection(near:Float, far:Float):Mat4;
    public function getViewMatrix(transform:Transform):Mat4;
    public function getFrustum(transform:Transform):Frustum;
}
```

### Step 3: Add Frustum Class
**New File:** `/home/vscode/projects/bevy_haxe/src/haxe/render/Frustum.hx`

**Contents:**
```haxe
package haxe.render;

import haxe.math.Vec3;
import haxe.math.Mat4;

/**
 * View frustum for visibility culling
 */
class Frustum {
    /** Array of 6 frustum planes (normalized outward normals) */
    public var planes:Array<FrustumPlane>;
    
    /** Array of 8 corner vertices */
    public var corners:Array<Vec3>;
    
    public function new();
    
    /** Update frustum from view-projection matrix */
    public function update(viewProj:Mat4):Void;
    
    /** Check if a point is inside the frustum */
    public function containsPoint(point:Vec3):Bool;
    
    /** Check if a sphere intersects the frustum */
    public function intersectsSphere(center:Vec3, radius:Float):Bool;
    
    /** Check if an axis-aligned bounding box intersects the frustum */
    public function intersectsAabb(min:Vec3, max:Vec3):Bool;
}
```

### Step 4: Enhance Mesh.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/render/Mesh.hx`

**Changes:**
- Add GPU buffer abstraction (VertexBuffer, IndexBuffer)
- Add mesh topology for WebGL
- Add morph target support structures
- Add AABB helper methods
- Add more primitive shapes (sphere, cylinder, torus)
- Add mesh caching support

**Key Additions:**
```haxe
// GPU Buffer abstraction
class GpuVertexBuffer {
    public var id:Int;
    public var data:js.html.ArrayBuffer;
    public var layout:VertexBufferLayout;
}

class GpuIndexBuffer {
    public var id:Int;
    public var data:js.html.ArrayBuffer;
    public var format:IndexFormat;
}

// Mesh builder
class MeshBuilder {
    public var positions:Array<Vec3>;
    public var normals:Array<Vec3>;
    public var uvs:Array<Vec2>;
    public var indices:Array<Int>;
    
    public function addVertex(x:Float, y:Float, z:Float):Int;
    public function addTriangle(a:Int, b:Int, c:Int):Void;
    public function build():Mesh;
    public function buildPlane(width:Float, height:Float):MeshBuilder;
    public function buildBox(size:Float):MeshBuilder;
    public function buildSphere(radius:Float, segments:Int):MeshBuilder;
}
```

### Step 5: Enhance RenderContext.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/render/RenderContext.hx`

**Changes:**
- Add command buffer management
- Add render pass abstraction
- Add texture/sampler registry
- Add shader program cache
- Add debug rendering helpers
- Add frame statistics

**Key Additions:**
```haxe
// Command buffer
class CommandBuffer {
    public var id:Int;
    public var commands:Array<RenderCommand>;
    
    public function clear():Void;
    public function setViewport(x:Int, y:Int, w:Int, h:Int):Void;
    public function drawMesh(mesh:Mesh, transform:Mat4, material:Material):Void;
    public function finish():Void;
}

// Render pass abstraction
enum RenderPassType {
    Color;
    Depth;
    Stencil;
}

class TrackedRenderPass {
    public var passType:RenderPassType;
    public var target:RenderTarget;
    public var commandEncoder:js.html.webgl.WebGLRenderingContext;
    
    public function setViewport(x:Int, y:Int, w:Int, h:Int):Void;
    public function drawIndexed(mesh:Mesh, vertexCount:Int, indexOffset:Int):Void;
    public function draw(vertexCount:Int, vertexOffset:Int):Void;
}
```

### Step 6: Enhance RenderModule.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/render/RenderModule.hx`

**Changes:**
- Add comprehensive documentation
- Add usage examples
- Add module constants
- Add plugin registration helpers

**Key Additions:**
```haxe
class Module {
    // WebGL constants
    public static inline var MAX_TEXTURE_SLOTS:Int = 16;
    public static inline var MAX_VERTEX_ATTRIBUTES:Int = 16;
    public static inline var MAX_UNIFORM_BUFFERS:Int = 12;
}
```

## 4. File Changes Summary

### Created Files
| File | Description |
|------|-------------|
| `src/haxe/render/Frustum.hx` | View frustum for visibility culling |

### Modified Files
| File | Description |
|------|-------------|
| `src/haxe/render/Camera.hx` | Enhanced with viewport, visibility, render target |
| `src/haxe/render/Projection.hx` | Enhanced with view matrix, inverse projection |
| `src/haxe/render/Mesh.hx` | Added GPU buffer, mesh builder, more primitives |
| `src/haxe/render/RenderContext.hx` | Added command buffer, render pass, texture registry |
| `src/haxe/render/RenderModule.hx` | Enhanced documentation and constants |

## 5. Testing Strategy

### Unit Tests
- `test/render/CameraTest.hx`: Test camera creation, viewport, projection switching
- `test/render/ProjectionTest.hx`: Test matrix computations
- `test/render/MeshTest.hx`: Test primitive generation, AABB computation
- `test/render/FrustumTest.hx`: Test frustum visibility checks

### Integration Tests
- Camera + Projection + Transform matrix chain
- Mesh rendering pipeline (conceptual)

### Manual Testing
1. Create camera with perspective/orthographic projection
2. Generate primitives (cube, sphere, plane)
3. Compute view-projection matrices
4. Test frustum culling with various shapes

## 6. Rollback Plan

### Revert Strategy
Each file modification can be reverted by restoring the original version from git:

```bash
git checkout HEAD -- src/haxe/render/Camera.hx
git checkout HEAD -- src/haxe/render/Projection.hx
# etc.
```

### Data Migration
- No persistent data migration required
- Mesh data structures are compatible with existing usage

## 7. Estimated Effort

| Task | Complexity | Estimated Time |
|------|------------|-----------------|
| Camera.hx enhancements | Medium | 2 hours |
| Projection.hx enhancements | Medium | 1.5 hours |
| Frustum.hx (new file) | Medium | 1 hour |
| Mesh.hx enhancements | High | 3 hours |
| RenderContext.hx enhancements | High | 2.5 hours |
| RenderModule.hx documentation | Low | 0.5 hours |
| **Total** | - | **~10.5 hours** |

## 8. Implementation Notes

### WebGL Simplifications
1. No compute shaders (WebGL 1/2 limitation)
2. Simplified texture formats
3. No GPU-driven rendering (immediate mode abstraction)
4. Basic batching support only

### Future Extensions
- Texture module for image loading/caching
- Material system with shader compilation
- Post-processing pipeline
- PBR lighting helpers
