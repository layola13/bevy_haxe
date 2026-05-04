# Bevy ECS Event System Implementation Plan

## 1. Overview

完善 `bevy_ecs` 事件系统，实现符合 Rust `bevy_ecs` 规范的双缓冲事件机制。

### Goals
- `Event` 接口正确标记事件类型
- `Events<T>` 实现双缓冲机制
- `EventWriter<T>` 支持批量写入
- `EventReader<T>` 支持迭代访问

### Scope
- **Included**: Event.hx, Events.hx, EventWriter.hx, EventReader.hx
- **Excluded**: Observer/Trigger 系统（已在现有代码中部分实现）

---

## 2. Prerequisites

- Haxe 4.x+
- 现有 `haxe.ecs` 模块已存在
- `Resource` 接口已定义
- `World` 类已实现

---

## 3. Implementation Steps

### Step 1: Update Event.hx

**文件**: `/home/vscode/projects/bevy_haxe/src/haxe/ecs/Event.hx`

**修改内容**:
- 保留 `Event` 接口作为 marker trait
- 保留 `EntityEvent` 接口用于实体事件
- 保留 `EventBatch` 辅助类
- 清理重复/冗余代码
- 添加必要的类型 ID 方法

**关键实现**:
```haxe
interface Event {
    public function getTypeId():Any;
}

interface EntityEvent extends Event {
    public function getTarget():Entity;
}
```

### Step 2: Update Events.hx

**文件**: `/home/vscode/projects/bevy_haxe/src/haxe/ecs/Events.hx`

**修改内容**:
- 实现双缓冲机制（双缓冲区）
- 添加 `a` / `b` 两个缓冲区
- 实现 `update()` 方法进行缓冲区切换
- 添加 `lastEventCountA` / `lastEventCountB` 跟踪读取位置
- 实现 `getCursor()` / `releaseCursor()` 管理游标
- 添加 `updateDrain()` 方法清空旧事件

**关键实现**:
```haxe
class Events<T:Event> implements Resource {
    // 双缓冲存储
    private var a:Array<T> = [];
    private var b:Array<T> = [];
    private var state:Int = 0; // 0 = a 写入, b 读取; 1 = b 写入, a 读取
    
    // 游标管理
    private var readers:Map<Int, Int> = new Map();
    private var nextReaderId:Int = 0;
    
    private var eventCount:Int = 0;
    private var lastEventCount:Int = 0;
    
    // 写入缓冲区
    public inline function write(event:T):Void {
        if (state == 0) a.push(event);
        else b.push(event);
        eventCount++;
    }
    
    // 切换缓冲区
    public function update():Void {
        lastEventCount = eventCount;
        eventCount = 0;
        state = 1 - state;
    }
    
    // 获取游标
    public function getCursor():EventCursor<T> {
        var id = nextReaderId++;
        var lastIndex = state == 1 ? a.length : b.length;
        readers.set(id, lastIndex);
        return new EventCursor<T>(id, this);
    }
    
    // 释放游标
    public function releaseCursor(id:Int):Void {
        readers.remove(id);
    }
}
```

### Step 3: Update EventWriter.hx

**文件**: `/home/vscode/projects/bevy_haxe/src/haxe/ecs/EventWriter.hx`

**修改内容**:
- 保持现有 `send()` 方法
- 添加批量写入支持 `sendBatch()`
- 添加 `sendIterator()` 支持迭代器批量写入
- 添加 `sendAnonymous()` 支持匿名对象

**关键实现**:
```haxe
class EventWriter<T:Event> {
    private var events:Events<T>;
    
    public function new(events:Events<T>) {
        this.events = events;
    }
    
    public inline function send(event:T):Void {
        events.write(event);
    }
    
    public function sendBatch(events:Array<T>):Void {
        for (e in events) {
            this.events.write(e);
        }
    }
    
    public inline function len():Int {
        return events.len();
    }
}
```

### Step 4: Update EventReader.hx

**文件**: `/home/vscode/projects/bevy_haxe/src/haxe/ecs/EventReader.hx`

**修改内容**:
- 使用 Events 的游标系统
- 实现 `Iterator<T>` 接口支持 `for...in` 循环
- 添加 `read()` 方法返回未读事件
- 添加 `len()` / `isEmpty()` 查询方法
- 支持 `update()` 同步读取位置

**关键实现**:
```haxe
class EventReader<T:Event> implements Iterator<T> {
    private var events:Events<T>;
    private var cursor:EventCursor<T>;
    private var currentIndex:Int = 0;
    private var buffer:Array<T> = [];
    
    public function new(events:Events<T>) {
        this.events = events;
        this.cursor = events.getCursor();
        this.buffer = events.getReadBuffer();
    }
    
    public function read():Array<T> {
        return events.readFromCursor(cursor);
    }
    
    // Iterator<T> 实现
    public function hasNext():Bool {
        return currentIndex < buffer.length;
    }
    
    public function next():T {
        return buffer[currentIndex++];
    }
}
```

---

## 4. File Changes Summary

| 文件 | 操作 | 说明 |
|------|------|------|
| `src/haxe/ecs/Event.hx` | 修改 | 保留 Event/EntityEvent 接口，清理冗余代码 |
| `src/haxe/ecs/Events.hx` | 重写 | 实现双缓冲机制 |
| `src/haxe/ecs/EventWriter.hx` | 修改 | 添加批量写入支持 |
| `src/haxe/ecs/EventReader.hx` | 重写 | 实现 Iterator 接口 |

---

## 5. Testing Strategy

### Unit Tests
- 测试 `Events.write()` 和 `update()` 交替写入
- 测试 `EventReader` 正确读取未读事件
- 测试 `EventWriter.sendBatch()` 批量写入
- 测试缓冲区切换后的正确性

### Manual Testing
```haxe
// 测试双缓冲
var events = new Events<TestEvent>();
var writer = new EventWriter(events);
var reader = new EventReader(events);

writer.send({ value: 1 });
writer.send({ value: 2 });

var read1 = reader.read();
trace(read1.length); // 应该是 2

events.update(); // 切换缓冲区

writer.send({ value: 3 });
var read2 = reader.read();
trace(read2.length); // 应该是 1 (只有新的事件)
```

---

## 6. Rollback Plan

如需回滚，保留以下文件的备份：
- `src/haxe/ecs/Event.hx.bak`
- `src/haxe/ecs/Events.hx.bak`
- `src/haxe/ecs/EventWriter.hx.bak`
- `src/haxe/ecs/EventReader.hx.bak`

使用 `cp` 命令恢复备份即可。

---

## 7. Estimated Effort

- **时间**: 2-3 小时
- **复杂度**: 中等
- **风险**: 低

需要确保 Haxe 4.x 的泛型支持正确处理 `Events<T>` 类型参数。
