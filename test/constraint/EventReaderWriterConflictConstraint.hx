package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Event;
import bevy.ecs.Events.EventReader;
import bevy.ecs.Events.EventWriter;

class EventReaderWriterConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("EventReaderWriterConflictConstraint");
    }

    @:system("Update")
    public static function illegal(reader:EventReader<ConstraintSignal>, writer:EventWriter<ConstraintSignal>):Void {
        var total = 0;
        for (event in reader.read()) {
            total += event.value;
        }
        writer.send(new ConstraintSignal(total + 1));
    }
}

class ConstraintSignal implements Event {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
