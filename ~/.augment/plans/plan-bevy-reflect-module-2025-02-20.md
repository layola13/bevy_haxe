# Bevy Reflect Module Enhancement Plan

## 1. Overview

完善 `haxe.reflect` 模块，使其更接近 Rust `bevy_reflect` 的设计。

### Goals
- 增强 `Reflect` 接口，提供更完整的动态类型操作
- 完善 `TypeInfo` 类，存储类型元数据
- 改进 `TypePath` 接口，表示类型路径

### Success Criteria
- 所有类型可实现动态字段访问
- 支持反射引用（只读、可变、拥有）
- 支持类型转换和向下转型

## 2. Prerequisites

- Haxe 4.x+
- haxe.utils.TypeId 模块已存在

## 3. Implementation Steps

### Step 1: 更新 Reflect.hx
创建新的完整实现文件：
- 定义 `ReflectKind` 枚举
- 定义 `ReflectRef`、`ReflectMut`、`ReflectOwned` 接口
- 定义 `PartialReflect` 和 `Reflect` 接口
- 实现 `DynamicReflect` 动态反射类
- 实现 `ReflectApply` 工具类

### Step 2: 更新 TypeInfo.hx
创建新的完整实现文件：
- 定义 `StructInfo`、`TupleInfo`、`ListInfo` 等信息类
- 完善 `TypeInfo` 接口
- 实现 `DynamicTypeInfo` 动态类型信息

### Step 3: 更新 TypePath.hx
创建新的完整实现文件：
- 完善 `TypePath` 接口
- 实现 `TypePathTable` 静态表格
- 实现 `Typed` 接口

## 4. File Changes Summary

| 操作 | 文件路径 |
|------|----------|
| 修改 | `src/haxe/reflect/Reflect.hx` |
| 修改 | `src/haxe/reflect/TypeInfo.hx` |
| 修改 | `src/haxe/reflect/TypePath.hx` |

## 5. Testing Strategy

- 编译测试：`haxe --cwd /home/vscode/projects/bevy_haxe build.hxml`
- 语法检查所有新接口
- 确认 Dynamic* 类可正常实例化

## 6. Rollback Plan

- 使用 git 恢复原始文件
- 保留备份在 `~/.augment/backups/`

## 7. Estimated Effort

- 复杂度：中等
- 预估时间：1-2 小时
