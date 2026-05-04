# Bevy Reflect Module Implementation Plan

## Overview

完善 bevy_reflect 模块的三个核心文件：
- `Reflect.hx` - 反射基类接口和动态类型操作
- `TypeInfo.hx` - 类型元数据存储
- `TypePath.hx` - 类型路径表示

参考 Rust `/home/vscode/projects/bevy/crates/bevy_reflect/src/` 下的代码结构。

## 文件变更

### 1. Reflect.hx (更新)
- 核心 `Reflect` 接口，定义动态类型操作
- `PartialReflect` 子特质，用于只读操作
- `ReflectMut` 子特质，用于可变操作
- `ReflectRef` 枚举，封装只读引用
- `ReflectMut` 枚举，封装可变引用
- `ReflectOwned` 枚举，封装拥有所有权
- `ReflectKind` 枚举，类型种类
- `DynamicReflect` 动态反射实现
- `ApplyError` 应用错误类型

### 2. TypeInfo.hx (更新)
- `TypeInfo` 接口，类型元数据访问
- `TypeInfoError` 错误枚举
- `ReflectedTypeInfo` 类型数据存储
- `StructInfo`, `TupleInfo`, `ListInfo` 等结构信息
- `DynamicTypeInfo` 动态类型信息
- 各种 Info 类的实现

### 3. TypePath.hx (更新)
- `TypePath` 接口，类型路径访问
- `TypePathTable` 静态类型路径表
- `Typed` 接口，类型信息访问
- `TypeRegistry` 类型注册表

## 实现步骤

1. **Reflect.hx**
   - 完善 Reflect 接口方法
   - 实现 ReflectRef/ReflectMut/ReflectOwned 枚举
   - 添加 DynamicReflect 类
   - 实现 ReflectKind
   - 添加 ApplyError

2. **TypeInfo.hx**
   - 完善 TypeInfo 接口
   - 实现 StructInfo, TupleInfo, ListInfo 等
   - 添加 DynamicTypeInfo 实现

3. **TypePath.hx**
   - 完善 TypePath 接口
   - 实现 TypePathTable
   - 添加 TypeRegistry 类
   - 实现 Typed 接口

## 测试策略

- 创建 `test/reflect/` 测试目录
- 编写单元测试验证反射功能
- 测试动态属性访问
- 测试类型信息查询

## 回滚计划

如需回滚，通过 Git 恢复原始文件。
