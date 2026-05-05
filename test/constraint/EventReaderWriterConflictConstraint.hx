package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Event;
import bevy.ecs.Events.EventReader;
import bevy.ecs.Events.EventWriter;

class EventReaderWriterConflictConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(reader:EventReader<ConstraintSignal>, writer:EventWriter<ConstraintSignal>):Void {
        reader.read();
        writer.send(new ConstraintSignal());
    }
}

class ConstraintSignal implements Event {
    public function new() {}
}
