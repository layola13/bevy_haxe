package bevy.ecs;

import bevy.ecs.QueryFilter.QueryFilterKind;
import bevy.ecs.QueryFilter.QueryFilterNode;
import bevy.ecs.QueryFilter.QueryFilterSpec;
import bevy.ecs.QueryFilter.QueryFilterTools;

class Without<T> implements QueryFilter {
    public var typeKey(default, null):String;

    public function new(cls:Class<T>, ?componentKey:String) {
        typeKey = QueryFilterTools.resolveTypeKey(cls, componentKey);
    }

    public static function of<T>(cls:Class<T>, ?componentKey:String):Without<T> {
        return new Without<T>(cls, componentKey);
    }

    public function node():QueryFilterNode {
        var spec:QueryFilterSpec = {
            typeKey: typeKey,
            kind: Exclude
        };
        return Single(spec);
    }
}
