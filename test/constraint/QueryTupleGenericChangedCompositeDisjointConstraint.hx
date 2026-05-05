package constraint;

import bevy.app.SystemClass;
import bevy.ecs.All;
import bevy.ecs.Changed;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.ResMut;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.With;
import bevy.ecs.Without;

class QueryTupleGenericChangedCompositeDisjointConstraint implements SystemClass {
    public static function main():Void {
        ConstraintRuntime.runUpdateWithCounter("QueryTupleGenericChangedCompositeDisjointConstraint", function(app) {
            app.world.spawn([new TupleGenericChangedCompositeDisjointHealth(2), new TupleGenericChangedCompositeDisjointSpeed(5), new TupleGenericChangedCompositeDisjointPlayerTag(100)]);
            app.world.spawn([new TupleGenericChangedCompositeDisjointHealth(11), new TupleGenericChangedCompositeDisjointSpeed(13), new TupleGenericChangedCompositeDisjointEnemyTag(200)]);
        }, 18);
    }

    @:system("Update")
    public static function legal(
        tupleQuery:Query<Tuple<TupleGenericChangedCompositeDisjointHealth, TupleGenericChangedCompositeDisjointSpeed>, All<With<TupleGenericChangedCompositeDisjointPlayerTag>, Without<TupleGenericChangedCompositeDisjointEnemyTag>>>,
        changed:Query<TupleGenericChangedCompositeDisjointHealth, All<Changed<TupleGenericChangedCompositeDisjointHealth>, With<TupleGenericChangedCompositeDisjointEnemyTag>>>,
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

class TupleGenericChangedCompositeDisjointHealth implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleGenericChangedCompositeDisjointSpeed implements Component {
    public var value:Int;

    public function new(value:Int) {
        this.value = value;
    }
}

class TupleGenericChangedCompositeDisjointPlayerTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}

class TupleGenericChangedCompositeDisjointEnemyTag implements Component {
    public var id:Int;

    public function new(id:Int) {
        this.id = id;
    }
}
