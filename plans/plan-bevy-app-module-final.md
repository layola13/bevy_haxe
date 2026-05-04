# bevy_app 模块完善计划

## 1. Overview

完善 `/home/vscode/projects/bevy_haxe` 中的 `bevy_app` 模块，将 Rust bevy_app 功能转换到 Haxe。

### Goals
- App 使用链式 API (`app.addPlugin().addSystem().run()`)
- Plugin 用 interface + 默认实现类
- 支持插件组批量添加
- 调度标签 (First, PreUpdate, Update, PostUpdate, Last)

### Scope
- **Included**: App, Plugin, PluginGroup, LifecyclePlugin, MainSchedule, prelude
- **Excluded**: SubApp, task_pool_plugin, schedule_runner (高级功能)

---

## 2. Prerequisites

- Haxe 4.x+
- 现有 haxe.ecs 模块正常工作
- 无需数据库迁移

---

## 3. Implementation Steps

### Step 1: 修复 MainSchedule.hx
**文件**: `/home/vscode/projects/bevy_haxe/src/haxe/app/MainSchedule.hx`

**问题**: 当前引用不存在的 ECS schedule 文件
**修复**:
- 移除对 `haxe.ecs.schedule.ScheduleLabel` 等的无效引用
- 使用 App.hx 中定义的 Schedule enum
- 精简主调度标签类

### Step 2: 更新 App.hx
**文件**: `/home/vscode/projects/bevy_haxe/src/haxe/app/App.hx`

**增强内容**:
- 移除重复的 Schedule enum (已在 MainSchedule.hx)
- 添加更多链式方法: `addSystems()`, `addPlugins()`, `configureSchedules()`
- 添加插件生命周期管理 (ready, finish, cleanup)
- 完善 `run()` 方法

### Step 3: 重构 Plugin.hx + LifecyclePlugin.hx
**文件**: 
- `/home/vscode/projects/bevy_haxe/src/haxe/app/Plugin.hx`
- `/home/vscode/projects/bevy_haxe/src/haxe/app/LifecyclePlugin.hx`

**策略**: Haxe interface 不支持默认方法，所以 Plugin 接口只声明方法签名，`LifecyclePlugin` 提供可选方法实现。

Plugin 接口:
```haxe
interface Plugin {
    var name(get, never):String;
    var isUnique(get, never):Bool;
    function build(app:App):Void;
    function ready(app:App):Bool;
    function finish(app:App):Void;
    function cleanup(app:App):Void;
}
```

### Step 4: 更新 PluginGroup.hx
**文件**: `/home/vscode/projects/bevy_haxe/src/haxe/app/PluginGroup.hx`

**功能**:
- `PluginGroup` 接口: `build() -> PluginGroupBuilder`
- `PluginGroupBuilder`: 链式添加插件
- `BuiltPluginGroup`: 最终构建结果

### Step 5: 创建 AppPrelude.hx
**文件**: `/home/vscode/projects/bevy_haxe/src/haxe/app/prelude/AppPrelude.hx`

**导出内容**:
```haxe
import haxe.app.App;
import haxe.app.Plugin;
import haxe.app.PluginGroup;
import haxe.app.LifecyclePlugin;
import haxe.app.MainSchedule.*;
```

---

## 4. File Changes Summary

| 操作 | 文件路径 |
|------|----------|
| **修改** | `src/haxe/app/App.hx` |
| **修改** | `src/haxe/app/LifecyclePlugin.hx` |
| **修改** | `src/haxe/app/Plugin.hx` |
| **修改** | `src/haxe/app/PluginGroup.hx` |
| **重写** | `src/haxe/app/MainSchedule.hx` |
| **创建** | `src/haxe/app/prelude/AppPrelude.hx` |

---

## 5. Testing Strategy

### 单元测试
- `Plugin` 可以添加到 `App`
- `PluginGroup` 批量添加插件
- 链式 API 正常工作
- 调度标签可以用于系统排序

### 集成测试
- 创建自定义 Plugin
- 创建自定义 PluginGroup
- 使用 `app.addPlugins(group).run()`

---

## 6. Rollback Plan

如需回滚，使用 git:
```bash
git checkout HEAD -- src/haxe/app/
```

---

## 7. Estimated Effort

- **时间**: 2-3 小时
- **复杂度**: Medium
- **风险**: Low (核心类型都是新增/修改，不影响现有 ECS)

---

## 8. 示例用法

```haxe
// 定义插件
class MyPlugin extends LifecyclePlugin {
    public function new() {
        super('MyPlugin');
    }
    
    override function build(app:App):Void {
        app.addSystem(Update, () -> trace("Running!"));
    }
}

// 定义插件组
class GamePlugins implements PluginGroup {
    public function new() {}
    
    public function build():PluginGroupBuilder {
        return new PluginGroupBuilder('GamePlugins')
            .add(new MyPlugin())
            .add(new OtherPlugin());
    }
}

// 使用
class Main {
    static function main() {
        App.new()
            .addPlugin(new TaskPoolPlugin())
            .addPlugins(new GamePlugins())
            .run();
    }
}
```
