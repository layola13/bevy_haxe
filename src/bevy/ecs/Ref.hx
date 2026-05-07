package bevy.ecs;

class Ref<T> {
    public var value(default, null):T;
    private var addedTickValue:Int;
    private var changedTickValue:Int;
    private var lastRunTickValue:Int;
    private var thisRunTickValue:Int;

    public function new(value:T, addedTick:Int, changedTick:Int, lastRunTick:Int, thisRunTick:Int) {
        this.value = value;
        this.addedTickValue = addedTick;
        this.changedTickValue = changedTick;
        this.lastRunTickValue = lastRunTick;
        this.thisRunTickValue = thisRunTick;
    }

    public inline function intoInner():T {
        return value;
    }

    public inline function isAdded():Bool {
        return isAddedAfter(lastRunTickValue);
    }

    public inline function isChanged():Bool {
        return isChangedAfter(lastRunTickValue);
    }

    public inline function isAddedAfter(otherTick:Int):Bool {
        return addedTickValue > otherTick && addedTickValue <= thisRunTickValue;
    }

    public inline function isChangedAfter(otherTick:Int):Bool {
        return changedTickValue > otherTick && changedTickValue <= thisRunTickValue;
    }

    public inline function added():Int {
        return addedTickValue;
    }

    public inline function lastChanged():Int {
        return changedTickValue;
    }

    public inline function lastRunTick():Int {
        return lastRunTickValue;
    }

    public inline function thisRunTick():Int {
        return thisRunTickValue;
    }

    @:allow(bevy.ecs.Mut)
    private inline function setChangedTickForMut(nextChangedTick:Int):Void {
        changedTickValue = nextChangedTick;
    }

    @:allow(bevy.ecs.Mut)
    private inline function thisRunTickForMut():Int {
        return thisRunTickValue;
    }
}
