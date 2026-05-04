# 计划：完善 bevy_reflect 模块

## 概述

基于 `/home/vscode/projects/bevy/crates/bevy_reflect/src/` 中的 Rust 代码，完善 Haxe 版本的 bevy_reflect 模块。

## 目标

更新/创建以下核心文件：
1. **Reflect.hx** - 反射基类接口和实现
2. **TypeInfo.hx** - 类型信息存储
3. **TypePath.hx** - 类型路径表示

## 详细设计

### 1. Reflect.hx

#### Reflect 接口方法
```haxe
interface Reflect {
    // 转换为 Any
    function intoAny():Any;
    function asAny():Any;
    function asAnyMut():AnyMut;
    
    // 转换为 Reflect trait object
    function intoReflect():Reflect;
    function asReflect():Reflect;
    function asReflectMut():Reflect;
    
    // 设置值
    function set(value:Reflect):Result<Void, ReflectError>;
    
    // 类型信息
    function typeInfo():TypeInfo;
    function typeId():TypeId;
    function typePath():String;
    
    // 动态访问
    function get(name:String):Option<Dynamic>;
    function setField(name:String, value:Dynamic):Result<Void, ReflectError>;
    
    // 克隆与比较
    function clone():Reflect;
    function ReflectKind():ReflectKind;
    
    // 应用
    function apply(other:Reflect):Result<Void, ApplyError>;
    
    // 反射引用
    function reflectRef():ReflectRef;
    function reflectMut():ReflectMut;
    function reflectOwned():ReflectOwned;
}
```

#### 枚举类
- **ReflectKind** - Struct, TupleStruct, Tuple, List, Array, Map, Set, Enum, Function, Opaque
- **ReflectRef** - 值只读视图
- **ReflectMut** - 值可变视图
- **ReflectOwned** - 值拥有权视图

#### 错误类型
- **ReflectError** - 反射操作错误
- **ApplyError** - 应用值错误
- **ReflectKindMismatchError** - 类型不匹配错误

#### 实现类
- **DynamicReflect** - 动态反射值包装器
- **PartialReflect** - 部分反射能力

### 2. TypeInfo.hx

#### TypeInfo 联合类型
```
TypeInfoData = 
    | StructTypeInfo(fields:Array<StructField>, data:Map<TypeId, Dynamic>)
    | TupleStructTypeInfo(fields:Array<TupleField>, data:Map<TypeId, Dynamic>)
    | TupleTypeInfo(fieldCount:Int, data:Map<TypeId, Dynamic>)
    | ListTypeInfo(elementType:TypeId, data:Map<TypeId, Dynamic>)
    | ArrayTypeInfo(elementType:TypeId, capacity:Int, data:Map<TypeId, Dynamic>)
    | MapTypeInfo(keyType:TypeId, valueType:TypeId, data:Map<TypeId, Dynamic>)
    | SetTypeInfo(elementType:TypeId, data:Map<TypeId, Dynamic>)
    | EnumTypeInfo(variants:Array<EnumVariant>, data:Map<TypeId, Dynamic>)
    | OpaqueTypeInfo(data:Map<TypeId, Dynamic>)
```

#### StructField
```haxe
class StructField {
    final name:String;
    final typeId:TypeId;
    final visibility:FieldVisibility;
}
```

### 3. TypePath.hx

#### TypePath 静态方法
```haxe
interface TypePath {
    static function type_path():String;
    static function short_type_path():String;
    static function type_ident():Null<String>;
    static function crate_name():Null<String>;
    static function module_path():Null<String>;
}
```

#### TypePathTable 类
- 存储类型路径的静态表
- 用于高效的类型路径查询

#### Typed 组合特征
- `typeInfo()` + `typeId()` + `typePath()`

## 实现步骤

### Step 1: 更新 Reflect.hx (文件路径: src/haxe/reflect/Reflect.hx)
1. 扩展 Reflect 接口
2. 添加 ReflectRef, ReflectMut, ReflectOwned 枚举
3. 添加 ReflectKind 枚举
4. 添加 ReflectError, ApplyError 错误类型
5. 添加 DynamicReflect 实现类

### Step 2: 更新 TypeInfo.hx (文件路径: src/haxe/reflect/TypeInfo.hx)
1. 使用联合类型表示 TypeInfo
2. 添加 StructField, TupleField 等辅助类
3. 添加信息获取方法

### Step 3: 更新 TypePath.hx (文件路径: src/haxe/reflect/TypePath.hx)
1. 完善 TypePath 接口
2. 添加 TypePathTable 类
3. 添加 Typed 组合特征

## 文件变更摘要

| 文件 | 操作 | 描述 |
|------|------|------|
| src/haxe/reflect/Reflect.hx | 更新 | 反射基类接口和实现 |
| src/haxe/reflect/TypeInfo.hx | 更新 | 类型信息存储 |
| src/haxe/reflect/TypePath.hx | 更新 | 类型路径表示 |

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
