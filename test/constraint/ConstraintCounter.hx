package constraint;

import bevy.ecs.Resource;

class ConstraintCounter implements Resource {
    public var total:Int;
    public var writes:Int;

    public function new() {
        total = 0;
        writes = 0;
    }

    public function record(value:Int):Void {
        total += value;
        writes++;
    }
}
