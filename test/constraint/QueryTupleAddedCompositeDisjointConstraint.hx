package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Added;
import bevy.ecs.All;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleAddedCompositeDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTupleAddedCompositeDisjointConstraint", function(app) {
            app.world.spawn([new TupleAddedCompositeDisjointHealth(2), new TupleAddedCompositeDisjointSpeed(5), new TupleAddedCompositeDisjointPlayerTag(100)]);
            app.world.spawn([new TupleAddedCompositeDisjointHealth(11), new TupleAddedCompositeDisjointSpeed(13), new TupleAddedCompositeDisjointEnemyTag(200)]);
        }, 18);
    }

    @:system("Update")
    public static function legal(
        tupleQuery:Query<Tuple2<TupleAddedCompositeDisjointHealth, TupleAddedCompositeDisjointSpeed>, All<With<TupleAddedCompositeDisjointPlayerTag>, Without<TupleAddedCompositeDisjointEnemyTag>>>,
        added:Query<TupleAddedCompositeDisjointHealth, All<Added<TupleAddedCompositeDisjointHealth>, With<TupleAddedCompositeDisjointEnemyTag>>>,
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

class TupleAddedCompositeDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleAddedCompositeDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleAddedCompositeDisjointPlayerTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}

class TupleAddedCompositeDisjointEnemyTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}
