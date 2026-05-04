# Implementation Plan: Prelude Module and Examples

## 1. Overview

创建 Bevy Haxe 引擎的 prelude 模块和示例文件，统一预导入所有常用类型，并提供可运行的示例代码。

**Goals:**
- 创建统一的 Prelude 模块，导出所有核心类型
- 更新 Main 入口文件，支持 App 运行
- 创建 HelloWorld 示例展示基本用法
- 创建 QueryExample 示例展示 ECS 查询系统

**Scope:**
- ✅ `src/haxe/prelude/Prelude.hx` - 统一预导入模块
- ✅ `src/Main.hx` - 入口文件
- ✅ `examples/HelloWorld.hx` - Hello World 示例
- ✅ `examples/QueryExample.hx` - ECS 查询示例

## 2. Prerequisites

- Haxe 4.x 环境
- 项目结构已存在（src/haxe/* 模块目录）

## 3. Implementation Steps

### Step 1: Create/Update Prelude Module
**File:** `src/haxe/prelude/Prelude.hx`

包含内容：
- 类型别名：Vec2, Vec3, Vec4, Mat4, Quat, Color, RGBA, Entity
- 内联工厂函数：vec2(), vec3(), vec4(), quat(), quatIdentity(), mat4(), translation(), scaling(), rotationX/Y/Z(), perspective(), lookAt(), rgba(), entity()
- 零成本抽象设计

### Step 2: Update Main Entry Point
**File:** `src/Main.hx`

功能：
- 创建和运行 App 实例
- 配置窗口标题和分辨率
- 添加默认插件
- 提供 quickStart() 快捷启动方法
- 支持 debug 模式日志

### Step 3: Create HelloWorld Example
**File:** `examples/HelloWorld.hx`

演示内容：
- Prelude 导入和使用
- Vec3 向量运算
- Entity 创建
- App 生命周期（setup, update, render, cleanup）
- 四元数基础操作

### Step 4: Create QueryExample
**File:** `examples/QueryExample.hx`

演示内容：
- ECS 组件系统（Transform, Velocity, Player, Enemy）
- World 实体的创建和组件管理
- QueryBuilder 查询构建器
- .with() 和 .without() 查询过滤
- 系统调度

## 4. File Changes Summary

| 操作 | 文件路径 |
|------|----------|
| Modified | `src/haxe/prelude/Prelude.hx` → `PreludeUpdated.hx` |
| Modified | `src/Main.hx` → `MainUpdated.hx` |
| Modified | `examples/HelloWorld.hx` → `HelloWorldUpdated.hx` |
| Created | `examples/QueryExample.hx` (已直接保存) |

**Note:** 文件以 "Updated" 后缀保存（避免覆盖现有文件）

## 5. Testing Strategy

### 编译测试
```bash
haxe project.hxml
```

### 运行示例
```bash
# HelloWorld
haxe -main Main --cwd examples

# QueryExample  
haxe -main Main --cwd examples/examples
```

## 6. Rollback Plan

如需回滚，删除所有 `*Updated.hx` 文件，恢复原始文件内容。

## 7. Estimated Effort

- **Time:** ~30 minutes
- **Complexity:** Low
- **Risk:** Low (纯新增文件，不修改核心依赖)
