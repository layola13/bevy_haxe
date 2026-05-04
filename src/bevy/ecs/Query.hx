package bevy.ecs;

typedef QueryItem<T> = {
    var entity:Entity;
    var component:T;
}

typedef QueryItem2<A, B> = {
    var entity:Entity;
    var a:A;
    var b:B;
}

class Query<T> {
    private var world:World;
    private var componentClass:Class<T>;
    private var withFilters:Array<String>;
    private var withoutFilters:Array<String>;

    public function new(world:World, componentClass:Class<T>) {
        this.world = world;
        this.componentClass = componentClass;
        withFilters = [];
        withoutFilters = [];
    }

    public function with<C>(cls:Class<C>):Query<T> {
        withFilters.push(TypeKey.ofClass(cls));
        return this;
    }

    public function without<C>(cls:Class<C>):Query<T> {
        withoutFilters.push(TypeKey.ofClass(cls));
        return this;
    }

    public function toArray():Array<QueryItem<T>> {
        return world.queryOne(componentClass, withFilters, withoutFilters);
    }
}

class Query2<A, B> {
    private var world:World;
    private var aClass:Class<A>;
    private var bClass:Class<B>;
    private var withFilters:Array<String>;
    private var withoutFilters:Array<String>;

    public function new(world:World, aClass:Class<A>, bClass:Class<B>) {
        this.world = world;
        this.aClass = aClass;
        this.bClass = bClass;
        withFilters = [];
        withoutFilters = [];
    }

    public function with<C>(cls:Class<C>):Query2<A, B> {
        withFilters.push(TypeKey.ofClass(cls));
        return this;
    }

    public function without<C>(cls:Class<C>):Query2<A, B> {
        withoutFilters.push(TypeKey.ofClass(cls));
        return this;
    }

    public function toArray():Array<QueryItem2<A, B>> {
        return world.queryTwo(aClass, bClass, withFilters, withoutFilters);
    }
}
