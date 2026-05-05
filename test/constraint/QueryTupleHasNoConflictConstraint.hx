package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Has;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple;

class QueryTupleHasNoConflictConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTupleHasNoConflictConstraint", function(app) {
            app.world.spawn([new TupleHasHealth(5), new TupleHasTag(50)]);
            app.world.spawn([new TupleHasHealth(7)]);
        }, 172);
    }

    @:system("Update")
    public static function legal(tupleQuery:Query<Tuple<TupleHasHealth, Has<TupleHasTag>>>, tags:Query<TupleHasTag>, counter:ResMut<ConstraintCounter>):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            total += item.component._0.value;
            total += item.component._1.isPresent() ? 100 : 10;
        }
        for (item in tags.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class TupleHasHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleHasTag implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}
