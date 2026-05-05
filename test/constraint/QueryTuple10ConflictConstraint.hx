package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple10;

class QueryTuple10ConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTuple10ConflictConstraint");
    }

    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple10<Tuple10Position, Tuple10Velocity, Tuple10Health, Tuple10Armor, Tuple10StatA, Tuple10StatB, Tuple10StatC, Tuple10StatD, Tuple10StatE, Tuple10Tag>>, single:Query<Tuple10Position>):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            total += item.component._0.value + item.component._1.value + item.component._2.value + item.component._3.value + item.component._4.value + item.component._5.value + item.component._6.value + item.component._7.value + item.component._8.value + item.component._9.value;
        }
        for (item in single.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable query conflict probe";
        }
    }
}

class Tuple10Position implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple10Velocity implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple10Health implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple10Armor implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple10StatA implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple10StatB implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple10StatC implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple10StatD implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple10StatE implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple10Tag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
