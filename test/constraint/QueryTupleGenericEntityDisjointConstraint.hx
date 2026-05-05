package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Entity;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleGenericEntityDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTupleGenericEntityDisjointConstraint", function(app) {
            app.world.spawn([new TupleGenericEntityDisjointHealth(5), new TupleGenericEntityDisjointTag(100)]);
            app.world.spawn([new TupleGenericEntityDisjointHealth(11)]);
        }, 16);
    }

    @:system("Update")
    public static function legal(
        tupleQuery:Query<Tuple<Entity, TupleGenericEntityDisjointHealth>, With<TupleGenericEntityDisjointTag>>,
        single:Query<TupleGenericEntityDisjointHealth, Without<TupleGenericEntityDisjointTag>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            if (!item.entity.equals(item.component._0)) {
                throw "Query<Tuple<Entity, T>> returned mismatched Entity data";
            }
            total += item.component._1.value;
        }
        for (item in single.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class TupleGenericEntityDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleGenericEntityDisjointTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}
