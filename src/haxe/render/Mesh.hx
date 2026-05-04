package haxe.render;

import haxe.ecs.Component;
import haxe.math.Mat4;
import haxe.math.Vec3;
import haxe.math.Vec4;

/**
 * Vertex attribute formats for mesh data
 */
enum VertexFormat {
    Float32x1;
    Float32x2;
    Float32x3;
    Float32x4;
    Uint8x4;
}

/**
 * Index format for mesh indices
 */
enum IndexFormat {
    Uint16;
    Uint32;
}

/**
 * Primitive topology types
 */
enum PrimitiveTopology {
    PointList;
    LineList;
    LineStrip;
    TriangleList;
    TriangleStrip;
}

/**
 * Vertex attribute descriptor
 */
class VertexAttribute {
    public var name:String;
    public var format:VertexFormat;
    public var offset:Int;
    public var shaderLocation:Int;
    
    public function new(name:String, format:VertexFormat, offset:Int, shaderLocation:Int = 0) {
        this.name = name;
        this.format = format;
        this.offset = offset;
        this.shaderLocation = shaderLocation;
    }
    
    public inline function getSize():Int {
        return switch (format) {
            case Float32x1: 4;
            case Float32x2: 8;
            case Float32x3: 12;
            case Float32x4: 16;
            case Uint8x4: 4;
        }
    }
}

/**
 * Layout description for vertex buffer
 */
class VertexBufferLayout {
    public var arrayStride:Int;
    public var stepMode:Int; // 0 = vertex, 1 = instance
    public var attributes:Array<VertexAttribute>;
    
    public function new(arrayStride:Int, stepMode:Int = 0, attributes:Array<VertexAttribute> = null) {
        this.arrayStride = arrayStride;
        this.stepMode = stepMode;
        this.attributes = attributes != null ? attributes : [];
    }
    
    public function addAttribute(name:String, format:VertexFormat, shaderLocation:Int = 0):Void {
        var offset = 0;
        if (attributes.length > 0) {
            var last = attributes[attributes.length - 1];
            offset = last.offset + last.getSize();
        }
        attributes.push(new VertexAttribute(name, format, offset, shaderLocation));
    }
    
    public inline function getTotalSize():Int {
        if (attributes.length == 0) return 0;
        var last = attributes[attributes.length - 1];
        return last.offset + last.getSize();
    }
}

/**
 * Bounding box for mesh
 */
class BoundingBox {
    public var min:Vec3;
    public var max:Vec3;
    
    public function new(?min:Vec3, ?max:Vec3) {
        this.min = min != null ? min : new Vec3(-0.5, -0.5, -0.5);
        this.max = max != null ? max : new Vec3(0.5, 0.5, 0.5);
    }
    
    public inline function getCenter():Vec3 {
        return (min + max) * 0.5;
    }
    
    public inline function getExtents():Vec3 {
        return (max - min) * 0.5;
    }
    
    public inline function containsPoint(point:Vec3):Bool {
        return point.x >= min.x && point.x <= max.x &&
               point.y >= min.y && point.y <= max.y &&
               point.z >= min.z && point.z <= max.z;
    }
    
    public function transformBy(matrix:Mat4):BoundingBox {
        // Transform all 8 corners and find new bounds
        var corners = [
            new Vec3(min.x, min.y, min.z),
            new Vec3(max.x, min.y, min.z),
            new Vec3(min.x, max.y, min.z),
            new Vec3(max.x, max.y, min.z),
            new Vec3(min.x, min.y, max.z),
            new Vec3(max.x, min.y, max.z),
            new Vec3(min.x, max.y, max.z),
            new Vec3(max.x, max.y, max.z)
        ];
        
        var transformed = corners.map(c -> matrix.transformPoint(c));
        var newMin = transformed[0].clone();
        var newMax = transformed[0].clone();
        
        for (i in 1...transformed.length) {
            newMin = newMin.min(transformed[i]);
            newMax = newMax.max(transformed[i]);
        }
        
        return new BoundingBox(newMin, newMax);
    }
    
    public function toString():String {
        return 'BBox(min: $min, max: $max)';
    }
}

/**
 * Mesh primitive data - vertices and indices
 */
class MeshPrimitive {
    /** Vertex positions */
    public var positions:Array<Vec3>;
    
    /** Vertex normals (optional) */
    public var normals:Array<Vec3>;
    
    /** Vertex UV coordinates (optional) */
    public var uvs:Array<Vec2>;
    
    /** Vertex colors (optional) */
    public var colors:Array<Vec4>;
    
    /** Triangle indices (optional, auto-generated if not provided) */
    public var indices:Array<Int>;
    
    /** Index format */
    public var indexFormat:IndexFormat;
    
    /** Primitive topology */
    public var topology:PrimitiveTopology;
    
    public function new(topology:PrimitiveTopology = TriangleList) {
        this.positions = [];
        this.normals = [];
        this.uvs = [];
        this.colors = [];
        this.indices = [];
        this.indexFormat = Uint32;
        this.topology = topology;
    }
    
    public inline function vertexCount():Int return positions.length;
    
    public function computeIndicesFromPositions():Void {
        // This would compute indices from duplicate position vertices
        // Simple implementation for now
    }
    
    public function computeNormals():Void {
        normals = [];
        for (i in 0...positions.length) {
            normals.push(Vec3.ZERO);
        }
        
        // Accumulate face normals
        var i = 0;
        while (i < indices.length) {
            var i0 = indices[i];
            var i1 = indices[i + 1];
            var i2 = indices[i + 2];
            
            var v0 = positions[i0];
            var v1 = positions[i1];
            var v2 = positions[i2];
            
            var edge1 = v1 - v0;
            var edge2 = v2 - v0;
            var normal = edge1.cross(edge2).normalize();
            
            normals[i0] = normals[i0] + normal;
            normals[i1] = normals[i1] + normal;
            normals[i2] = normals[i2] + normal;
            
            i += 3;
        }
        
        // Normalize
        for (n in normals) {
            n.normalize();
        }
    }
}

/**
 * Mesh represents the geometry used for rendering.
 * 
 * Contains vertex buffers, index buffers, and associated metadata.
 * A Mesh can be shared across multiple entities.
 */
class Mesh implements Component {
    public var id:Int;
    
    /** Vertex buffer layout */
    public var layout:VertexBufferLayout;
    
    /** Raw vertex data (flattened floats) */
    public var vertexData:Array<Float>;
    
    /** Index data */
    public var indexData:Array<Int>;
    
    /** Index format */
    public var indexFormat:IndexFormat;
    
    /** Primitive topology */
    public var primitive:PrimitiveTopology;
    
    /** Bounding box for culling */
    public var aabb:BoundingBox;
    
    /** Morph targets (for skeletal animation) */
    public var morphTargets:Array<MorphTarget>;
    
    /** Vertex count */
    public var vertexCount(get, never):Int;
    
    /** Index count */
    public var indexCount(get, never):Int;
    
    public var componentTypeId(get, never):Int;
    private static var _typeId:Int = -1;
    private static function get_componentTypeId():Int {
        if (_typeId < 0) _typeId = haxe.ecs.ComponentType.get(Mesh);
        return _typeId;
    }
    
    public function new(?layout:VertexBufferLayout) {
        this.layout = layout != null ? layout : Mesh.defaultLayout();
        this.vertexData = [];
        this.indexData = [];
        this.indexFormat = Uint32;
        this.primitive = TriangleList;
        this.aabb = new BoundingBox();
        this.morphTargets = [];
        this.id = -1;
    }
    
    private inline function get_vertexCount():Int return Std.int(vertexData.length / (layout.getTotalSize() >> 2));
    private inline function get_indexCount():Int return indexData.length;
    
    /**
     * Create a default vertex buffer layout for a standard mesh
     */
    public static function defaultLayout():VertexBufferLayout {
        var layout = new VertexBufferLayout(48); // 12 bytes pos + 12 bytes normal + 8 bytes uv + 16 bytes color
        layout.addAttribute("position", Float32x3, 0);
        layout.addAttribute("normal", Float32x3, 1);
        layout.addAttribute("uv", Float32x2, 2);
        layout.addAttribute("color", Float32x4, 3);
        return layout;
    }
    
    /**
     * Set vertex positions
     */
    public function setPositions(positions:Array<Vec3>):Void {
        vertexData = [];
        for (pos in positions) {
            vertexData.push(pos.x, pos.y, pos.z);
        }
        computeAabb();
    }
    
    /**
     * Get vertex positions
     */
    public function getPositions():Array<Vec3> {
        var result = [];
        for (i in 0...Std.int(vertexData.length / 3)) {
            result.push(new Vec3(vertexData[i * 3], vertexData[i * 3 + 1], vertexData[i * 3 + 2]));
        }
        return result;
    }
    
    /**
     * Set indices for indexed drawing
     */
    public function setIndices(indices:Array<Int>):Void {
        indexData = indices;
    }
    
    /**
     * Compute bounding box from vertex positions
     */
    public function computeAabb():Void {
        if (vertexData.length < 3) {
            aabb = new BoundingBox();
            return;
        }
        
        var min = new Vec3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
        var max = new Vec3(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);
        
        for (i in 0...Std.int(vertexData.length / 3)) {
            var x = vertexData[i * 3];
            var y = vertexData[i * 3 + 1];
            var z = vertexData[i * 3 + 2];
            
            min.x = Math.min(min.x, x);
            min.y = Math.min(min.y, y);
            min.z = Math.min(min.z, z);
            max.x = Math.max(max.x, x);
            max.y = Math.max(max.y, y);
            max.z = Math.max(max.z, z);
        }
        
        aabb = new BoundingBox(min, max);
    }
    
    /**
     * Create a quad mesh (two triangles)
     */
    public static function quad():Mesh {
        var mesh = new Mesh();
        
        // Vertices: position (3) + normal (3) + uv (2) = 8 floats per vertex
        var verts:Array<Float> = [
            // Position      // Normal   // UV
            -0.5, -0.5, 0,   0, 0, 1,    0, 0,  // Bottom left
             0.5, -0.5, 0,   0, 0, 1,    1, 0,  // Bottom right
             0.5,  0.5, 0,   0, 0, 1,    1, 1,  // Top right
            -0.5,  0.5, 0,   0, 0, 1,    0, 1,  // Top left
        ];
        
        mesh.vertexData = verts;
        mesh.indexData = [0, 1, 2, 0, 2, 3];
        
        // Custom layout for this mesh
        mesh.layout = new VertexBufferLayout(32); // 8 floats * 4 bytes
        mesh.layout.addAttribute("position", Float32x3, 0);
        mesh.layout.addAttribute("normal", Float32x3, 1);
        mesh.layout.addAttribute("uv", Float32x2, 2);
        
        mesh.computeAabb();
        return mesh;
    }
    
    /**
     * Create a cube mesh
     */
    public static function cube():Mesh {
        var mesh = new Mesh();
        
        // Simple cube vertices with normals
        var verts:Array<Float> = [];
        var indices:Array<Int> = [];
        
        // Each face has 4 vertices
        var faceNormals:Array<Vec3> = [
            Vec3.X, -Vec3.X,
            Vec3.Y, -Vec3.Y,
            Vec3.Z, -Vec3.Z
        ];
        
        var vertexIndex = 0;
        
        // Generate all 6 faces
        for (f in 0...6) {
            var n = faceNormals[f];
            
            // Generate face vertices based on normal
            var corners = Mesh.getCubeFaceCorners(f);
            
            for (corner in corners) {
                verts.push(corner.x, corner.y, corner.z);
                verts.push(n.x, n.y, n.z);
                verts.push(corner.u, corner.v); // UV
            }
            
            // Two triangles per face
            indices.push(vertexIndex, vertexIndex + 1, vertexIndex + 2);
            indices.push(vertexIndex, vertexIndex + 2, vertexIndex + 3);
            vertexIndex += 4;
        }
        
        mesh.vertexData = verts;
        mesh.indexData = indices;
        
        mesh.layout = new VertexBufferLayout(32);
        mesh.layout.addAttribute("position", Float32x3, 0);
        mesh.layout.addAttribute("normal", Float32x3, 1);
        mesh.layout.addAttribute("uv", Float32x2, 2);
        
        mesh.computeAabb();
        return mesh;
    }
    
    private static function getCubeFaceCorners(face:Int):Array<{x:Float, y:Float, z:Float, u:Float, v:Float}> {
        var h = 0.5;
        var corners:Array<{x:Float, y:Float, z:Float, u:Float, v:Float}> = [];
        
        switch (face) {
            case 0: // +X
                corners = [
                    {x: h, y: -h, z: h, u: 0, v: 0},
                    {x: h, y: -h, z: -h, u: 1, v: 0},
                    {x: h, y: h, z: -h, u: 1, v: 1},
                    {x: h, y: h, z: h, u: 0, v: 1}
                ];
            case 1: // -X
                corners = [
                    {x: -h, y: -h, z: -h, u: 0, v: 0},
                    {x: -h, y: -h, z: h, u: 1, v: 0},
                    {x: -h, y: h, z: h, u: 1, v: 1},
                    {x: -h, y: h, z: -h, u: 0, v: 1}
                ];
            case 2: // +Y
                corners = [
                    {x: -h, y: h, z: h, u: 0, v: 0},
                    {x: h, y: h, z: h, u: 1, v: 0},
                    {x: h, y: h, z: -h, u: 1, v: 1},
                    {x: -h, y: h, z: -h, u: 0, v: 1}
                ];
            case 3: // -Y
                corners = [
                    {x: -h, y: -h, z: -h, u: 0, v: 0},
                    {x: h, y: -h, z: -h, u: 1, v: 0},
                    {x: h, y: -h, z: h, u: 1, v: 1},
                    {x: -h, y: -h, z: h, u: 0, v: 1}
                ];
            case 4: // +Z
                corners = [
                    {x: -h, y: -h, z: h, u: 0, v: 0},
                    {x: h, y: -h, z: h, u: 1, v: 0},
                    {x: h, y: h, z: h, u: 1, v: 1},
                    {x: -h, y: h, z: h, u: 0, v: 1}
                ];
            case 5: // -Z
                corners = [
                    {x: h, y: -h, z: -h, u: 0, v: 0},
                    {x: -h, y: -h, z: -h, u: 1, v: 0},
                    {x: -h, y: h, z: -h, u: 1, v: 1},
                    {x: h, y: h, z: -h, u: 0, v: 1}
                ];
        }
        
        return corners;
    }
    
    /**
     * Create a sphere mesh
     */
    public static function sphere(latitudeBands:Int = 16, longitudeBands:Int = 16):Mesh {
        var mesh = new Mesh();
        var verts:Array<Float> = [];
        var indices:Array<Int> = [];
        
        for (lat in 0...latitudeBands + 1) {
            var theta = lat * Math.PI / latitudeBands;
            var sinTheta = Math.sin(theta);
            var cosTheta = Math.cos(theta);
            
            for (lon in 0...longitudeBands + 1) {
                var phi = lon * 2 * Math.PI / longitudeBands;
                var sinPhi = Math.sin(phi);
                var cosPhi = Math.cos(phi);
                
                var x = cosPhi * sinTheta;
                var y = cosTheta;
                var z = sinPhi * sinTheta;
                
                // Position
                verts.push(x * 0.5, y * 0.5, z * 0.5);
                // Normal (same as position for unit sphere)
                verts.push(x, y, z);
                // UV
                verts.push(lon / longitudeBands, lat / latitudeBands);
            }
        }
        
        for (lat in 0...latitudeBands) {
            for (lon in 0...longitudeBands) {
                var first = lat * (longitudeBands + 1) + lon;
                var second = first + longitudeBands + 1;
                
                indices.push(first);
                indices.push(second);
                indices.push(first + 1);
                
                indices.push(second);
                indices.push(second + 1);
                indices.push(first + 1);
            }
        }
        
        mesh.vertexData = verts;
        mesh.indexData = indices;
        
        mesh.layout = new VertexBufferLayout(32);
        mesh.layout.addAttribute("position", Float32x3, 0);
        mesh.layout.addAttribute("normal", Float32x3, 1);
        mesh.layout.addAttribute("uv", Float32x2, 2);
        
        mesh.computeAabb();
        return mesh;
    }
    
    /**
     * Create a plane mesh
     */
    public static function plane(width:Float = 1.0, height:Float = 1.0):Mesh {
        var mesh = new Mesh();
        var w = width / 2;
        var h = height / 2;
        
        // Vertices: position + normal + UV
        mesh.vertexData = [
            -w, 0, -h,  0, 1, 0,  0, 0,
             w, 0, -h,  0, 1, 0,  1, 0,
             w, 0,  h,  0, 1, 0,  1, 1,
            -w, 0,  h,  0, 1, 0,  0, 1,
        ];
        
        mesh.indexData = [0, 1, 2, 0, 2, 3];
        
        mesh.layout = new VertexBufferLayout(32);
        mesh.layout.addAttribute("position", Float32x3, 0);
        mesh.layout.addAttribute("normal", Float32x3, 1);
        mesh.layout.addAttribute("uv", Float32x2, 2);
        
        mesh.computeAabb();
        return mesh;
    }
    
    public function toString():String {
        return 'Mesh(vertices: $vertexCount, indices: $indexCount, aabb: $aabb)';
    }
}

/**
 * Morph target for vertex animation
 */
class MorphTarget {
    public var name:String;
    public var positions:Array<Vec3>;
    public var normals:Array<Vec3>;
    
    public function new(name:String = "") {
        this.name = name;
        this.positions = [];
        this.normals = [];
    }
}
