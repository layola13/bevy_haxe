package bevy.ecs;

class Mut<T> extends Ref<T> {
    private var changeMarker:Void->Void;

    public function new(value:T, addedTick:Int, changedTick:Int, lastRunTick:Int, thisRunTick:Int, changeMarker:Void->Void) {
        super(value, addedTick, changedTick, lastRunTick, thisRunTick);
        this.changeMarker = changeMarker;
    }

    public function setChanged():Void {
        if (changeMarker != null) {
            changeMarker();
        }
        setChangedTickForMut(thisRunTickForMut());
    }
}
