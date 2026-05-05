package bevy.ecs;

import bevy.ecs.QueryFilter.QueryFilterKind;
import bevy.ecs.QueryFilter.QueryFilterNode;
import bevy.ecs.QueryFilter.QueryFilterSpec;

class Spawned implements QueryFilter {
    public var sinceTick(default, null):Int;

    public function new(?sinceTick:Int) {
        this.sinceTick = sinceTick != null ? sinceTick : 0;
    }

    public static function of(sinceTick:Int):Spawned {
        return new Spawned(sinceTick);
    }

    public function node():QueryFilterNode {
        var spec:QueryFilterSpec = {
            typeKey: "",
            kind: SpawnedSince(sinceTick)
        };
        return Single(spec);
    }
}
