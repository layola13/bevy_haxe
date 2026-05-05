package bevy.ecs;

import bevy.ecs.QueryFilter.QueryFilterKind;
import bevy.ecs.QueryFilter.QueryFilterNode;
import bevy.ecs.QueryFilter.QueryFilterSpec;
import bevy.ecs.QueryFilter.QueryFilterTools;

class Added<T> implements QueryFilter {
    public var typeKey(default, null):String;
    public var sinceTick(default, null):Int;

    public function new(cls:Class<T>, sinceTick:Int, ?componentKey:String) {
        this.sinceTick = sinceTick;
        typeKey = QueryFilterTools.resolveTypeKey(cls, componentKey);
    }

    public static function of<T>(cls:Class<T>, sinceTick:Int, ?componentKey:String):Added<T> {
        return new Added<T>(cls, sinceTick, componentKey);
    }

    public function node():QueryFilterNode {
        var spec:QueryFilterSpec = {
            typeKey: typeKey,
            kind: AddedSince(sinceTick)
        };
        return Single(spec);
    }
}
