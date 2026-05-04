package haxe.ecs;

/**
 * System状态标志位
 */
@:enum abstract SystemStateFlags(Int) {
    var None = 0;
    /** 系统不能跨线程发送 */
    var NonSend = 1 << 0;
    /** 系统需要独占World访问 */
    var Exclusive = 1 << 1;
    /** 系统有延迟缓冲区 */
    var Deferred = 1 << 2;
    
    @:op(a | b) static function or(a:SystemStateFlags, b:SystemStateFlags):SystemStateFlags;
    @:op(a & b) static function and(a:SystemStateFlags, b:SystemStateFlags):SystemStateFlags;
    @:op(~a) static function not(a:SystemStateFlags):SystemStateFlags;
}

/**
 * System接口 - ECS系统中可添加到Schedule的基本单元
 * 
 * Systems是所有参数都实现SystemParam的函数。
 * 系统添加到应用使用 `app.addSystem(Update, mySystem)` 或类似方法，
 * 会在主循环的每个pass中运行一次。
 * 
 * 系统以并行方式执行，以机会主义顺序运行；数据访问自动管理。
 */
interface System {
    /** 系统的输入类型 */
    // type In: SystemInput; // Haxe使用 Void 表示无输入
    
    /** 系统的输出类型 */
    // type Out; // Haxe使用 Dynamic
    
    /** 返回系统名称 */
    function name():String;
    
    /** 返回系统类型ID */
    function systemTypeId():String;
    
    /** 返回系统状态标志 */
    function flags():SystemStateFlags;
    
    /** 检查系统是否Send */
    function isSend():Bool;
    
    /** 检查系统是否必须独占运行 */
    function isExclusive():Bool;
    
    /** 检查系统是否有延迟缓冲区 */
    function hasDeferred():Bool;
    
    /**
     * 在世界中运行系统
     * 与runUnsafe不同，这会立即应用延迟参数
     */
    function run(world:World):Dynamic;
    
    /**
     * 在世界中运行系统，但不应用延迟参数
     * 延迟参数需要稍后通过applyDeferred独立应用
     */
    function runWithoutApplyingDeferred(world:World):Dynamic;
    
    /**
     * 将此系统的任何延迟参数应用到世界
     * 这里Commands会被应用
     */
    function applyDeferred(world:World):Void;
    
    /**
     * 将此系统的延迟参数入队到世界的命令缓冲区
     */
    function queueDeferred(world:DeferredWorld):Void;
    
    /**
     * 初始化系统
     * 返回访问系统所需的数据
     */
    function initialize(world:World):FilteredAccess;
    
    /**
     * 检查存储在此系统上的Tick并在太旧时包装其值
     */
    function checkChangeTick(tick:UInt):Void;
    
    /** 获取上次运行系统的时间tick */
    function getLastRun():UInt;
    
    /** 设置上次运行系统的时间tick */
    function setLastRun(tick:UInt):Void;
}

/**
 * 只读系统接口 - 不修改World的系统
 */
interface ReadOnlySystem extends System {
    // 只读系统不修改世界
}

/**
 * 延迟世界访问接口
 * 用于在系统之间传递延迟访问
 */
interface DeferredWorld {
    /** 队列延迟命令 */
    function queue(command:Command):Void;
}

/**
 * 访问过滤数据
 */
class FilteredAccess {
    public var read:Array<String> = [];
    public var write:Array<String> = [];
    public var archetypeAccess:Array<String> = [];
    
    public function new() {}
    
    public function addRead(id:String):Void {
        if (!read.contains(id)) read.push(id);
    }
    
    public function addWrite(id:String):Void {
        if (!write.contains(id)) write.push(id);
    }
    
    public function hasRead(id:String):Bool {
        return read.contains(id);
    }
    
    public function hasWrite(id:String):Bool {
        return write.contains(id);
    }
    
    public function conflicts(other:FilteredAccess):Bool {
        for (w in write) {
            if (other.hasWrite(w) || other.hasRead(w)) return true;
        }
        return false;
    }
}
