# Bevy App 调度系统完善计划

## 1. 概述

本计划旨在完善 `bevy_app` 调度系统，参考 Rust Bevy 的 `crates/bevy_ecs/src/schedule/` 实现，创建完整的 Haxe 版本。

### 目标
- Schedule 支持多阶段调度
- Stage 枚举包含完整的 Bevy 阶段
- SystemSet 支持 before/after 约束
- 实现调度图和依赖管理

### 成功标准
- 8 个标准 Stage 完全实现
- SystemSet 支持链式 before/after 配置
- Schedule 可以正确执行多阶段系统

## 2. 前提条件

- Haxe 4.x+
- 已有 ecs 模块基础结构
- 已有 System 接口和 World 类

## 3. 实现步骤

### Step 1: 更新 ScheduleStages.hx
- 添加完整 8 个阶段枚举
- 添加阶段排序和名称工具方法
- 添加 Startup 阶段支持

### Step 2: 更新 SystemSet.hx  
- 添加 SystemSetImpl 基类
- 添加 before/after 链式配置方法
- 添加 Condition 接口
- 添加 IntoSystemSet 支持

### Step 3: 更新 Schedule.hx
- 增强多阶段支持
- 实现系统排序
- 添加 ScheduleLabel 接口
- 添加 InternedScheduleLabel 类

### Step 4: 增强 ScheduleGraph.hx
- 添加依赖管理
- 添加歧义检测支持
- 添加 GraphInfo 结构

### Step 5: 增强 SystemSets.hx
- 添加 HierarchyInfo
- 添加依赖配置支持

### Step 6: 创建/更新 prelude
- 导出所有公共类型

## 4. 文件变更摘要

### 新建文件
- `src/haxe/ecs/schedule/ScheduleStages.hx` - 阶段定义
- `src/haxe/ecs/schedule/SystemSetConfig.hx` - 配置系统

### 修改文件
- `src/haxe/ecs/Schedule.hx` - 增强调度器
- `src/haxe/ecs/ScheduleStages.hx` - 完整阶段枚举
- `src/haxe/ecs/SystemSet.hx` - 完整系统集支持
- `src/haxe/ecs/schedule/ScheduleGraph.hx` - 增强图结构
- `src/haxe/ecs/schedule/SystemSets.hx` - 增强系统集
- `src/haxe/ecs/prelude/SchedulePrelude.hx` - 导出

## 5. 测试策略

- 编译测试：验证所有类型正确
- 阶段顺序测试：验证执行顺序
- 约束测试：验证 before/after 生效
- 循环检测测试：验证依赖循环报错

## 6. 回滚计划

如需回滚，可通过 Git 恢复以下文件：
- Schedule.hx
- ScheduleStages.hx
- SystemSet.hx

## 7. 预估工作量

- 复杂度：中等
- 预估时间：2-3 小时
- 涉及文件：6-8 个
