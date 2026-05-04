# Implementation Plan: Bevy Render Module Improvements

## 1. Overview

This plan outlines improvements to the `bevy_render` module in the Haxe port of Bevy, targeting WebGL-based simplified rendering. The improvements enhance Camera, Projection, Mesh, RenderContext, and RenderModule components.

**Goals:**
- Add frustum and visibility culling support
- Implement camera output modes and render targets
- Enhance mesh rendering with primitive types and morph targets
- Create a unified render context for WebGL rendering
- Add render graph and phase system support

**Success Criteria:**
- Camera supports perspective and orthographic projections with frustum computation
- Mesh provides common primitive creation and proper vertex attribute handling
- RenderContext manages WebGL state and rendering commands
- RenderModule integrates all render components properly

---

## 2. Prerequisites

### Dependencies
- `haxe.math.Mat4` - Matrix operations for projections and transforms
- `haxe.math.Vec3` - Vector math for 3D calculations
- `haxe.math.Vec4` - Homogeneous coordinates
- `haxe.ecs.Component` - Component interface
- `haxe.ecs.Resource` - Resource interface
- `haxe.transform.Transform` - Transform component
- `haxe.color.Color` - Color handling

### Environment
- Haxe 4.x or later
- WebGL 1.0 / WebGL 2.0 compatible target

---

## 3. Implementation Steps

### Step 1: Enhance Camera.hx

**Files to modify:** `/home/vscode/projects/bevy_haxe/src/haxe/render/Camera.hx`

**Changes:**
1. Add `CameraOutputMode` enum (Screen, View, Texture)
2. Add `RenderTarget` enum (Window, Texture)
3. Add frustum computation support
4. Add visibility/frustum culling interface
5. Implement camera ordering and sorting
6. Add viewport and sub-camera support
7. Implement `ExtractComponent` pattern for render world

**Key additions:**
```haxe
// Camera output modes
enum CameraOutputMode {
    Screen;      // Default screen output
    View(phase:Int);  // Intermediate view target
    Texture(textureId:String);  // Render to texture
}

// Visibility result
typedef VisibleEntities = Array<Entity>;

// Frustum for visibility culling
class Frustum {
    public var planes:Array<Vec4>;  // 6 frustum planes
    
    public function isVisible(center:Vec3, halfExtents:Vec3):Bool;
    public function computeFromProjection(matrix:Mat4):Void;
}
```

---

### Step 2: Enhance Projection.hx

**Files to modify:** `/home/vscode/projects/bevy_haxe/src/haxe/render/Projection.hx`

**Changes:**
1. Add projection traits and interfaces
2. Implement `compute_frustum()` method
3. Add world-to-view matrix computation
4. Implement view-projection matrix combination
5. Add depth range helpers

**Key additions:**
```haxe
interface ProjectionTrait {
    function getMatrix():Mat4;
    function computeFrustum():Frustum;
    function getNear():Float;
    function getFar():Float;
    function isPerspective():Bool;
}

class PerspectiveProjection {
    // existing code...
    
    public function computeFrustum():Frustum;
    public function getViewMatrix():Mat4;
}

class OrthographicProjection {
    // existing code...
    
    public function computeFrustum():Frustum;
    public function getViewMatrix():Mat4;
}
```

---

### Step 3: Enhance Mesh.hx

**Files to modify:** `/home/vscode/projects/bevy_haxe/src/haxe/render/Mesh.hx`

**Changes:**
1. Add `MorphTarget` support with weights
2. Implement GPU buffer representation
3. Add mesh morph system integration
4. Implement `RenderAsset` trait for GPU preparation
5. Add mesh AABB computation optimization
6. Add GPU buffer layout for morph targets

**Key additions:**
```haxe
class RenderMesh {
    public var vertexCount:Int;
    public var aabbCenter:Vec3;
    public var bufferInfo:MeshBufferInfo;
    public var morphTargetsTexture:Int;  // GPU texture id
    
    public static function fromMesh(mesh:Mesh):RenderMesh;
}

class MeshBufferInfo {
    public var vertexBuffer:Int;
    public var indexBuffer:Int;
    public var layout:VertexBufferLayout;
    public var indexFormat:IndexFormat;
}
```

---

### Step 4: Enhance RenderContext.hx

**Files to modify:** `/home/vscode/projects/bevy_haxe/src/haxe/render/RenderContext.hx`

**Changes:**
1. Add WebGL command buffer management
2. Implement render phase tracking
3. Add batched rendering support
4. Implement view and phase management
5. Add command encoder for rendering
6. Implement viewport and scissor management
7. Add texture and sampler management

**Key additions:**
```haxe
// Render command types
enum RenderCommand {
    SetPipeline(pipeline:Int);
    SetVertexBuffer(buffer:Int, slot:Int);
    SetIndexBuffer(buffer:Int);
    DrawIndexed(indexCount:Int, instanceCount:Int);
    Draw(vertCount:Int, instanceCount:Int);
    SetViewport(x:Int, y:Int, w:Int, h:Int);
    SetScissor(x:Int, y:Int, w:Int, h:Int);
}

// Render phase types
enum RenderPhase {
    Layout;
    Prepare;
    CameraSetup;
    PrePass;
    MainPass;
    PostPass;
    Finish;
}

class RenderContext {
    // existing code...
    
    public var commandEncoder:CommandEncoder;
    public var currentPhase:RenderPhase;
    public var pendingCommands:Array<RenderCommand>;
    
    public function beginFrame():Void;
    public function endFrame():Void;
    public function beginPhase(phase:RenderPhase):Void;
    public function endPhase(phase:RenderPhase):Void;
    public function submit():Void;
}
```

---

### Step 5: Enhance RenderModule.hx

**Files to modify:** `/home/vscode/projects/bevy_haxe/src/haxe/render/RenderModule.hx`

**Changes:**
1. Add plugin system integration
2. Implement render schedule
3. Add camera extraction system
4. Implement mesh preparation system
5. Add render graph definition
6. Export all render components

**Key additions:**
```haxe
class RenderModule {
    public static function createPlugin():RenderPlugin;
    public static function createMeshPlugin():MeshRenderPlugin;
    public static function createCameraPlugin():CameraRenderPlugin;
}

// Render plugin with lifecycle
class RenderPlugin implements Plugin {
    public function build(app:App):Void;
    public function setup(app:App):Void;
    public function finish(app:App):Void;
}

// Schedule labels
class RenderSchedule {
    public static var Extract:ScheduleLabel;
    public static var Prepare:ScheduleLabel;
    public static var Render:ScheduleLabel;
    public static var Finish:ScheduleLabel;
}
```

---

## 4. File Changes Summary

### New Files
- None (all enhancements to existing files)

### Modified Files

| File | Changes |
|------|---------|
| `src/haxe/render/Camera.hx` | Add frustum, output modes, visibility, viewport, render target |
| `src/haxe/render/Projection.hx` | Add projection traits, frustum computation, view matrices |
| `src/haxe/render/Mesh.hx` | Add morph support, GPU buffer info, RenderMesh, AABB optimization |
| `src/haxe/render/RenderContext.hx` | Add command buffer, phases, encoder, texture management |
| `src/haxe/render/RenderModule.hx` | Add plugins, schedules, system integration, exports |

---

## 5. Testing Strategy

### Unit Tests
- Camera frustum culling tests
- Projection matrix tests
- Mesh primitive creation tests
- Render state comparison tests

### Integration Tests
- Camera with perspective projection test
- Orthographic camera with multiple views
- Mesh rendering pipeline test
- Render context command generation

### Manual Testing
1. Create scene with multiple cameras
2. Test frustum culling with various meshes
3. Verify orthographic vs perspective differences
4. Test mesh morph animation

---

## 6. Rollback Plan

1. Keep backup of original files before modification
2. If issues arise, restore from backups
3. Test incrementally after each file change

---

## 7. Estimated Effort

- **Time:** 4-6 hours
- **Complexity:** Medium
- **Files:** 5 files to modify
- **Dependencies:** Existing math and ECS modules

---

## 8. Implementation Notes

### WebGL Simplifications
- Use WebGL 1.0 compatible functions
- Avoid WebGL 2 specific features for wider support
- Flatten struct hierarchies for simpler JS interop

### Performance Considerations
- Cache projection matrices
- Use typed arrays for vertex data
- Minimize object allocations in hot paths

### Future Extensibility
- Design interfaces for future WGPU-like abstraction
- Keep render commands generic for multi-backend support
