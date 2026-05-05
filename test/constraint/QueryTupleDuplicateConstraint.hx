package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple2;

class QueryTupleDuplicateConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(query:Query<Tuple2<TupleDupPosition, TupleDupPosition>>):Void {
        query.toArray();
    }
}

class TupleDupPosition implements Component {
    public function new() {}
}
