package haxe.ecs;

/**
 * Command trait - World突变操作
 * 
 * 用于Commands::queue来修改World
 */
interface Command {
    /** 在提供的world上应用此命令，导致其改变 */
    function apply(world:World):Void;
}

/**
 * EntityCommand trait - 针对特定实体的命令
 */
interface EntityCommand {
    /** 在提供的实体上应用此命令 */
    function apply(entity:Entity, world:World):Void;
}

/**
 * CommandQueue - 命令队列用于延迟执行
 * 
 * 由于每个命令都需要对World的独占访问，
 * 所有排队的命令在ApplyDeferred系统运行时自动按顺序应用。
 */
class CommandQueue {
    /** 命令列表 */
    private var commands:Array<Command> = [];
    
    public function new() {}
    
    /**
     * 添加命令到队列
     */
    public function push(command:Command):Void {
        commands.push(command);
    }
    
    /**
     * 添加命令（延迟世界）
     */
    public function queue(command:Command):Void {
        push(command);
    }
    
    /**
     * 应用所有命令
     */
    public function apply(world:World):Void {
        for (cmd in commands) {
            cmd.apply(world);
        }
    }
    
    /**
     * 清空队列
     */
    public function clear():Void {
        commands = [];
    }
    
    /**
     * 检查队列是否为空
     */
    public function isEmpty():Bool {
        return commands.length == 0;
    }
    
    /**
     * 获取命令数量
     */
    public function length():Int {
        return commands.length;
    }
}

/**
 * Commands - 命令队列系统参数
 * 
 * 用于在系统中对World进行结构性修改
 */
class Commands implements SystemParam implements Deferred {
    /** 内部命令队列 */
    private var queue:CommandQueue;
    
    /** 世界引用 */
    private var world:World;
    
    /** 实体分配器 */
    private var entityAllocator:EntityAllocator;
    
    /** 当前实体 */
    private var currentEntity:Entity;
    
    public function new(queue:CommandQueue, world:World) {
        this.queue = queue;
        this.world = world;
        this.entityAllocator = world.getEntityAllocator();
        this.currentEntity = Entity.NONE;
    }
    
    /**
     * 重新借用Commands（减小生命周期）
     */
    public function reborrow():Commands {
        var commands = new Commands(queue, world);
        commands.currentEntity = currentEntity;
        return commands;
    }
    
    // ======== 实体命令 ========
    
    /**
     * 生成一个空的实体
     */
    public function spawn():EntityCommands {
        var entity = entityAllocator.allocate();
        currentEntity = entity;
        
        queue.push(new SpawnCommand(entity));
        return new EntityCommands(entity, queue, world);
    }
    
    /**
     * 生成一个带有bundle的实体
     */
    public function spawnBundle(bundle:Dynamic):EntityCommands {
        var entity = entityAllocator.allocate();
        currentEntity = entity;
        
        queue.push(new SpawnBundleCommand(entity, bundle));
        return new EntityCommands(entity, queue, world);
    }
    
    /**
     * 生成多个实体（批量）
     */
    public function spawnBatch(bundles:Array<Dynamic>):Void {
        var entities:Array<Entity> = [];
        for (i in 0...bundles.length) {
            var entity = entityAllocator.allocate();
            entities.push(entity);
        }
        
        queue.push(new SpawnBatchCommand(entities, bundles));
    }
    
    // ======== 资源命令 ========
    
    /**
     * 插入资源
     */
    public function insertResource<T>(resource:T):Void {
        queue.push(new InsertResourceCommand<T>(resource));
    }
    
    /**
     * 移除资源
     */
    public function removeResource<T>():Void {
        queue.push(new RemoveResourceCommand<T>());
    }
    
    // ======== 命令流 ========
    
    /**
     * 队列一个命令
     */
    public function queueCommand(command:Command):Void {
        queue.push(command);
    }
    
    // ======== 系统命令 ========
    
    /**
     * 启动一个系统
     */
    public function runSystem<M, In, Out>(system:System):Void {
        queue.push(new RunSystemCommand(system));
    }
    
    // ======== 事件命令 ========
    
    /**
     * 发送事件
     */
    public function sendEvent<T:Event>(event:T):Void {
        queue.push(new SendEventCommand<T>(event));
    }
    
    // ======== 生命周期方法 ========
    
    public function getItem(world:World, changeTick:UInt):Dynamic {
        return this;
    }
    
    public function applyDeferred(world:World):Void {
        queue.apply(world);
    }
    
    public function init(world:World):Void {
        this.world = world;
        this.entityAllocator = world.getEntityAllocator();
    }
    
    public function getState():Dynamic {
        return queue;
    }
}

/**
 * EntityCommands - 针对特定实体的命令
 */
class EntityCommands {
    /** 当前实体 */
    public var entity:Entity;
    
    /** 命令队列 */
    private var commands:CommandQueue;
    
    /** 世界 */
    private var world:World;
    
    public function new(entity:Entity, commands:CommandQueue, world:World) {
        this.entity = entity;
        this.commands = commands;
        this.world = world;
    }
    
    /**
     * 获取实体ID
     */
    public function id():Entity {
        return entity;
    }
    
    /**
     * 重新借用
     */
    public function reborrow():EntityCommands {
        var cmds = new EntityCommands(entity, commands, world);
        return cmds;
    }
    
    /**
     * 插入组件
     */
    public function insert<T>(component:T):EntityCommands {
        commands.push(new InsertComponentCommand<T>(entity, component));
        return this;
    }
    
    /**
     * 移除组件
     */
    public function remove<T>():EntityCommands {
        commands.push(new RemoveComponentCommand<T>(entity));
        return this;
    }
    
    /**
     * 移除实体
     */
    public function despawn():Void {
        commands.push(new DespawnCommand(entity));
    }
    
    /**
     * 获取实体上的组件
     */
    public function get<T>():T {
        return world.getComponent(entity, T);
    }
    
    /**
     * 获取可变组件
     */
    public function getMut<T>():T {
        return world.getComponent(entity, T);
    }
    
    /**
     * 带有生命周期插入
     */
    public function insertLifetime<T>(component:T, lifetime:Float):EntityCommands {
        commands.push(new InsertWithLifetimeCommand<T>(entity, component, lifetime));
        return this;
    }
}

// ======== 具体命令实现 ========

/**
 * 生成实体命令
 */
class SpawnCommand implements Command {
    public var entity:Entity;
    
    public function new(entity:Entity) {
        this.entity = entity;
    }
    
    public function apply(world:World):Void {
        world.spawnAt(entity);
    }
}

/**
 * 生成带Bundle的实体命令
 */
class SpawnBundleCommand implements Command {
    public var entity:Entity;
    public var bundle:Dynamic;
    
    public function new(entity:Entity, bundle:Dynamic) {
        this.entity = entity;
        this.bundle = bundle;
    }
    
    public function apply(world:World):Void {
        world.spawnBundleAt(entity, bundle);
    }
}

/**
 * 批量生成命令
 */
class SpawnBatchCommand implements Command {
    public var entities:Array<Entity>;
    public var bundles:Array<Dynamic>;
    
    public function new(entities:Array<Entity>, bundles:Array<Dynamic>) {
        this.entities = entities;
        this.bundles = bundles;
    }
    
    public function apply(world:World):Void {
        for (i in 0...entities.length) {
            world.spawnBundleAt(entities[i], bundles[i]);
        }
    }
}

/**
 * 插入资源命令
 */
class InsertResourceCommand<T> implements Command {
    public var resource:T;
    
    public function new(resource:T) {
        this.resource = resource;
    }
    
    public function apply(world:World):Void {
        world.insertResource(resource);
    }
}

/**
 * 移除资源命令
 */
class RemoveResourceCommand<T> implements Command {
    public function new() {}
    
    public function apply(world:World):Void {
        world.removeResource(T);
    }
}

/**
 * 插入组件命令
 */
class InsertComponentCommand<T> implements Command {
    public var entity:Entity;
    public var component:T;
    
    public function new(entity:Entity, component:T) {
        this.entity = entity;
        this.component = component;
    }
    
    public function apply(world:World):Void {
        world.insertComponent(entity, component);
    }
}

/**
 * 移除组件命令
 */
class RemoveComponentCommand<T> implements Command {
    public var entity:Entity;
    
    public function new(entity:Entity) {
        this.entity = entity;
    }
    
    public function apply(world:World):Void {
        world.removeComponent(entity, T);
    }
}

/**
 * 销毁实体命令
 */
class DespawnCommand implements Command {
    public var entity:Entity;
    
    public function new(entity:Entity) {
        this.entity = entity;
    }
    
    public function apply(world:World):Void {
        world.despawn(entity);
    }
}

/**
 * 带有生命周期的插入命令
 */
class InsertWithLifetimeCommand<T> implements Command {
    public var entity:Entity;
    public var component:T;
    public var lifetime:Float;
    
    public function new(entity:Entity, component:T, lifetime:Float) {
        this.entity = entity;
        this.component = component;
        this.lifetime = lifetime;
    }
    
    public function apply(world:World):Void {
        world.insertComponent(entity, component);
        // 生命周期的处理需要在另一个系统中处理
    }
}

/**
 * 运行系统命令
 */
class RunSystemCommand implements Command {
    public var system:System;
    
    public function new(system:System) {
        this.system = system;
    }
    
    public function apply(world:World):Void {
        system.run(world);
    }
}

/**
 * 发送事件命令
 */
class SendEventCommand<T:Event> implements Command {
    public var event:T;
    
    public function new(event:T) {
        this.event = event;
    }
    
    public function apply(world:World):Void {
        world.sendEvent(event);
    }
}

/**
 * 应用延迟世界命令
 */
class ApplyDeferredCommand implements Command {
    public function new() {}
    
    public function apply(world:World):Void {
        world.applyDeferred();
    }
}

/**
 * 空命令 - 用于调试
 */
class NopCommand implements Command {
    public function new() {}
    
    public function apply(world:World):Void {
        // 不做任何事
    }
}

/**
 * 组合多个命令
 */
class ChainCommand implements Command {
    private var commands:Array<Command>;
    
    public function new(commands:Array<Command>) {
        this.commands = commands;
    }
    
    public function apply(world:World):Void {
        for (cmd in commands) {
            cmd.apply(world);
        }
    }
}
