package constraint;

import bevy.app.SystemClass;
import bevy.async.AsyncClass;
import bevy.ecs.Event;
import bevy.ecs.Events.EventWriter;

class AsyncEventWriterConstraint implements SystemClass implements AsyncClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("AsyncEventWriterConstraint");
    }

    @:async
    @:system("Update")
    public static function illegal(writer:EventWriter<ConstraintEvent>):Void {
        writer.send(new ConstraintEvent(1));
    }
}

class ConstraintEvent implements Event {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
