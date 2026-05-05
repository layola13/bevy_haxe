package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Added;
import bevy.ecs.All;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleGenericAddedCompositeDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTupleGenericAddedCompositeDisjointConstraint", function(app) {
            app.world.spawn([new TupleGenericAddedCompositeDisjointHealth(2), new TupleGenericAddedCompositeDisjointSpeed(5), new TupleGenericAddedCompositeDisjointPlayerTag(100)]);
            app.world.spawn([new TupleGenericAddedCompositeDisjointHealth(11), new TupleGenericAddedCompositeDisjointSpeed(13), new TupleGenericAddedCompositeDisjointEnemyTag(200)]);
        }, 18);
    }

    @:system("Update")
    public static function legal(
        tupleQuery:Query<Tuple<TupleGenericAddedCompositeDisjointHealth, TupleGenericAddedCompositeDisjointSpeed>, All<With<TupleGenericAddedCompositeDisjointPlayerTag>, Without<TupleGenericAddedCompositeDisjointEnemyTag>>>,
        added:Query<TupleGenericAddedCompositeDisjointHealth, All<Added<TupleGenericAddedCompositeDisjointHealth>, With<TupleGenericAddedCompositeDisjointEnemyTag>>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            total += item.component._0.value + item.component._1.value;
        }
        for (item in added.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class TupleGenericAddedCompositeDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleGenericAddedCompositeDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleGenericAddedCompositeDisjointPlayerTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}

class TupleGenericAddedCompositeDisjointEnemyTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}
