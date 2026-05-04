# ECS System 实现计划

## 1. 概述

基于 Bevy ECS 的 Rust 实现，为 Haxe 移植创建 ECS System 系统。

### 目标
- 实现 `System` 接口 - ECS 系统的基本抽象
- 实现 `SystemParam` 接口 - 系统参数抽象（Res<T>, ResMut<T>, Query<T>）
- 实现 `FunctionSystem` - 将普通函数包装为系统
- 实现 `Commands` - 延迟命令执行机制

### 成功标准
- 所有接口和类编译通过
- 延迟命令执行机制正常工作
- 系统可以正确访问 World 中的数据和实体

---

## 2. 已创建文件

| 文件 | 描述 |
|------|------|
| `System.hx` | System 接口、SystemStateFlags、FilteredAccess |
| `SystemParam.hx` | SystemParam 接口、Res<T>、ResMut<T>、Query<T> |
| `FunctionSystem.hx` | 函数系统包装器、系统元数据 |
| `Commands.hx` | Commands、CommandQueue、EntityCommands、具体命令实现 |

---

## 3. 核心实现细节

### 3.1 延迟命令执行机制

```
系统运行 → 收集命令到 CommandQueue → 系统结束
                                    ↓
                          ApplyDeferred 系统执行
                                    ↓
                          CommandQueue.apply(world)
                                    ↓
                          所有命令按顺序应用到 World
```

**关键组件**:
- `CommandQueue` - 存储所有待执行的命令
- `Command` 接口 - 所有命令实现此接口
- `apply()` 方法 - 在 ApplyDeferred 阶段执行

### 3.2 SystemParam 参数解析

```haxe
interface SystemParam {
    function getItem(world:World, changeTick:UInt):Dynamic;
    function applyDeferred(world:World):Void;
    function init(world:World):Void;
    function getState():Dynamic;
}
```

**实现类**:
- `Res<T>` - 只读资源访问
- `ResMut<T>` - 可变资源访问
- `Query<D, F>` - 组件查询
- `Commands` - 命令队列
- `Local<T>` - 系统本地状态
- `NonSend<T>` / `NonSendMut<T>` - 非 Send 资源

### 3.3 FunctionSystem 运行流程

```
1. initialize(world) → 构建 FilteredAccess
2. run(world) → 
   a. runWithoutApplyingDeferred(world)
   b. applyDeferred(world)
3. runWithoutApplyingDeferred:
   a. 解析所有 SystemParam
   b. 调用系统函数
   c. Commands 填充到 CommandQueue
```

---

## 4. 依赖关系

```
System.hx
    ├── DeferredWorld (接口)
    ├── FilteredAccess (类)
    └── SystemStateFlags (枚举)

SystemParam.hx
    ├── SystemParam (接口)
    ├── Deferred (接口)
    ├── Res<T> (类)
    ├── ResMut<T> (类)
    ├── Query<D, F> (类)
    └── ComponentTicks (类)

FunctionSystem.hx
    ├── System (接口)
    ├── SystemMeta (类)
    └── SystemParamState (类)

Commands.hx
    ├── Command (接口)
    ├── EntityCommand (接口)
    ├── CommandQueue (类)
    ├── Commands (类)
    ├── EntityCommands (类)
    └── [具体命令实现...]
```

---

## 5. 使用示例

```haxe
// 定义资源
class Score implements Resource {
    public var value:Int = 0;
}

// 定义组件
class Position {
    public var x:Float;
    public var y:Float;
}

// 定义系统
function scoreSystem(mutScore:ResMut<Score>, query:Query<Position>) {
    mutScore.value = query.count();
}

// 添加到应用
app.addSystem(Update, scoreSystem);

// 使用 Commands
function spawnSystem(commands:Commands) {
    commands.spawn()
        .insert(new Position { x: 0, y: 0 });
}
```

---

## 6. 测试策略

### 单元测试
- `CommandQueue.apply()` 正确执行所有命令
- `Res<T>` / `ResMut<T>` 正确检测变化
- `Query<T>` 正确过滤实体

### 集成测试
- 系统正确访问资源和组件
- Commands 延迟执行机制正常工作
- Schedule 中的系统按正确顺序执行

---

## 7. 待完善项

1. **宏支持** - `@system` 宏自动提取参数类型
2. **变化检测** - Tick 机制完整实现
3. **并行查询** - `par_iter` 并行迭代器
4. **World 接口** - 补充 World 中被引用的方法

---

## 8. 文件清单

```
src/haxe/ecs/
├── System.hx          ✓ (144 行)
├── SystemParam.hx     ✓ (323 行)
├── FunctionSystem.hx ✓ (265 行)
└── Commands.hx       ✓ (506 行)
```

---

**创建时间**: 2025-01-27
**参考**: `/home/vscode/projects/bevy/crates/bevy_ecs/src/system/`
