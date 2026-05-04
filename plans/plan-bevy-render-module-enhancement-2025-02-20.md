# Bevy Render Module Enhancement Plan

## Overview

完善 bevy_render 模块，增强现有 Haxe 代码以更好地匹配 Rust bevy_render 架构。

**目标:**
- Camera 管理视图投影矩阵 - 已有基础，需要增强
- Projection 支持透视/正交 - 已有，需要完善
- Mesh 存储顶点数据 - 已有，需要增强
- RenderContext 渲染上下文 - 已有，需要完善
- RenderModule 模块化 - 需要增强

## 已有文件分析

| 文件 | 状态 | 行数 | 需要改进 |
|------|------|------|----------|
| RenderContext.hx | 已有 | 603 | 增强 |
| Camera.hx | 已有 | 162 | 增强 |
| Projection.hx | 已有 | 215 | 完善 |
| Mesh.hx | 已有 | 588 | 增强 |
| RenderModule.hx | 已有 | 39 | 增强 |

## 参考 Rust 模块

从 `/home/vscode/projects/bevy/crates/bevy_render/src/` 参考:
- `camera.rs` - 相机系统
- `renderer/render_context.rs` - 渲染上下文
- `mesh/mod.rs` - 网格系统
- `view/mod.rs` - 视图系统

## Implementation Steps

### Step 1: 增强 Projection.hx
- 添加 `CameraProjection` 接口
- 增强 `PerspectiveProjection` 和 `OrthographicProjection`
- 添加 `getViewProjection()` 方法支持
- 添加 `flipY()` 和 `recalc_aspect_ratio()` 方法

### Step 2: 增强 Camera.hx
- 添加 `CameraProjection` 实现
- 添加 `camera3d` / `camera2d` 标记
- 增强 `Frustum` 可见性检测
- 添加 `Viewport` 支持
- 添加 `Msaa` / `OutputMode` 支持
- 完善视图投影矩阵计算

### Step 3: 增强 Mesh.hx
- 添加 `RenderMesh` 结构
- 添加 `MeshVertexBufferLayouts` 资源
- 增强 `Mesh` 资产的 GPU 准备
- 添加 `Indices` 联合类型支持
- 添加 `VertexAttributeValues` 支持

### Step 4: 增强 RenderContext.hx
- 添加 `RenderDevice` / `RenderQueue` 接口
- 添加 `PendingCommandBuffers` 资源
- 增强 `ViewQuery` / `ViewProjection` 支持
- 添加 `TrackedRenderPass` 支持

### Step 5: 增强 RenderModule.hx
- 添加模块导出
- 添加 `RenderPlugin` 入口
- 添加模块初始化逻辑

## File Changes Summary

| 操作 | 文件路径 |
|------|----------|
| 修改 | src/haxe/render/Projection.hx |
| 修改 | src/haxe/render/Camera.hx |
| 修改 | src/haxe/render/Mesh.hx |
| 修改 | src/haxe/render/RenderContext.hx |
| 修改 | src/haxe/render/RenderModule.hx |

## Testing Strategy

1. 编译测试：`haxe --no-output project.hxml`
2. 类型检查：确保所有接口正确
3. 示例代码：验证 API 可用性

## Rollback Plan

- 使用 Git 管理版本
- 每次修改前确保文件已保存
- 如有问题，参考 Rust 源码恢复

## Estimated Effort

- **时间**: 2-3 小时
- **复杂度**: 中等
- **优先级**: 高

---

*Created: 2025-02-20*
