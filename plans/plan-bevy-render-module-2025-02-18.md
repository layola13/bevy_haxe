# Bevy Render Module Improvement Plan

## 1. Overview

This plan outlines improvements to the `haxe.render` module, targeting WebGL-optimized rendering components for the Haxe ECS framework. The improvements enhance camera systems, projection handling, mesh data structures, render context, and module organization.

### Goals
- Add view frustum and frustum culling support to Camera
- Enhance projection types with more precise matrix calculations
- Add mesh morph targets and computed AABB support
- Improve RenderContext with WebGL-specific optimizations
- Add proper plugin architecture for RenderModule

### Success Criteria
- All components work together seamlessly
- Clear integration points with existing ECS
- WebGL-compatible data structures
- Proper resource management patterns

---

## 2. Prerequisites

### Existing Dependencies
- `haxe.math.Mat4` - Matrix operations
- `haxe.math.Vec3`, `haxe.math.Vec4` - Vector types
- `haxe.ecs.Component` - Component interface
- `haxe.ecs.Resource` - Resource interface
- `haxe.transform.Transform` - Transform component

### Required Files (New)
- None required - all files already exist

### Environment
- Haxe 4.x+
- WebGL target support

---

## 3. Implementation Steps

### Step 1: Enhance Camera.hx

**Files to modify:** `src/haxe/render/Camera.hx`

**Key additions:**
1. Add `frustum:Frustum` field for view frustum representation
2. Add `viewport:Vec4` for viewport management
3. Add `target:String` for render target identification
4. Add `priority:Int` for camera priority ordering
5. Add `exposure:Float` for HDR exposure control
6. Add computed view matrix generation from Transform
7. Add `getViewProjectionMatrix()` method combining view and projection
8. Add `isInFrustum()` for visibility checks

**Implementation Details:**
```haxe
// Add Frustum class reference
class Frustum {
    public var planes:Array<Vec4>; // 6 frustum planes
    public var corners:Array<Vec3>; // 8 frustum corners
    
    public function extractFromMatrices(view:Mat4, proj:Mat4):Void;
    public function isVisible(point:Vec3):Bool;
    public function isVisibleSphere(center:Vec3, radius:Float):Bool;
}
```

**Testing:**
- Unit test for frustum extraction
- Unit test for frustum culling with sphere
- Integration test with Camera and Transform

---

### Step 2: Enhance Projection.hx

**Files to modify:** `src/haxe/render/Projection.hx`

**Key additions:**
1. Add `getAspectRatio()` method to projection base
2. Enhance `PerspectiveProjection` with:
   - `horizontalFov` option
   - `projectionMatrix(aspectRatio)` cached computation
3. Enhance `OrthographicProjection` with:
   - `rect:Vec4` shortcut for (left, right, top, bottom)
   - `zoom:Float` for zoom scaling
4. Add `InverseProjection` utility for view-projection inversion
5. Add `ProjectionMode` enum for easy type checking
6. Add `ProjectionExt` extension methods

**Implementation Details:**
```haxe
enum ProjectionMode {
    Perspective;
    Orthographic;
}

class ProjectionExt {
    static inline function getMode(p:Projection):ProjectionMode;
    static inline function getNear(p:Projection):Float;
    static inline function getFar(p:Projection):Float;
    static inline function getAspect(p:Projection):Float;
    static function inverseProjection(p:Projection, aspect:Float):Mat4;
}
```

**Testing:**
- Unit test for projection matrix generation
- Unit test for inverse projection
- Visual test comparing with Rust Bevy output

---

### Step 3: Enhance Mesh.hx

**Files to modify:** `src/haxe/render/Mesh.hx`

**Key additions:**
1. Add `RenderMesh` wrapper for GPU-ready mesh data
2. Add `MeshBuilder` fluent API for mesh construction
3. Add `morphTargets:Array<MorphTarget>` field
4. Add `skeleton:SkeletonData>` for skeletal animation
5. Add `computeNormals()` method for normal computation
6. Add `merge(other:Mesh)` method for mesh combining
7. Add `subdivide(segments:Int)` for mesh subdivision
8. Add `generateUVWrap(wrapMode:Int)` for UV generation

**Implementation Details:**
```haxe
class RenderMesh {
    public var vertexBuffer:Dynamic; // WebGL buffer handle
    public var indexBuffer:Dynamic;   // WebGL buffer handle
    public var vertexCount:Int;
    public var indexCount:Int;
    public var layout:VertexBufferLayout;
    public var aabb:Vec3Aabb;
}

class MeshBuilder {
    var mesh:Mesh;
    
    static function create():MeshBuilder;
    function positions(data:Array<Float>):MeshBuilder;
    function normals(data:Array<Float>):MeshBuilder;
    function uvs(data:Array<Float>):MeshBuilder;
    function indices(data:Array<Int>):MeshBuilder;
    function build():Mesh;
}
```

**Testing:**
- Unit test for cube/plane generation
- Unit test for normal computation
- Unit test for mesh merging

---

### Step 4: Enhance RenderContext.hx

**Files to modify:** `src/haxe/render/RenderContext.hx`

**Key additions:**
1. Add `pendingCommandBuffers:Array<Dynamic>` for command buffering
2. Add `currentPass:RenderPass>` for pass tracking
3. Add `viewUniforms:ViewUniforms>` for view matrices
4. Add `beginRenderPass(descriptor:RenderPassDescriptor)`
5. Add `endRenderPass()` with buffer submission
6. Add `drawIndexed(mesh:Mesh, instanceCount:Int)`
7. Add `drawMeshInstanced(mesh:Mesh, instances:Int)`
8. Add `setGlobalUniform(name:String, data:Dynamic)`
9. Add frame timing utilities

**Implementation Details:**
```haxe
class RenderPassDescriptor {
    public var colorAttachments:Array<ColorAttachment>;
    public var depthStencilAttachment:DepthAttachment;
    public var viewport:Vec4;
}

class ViewUniforms {
    public var view:Mat4;
    public var projection:Mat4;
    public var viewProjection:Mat4;
    public var inverseViewProjection:Mat4;
    public var worldPosition:Vec3;
}

class TrackedRenderPass {
    public var encoder:Dynamic;
    public var bindGroups:Map<Int, Dynamic>;
    public var pipeline:PipelineState;
}
```

**Testing:**
- Unit test for command buffer management
- Unit test for uniform updates
- Integration test with Camera rendering

---

### Step 5: Enhance RenderModule.hx

**Files to modify:** `src/haxe/render/RenderModule.hx`

**Key additions:**
1. Add `RenderPlugin` implementing `Plugin` interface
2. Add `RenderSchedule` for render loop organization
3. Add `RenderSystems` enum for system ordering
4. Add module constants for render configuration
5. Add plugin registration helper methods

**Implementation Details:**
```haxe
class RenderPlugin implements haxe.app.Plugin {
    var app:App;
    
    public function build(app:App):Void;
    public function setup(app:App):Void;
    public function finish(app:App):Void;
}

enum RenderSystems {
    ExtractEntities;
    PrepareAssets;
    PrepareViews;
    Queue;
    PhaseSort;
    Render;
    Cleanup;
}

class Module {
    public static inline var DEFAULT_FAR = 1000.0;
    public static inline var DEFAULT_NEAR = 0.1;
    public static inline var DEFAULT_FOV = 60.0;
}
```

**Testing:**
- Unit test for plugin registration
- Integration test with App lifecycle

---

## 4. File Changes Summary

### Files to Modify

| File | Action | Changes |
|------|--------|---------|
| `src/haxe/render/Camera.hx` | Modify | Add frustum, viewport, exposure, view matrix computation |
| `src/haxe/render/Projection.hx` | Modify | Add ProjectionMode, enhanced projection methods, inverse projection |
| `src/haxe/render/Mesh.hx` | Modify | Add RenderMesh, MeshBuilder, morph targets, mesh utilities |
| `src/haxe/render/RenderContext.hx` | Modify | Add command buffers, render passes, view uniforms |
| `src/haxe/render/RenderModule.hx` | Modify | Add RenderPlugin, RenderSystems, module constants |

### Files to Create

| File | Purpose |
|------|---------|
| None | All files already exist |

---

## 5. Testing Strategy

### Unit Tests
- `CameraTest.hx` - Frustum extraction, view matrix computation
- `ProjectionTest.hx` - Matrix generation, inverse calculation
- `MeshTest.hx` - Primitive generation, normal computation, merging
- `RenderContextTest.hx` - Command buffer operations, uniform updates

### Integration Tests
- `RenderIntegrationTest.hx` - Full render pipeline with camera and mesh

### Manual Testing
1. Create a simple scene with camera and mesh
2. Verify camera matrices match expected values
3. Verify mesh renders correctly with perspective projection

---

## 6. Rollback Plan

### Individual File Reverts
Each file can be reverted independently by restoring from git:
```bash
git checkout HEAD -- src/haxe/render/Camera.hx
```

### Full Module Revert
```bash
git checkout HEAD -- src/haxe/render/
```

### Migration Steps
- No database migrations required
- No configuration changes needed
- All changes are additive or internal

---

## 7. Estimated Effort

### Time Estimate
- **Camera.hx**: 2 hours
- **Projection.hx**: 1.5 hours  
- **Mesh.hx**: 3 hours
- **RenderContext.hx**: 2.5 hours
- **RenderModule.hx**: 1 hour

**Total**: ~10 hours

### Complexity Assessment
- **Medium** - Some matrix math involved, but mostly additive features
- No breaking API changes
- All existing functionality preserved

### Dependencies
- All features are independent and can be implemented in parallel
- Recommended to start with Projection.hx as it's foundational
- RenderContext depends on Camera and Projection

---

## 8. Implementation Order

1. **Projection.hx** (Foundation - no dependencies)
2. **Camera.hx** (Depends on Projection)
3. **Mesh.hx** (Independent)
4. **RenderContext.hx** (Depends on Camera, Mesh)
5. **RenderModule.hx** (Integration layer)

Each step can be tested independently before proceeding.
