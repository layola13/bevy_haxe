package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple6;

class QueryTuple6ConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTuple6ConflictConstraint");
    }

    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple6<Tuple6Position, Tuple6Velocity, Tuple6Health, Tuple6Armor, Tuple6StatA, Tuple6Tag>>, single:Query<Tuple6Position>):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            total += item.component._0.value + item.component._1.value + item.component._2.value + item.component._3.value + item.component._4.value + item.component._5.value;
        }
        for (item in single.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable query conflict probe";
        }
    }
}

class Tuple6Position implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple6Velocity implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple6Health implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple6Armor implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple6StatA implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple6Tag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
