# Roblox 灵动岛

[English](README.md) | [中文](README_CN.md)

仿照 iOS 灵动岛设计的现代化 Roblox 通知系统。

## 功能特性

- **多通知显示**：最多同时显示3个通知
- **智能队列**：自动队列管理，支持优先级
- **交互动画**：流畅的过渡效果和果冻动画
- **主题切换**：内置深色和浅色主题
- **触控优化**：完美适配手机和电脑
- **可拖动**：自由移动灵动岛位置
- **历史记录**：查看最近的通知

## 安装方法

```lua
local DynamicIsland = loadstring(game:HttpGet("你的脚本URL"))()
```

## 快速开始

```lua
-- 显示通知
_G.ShowIslandNotification("标题", "内容", "success", 3)

-- 可用类型：success, error, warning, info
```

## API 文档

### ShowIslandNotification
```lua
_G.ShowIslandNotification(title, content, type, duration, priority)
```

**参数说明：**
- `title`（字符串）：通知标题
- `content`（字符串）：通知内容
- `type`（字符串）：通知类型 - "success"、"error"、"warning" 或 "info"
- `duration`（数字）：显示时长，单位秒（默认：3.5）
- `priority`（数字）：队列优先级（默认：1，高优先级：>5）

### ToggleTheme
```lua
_G.DynamicIsland.ToggleTheme()
```
切换深色/浅色主题。

### ToggleVisibility
```lua
_G.DynamicIsland.ToggleVisibility()
```
显示或隐藏灵动岛。

### ShowHistory
```lua
_G.DynamicIsland.ShowHistory()
```
查看最近的通知历史。

### Destroy
```lua
_G.DynamicIsland.Destroy()
```
清理并移除灵动岛。

## 配置选项

```lua
local Config = {
    DemoMode = false,
    DefaultNotifDuration = 3.5,
    MaxHistoryCount = 10,
    MaxQueueSize = 20,
    MaxConcurrentNotifications = 3,
    NotificationSpacing = 10,
}
```

## 交互方式

- **单击**：触发菜单（K键）
- **双击**：切换主题
- **长按**：查看通知历史
- **拖动**：移动灵动岛
- **悬停**：显示关闭按钮

## 使用示例

### 基础通知
```lua
_G.ShowIslandNotification("成功", "操作完成", "success")
_G.ShowIslandNotification("错误", "出现问题", "error")
_G.ShowIslandNotification("警告", "请注意", "warning")
_G.ShowIslandNotification("提示", "新消息", "info")
```

### 自定义时长
```lua
_G.ShowIslandNotification("加载中", "请稍候...", "info", 10)
```

### 高优先级
```lua
_G.ShowIslandNotification("紧急", "重要消息", "error", 5, 10)
```

### 批量通知
```lua
for i = 1, 5 do
    _G.ShowIslandNotification("消息 " .. i, "内容", "info", 3)
    task.wait(0.2)
end
```

## 平台支持

- 电脑端（Windows、macOS、Linux）
- 手机端（iOS、Android）
- 平板设备

## 性能优化

- 优化的内存管理
- 自动清理过期通知
- 高效的动画处理
- 无内存泄漏

## 技术细节

- **UI 框架**：Roblox GUI
- **动画系统**：TweenService
- **移动端支持**：触控和拖动优化
- **安全检测**：环境验证

## 贡献指南

欢迎贡献代码。提交前请确保代码质量并充分测试。

## 开源协议

MIT License - 可自由用于项目中。

## 作者

**xiaomao**

## 更新日志

### 版本 1.0
- 首次发布
- 多通知支持（最多3个并发）
- 交互式动画
- 主题系统
- 优先级队列
- 历史记录
- 移动端优化
- 拖拽功能

## 技术支持

如有问题或建议，请在 GitHub 提交 Issue。

---

**注意**：这是客户端脚本。在生产环境中使用时请确保适当的安全措施。

