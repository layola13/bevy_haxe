# bevy_app 调度系统完善计划

## 1. 概述

本计划旨在完善 bevy_haxe 中的 bevy_app 调度系统，参考 Rust 版 Bevy 的 `bevy_ecs/src/schedule/` 实现。

### 目标
- 实现完整的多阶段调度器
- 支持 Startup/Update 阶段分离
- 支持 SystemSet 的 before/after 约束

### 范围
- **包含**: ScheduleStages, ScheduleGraph, SystemSets, Schedule 增强
- **不包含**: 多线程执行器, 完整的条件系统

## 2. 先决条件

### 文件位置
- Haxe 源码: `/home/vscode/projects/bevy_haxe/src/haxe/ecs/`
- 调度相关: `/home/vscode/projects/bevy_haxe/src/haxe/ecs/schedule/`

### 依赖
- `haxe.ecs.World` - 世界管理
- `haxe.ecs.SystemSet` - 系统集合接口
- `haxe.ecs.ScheduleLabel` - 调度标签
- `haxe.ecs.system.System` - 系统接口

## 3. 实现步骤

### Step 1: 更新 ScheduleStages.hx
- 添加 Startup 相关阶段: PreStartup, Startup, PostStartup
- 添加运行时阶段: First, PreUpdate, Update, PostUpdate, Last
- 实现阶段排序逻辑

### Step 2: 更新 SystemSets.hx  
- 添加 `before` 和 `after` 约束字段
- 实现 `SystemSetConstraints` 类管理约束关系
- 添加 `ambiguousWith` 检测支持

### Step 3: 更新 ScheduleGraph.hx
- 实现 `GraphInfo` 结构管理图元数据
- 添加 `Dependency` 依赖边支持
- 实现 Tarjan SCC 检测循环依赖

### Step 4: 更新 Schedule.hx
- 增强 addSystem 支持 before/after 约束
- 实现多阶段执行
- 添加 startup 和 main 阶段分离
- 实现 ScheduleExecutor 接口

## 4. 文件变更摘要

### 创建文件
| 文件 | 描述 |
|------|------|
| - | 无新文件创建 |

### 修改文件
| 文件 | 描述 |
|------|------|
| `src/haxe/ecs/ScheduleStages.hx` | 添加完整阶段枚举 |
| `src/haxe/ecs/schedule/SystemSets.hx` | 添加 before/after 约束 |
| `src/haxe/ecs/schedule/ScheduleGraph.hx` | 增强图结构 |
| `src/haxe/ecs/Schedule.hx` | 增强调度器功能 |

## 5. 测试策略

- 创建 `test/schedule/` 测试目录
- 编写基础调度测试
- 测试 before/after 约束解析
- 测试阶段执行顺序

## 6. 回滚计划

如需回滚，保持 Git 工作区清洁:
```bash
git checkout -- src/haxe/ecs/Schedule*.hx src/haxe/ecs/schedule/
```

## 7. 估计工作

- **时间**: 2-3 小时
- **复杂度**: 中等
- **风险**: 低 - 增量修改现有文件
