package haxe.render;

import haxe.ecs.Component;
import haxe.math.Vec2;
import haxe.render.Projection;

/**
 * Camera component for rendering.
 * 
 * A Camera determines what part of the world is visible and how it appears on screen.
 * It can be orthographic (parallel projection) or perspective (realistic 3D projection).
 */
class Camera implements Component {
    /** Unique identifier for this camera */
    public var entityId:Int = 0;
    
    /** The projection method used by this camera */
    public var projection:Projection;
    
    /** Camera order for sorting when multiple cameras are present */
    public var order:Float;
    
    /** Render target size in pixels */
    public var renderTargetSize:Vec2;
    
    /** Near clipping plane distance */
    public var near:Float;
    
    /** Far clipping plane distance */
    public var far:Float;
    
    /** Camera position offset from the Transform */
    public var transformOffset:Vec2;
    
    /** Clear color for the render target (RGBA) */
    public var clearColor:Vec4;
    
    /** Whether this camera is enabled */
    public var isActive:Bool;
    
    /** Render layers this camera can see */
    public var renderLayers:Array<Int>;
    
    /** Depth from the Transform to the camera */
    public var depth:Float;
    
    public var componentTypeId(get, never):Int;
    private static var _typeId:Int = -1;
    private static function get_componentTypeId():Int {
        if (_typeId < 0) _typeId = haxe.ecs.ComponentType.get(Camera);
        return _typeId;
    }
    
    public function new(?projection:Projection, ?renderTargetSize:Vec2) {
        this.projection = projection != null ? projection : new PerspectiveProjection();
        this.renderTargetSize = renderTargetSize != null ? renderTargetSize : new Vec2(1920, 1080);
        this.order = 0.0;
        this.near = 0.1;
        this.far = 1000.0;
        this.transformOffset = Vec2.ZERO;
        this.clearColor = new Vec4(0.0, 0.0, 0.0, 1.0);
        this.isActive = true;
        this.renderLayers = [0];
        this.depth = 0.0;
    }
    
    /**
     * Get the projection matrix for this camera
     */
    public function getProjectionMatrix(aspectRatio:Float):Mat4 {
        return projection.getProjectionMatrix(aspectRatio, near, far);
    }
    
    /**
     * Get the view matrix for this camera given a transform
     */
    public function getViewMatrix(cameraTransform:haxe.transform.Transform):Mat4 {
        var eye = cameraTransform.translation;
        var forward = cameraTransform.forward();
        var center = eye + forward;
        return Mat4.lookAt(eye, center, Vec3.Y);
    }
    
    /**
     * Compute the view-projection matrix
     */
    public function getViewProjection(cameraTransform:haxe.transform.Transform):Mat4 {
        var aspect = renderTargetSize.x / renderTargetSize.y;
        return getProjectionMatrix(aspect) * getViewMatrix(cameraTransform);
    }
    
    /**
     * Check if a world point is visible in this camera's frustum
     */
    public function isVisible(worldPos:Vec3, cameraTransform:haxe.transform.Transform):Bool {
        var aspect = renderTargetSize.x / renderTargetSize.y;
        var projectionMat = getProjectionMatrix(aspect);
        var viewMat = getViewMatrix(cameraTransform);
        var mvp = projectionMat * viewMat;
        
        // Transform point to clip space
        var clipPos = mvp.transformVec4(new Vec4(worldPos.x, worldPos.y, worldPos.z, 1.0));
        
        // Check if within clip volume
        var w = clipPos.w;
        return clipPos.x >= -w && clipPos.x <= w &&
               clipPos.y >= -w && clipPos.y <= w &&
               clipPos.z >= 0 && clipPos.z <= w;
    }
    
    /**
     * Set orthographic projection
     */
    public function setOrthographic(?left:Float, ?right:Float, ?bottom:Float, ?top:Float, ?near:Float, ?far:Float):Void {
        var size = cast projection;
        var aspect = renderTargetSize.x / renderTargetSize.y;
        
        if (size == null || !Std.is(size, OrthographicProjection)) {
            var halfHeight = 5.0;
            var halfWidth = halfHeight * aspect;
            this.projection = new OrthographicProjection(-halfWidth, halfWidth, halfHeight, -halfHeight, 0.1, 1000.0);
        } else {
            this.projection = size;
        }
    }
    
    /**
     * Set perspective projection
     */
    public function setPerspective(fovY:Float, ?aspectRatio:Float, ?near:Float, ?far:Float):Void {
        if (aspectRatio == null) aspectRatio = renderTargetSize.x / renderTargetSize.y;
        this.projection = new PerspectiveProjection(fovY, aspectRatio, near, far);
        this.near = near != null ? near : 0.1;
        this.far = far != null ? far : 1000.0;
    }
    
    /**
     * Create a 2D camera with orthographic projection
     */
    public static function orthographic2D(?scale:Float, ?near:Float, ?far:Float):Camera {
        var cam = new Camera();
        var s = scale != null ? scale : 10.0;
        cam.projection = new OrthographicProjection(-s, s, s, -s, near != null ? near : 0.1, far != null ? far : 1000.0);
        return cam;
    }
    
    /**
     * Create a 3D camera with perspective projection
     */
    public static function perspective3D(fovY:Float = 60.0, ?aspectRatio:Float, ?near:Float, ?far:Float):Camera {
        var cam = new Camera();
        if (near != null) cam.near = near;
        if (far != null) cam.far = far;
        cam.setPerspective(fovY, aspectRatio, cam.near, cam.far);
        return cam;
    }
    
    public function toString():String {
        return 'Camera(order: $order, projection: $projection, active: $isActive)';
    }
}
