package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Mut;
import bevy.ecs.Query.Query3;

class QueryTripleMutDuplicateConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTripleMutDuplicateConstraint");
    }

    @:system("Update")
    public static function illegal(triple:Query3<Mut<TripleMutDuplicateHealth>, TripleMutDuplicateHealth, TripleMutDuplicateSpeed>):Void {
        var total = 0;
        for (item in triple.iter()) {
            item.a.setChanged();
            total += item.a.value.value + item.b.value + item.c.value;
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class TripleMutDuplicateHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleMutDuplicateSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
