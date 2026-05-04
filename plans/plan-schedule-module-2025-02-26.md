# Bevy App 调度系统完善计划

## 概述

根据 `/home/vscode/projects/bevy/crates/bevy_ecs/src/schedule/` 中的 Rust 代码，完善 Haxe 版本的调度系统。

## 目标

1. **Schedule.hx** - 增强调度器，支持多阶段和依赖图
2. **ScheduleStages.hx** - 添加完整阶段定义
3. **ScheduleGraph.hx** - 创建调度图实现
4. **SystemSets.hx** - 实现系统集合的 before/after 约束

## 文件变更列表

### 修改的文件

| 文件路径 | 操作 | 说明 |
|---------|------|------|
| `src/haxe/ecs/Schedule.hx` | 修改 | 增强多阶段支持和调度图 |
| `src/haxe/ecs/ScheduleStages.hx` | 修改 | 添加完整阶段枚举 |
| `src/haxe/ecs/SystemSet.hx` | 修改 | 添加 before/after 约束支持 |
| `src/haxe/ecs/schedule/ScheduleGraph.hx` | 修改 | 完善调度图实现 |
| `src/haxe/ecs/schedule/SystemSets.hx` | 修改 | 完善系统集合管理 |
| `src/haxe/ecs/schedule/node/DiGraph.hx` | 修改 | 增强有向图功能 |
| `src/haxe/app/prelude.hx` | 创建 | app 模块导出 |

### 新建文件

| 文件路径 | 操作 | 说明 |
|---------|------|------|
| `src/haxe/ecs/schedule/ScheduleBuilder.hx` | 创建 | 调度构建器 |
| `src/haxe/ecs/schedule/ScheduleExecutor.hx` | 创建 | 调度执行器 |
| `src/haxe/ecs/schedule/ScheduleConditions.hx` | 创建 | 调度条件 |

## 实现细节

### 1. ScheduleStages.hx - 阶段枚举

```haxe
enum ScheduleStages {
    PreStartup;    // 启动前
    Startup;       // 启动
    PostStartup;   // 启动后
    First;         // 第一帧
    PreUpdate;     // 更新前
    Update;        // 主更新
    PostUpdate;    // 更新后
    Last;          // 最后一帧
}
```

### 2. SystemSet - before/after 约束

```haxe
interface SystemSet {
    function intern():InternedSystemSet;
    function name():String;
}

interface SystemSetConfigurable {
    function before(set:InternedSystemSet):Void;
    function after(set:InternedSystemSet):Void;
}
```

### 3. Schedule - 多阶段支持

- 默认阶段顺序: First -> PreUpdate -> Update -> PostUpdate -> Last
- 启动阶段: PreStartup -> Startup -> PostStartup

## 依赖关系

```
App.hx -> Schedule.hx -> ScheduleStages.hx
                         -> ScheduleGraph.hx -> DiGraph.hx
                         -> SystemSets.hx
                         -> SystemSet.hx
```

## 测试策略

1. 创建 test/schedule 目录
2. 编写 ScheduleTest.hx 测试基本功能
3. 测试阶段执行顺序
4. 测试系统依赖排序
