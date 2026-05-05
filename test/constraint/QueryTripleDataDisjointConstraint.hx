package constraint;

import bevy.app.SystemClass;
import bevy.ecs.Component;
import bevy.ecs.Query;
import bevy.ecs.Query.Query3;
import bevy.ecs.Without;

class QueryTripleDataDisjointConstraint implements SystemClass {
    public static function main():Void {}

    @:system("Update")
    public static function legal(tripleQuery:Query3<TripleDataHealth, TripleDataTag, TripleDataSpeed>, single:Query<TripleDataHealth, Without<TripleDataTag>>):Void {
        tripleQuery.toArray();
        single.toArray();
    }
}

class TripleDataHealth implements Component {
    public function new() {}
}

class TripleDataTag implements Component {
    public function new() {}
}

class TripleDataSpeed implements Component {
    public function new() {}
}
