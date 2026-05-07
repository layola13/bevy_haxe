package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Mut;
import bevy.ecs.Query.Query3;
import bevy.ecs.Ref;

class QueryTripleRefMutDuplicateConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTripleRefMutDuplicateConstraint");
    }

    @:system("Update")
    public static function illegal(triple:Query3<Ref<TripleRefMutDuplicateHealth>, Mut<TripleRefMutDuplicateHealth>, TripleRefMutDuplicateSpeed>):Void {
        var total = 0;
        for (item in triple.iter()) {
            item.b.setChanged();
            total += item.a.value.value + item.b.value.value + item.c.value;
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class TripleRefMutDuplicateHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleRefMutDuplicateSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
