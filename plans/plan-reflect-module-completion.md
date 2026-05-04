# Plan: 完善 bevy_reflect 模块

## 概述

基于 `/home/vscode/projects/bevy/crates/bevy_reflect/src/` 中的 Rust 代码，完善 Haxe 版本的 bevy_reflect 模块。

## 目标

更新/创建以下核心文件：
1. **Reflect.hx** - 反射基类接口和实现
2. **TypeInfo.hx** - 类型信息存储
3. **TypePath.hx** - 类型路径表示

## 1. Reflect.hx 完善

### 核心接口
```haxe
interface Reflect {
    // 基础反射操作
    function intoAny():Any;
    function asAny():Any;
    function asAnyMut():AnyMut;
    
    // 类型信息
    function typeInfo():TypeInfo;
    function typeId():TypeId;
    function typePath():String;
    
    // 动态访问
    function get(name:String):Dynamic;
    function set(name:String, value:Dynamic):Bool;
    
    // 克隆与比较
    function clone():Reflect;
    function ReflectKind():ReflectKind;
    // ...
}
```

### 枚举类
- **ReflectKind** - 类型的种类 (Struct, Tuple, List, Array, Map, Set, Enum, Opaque)
- **ReflectRef** - 值的只读引用视图
- **ReflectMut** - 值的可变引用视图
- **ReflectOwned** - 值的拥有所有权视图

### 实现类
- **DynamicReflect** - 动态反射值包装器
- **DynamicTypePath** - 动态类型路径

## 2. TypeInfo.hx 完善

### 核心接口
```haxe
interface TypeInfo {
    function id():TypeId;
    function typePath():String;
    function kind():ReflectKind;
    function dataCount():Int;
    function getData<T>(typeId:TypeId):Null<T>;
}
```

### 信息类
- **StructInfo** - 结构体字段信息
- **TupleInfo** - 元组字段信息
- **ListInfo** - 列表元素类型信息
- **ArrayInfo** - 数组元素类型和长度信息
- **MapInfo** - 键值类型信息
- **SetInfo** - 集合元素类型信息
- **EnumInfo** - 枚举变体信息

## 3. TypePath.hx 完善

### 核心接口
```haxe
interface TypePath {
    static function type_path():String;
    static function short_type_path():String;
    static function type_ident():Null<String>;
    static function crate_name():Null<String>;
    static function module_path():Null<String>;
}
```

### 表类
- **TypePathTable** - 类型路径静态表

### 组合特征
- **Typed** - 类型信息组合特征
- **Reflectable** - 完整反射能力组合

## 文件列表

| 文件 | 操作 | 描述 |
|------|------|------|
| src/haxe/reflect/Reflect.hx | 更新 | 反射基类 |
| src/haxe/reflect/TypeInfo.hx | 更新 | 类型信息 |
| src/haxe/reflect/TypePath.hx | 更新 | 类型路径 |

## 实现步骤

### Step 1: 更新 Reflect.hx
- 扩展 Reflect 接口，添加新的方法
- 添加 ReflectRef, ReflectMut, ReflectOwned 枚举
- 添加 ReflectKind 枚举
- 添加 DynamicReflect 实现类
- 添加 ReflectError 和 ApplyError

### Step 2: 更新 TypeInfo.hx
- 完善 TypeInfo 接口
- 添加 StructInfo, TupleInfo, ListInfo 等信息类
- 添加 DynamicTypeInfo 实现类

### Step 3: 更新 TypePath.hx
- 完善 TypePath 接口
- 添加 TypePathTable 类
- 添加 Typed 和 Reflectable 组合特征

## 测试策略

1. 单元测试：
   - 测试 Reflect 接口方法
   - 测试 TypeInfo 类型查询
   - 测试 TypePath 路径解析

2. 集成测试：
   - 使用 @:reflect 宏生成完整实现
   - 测试序列化/反序列化

## 回滚计划

如需回滚，只需恢复原始文件内容（可通过版本控制）。
