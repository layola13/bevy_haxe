package bevy.ecs;

enum QueryFilterKind {
    Require;
    Exclude;
    AddedSince(sinceTick:Int);
    ChangedSince(sinceTick:Int);
}

enum QueryFilterNode {
    Single(spec:QueryFilterSpec);
    AllOf(children:Array<QueryFilterNode>);
    AnyOf(children:Array<QueryFilterNode>);
}

typedef QueryFilterSpec = {
    var typeKey:String;
    var kind:QueryFilterKind;
}

interface QueryFilter {
    function node():QueryFilterNode;
}

class QueryFilterTools {
    public static function resolveTypeKey<T>(cls:Class<T>, ?componentKey:String):String {
        if (componentKey != null && componentKey != "") {
            return TypeKey.named(componentKey);
        }
        return TypeKey.ofClass(cls);
    }
}
