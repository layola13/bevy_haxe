package bevy.ecs;

class SpawnDetails {
    private var spawnedAtTick:Int;
    private var lastRunTick:Int;
    private var thisRunTick:Int;
    private var spawnedByValue:Null<String>;

    public function new(spawnTick:Int, lastRunTick:Int, thisRunTick:Int, ?spawnedBy:String) {
        this.spawnedAtTick = spawnTick;
        this.lastRunTick = lastRunTick;
        this.thisRunTick = thisRunTick;
        this.spawnedByValue = spawnedBy;
    }

    public function isSpawned():Bool {
        return isSpawnedAfter(lastRunTick);
    }

    public function isSpawnedAfter(otherTick:Int):Bool {
        return spawnedAtTick > otherTick && spawnedAtTick <= thisRunTick;
    }

    public function spawnTick():Int {
        return spawnedAtTick;
    }

    public function spawnedBy():Null<String> {
        return spawnedByValue;
    }
}
