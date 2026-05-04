package haxe.render;

import haxe.math.Mat4;
import haxe.math.Vec2;
import haxe.math.Vec3;
import haxe.math.Vec4;

/**
 * Projection modes for cameras.
 * Defines how 3D world coordinates are transformed to 2D screen coordinates.
 */
enum Projection {
    /** Perspective projection - objects appear smaller with distance */
    Perspective(proj:PerspectiveProjection);
    /** Orthographic projection - parallel lines stay parallel */
    Orthographic(proj:OrthographicProjection);
}

class ProjectionTools {
    /**
     * Get the projection matrix from a Projection enum
     */
    public static function getMatrix(proj:Projection, aspectRatio:Float, near:Float, far:Float):Mat4 {
        return switch (proj) {
            case Perspective(p): p.getProjectionMatrix(aspectRatio, near, far);
            case Orthographic(o): o.getProjectionMatrix(near, far);
        }
    }
}

/**
 * Perspective projection settings.
 * Creates a view frustum with perspective distortion.
 */
class PerspectiveProjection {
    /** Vertical field of view in degrees */
    public var fov:Float;
    
    /** Aspect ratio (width / height) */
    public var aspectRatio:Float;
    
    /** Near clipping plane */
    public var near:Float;
    
    /** Far clipping plane */
    public var far:Float;
    
    public function new(fov:Float = 60.0, ?aspectRatio:Float, ?near:Float, ?far:Float) {
        this.fov = fov;
        this.aspectRatio = aspectRatio != null ? aspectRatio : 16.0 / 9.0;
        this.near = near != null ? near : 0.1;
        this.far = far != null ? far : 1000.0;
    }
    
    /**
     * Get the perspective projection matrix
     * @param aspectRatio Width / height ratio
     * @param near Near clipping plane
     * @param far Far clipping plane
     */
    public function getProjectionMatrix(aspectRatio:Float, near:Float, far:Float):Mat4 {
        var fovRad = fov * Math.PI / 180.0;
        var tanHalfFov = Math.tan(fovRad / 2);
        var dz = far - near;
        
        return new Mat4(
            1.0 / (aspectRatio * tanHalfFov), 0,              0,                                    0,
            0,                                   1.0 / tanHalfFov, 0,                                    0,
            0,                                   0,              -(far + near) / dz,                  -1,
            0,                                   0,              -(2.0 * far * near) / dz,            0
        );
    }
    
    /**
     * Compute the world-space depth from a normalized device coordinate
     */
    public inline function getDepth(ndcZ:Float, near:Float, far:Float):Float {
        var dz = far - near;
        return -(2.0 * far * near) / (ndcZ * dz - (far + near));
    }
    
    /**
     * Get the camera position for a given view direction and target
     */
    public static function lookAt(eye:Vec3, target:Vec3, up:Vec3 = Vec3.Y):Mat4 {
        return Mat4.lookAt(eye, target, up);
    }
    
    public function toString():String {
        return 'Perspective(fov: $fov, aspect: $aspectRatio, near: $near, far: $far)';
    }
}

/**
 * Orthographic projection settings.
 * Creates a view volume with parallel sides (no perspective distortion).
 */
class OrthographicProjection {
    /** View volume left boundary */
    public var left:Float;
    
    /** View volume right boundary */
    public var right:Float;
    
    /** View volume bottom boundary */
    public var bottom:Float;
    
    /** View volume top boundary */
    public var top:Float;
    
    /** Near clipping plane */
    public var near:Float;
    
    /** Far clipping plane */
    public var far:Float;
    
    /** Scaling factor for zoom effects */
    public var scale:Float;
    
    public function new(?left:Float, ?right:Float, ?top:Float, ?bottom:Float, ?near:Float, ?far:Float) {
        this.left = left != null ? left : -10.0;
        this.right = right != null ? right : 10.0;
        this.top = top != null ? top : 10.0;
        this.bottom = bottom != null ? bottom : -10.0;
        this.near = near != null ? near : 0.1;
        this.far = far != null ? far : 1000.0;
        this.scale = 1.0;
    }
    
    /**
     * Get the orthographic projection matrix
     * @param near Near clipping plane
     * @param far Far clipping plane
     */
    public function getProjectionMatrix(near:Float, far:Float):Mat4 {
        var dx = right - left;
        var dy = top - bottom;
        var dz = far - near;
        
        // Apply scale if set
        var scaledDx = dx / scale;
        var scaledDy = dy / scale;
        var centerX = (left + right) / 2;
        var centerY = (bottom + top) / 2;
        
        return new Mat4(
            2.0 / scaledDx, 0,             0,             -(right + left) / scaledDx,
            0,             2.0 / scaledDy, 0,             -(top + bottom) / scaledDy,
            0,             0,             -2.0 / dz,      -(far + near) / dz,
            0,             0,             0,              1
        );
    }
    
    /**
     * Create from window size with aspect ratio preserved
     */
    public static function fromWindowSize(height:Float, aspectRatio:Float, ?near:Float, ?far:Float):OrthographicProjection {
        var width = height * aspectRatio;
        return new OrthographicProjection(-width/2, width/2, height/2, -height/2, near, far);
    }
    
    /**
     * Adjust the projection for window resize
     */
    public function resize(width:Float, height:Float):Void {
        var halfWidth = width / 2;
        var halfHeight = height / 2;
        left = -halfWidth;
        right = halfWidth;
        top = halfHeight;
        bottom = -halfHeight;
    }
    
    public inline function getWidth():Float return right - left;
    public inline function getHeight():Float return top - bottom;
    public inline function getCenter():Vec2 return new Vec2((left + right) / 2, (top + bottom) / 2);
    
    public function toString():String {
        return 'Orthographic(left: $left, right: $right, top: $top, bottom: $bottom, near: $near, far: $far, scale: $scale)';
    }
}

/**
 * Helper for creating projections
 */
class ProjectionFactory {
    /**
     * Create a perspective projection from vertical FOV
     */
    public static function perspective(fov:Float, ?aspectRatio:Float, ?near:Float, ?far:Float):Projection {
        return Perspective(new PerspectiveProjection(fov, aspectRatio, near, far));
    }
    
    /**
     * Create an orthographic projection
     */
    public static function orthographic(?left:Float, ?right:Float, ?top:Float, ?bottom:Float, ?near:Float, ?far:Float):Projection {
        return Orthographic(new OrthographicProjection(left, right, top, bottom, near, far));
    }
    
    /**
     * Create a 2D orthographic projection from window size
     */
    public static function orthographic2D(width:Float, height:Float, ?depth:Float):Projection {
        return Orthographic(new OrthographicProjection(0, width, height, 0, 0, depth != null ? depth : 1000.0));
    }
    
    /**
     * Get projection matrix from enum value
     */
    public static function getMatrix(proj:Projection, aspectRatio:Float, near:Float, far:Float):Mat4 {
        return ProjectionTools.getMatrix(proj, aspectRatio, near, far);
    }
}
