# Bevy Haxe Schedule System Enhancement Plan

## 1. Overview

完善 bevy_haxe 的调度系统，使其与 Rust Bevy 的 schedule 模块对齐。

### Goals
- Schedule 支持多阶段调度
- 定义完整的 Stage 枚举（PreStartup, Startup, PostStartup, First, PreUpdate, Update, PostUpdate, Last）
- SystemSet 支持 before/after 约束
- 实现调度图和依赖管理

### Scope
- 创建/更新 `Schedule.hx`、`ScheduleStages.hx`、`ScheduleGraph.hx`、`SystemSets.hx`
- 创建 `ScheduleLabel.hx` 和 `InternedSystemSet.hx`
- 更新 `prelude` 导出

---

## 2. Prerequisites

- Haxe 4.x 环境
- 已有 ecs 模块基础代码
- 参考 Rust 路径: `/home/vscode/projects/bevy/crates/bevy_ecs/src/schedule/`

---

## 3. Implementation Steps

### Step 1: Update ScheduleStages.hx
创建完整的 Stage 枚举定义。

### Step 2: Update SystemSets.hx
增强系统集合，支持 before/after 约束和条件。

### Step 3: Update ScheduleGraph.hx
完善调度图结构，支持依赖管理。

### Step 4: Update Schedule.hx
增强调度器，支持多阶段执行。

### Step 5: Create ScheduleLabel.hx
定义 ScheduleLabel 接口和 InternedScheduleLabel。

### Step 6: Create InternedSystemSet.hx
优化 InternedSystemSet 实现。

### Step 7: Update prelude
更新导出文件。

---

## 4. File Changes Summary

### Modified Files:
1. `src/haxe/ecs/Schedule.hx` - 增强调度器
2. `src/haxe/ecs/ScheduleStages.hx` - 完整阶段定义
3. `src/haxe/ecs/schedule/ScheduleGraph.hx` - 调度图
4. `src/haxe/ecs/schedule/SystemSets.hx` - 系统集合
5. `src/haxe/ecs/SystemSet.hx` - 系统集合接口
6. `src/haxe/ecs/prelude` - 更新导出

### New Files:
1. `src/haxe/ecs/ScheduleLabel.hx` - Schedule标签
2. `src/haxe/ecs/InternedSystemSet.hx` - 优化实现

---

## 5. Testing Strategy

- 验证多阶段执行顺序
- 验证 before/after 约束
- 验证循环依赖检测

## 6. Rollback Plan

- 通过 Git 回滚修改的文件

## 7. Estimated Effort

- Complexity: Medium
- Files: 6 个文件（2 新建，4 修改）
- Time: ~2-3 小时
