package constraint;

import bevy.app.SystemClass;
import bevy.ecs.All;
import bevy.ecs.Changed;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleChangedCompositeDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTupleChangedCompositeDisjointConstraint", function(app) {
            app.world.spawn([new TupleChangedCompositeDisjointHealth(2), new TupleChangedCompositeDisjointSpeed(5), new TupleChangedCompositeDisjointPlayerTag(100)]);
            app.world.spawn([new TupleChangedCompositeDisjointHealth(11), new TupleChangedCompositeDisjointSpeed(13), new TupleChangedCompositeDisjointEnemyTag(200)]);
        }, 18);
    }

    @:system("Update")
    public static function legal(
        tupleQuery:Query<Tuple2<TupleChangedCompositeDisjointHealth, TupleChangedCompositeDisjointSpeed>, All<With<TupleChangedCompositeDisjointPlayerTag>, Without<TupleChangedCompositeDisjointEnemyTag>>>,
        changed:Query<TupleChangedCompositeDisjointHealth, All<Changed<TupleChangedCompositeDisjointHealth>, With<TupleChangedCompositeDisjointEnemyTag>>>,
        counter:ResMut<ConstraintCounter>
    ):Void {
        var total = 0;
        for (item in tupleQuery.iter()) {
            total += item.component._0.value + item.component._1.value;
        }
        for (item in changed.iter()) {
            total += item.component.value;
        }
        counter.value.record(total);
    }
}

class TupleChangedCompositeDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleChangedCompositeDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleChangedCompositeDisjointPlayerTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}

class TupleChangedCompositeDisjointEnemyTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}
