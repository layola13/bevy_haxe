package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Changed;
import bevy.ecs.Component;
import bevy.ecs.Query;

class QueryChangedConflictConstraint implements SystemClass {
    @:system("Update")
    public static function illegal(data:Query<ChangedTracked>, changed:Query<EntityMarker, Changed<ChangedTracked>>):Void {
        data.toArray();
        changed.toArray();
    }
}

class ChangedTracked implements Component {
    public function new() {}
}

class EntityMarker implements Component {
    public function new() {}
}
