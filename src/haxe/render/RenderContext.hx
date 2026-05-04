package haxe.render;

import haxe.ecs.Resource;
import haxe.math.Mat4;
import haxe.math.Vec2;
import haxe.math.Vec3;
import haxe.math.Vec4;

/**
 * WebGL-specific render state
 */
class RenderState {
    /** Current viewport */
    public var viewport:Vec4;
    
    /** Clear color */
    public var clearColor:Vec4;
    
    /** Depth test enabled */
    public var depthTest:Bool;
    
    /** Depth write enabled */
    public var depthWrite:Bool;
    
    /** Depth func (0=never, 1=less, 2=equal, 3=lequal, 4=greater, 5=notequal, 6=always) */
    public var depthFunc:Int;
    
    /** Blend enabled */
    public var blend:Bool;
    
    /** Cull face mode (0=none, 1=back, 2=fron) */
    public var cullFace:Int;
    
    /** Scissor test enabled */
    public var scissorTest:Bool;
    
    /** Scissor rectangle */
    public var scissorRect:Vec4;
    
    public function new() {
        this.viewport = new Vec4(0, 0, 1920, 1080);
        this.clearColor = new Vec4(0, 0, 0, 1);
        this.depthTest = true;
        this.depthWrite = true;
        this.depthFunc = 3; // LEQUAL
        this.blend = false;
        this.cullFace = 1; // BACK
        this.scissorTest = false;
        this.scissorRect = new Vec4(0, 0, 1920, 1080);
    }
    
    public function reset():Void {
        viewport = new Vec4(0, 0, 1920, 1080);
        clearColor = new Vec4(0, 0, 0, 1);
        depthTest = true;
        depthWrite = true;
        depthFunc = 3;
        blend = false;
        cullFace = 1;
        scissorTest = false;
    }
    
    public inline function clone():RenderState {
        var s = new RenderState();
        s.viewport = viewport.clone();
        s.clearColor = clearColor.clone();
        s.depthTest = depthTest;
        s.depthWrite = depthWrite;
        s.depthFunc = depthFunc;
        s.blend = blend;
        s.cullFace = cullFace;
        s.scissorTest = scissorTest;
        s.scissorRect = scissorRect.clone();
        return s;
    }
}

/**
 * Camera uniforms for shaders
 */
class CameraUniforms {
    /** View matrix */
    public var view:Mat4;
    
    /** Projection matrix */
    public var projection:Mat4;
    
    /** View * Projection combined */
    public var viewProjection:Mat4;
    
    /** Camera world position */
    public var position:Vec3;
    
    /** Camera far plane distance */
    public var far:Float;
    
    /** Camera near plane distance */
    public var near:Float;
    
    public function new() {
        view = Mat4.IDENTITY;
        projection = Mat4.IDENTITY;
        viewProjection = Mat4.IDENTITY;
        position = Vec3.ZERO;
        far = 1000.0;
        near = 0.1;
    }
    
    public function update(camera:Camera, cameraTransform:haxe.transform.Transform):Void {
        var aspect = camera.renderTargetSize.x / camera.renderTargetSize.y;
        view = camera.getViewMatrix(cameraTransform);
        projection = camera.getProjectionMatrix(aspect);
        viewProjection = projection * view;
        position = cameraTransform.translation;
        near = camera.near;
        far = camera.far;
    }
}

/**
 * Light uniforms for shaders
 */
class LightUniforms {
    /** Directional light count */
    public var directionalCount:Int;
    
    /** Point light count */
    public var pointCount:Int;
    
    /** Ambient light color */
    public var ambient:Vec4;
    
    public function new() {
        directionalCount = 0;
        pointCount = 0;
        ambient = new Vec4(0.1, 0.1, 0.1, 1.0);
    }
}

/**
 * RenderContext provides the interface for rendering operations.
 * 
 * This is a simplified abstraction over WebGL that handles:
 * - Viewport management
 * - Camera setup and uniform management
 * - Render state management
 * - Drawing commands
 */
class RenderContext implements Resource {
    /** Current render state */
    public var state:RenderState;
    
    /** Current camera uniforms */
    public var camera:Vec2; // Render target size
    
    /** Width of the render target */
    public var width:Int;
    
    /** Height of the render target */
    public var height:Int;
    
    /** Device pixel ratio */
    public var devicePixelRatio:Float;
    
    /** Whether rendering is initialized */
    public var initialized:Bool;
    
    /** Frame counter */
    public var frame:Int;
    
    /** Delta time since last frame */
    public var deltaTime:Float;
    
    /** Time since start */
    public var time:Float;
    
    /** Pending command buffers */
    public var pendingCommands:Array<RenderCommand>;
    
    /** Currently active camera */
    public var currentCamera:Null<Camera>;
    
    /** Currently active camera transform */
    public var currentCameraTransform:Null<haxe.transform.Transform>;
    
    /** Current view-projection matrix */
    public var viewProjection:Mat4;
    
    /** Default camera uniforms */
    public var cameraUniforms:CameraUniforms;
    
    /** Default light uniforms */
    public var lightUniforms:LightUniforms;
    
    public function new() {
        state = new RenderState();
        width = 1920;
        height = 1080;
        devicePixelRatio = 1.0;
        initialized = false;
        frame = 0;
        deltaTime = 0.016;
        time = 0;
        pendingCommands = [];
        currentCamera = null;
        currentCameraTransform = null;
        viewProjection = Mat4.IDENTITY;
        cameraUniforms = new CameraUniforms();
        lightUniforms = new LightUniforms();
    }
    
    /**
     * Initialize the render context
     */
    public function initialize(width:Int, height:Int, ?devicePixelRatio:Float):Void {
        this.width = width;
        this.height = height;
        this.devicePixelRatio = devicePixelRatio != null ? devicePixelRatio : 1.0;
        this.camera = new Vec2(width * this.devicePixelRatio, height * this.devicePixelRatio);
        this.initialized = true;
        
        // Set default viewport
        state.viewport = new Vec4(0, 0, width, height);
        state.scissorRect = new Vec4(0, 0, width, height);
    }
    
    /**
     * Resize the render target
     */
    public function resize(width:Int, height:Int):Void {
        this.width = width;
        this.height = height;
        state.viewport = new Vec4(0, 0, width, height);
        state.scissorRect = new Vec4(0, 0, width, height);
        
        if (currentCamera != null) {
            currentCamera.renderTargetSize = new Vec2(width * devicePixelRatio, height * devicePixelRatio);
            updateCameraUniforms();
        }
    }
    
    /**
     * Begin rendering with a camera
     */
    public function beginCamera(camera:Camera, transform:haxe.transform.Transform):Void {
        currentCamera = camera;
        currentCameraTransform = transform;
        
        // Update camera uniforms
        cameraUniforms.update(camera, transform);
        viewProjection = cameraUniforms.viewProjection;
        
        // Update state from camera
        state.clearColor = camera.clearColor;
    }
    
    /**
     * End camera rendering
     */
    public function endCamera():Void {
        currentCamera = null;
        currentCameraTransform = null;
    }
    
    /**
     * Update camera uniforms when camera changes
     */
    private function updateCameraUniforms():Void {
        if (currentCamera != null && currentCameraTransform != null) {
            cameraUniforms.update(currentCamera, currentCameraTransform);
            viewProjection = cameraUniforms.viewProjection;
        }
    }
    
    /**
     * Set the viewport
     */
    public function setViewport(x:Int, y:Int, w:Int, h:Int):Void {
        state.viewport = new Vec4(x, y, w, h);
    }
    
    /**
     * Set clear color
     */
    public function setClearColor(r:Float, g:Float, b:Float, a:Float):Void {
        state.clearColor = new Vec4(r, g, b, a);
    }
    
    /**
     * Set depth test enabled/disabled
     */
    public function setDepthTest(enabled:Bool):Void {
        state.depthTest = enabled;
    }
    
    /**
     * Set depth write enabled/disabled
     */
    public function setDepthWrite(enabled:Bool):Void {
        state.depthWrite = enabled;
    }
    
    /**
     * Set blend enabled/disabled
     */
    public function setBlend(enabled:Bool):Void {
        state.blend = enabled;
    }
    
    /**
     * Set cull face mode
     */
    public function setCullFace(mode:Int):Void {
        state.cullFace = mode;
    }
    
    /**
     * Clear the current render target
     * @param color Clear color buffer
     * @param depth Clear depth buffer
     * @param stencil Clear stencil buffer
     */
    public function clear(color:Bool = true, depth:Bool = true, stencil:Bool = false):Void {
        var cmd = RenderCommand.clear(color, depth, stencil, state.clearColor);
        pendingCommands.push(cmd);
    }
    
    /**
     * Draw a mesh
     */
    public function drawMesh(mesh:Mesh, transform:haxe.transform.Transform, ?material:Material):Void {
        var cmd = RenderCommand.drawMesh(mesh, transform, material);
        pendingCommands.push(cmd);
    }
    
    /**
     * Draw a mesh instance (instanced rendering)
     */
    public function drawMeshInstanced(mesh:Mesh, transforms:Array<haxe.transform.Transform>, ?material:Material):Void {
        var cmd = RenderCommand.drawMeshInstanced(mesh, transforms, material);
        pendingCommands.push(cmd);
    }
    
    /**
     * Submit pending commands to the GPU
     */
    public function submit():Void {
        // Commands are queued for the render system to process
        frame++;
    }
    
    /**
     * Clear all pending commands without submitting
     */
    public function clearCommands():Void {
        pendingCommands = [];
    }
    
    /**
     * Begin a render pass
     */
    public function beginPass():Void {
        // Reset render state for new pass
        state.reset();
    }
    
    /**
     * End the current render pass
     */
    public function endPass():Void {
        // Submit commands at end of pass
        submit();
    }
    
    /**
     * Check if a mesh is visible in the current camera
     */
    public function isMeshVisible(mesh:Mesh, transform:haxe.transform.Transform):Bool {
        if (currentCamera == null || currentCameraTransform == null) return true;
        
        // Transform AABB to world space
        var worldAabb = mesh.aabb.transformBy(transform.getMatrix());
        var center = worldAabb.getCenter();
        var extents = worldAabb.getExtents();
        
        // Simple frustum culling - check if AABB corners are behind any plane
        var cameraPos = currentCameraTransform.translation;
        var forward = currentCameraTransform.forward();
        
        // Check if all corners are behind the camera
        var allBehind = true;
        for (i in 0...8) {
            var corner = new Vec3(
                i & 1 == 0 ? worldAabb.min.x : worldAabb.max.x,
                i & 2 == 0 ? worldAabb.min.y : worldAabb.max.y,
                i & 4 == 0 ? worldAabb.min.z : worldAabb.max.z
            );
            var toCorner = corner - cameraPos;
            if (toCorner.dot(forward) > 0) {
                allBehind = false;
                break;
            }
        }
        
        return !allBehind;
    }
    
    /**
     * Get current time
     */
    public function getTime():Float return time;
    
    /**
     * Get delta time
     */
    public function getDeltaTime():Float return deltaTime;
    
    /**
     * Get frame count
     */
    public function getFrame():Int return frame;
    
    public function toString():String {
        return 'RenderContext(${width}x${height}, frame: $frame, commands: ${pendingCommands.length})';
    }
}

/**
 * Abstract render command
 */
enum RenderCommand {
    Clear(color:Bool, depth:Bool, stencil:Bool, clearColor:Vec4);
    DrawMesh(mesh:Mesh, transform:haxe.transform.Transform, ?material:Material);
    DrawMeshInstanced(mesh:Mesh, transforms:Array<haxe.transform.Transform>, ?material:Material);
    SetState(state:RenderState);
    DrawFullscreenQuad(?material:Material);
    RenderToTexture(mesh:Mesh, transform:haxe.transform.Transform, ?material:Material, target:RenderTarget);
}

/**
 * Material for rendering
 */
class Material {
    /** Base color */
    public var baseColor:Vec4;
    
    /** Metallic factor */
    public var metallic:Float;
    
    /** Roughness factor */
    public var roughness:Float;
    
    /** Emissive color */
    public var emissive:Vec4;
    
    /** Texture ID or path */
    public var albedoTexture:String;
    
    /** Normal map texture ID or path */
    public var normalTexture:String;
    
    public function new() {
        baseColor = new Vec4(1, 1, 1, 1);
        metallic = 0.0;
        roughness = 1.0;
        emissive = new Vec4(0, 0, 0, 1);
        albedoTexture = "";
        normalTexture = "";
    }
    
    public static function standard():Material {
        return new Material();
    }
    
    public static function unlit(color:Vec4):Material {
        var mat = new Material();
        mat.baseColor = color;
        mat.metallic = 0.0;
        mat.roughness = 1.0;
        return mat;
    }
    
    public static function pbr(albedo:Vec4, metallic:Float, roughness:Float):Material {
        var mat = new Material();
        mat.baseColor = albedo;
        mat.metallic = metallic;
        mat.roughness = roughness;
        return mat;
    }
}

/**
 * Render target for offscreen rendering
 */
class RenderTarget {
    public var id:String;
    public var width:Int;
    public var height:Int;
    public var colorAttachment:String;
    public var depthAttachment:String;
    
    public function new(id:String, width:Int, height:Int) {
        this.id = id;
        this.width = width;
        this.height = height;
    }
}

/**
 * RenderCommand helper functions
 */
class RenderCommand {
    public static function clear(color:Bool, depth:Bool, stencil:Bool, clearColor:Vec4):RenderCommand {
        return Clear(color, depth, stencil, clearColor);
    }
    
    public static function drawMesh(mesh:Mesh, transform:haxe.transform.Transform, ?material:Material):RenderCommand {
        return DrawMesh(mesh, transform, material);
    }
    
    public static function drawMeshInstanced(mesh:Mesh, transforms:Array<haxe.transform.Transform>, ?material:Material):RenderCommand {
        return DrawMeshInstanced(mesh, transforms, material);
    }
    
    public static function drawFullscreenQuad(?material:Material):RenderCommand {
        return DrawFullscreenQuad(material);
    }
}

/**
 * RenderWorld manages render-specific world state
 */
class RenderWorld implements Resource {
    /** All active meshes in the render world */
    public var meshes:Map<Int, Mesh>;
    
    /** All active materials */
    public var materials:Map<Int, Material>;
    
    /** All render targets */
    public var renderTargets:Map<String, RenderTarget>;
    
    /** Camera cache for quick lookup */
    public var cameras:Array<{camera:Camera, transform:haxe.transform.Transform}>;
    
    public function new() {
        meshes = new Map();
        materials = new Map();
        renderTargets = new Map();
        cameras = [];
    }
    
    public function registerMesh(id:Int, mesh:Mesh):Void {
        mesh.id = id;
        meshes.set(id, mesh);
    }
    
    public function getMesh(id:Int):Null<Mesh> {
        return meshes.get(id);
    }
    
    public function unregisterMesh(id:Int):Void {
        meshes.remove(id);
    }
    
    public function registerMaterial(id:Int, material:Material):Void {
        materials.set(id, material);
    }
    
    public function getMaterial(id:Int):Null<Material> {
        return materials.get(id);
    }
    
    public function registerRenderTarget(target:RenderTarget):Void {
        renderTargets.set(target.id, target);
    }
    
    public function getRenderTarget(id:String):Null<RenderTarget> {
        return renderTargets.get(id);
    }
    
    public function addCamera(camera:Camera, transform:haxe.transform.Transform):Void {
        cameras.push({camera: camera, transform: transform});
    }
    
    public function getActiveCamera():Null<{camera:Camera, transform:haxe.transform.Transform}> {
        if (cameras.length == 0) return null;
        
        // Sort by order and find first active
        cameras.sort((a, b) -> a.camera.order > b.camera.order ? 1 : -1);
        
        for (cam in cameras) {
            if (cam.camera.isActive) return cam;
        }
        
        return cameras.length > 0 ? cameras[0] : null;
    }
    
    public function clearCameras():Void {
        cameras = [];
    }
}
