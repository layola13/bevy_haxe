# Plan: Bevy Reflect Module Enhancement

## Overview
完善 `/home/vscode/projects/bevy_haxe/src/haxe/reflect/` 模块，使其与 Rust `bevy_reflect` 库的功能更接近。

## Goals
- `Reflect` 提供动态类型操作能力
- `TypeInfo` 存储类型元数据
- `TypePath` 表示类型路径和标识

## Implementation Steps

### Step 1: Update Reflect.hx
创建/更新 `src/haxe/reflect/Reflect.hx`:
- 完善 `PartialReflect` 接口（核心反射能力）
- 完善 `Reflect` 接口（完整反射能力）
- 添加 `ReflectRef`, `ReflectMut`, `ReflectOwned` 枚举
- 添加 `DynamicReflect` 类
- 添加 `ReflectKind` 枚举
- 添加错误类型：`ApplyError`, `ReflectCloneError`

### Step 2: Update TypeInfo.hx
创建/更新 `src/haxe/reflect/TypeInfo.hx`:
- 完善 `TypeInfo` 接口
- 添加 `Typed` 接口
- 添加 `StructInfo`, `TupleInfo`, `EnumInfo` 等信息类
- 添加 `DynamicTypeInfo` 类
- 添加类型数据支持

### Step 3: Update TypePath.hx
创建/更新 `src/haxe/reflect/TypePath.hx`:
- 完善 `TypePath` 接口
- 添加 `TypePathTable` 类
- 添加 `DynamicTypePath` 类
- 添加 `Typed` 接口

## Files to Modify/Create

| File | Action |
|------|--------|
| `src/haxe/reflect/Reflect.hx` | 更新 |
| `src/haxe/reflect/TypeInfo.hx` | 更新 |
| `src/haxe/reflect/TypePath.hx` | 更新 |

## Testing Strategy
1. 编译检查
2. 基础功能测试

## Estimated Effort
Medium (2-3 hours)
