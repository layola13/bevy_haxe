package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple4;

class QueryTuple4ConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTuple4ConflictConstraint");
    }

    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple4<Tuple4Position, Tuple4Velocity, Tuple4Health, Tuple4Tag>>, single:Query<Tuple4Position>):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            total += item.component._0.value + item.component._1.value + item.component._2.value + item.component._3.value;
        }
        for (item in single.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable query conflict probe";
        }
    }
}

class Tuple4Position implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple4Velocity implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple4Health implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple4Tag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
