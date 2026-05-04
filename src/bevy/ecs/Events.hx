package bevy.ecs;

class Events<T> {
    private var values:Array<T>;
    private var startEventCount:Int;

    public function new() {
        values = [];
        startEventCount = 0;
    }

    public function send(value:T):Void {
        values.push(value);
    }

    public function reader():EventReader<T> {
        return new EventReader<T>(this, startEventCount);
    }

    public function len():Int {
        return values.length;
    }

    public function clear():Void {
        startEventCount += values.length;
        values = [];
    }

    public function readFrom(cursor:Int):Array<T> {
        var local = cursor - startEventCount;
        if (local < 0) {
            local = 0;
        }
        if (local > values.length) {
            local = values.length;
        }
        return values.slice(local);
    }

    public function currentCursor():Int {
        return startEventCount + values.length;
    }
}

class EventReader<T> {
    private var events:Events<T>;
    private var cursor:Int;

    public function new(events:Events<T>, cursor:Int = 0) {
        this.events = events;
        this.cursor = cursor;
    }

    public function read():Array<T> {
        var result = events.readFrom(cursor);
        cursor = events.currentCursor();
        return result;
    }
}

class EventWriter<T> {
    private var events:Events<T>;

    public function new(events:Events<T>) {
        this.events = events;
    }

    public function send(value:T):Void {
        events.send(value);
    }
}
