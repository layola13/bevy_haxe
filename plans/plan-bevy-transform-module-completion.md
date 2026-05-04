# bevy_transform Module Implementation Plan

## 1. Overview

完善 bevy_transform 模块，将 Rust 的 bevy_transform 库转换为 Haxe 版本。

**Goals:**
- Transform 组件存储 translation, rotation, scale
- GlobalTransform 计算世界空间变换
- Parent/Children/ChildOf 实现变换层级
- 自动更新 GlobalTransform
- TransformPlugin 自动注册变换更新系统

**Scope:**
- 实现 Transform.hx 的方法增强
- 更新 GlobalTransform.hx 的方法
- 创建 ChildOf.hx - 父子关系组件
- 更新 Parent.hx 和 Children.hx
- 创建 TransformPlugin.hx - 插件系统
- 创建 TransformHelper.hx - 帮助类
- 更新 TransformSystem.hx - 改进变换传播系统

## 2. Prerequisites

**Dependencies:**
- haxe.math.Vec3, Quat, Mat4
- haxe.ecs.World, Entity, Component
- haxe.ecs.query 相关

**Files to reference:**
- `/home/vscode/projects/bevy/crates/bevy_transform/src/` - Rust 源文件
- `/home/vscode/projects/bevy_haxe/src/haxe/ecs/World.hx` - ECS World

## 3. Implementation Steps

### Step 1: Update Transform.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/transform/Transform.hx`

Enhance with:
- `lookAt(target, up)` - 朝向目标
- `reparentedTo(parent)` - 计算重父级变换
- `transform_vector(vector)` - 变换向量
- `transform_point(point)` - 变换点
- `transform_vector_mut(vector)` - 就地变换向量
- 完整的 `mul_transform(other)` - 组合变换
- `assert_is_normalized()` - 验证方法

### Step 2: Update GlobalTransform.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/transform/GlobalTransform.hx`

Enhance with:
- `reparentedTo(parent)` - 计算重父级变换
- `compute_transform()` - 提取为 Transform
- `to_scale_rotation_translation()` - 分解
- `right()`, `up()`, `forward()`, `back()` - 方向向量
- `transform_vector_mut()` - 就地变换向量
- `transform_point_mut()` - 就地变换点
- `rotate(rotation)` - 旋转变换
- `rotate_translate_scale(rotation, translation, scale)` - 完整变换

### Step 3: Create ChildOf.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/transform/ChildOf.hx`

New file for parent-child relationship:
```haxe
class ChildOf implements haxe.ecs.Component {
    public var parentId:Int;
    
    // Index in parent's Children list (for ordering)
    public var index:Int;
    
    // Helper methods
    public function parent():Entity;
    public static function of(entity:Entity, ?index:Int):ChildOf;
}
```

### Step 4: Update Parent.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/transform/Parent.hx`

Keep existing, add:
- Better documentation referencing ChildOf
- Ensure compatibility with hierarchy system

### Step 5: Update Children.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/transform/Children.hx`

Enhance with:
- `replace(oldChildren:Array<Int>, newChildren:Array<Int>)` - 批量替换
- `set_difference(oldChildren, newChildren)` - 差异操作
- `insert(index, childId)` - 在指定位置插入
- Index-based access methods

### Step 6: Create TransformPlugin.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/transform/TransformPlugin.hx`

New plugin:
```haxe
class TransformPlugin implements haxe.app.Plugin {
    public function build(app:App):Void;
}

// System sets
class TransformSystems {
    public static inline var PROPAGATE:String = "TransformSystems.Propagate";
}
```

### Step 7: Create TransformHelper.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/transform/TransformHelper.hx`

System parameter for computing transforms:
```haxe
class TransformHelper {
    public function new(world:World);
    public function compute_global_transform(entityId:Int):GlobalTransform;
    public function transform_point(entityId:Int, point:Vec3):Vec3;
}
```

### Step 8: Update TransformSystem.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/transform/TransformSystem.hx`

Complete rewrite with:
- `propagate_transforms()` - 主传播方法
- `mark_dirty_trees()` - 标记脏树
- `sync_simple_transforms()` - 同步简单变换
- `update(world)` - 整合更新方法
- 优化：使用 `TransformTreeChanged` 标记

### Step 9: Create TransformTreeChanged.hx
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/transform/TransformTreeChanged.hx`

New marker component for optimization:
```haxe
class TransformTreeChanged implements haxe.ecs.Component {
    // ZST marker - no data needed
    // Used for change detection optimization
}
```

### Step 10: Create prelude export
**File:** `/home/vscode/projects/bevy_haxe/src/haxe/prelude/TransformPrelude.hx`

Export commonly used types:
```haxe
class TransformPrelude {
    public static function createPrelude():Dynamic;
}
```

## 4. File Changes Summary

### Created Files (New):
| File | Description |
|------|-------------|
| `src/haxe/transform/ChildOf.hx` | Parent-child relationship component |
| `src/haxe/transform/TransformPlugin.hx` | Plugin for transform system |
| `src/haxe/transform/TransformHelper.hx` | Helper for computing transforms |
| `src/haxe/transform/TransformTreeChanged.hx` | Change detection marker |
| `src/haxe/prelude/TransformPrelude.hx` | Prelude exports |

### Modified Files:
| File | Changes |
|------|---------|
| `src/haxe/transform/Transform.hx` | Add lookAt, reparented_to, transform methods |
| `src/haxe/transform/GlobalTransform.hx` | Add direction vectors, reparented_to, rotation methods |
| `src/haxe/transform/Parent.hx` | Documentation updates |
| `src/haxe/transform/Children.hx` | Add replace, set_difference, insert methods |
| `src/haxe/transform/TransformSystem.hx` | Complete rewrite with propagation system |

### Deleted Files:
- None

## 5. Testing Strategy

### Unit Tests:
1. **Transform Tests:**
   - Identity transform operations
   - Transform composition (mul_transform)
   - lookAt function
   - from_matrix / to_matrix roundtrip

2. **GlobalTransform Tests:**
   - Identity operations
   - Transform composition
   - reparented_to calculation
   - Direction vectors (right, up, forward)
   - Inverse computation

3. **Hierarchy Tests:**
   - Parent/Children setup
   - ChildOf relationship
   - Transform propagation through hierarchy

4. **TransformSystem Tests:**
   - Root entity transform
   - Single child propagation
   - Multiple level hierarchy
   - Change detection

### Integration Tests:
1. Scene with nested transforms
2. Reparenting scenarios
3. Transform interpolation

## 6. Rollback Plan

**To revert changes:**
1. Restore original files from git
2. Delete new files (ChildOf.hx, TransformPlugin.hx, etc.)

**Git commands:**
```bash
git checkout src/haxe/transform/Transform.hx
git checkout src/haxe/transform/GlobalTransform.hx
# etc.
rm src/haxe/transform/ChildOf.hx
rm src/haxe/transform/TransformPlugin.hx
# etc.
```

## 7. Estimated Effort

**Complexity:** Medium

**Time Estimate:** 2-3 hours

**Breakdown:**
- Transform.hx enhancements: 30 min
- GlobalTransform.hx enhancements: 30 min
- ChildOf.hx creation: 15 min
- Parent.hx, Children.hx updates: 15 min
- TransformPlugin.hx creation: 20 min
- TransformHelper.hx creation: 20 min
- TransformSystem.hx rewrite: 45 min
- Testing: 30 min

---

**Plan created:** $(date)
**Status:** Ready for implementation
