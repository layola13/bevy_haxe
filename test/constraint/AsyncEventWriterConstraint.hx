package constraint;

import bevy.app.SystemClass;
import bevy.async.AsyncClass;
import bevy.ecs.Event;
import bevy.ecs.Events.EventWriter;

class AsyncEventWriterConstraint implements SystemClass implements AsyncClass {
    @:async
    @:system("Update")
    public static function illegal(writer:EventWriter<ConstraintEvent>):Void {
        writer.send(new ConstraintEvent());
    }
}

class ConstraintEvent implements Event {
    public function new() {}
}
