package bevy.ecs;

import bevy.ecs.QueryFilter.QueryFilterNode;

class Or<A:QueryFilter, B:QueryFilter = bevy.ecs.QueryFilter, C:QueryFilter = bevy.ecs.QueryFilter, D:QueryFilter = bevy.ecs.QueryFilter> implements QueryFilter {
    public var filters(default, null):Array<QueryFilter>;

    public function new(filters:Array<QueryFilter>) {
        if (filters == null || filters.length == 0) {
            throw "Or filter requires at least one child filter";
        }
        this.filters = filters.copy();
    }

    public static function of(filters:Array<QueryFilter>):Or<QueryFilter> {
        return new Or<QueryFilter>(filters);
    }

    public function node():QueryFilterNode {
        var children:Array<QueryFilterNode> = [];
        for (filter in filters) {
            children.push(filter.node());
        }
        return AnyOf(children);
    }
}
