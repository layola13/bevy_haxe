package bevy.app;

class AppExit {
    public var code(default, null):Int;

    public function new(?code:Int) {
        this.code = code != null ? code : 0;
    }
}
