package constraint;

import bevy.app.SystemClass;
import bevy.ecs.All;
import bevy.ecs.Changed;
import bevy.ecs.Component;
import bevy.ecs.Entity;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleGenericEntityChangedDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTupleGenericEntityChangedDisjointConstraint", function(app) {
            app.world.spawn([new TupleGenericEntityChangedDisjointHealth(2), new TupleGenericEntityChangedDisjointSpeed(3), new TupleGenericEntityChangedDisjointTag(100)]);
            app.world.spawn([new TupleGenericEntityChangedDisjointHealth(11), new TupleGenericEntityChangedDisjointSpeed(13)]);
        }, 16);
    }

    @:system("Update")
    public static function legal(
        tupleQuery:Query<Tuple<Entity, TupleGenericEntityChangedDisjointHealth, TupleGenericEntityChangedDisjointSpeed>, With<TupleGenericEntityChangedDisjointTag>>,
        changed:Query<TupleGenericEntityChangedDisjointHealth, All<Changed<TupleGenericEntityChangedDisjointHealth>, Without<TupleGenericEntityChangedDisjointTag>>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            if (!item.entity.equals(item.component._0)) {
                throw "Query<Tuple<Entity, A, B>> returned mismatched Entity data";
            }
            total += item.component._1.value + item.component._2.value;
        }
        for (item in changed.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class TupleGenericEntityChangedDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleGenericEntityChangedDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleGenericEntityChangedDisjointTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}
