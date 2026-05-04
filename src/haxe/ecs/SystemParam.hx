package haxe.ecs;

/**
 * SystemParam接口 - 可以用作System参数的类型的trait
 * 
 * 所有可以用作系统函数参数的项都必须实现此接口。
 */
interface SystemParam {
    /** 获取此参数的项 */
    function getItem(world:World, changeTick:UInt):Dynamic;
    
    /** 应用延迟操作 */
    function applyDeferred(world:World):Void;
    
    /** 初始化参数状态 */
    function init(world:World):Void;
    
    /** 获取参数状态信息 */
    function getState():Dynamic;
}

/**
 * SystemParamState - 存储SystemParam的运行时状态
 */
class SystemParamState {
    public function new() {}
}

/**
 * 延迟参数接口
 */
interface Deferred {
    function applyDeferred(world:World):Void;
}

/**
 * 资源只读访问
 */
class Res<T> {
    /** 资源指针 */
    public var ptr:Dynamic;
    
    /** 组件ticks */
    public var ticks:ComponentTicks;
    
    /** 上次改变tick */
    public var lastChangeTick:UInt;
    
    /** 当前tick */
    public var changeTick:UInt;
    
    public function new() {}
    
    /**
     * 获取资源值
     */
    public function get():T {
        return ptr;
    }
    
    /**
     * 检查资源是否在本帧更改
     */
    public function isChanged():Bool {
        return ticks.check_changed(lastChangeTick, changeTick);
    }
    
    /**
     * 转换为指针值
     */
    @:to public inline function toT():T return get();
}

/**
 * 资源可变访问
 */
class ResMut<T> {
    /** 资源指针 */
    public var ptr:Dynamic;
    
    /** 组件ticks */
    public var ticks:ComponentTicks;
    
    /** 上次改变tick */
    public var lastChangeTick:UInt;
    
    /** 当前tick */
    public var changeTick:UInt;
    
    public function new() {}
    
    /**
     * 获取资源值
     */
    public function get():T {
        return ptr;
    }
    
    /**
     * 设置资源值
     */
    public function set(value:T):Void {
        ptr = value;
        ticks.set_changed(changeTick);
    }
    
    /**
     * 检查资源是否在本帧更改
     */
    public function isChanged():Bool {
        return ticks.check_changed(lastChangeTick, changeTick);
    }
}

/**
 * 组件ticks信息
 */
class ComponentTicks {
    /** 增加tick */
    public var added:UInt;
    
    /** 更改tick */
    public var changed:UInt;
    
    public function new() {}
    
    public function check_changed(last_run:UInt, current:UInt):Bool {
        return changed > last_run || current.wrapping_sub(changed) < 0x80000000;
    }
    
    public function set_changed(tick:UInt):Void {
        changed = tick;
    }
}

/**
 * Query状态
 */
class QueryState<D:QueryData, F:QueryFilter> {
    public var archetypeId:Int = 0;
    public var matchedArchetypesLength:Int = 0;
    public var archetypeMatchesFilter:Array<Bool> = [];
    public var lastChangeTick:UInt = 0;
    public var changeTick:UInt = 0;
    
    public function new() {}
}

/**
 * Query数据标记接口
 */
interface QueryData {}

/**
 * Query过滤器标记接口
 */
interface QueryFilter {}

/**
 * Query<T> 系统参数 - 提供对World中存储的Component数据的选择性访问
 */
class Query<D:QueryData, F:QueryFilter> implements SystemParam implements Deferred {
    /** Query状态 */
    public var state:QueryState<D, F>;
    
    /** 指向世界的指针 */
    public var world:World;
    
    /** 当前迭代器索引 */
    private var iterIndex:Int = 0;
    
    /** 当前实体列表 */
    private var entities:Array<Entity> = [];
    
    public function new() {}
    
    /**
     * 初始化Query
     */
    public function init(world:World, state:QueryState<D, F>):Void {
        this.world = world;
        this.state = state;
    }
    
    /**
     * 获取所有匹配的实体
     */
    public function getEntities():Array<Entity> {
        return world.query(this);
    }
    
    /**
     * 获取匹配实体的迭代器
     */
    public function iterator():QueryIterator<D, F> {
        return new QueryIterator(this, getEntities());
    }
    
    /**
     * 获取单个实体（如果有多个则抛出错误）
     */
    public function single():D {
        var entities = getEntities();
        if (entities.length != 1) {
            throw 'Query.single() expected exactly 1 result, got ${entities.length}';
        }
        return getComponentData(entities[0]);
    }
    
    /**
     * 获取单个实体或null
     */
    public function singleOrNull():D {
        var entities = getEntities();
        if (entities.length == 0) return null;
        if (entities.length > 1) {
            throw 'Query.singleOrNull() expected 0 or 1 result, got ${entities.length}';
        }
        return getComponentData(entities[0]);
    }
    
    /**
     * 获取实体数量
     */
    public function count():Int {
        return getEntities().length;
    }
    
    /**
     * 获取实体的组件数据
     */
    @:SuppressWarnings("checkcast:Dynamic")
    private function getComponentData(entity:Entity):D {
        return world.getComponent(entity, Type.resolveClass(D));
    }
    
    // SystemParam 实现
    public function getItem(world:World, changeTick:UInt):Dynamic {
        return this;
    }
    
    public function applyDeferred(world:World):Void {
        // Query不需要延迟应用
    }
    
    public function init_param(world:World):Void {
        // Query在首次迭代时构建
    }
    
    public function getState():Dynamic {
        return state;
    }
}

/**
 * Query迭代器
 */
class QueryIterator<D:QueryData, F:QueryFilter> {
    private var query:Query<D, F>;
    private var entities:Array<Entity>;
    private var index:Int = 0;
    
    public function new(query:Query<D, F>, entities:Array<Entity>) {
        this.query = query;
        this.entities = entities;
        this.index = 0;
    }
    
    public function hasNext():Bool {
        return index < entities.length;
    }
    
    @:SuppressWarnings("checkcast:Dynamic")
    public function next():D {
        if (!hasNext()) return null;
        var entity = entities[index++];
        return query.getComponentData(entity);
    }
    
    public function length():Int {
        return entities.length;
    }
}

/**
 * NonSend资源 - 只在主线程可访问的资源
 */
class NonSend<T> {
    public var value:T;
    
    public function new(value:T) {
        this.value = value;
    }
    
    @:to public inline function toT():T return value;
}

/**
 * NonSend可变资源
 */
class NonSendMut<T> {
    public var value:T;
    
    public function new(value:T) {
        this.value = value;
    }
    
    @:to public inline function toT():T return value;
}

/**
 * Local系统参数 - 系统本地的状态
 */
class Local<T> {
    public var value:T;
    
    public function new(?value:T) {
        this.value = value != null ? value : cast Type.createEmptyInstance(T);
    }
    
    @:to public inline function toT():T return value;
}
