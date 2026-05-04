package bevy.render;

class TriangleMesh {
    public var positions:Array<Float>;

    public function new(positions:Array<Float>) {
        this.positions = positions;
    }

    public static function triangle():TriangleMesh {
        return new TriangleMesh([
            0.0, 0.6, 0.0,
            -0.6, -0.6, 0.0,
            0.6, -0.6, 0.0
        ]);
    }
}
