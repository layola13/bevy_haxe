package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query.Query3;
import bevy.ecs.Ref;

class QueryTripleRefDuplicateConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTripleRefDuplicateConstraint");
    }

    @:system("Update")
    public static function illegal(triple:Query3<Ref<TripleRefDuplicateHealth>, TripleRefDuplicateHealth, TripleRefDuplicateSpeed>):Void {
        var total = 0;
        for (item in triple.iter()) {
            total += item.a.value.value + item.b.value + item.c.value;
        }
        if (total == -1) {
            throw "unreachable";
        }
    }
}

class TripleRefDuplicateHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TripleRefDuplicateSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
