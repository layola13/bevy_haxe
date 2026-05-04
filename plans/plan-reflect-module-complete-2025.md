# bevy_reflect 模块完善计划

## 概述

完善 `/home/vscode/projects/bevy_haxe/src/haxe/reflect/` 下的反射模块，参考 Rust 的 `bevy_reflect` crate。

## 目标

1. **Reflect.hx** - 核心反射接口，提供动态类型操作
2. **TypeInfo.hx** - 类型信息存储元数据
3. **TypePath.hx** - 类型路径表示

## 文件结构

```
src/haxe/reflect/
├── Reflect.hx      (更新)
├── TypeInfo.hx     (更新)
├── TypePath.hx     (更新)
└── prelude/
    └── Reflect.hx  (创建)
```

## 实现步骤

### Step 1: 更新 Reflect.hx

核心接口：
- `PartialReflect` - 部分反射能力
- `Reflect` - 完整反射能力，继承 PartialReflect
- `ReflectRef` / `ReflectMut` / `ReflectOwned` - 反射视图枚举
- `ReflectKind` - 类型种类枚举
- `DynamicReflect` - 动态反射实现

### Step 2: 更新 TypeInfo.hx

核心类型：
- `TypeInfo` 接口 - 类型元数据访问
- `Typed` 接口 - 编译时常量类型信息
- `DynamicTypeInfo` - 动态类型信息
- `StructInfo` / `EnumInfo` / `TupleInfo` 等
- `TypeInfoError` - 类型信息错误

### Step 3: 更新 TypePath.hx

核心类型：
- `TypePath` 接口 - 类型路径访问
- `TypePathTable` - 静态类型路径表
- `DefaultTypePath` - 默认实现

### Step 4: 创建 prelude/Reflect.hx

导出所有反射类型供 prelude 使用。

## 文件变更总结

| 文件 | 操作 |
|------|------|
| src/haxe/reflect/Reflect.hx | 更新 |
| src/haxe/reflect/TypeInfo.hx | 更新 |
| src/haxe/reflect/TypePath.hx | 更新 |
| src/haxe/reflect/prelude/Reflect.hx | 创建 |

## 测试策略

1. 单元测试：
   - Reflect 接口基本功能
   - TypeInfo 类型信息访问
   - TypePath 路径解析

2. 集成测试：
   - 与 ECS 模块集成测试
   - 与序列化模块集成测试

## 回滚计划

如需回滚，保留原始文件备份。
