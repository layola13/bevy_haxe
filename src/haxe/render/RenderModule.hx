package haxe.render;

/**
 * Render Module for Bevy-Haxe
 * 
 * This module provides rendering components and context for WebGL rendering.
 * 
 * Main classes:
 * - Camera: Camera component with projection settings
 * - Projection: Camera projection types (Perspective, Orthographic)
 * - Mesh: Geometry data for rendering
 * - RenderContext: Main rendering interface
 * - RenderWorld: Manages render-specific world state
 * - Material: Material properties for rendering
 * 
 * Example usage:
 * ```haxe
 * // Create a perspective camera
 * var camera = Camera.perspective3D(60.0);
 * 
 * // Create a mesh
 * var mesh = Mesh.cube();
 * 
 * // Setup render context
 * var renderContext = new RenderContext();
 * renderContext.initialize(1920, 1080);
 * renderContext.beginCamera(camera, cameraTransform);
 * renderContext.clear();
 * renderContext.drawMesh(mesh, entityTransform);
 * renderContext.endCamera();
 * ```
 */

// Re-export main classes for convenience
#if !macro
@:noDoc
#end
class Module {}
