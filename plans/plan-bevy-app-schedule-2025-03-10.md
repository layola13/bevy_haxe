# Bevy App 调度系统完善计划

## 1. 概述

### 目标
完善 `bevy_haxe` 项目中的 `bevy_app` 调度系统，参考 Rust Bevy 的 `bevy_ecs/src/schedule/` 实现。

### 核心功能
- 支持多阶段调度的 Schedule
- 完整的 Stage 枚举定义
- SystemSet 支持 before/after 约束
- 调度图依赖管理

## 2. 文件结构

```
src/haxe/ecs/schedule/
├── Schedule.hx           # 增强版调度器
├── ScheduleStages.hx     # 阶段定义枚举
├── ScheduleGraph.hx       # 调度图
├── SystemSets.hx          # 系统集合管理
├── SystemSet.hx           # 系统集合接口
├── node/
│   ├── DiGraph.hx         # 有向图
│   ├── Dependency.hx      # 依赖定义 (新建)
│   └── TopologicalSort.hx # 拓扑排序 (新建)

src/haxe/app/
├── MainSchedule.hx        # 主调度标签 (更新)
└── prelude/
    └── EcsSchedule.hx     # 导出文件 (新建)
```

## 3. 实现细节

### 3.1 ScheduleStages.hx
阶段枚举，包含所有 Bevy 标准阶段：
- PreStartup / Startup / PostStartup (启动阶段)
- First / PreUpdate / Update / PostUpdate / Last (主循环阶段)

### 3.2 SystemSet.hx
- `SystemSet` 接口：系统集合基类
- `SystemSetLabel` 接口：集合标签
- `InternedSystemSet`： interned 缓存
- `SystemSetData`：集合数据
- `Condition`：条件接口
- 支持 before/after 依赖配置

### 3.3 ScheduleGraph.hx
- 层级图 (hierarchy)：父子关系
- 依赖图 (dependency)：执行顺序
- 歧义检测支持

### 3.4 Schedule.hx
- 多阶段支持
- 系统添加和配置
- 条件系统
- 执行器接口

## 4. 完成报告

### 新建文件
1. `src/haxe/ecs/schedule/node/Dependency.hx`
2. `src/haxe/ecs/schedule/node/TopologicalSort.hx`
3. `src/haxe/app/prelude/EcsSchedule.hx`

### 修改文件
1. `src/haxe/ecs/Schedule.hx` - 增强多阶段支持
2. `src/haxe/ecs/ScheduleStages.hx` - 完整阶段枚举
3. `src/haxe/ecs/schedule/ScheduleGraph.hx` - 图结构完善
4. `src/haxe/ecs/schedule/SystemSets.hx` - before/after 支持
5. `src/haxe/ecs/SystemSet.hx` - 条件系统支持
6. `src/haxe/app/MainSchedule.hx` - 阶段标签定义

### 删除文件
无

## 5. 测试策略
- 拓扑排序循环检测
- 阶段顺序验证
- before/after 约束验证
- 条件系统执行验证

## 6. 回滚计划
如需回滚，恢复原始文件版本即可。
