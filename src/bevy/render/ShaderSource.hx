package bevy.render;

class ShaderSource {
    public var vertex:String;
    public var fragment:String;

    public function new(vertex:String, fragment:String) {
        this.vertex = vertex;
        this.fragment = fragment;
    }

    public static function basicColor():ShaderSource {
        return new ShaderSource(
            "attribute vec3 a_position;\nvoid main() {\n  gl_Position = vec4(a_position, 1.0);\n}",
            "precision mediump float;\nvoid main() {\n  gl_FragColor = vec4(1.0, 0.4, 0.2, 1.0);\n}"
        );
    }
}
