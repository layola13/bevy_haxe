package haxe.ecs;

/**
 * FunctionSystem - 函数系统包装器
 * 
 * 将普通函数包装为System实现
 */
class FunctionSystem<In, Out, Marker> implements System {
    /** 系统元数据 */
    public var meta:SystemMeta;
    
    /** 系统参数状态列表 */
    public var paramStates:Array<SystemParamState>;
    
    /** 延迟命令队列 */
    private var commandQueue:CommandQueue;
    
    /** 参数类型列表 */
    private var paramTypes:Array<String>;
    
    /** 系统函数 */
    private var fn:haxe.Function;
    
    public function new() {
        this.meta = new SystemMeta();
        this.paramStates = [];
        this.commandQueue = new CommandQueue();
    }
    
    /**
     * 设置系统函数
     */
    public function setFunction(fn:haxe.Function):Void {
        this.fn = fn;
    }
    
    /**
     * 设置参数类型
     */
    public function setParamTypes(types:Array<String>):Void {
        this.paramTypes = types;
    }
    
    /** 设置系统名称 */
    public function setName(name:String):Void {
        meta.name = name;
    }
    
    /** 设置参数状态 */
    public function setParamStates(states:Array<SystemParamState>):Void {
        this.paramStates = states;
    }
    
    // System 接口实现
    
    public function name():String {
        return meta.name;
    }
    
    public function systemTypeId():String {
        return meta.typeId;
    }
    
    public function flags():SystemStateFlags {
        var flags = SystemStateFlags.None;
        if (meta.isNonSend) flags = cast (flags | SystemStateFlags.NonSend);
        if (meta.isExclusive) flags = cast (flags | SystemStateFlags.Exclusive);
        if (!commandQueue.isEmpty()) flags = cast (flags | SystemStateFlags.Deferred);
        return flags;
    }
    
    public function isSend():Bool {
        return !meta.isNonSend;
    }
    
    public function isExclusive():Bool {
        return meta.isExclusive;
    }
    
    public function hasDeferred():Bool {
        return !commandQueue.isEmpty();
    }
    
    public function run(world:World):Out {
        var result = runWithoutApplyingDeferred(world);
        applyDeferred(world);
        return result;
    }
    
    public function runWithoutApplyingDeferred(world:World):Out {
        // 解析参数
        var params:Array<Dynamic> = [];
        for (i in 0...paramStates.length) {
            var param = paramStates[i].getItem(world, meta.currentTick);
            params.push(param);
        }
        
        // 添加命令队列
        var commands = new Commands(commandQueue, world);
        params.push(commands);
        
        // 调用函数
        if (fn != null) {
            return Reflect.callMethod(fn, fn, params);
        }
        return null;
    }
    
    public function applyDeferred(world:World):Void {
        commandQueue.apply(world);
        commandQueue.clear();
    }
    
    public function queueDeferred(deferredWorld:DeferredWorld):Void {
        // 将命令队列应用到延迟世界
        deferredWorld.queue(new ApplyCommandsCommand(commandQueue));
    }
    
    public function initialize(world:World):FilteredAccess {
        var access = new FilteredAccess();
        
        // 根据参数类型添加访问权限
        for (type in paramTypes) {
            if (type.indexOf("Res<") == 0) {
                access.addRead(extractTypeParam(type));
            } else if (type.indexOf("ResMut<") == 0) {
                access.addWrite(extractTypeParam(type));
            } else if (type.indexOf("Query<") == 0) {
                // Query访问需要在运行时确定
            }
        }
        
        return access;
    }
    
    public function checkChangeTick(tick:UInt):Void {
        if (meta.lastRun.wrapping_sub(tick) > 0x80000000) {
            // Tick已过期，需要重新包装
        }
    }
    
    public function getLastRun():UInt {
        return meta.lastRun;
    }
    
    public function setLastRun(tick:UInt):Void {
        meta.lastRun = tick;
    }
    
    private function extractTypeParam(type:String):String {
        var start = type.indexOf("<");
        var end = type.lastIndexOf(">");
        if (start >= 0 && end > start) {
            return type.substring(start + 1, end);
        }
        return type;
    }
}

/**
 * 系统元数据
 */
class SystemMeta {
    /** 系统名称 */
    public var name:String;
    
    /** 系统类型ID */
    public var typeId:String;
    
    /** 是否是非Send */
    public var isNonSend:Bool = false;
    
    /** 是否是独占系统 */
    public var isExclusive:Bool = false;
    
    /** 上次运行的tick */
    public var lastRun:UInt = 0;
    
    /** 当前tick */
    public var currentTick:UInt = 0;
    
    public function new() {
        this.name = "Unknown";
        this.typeId = "";
    }
}

/**
 * 应用命令命令
 */
class ApplyCommandsCommand implements Command {
    private var queue:CommandQueue;
    
    public function new(queue:CommandQueue) {
        this.queue = queue;
    }
    
    public function apply(world:World):Void {
        queue.apply(world);
    }
}

/**
 * IntoSystem - 将函数转换为系统的接口
 */
interface IntoSystem<In, Out, Marker> {
    function intoSystem():System;
    function systemTypeId():String;
}

/**
 * 函数系统构建器
 */
class SystemBuilder {
    private var name:String;
    private var paramTypes:Array<String> = [];
    private var fn:haxe.Function;
    
    public function new() {}
    
    public function named(name:String):SystemBuilder {
        this.name = name;
        return this;
    }
    
    public function withParam<T>(typeName:String):SystemBuilder {
        paramTypes.push(typeName);
        return this;
    }
    
    public function build(fn:haxe.Function):FunctionSystem<Void, Dynamic, Void> {
        var system = new FunctionSystem<Void, Dynamic, Void>();
        system.setName(name != null ? name : "System");
        system.setFunction(fn);
        system.setParamTypes(paramTypes);
        return system;
    }
}

/**
 * 系统参数提取器 - 用于编译时参数解析
 */
class SystemParamExtractor {
    /**
     * 从函数类型提取参数类型
     * 这需要在宏中实现
     */
    public static function extractParamTypes(fn:haxe.Function):Array<String> {
        // 基础实现，返回空数组
        // 实际实现需要在宏中完成
        return [];
    }
    
    /**
     * 从系统函数生成系统
     */
    public static function createSystem(fn:haxe.Function, name:String):FunctionSystem<Void, Dynamic, Void> {
        var system = new FunctionSystem<Void, Dynamic, Void>();
        system.setName(name != null ? name : "System");
        system.setFunction(fn);
        system.setParamTypes(extractParamTypes(fn));
        return system;
    }
}
