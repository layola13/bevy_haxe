package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Tuple.Tuple12;

class QueryTuple12ConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdate("QueryTuple12ConflictConstraint");
    }

    @:system("Update")
    public static function illegal(tupleQuery:Query<Tuple12<Tuple12Position, Tuple12Velocity, Tuple12Health, Tuple12Armor, Tuple12StatA, Tuple12StatB, Tuple12StatC, Tuple12StatD, Tuple12StatE, Tuple12StatF, Tuple12StatG, Tuple12Tag>>, single:Query<Tuple12Position>):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            total += item.component._0.value + item.component._1.value + item.component._2.value + item.component._3.value + item.component._4.value + item.component._5.value;
            total += item.component._6.value + item.component._7.value + item.component._8.value + item.component._9.value + item.component._10.value + item.component._11.value;
        }
        for (item in single.iter()) {
            total += item.component.value;
        }
        if (total == -1) {
            throw "unreachable query conflict probe";
        }
    }
}

class Tuple12Position implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple12Velocity implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple12Health implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple12Armor implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple12StatA implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple12StatB implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple12StatC implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple12StatD implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple12StatE implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple12StatF implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple12StatG implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class Tuple12Tag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
