package bevy.ecs;

import bevy.ecs.QueryFilter.QueryFilterNode;

class All<A:QueryFilter, B:QueryFilter = bevy.ecs.QueryFilter, C:QueryFilter = bevy.ecs.QueryFilter, D:QueryFilter = bevy.ecs.QueryFilter> implements QueryFilter {
    public var filters(default, null):Array<QueryFilter>;

    public function new(filters:Array<QueryFilter>) {
        this.filters = filters != null ? filters.copy() : [];
    }

    public static function of(filters:Array<QueryFilter>):All<QueryFilter> {
        return new All<QueryFilter>(filters);
    }

    public function node():QueryFilterNode {
        var children:Array<QueryFilterNode> = [];
        for (filter in filters) {
            children.push(filter.node());
        }
        return AllOf(children);
    }
}
