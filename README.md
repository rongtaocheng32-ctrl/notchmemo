# NotchMemo（岛上待办）

NotchMemo 是一款 macOS 原生的轻量计划与专注工具。它解决“待办事项太多、注意力不断切换”的问题：每天只保留三项重点，并在任务完成或番茄钟结束时通过 MacBook 刘海区域显示即时反馈。

## 主要功能

- 最多记录三项“今日重点”，支持完成、取消完成与删除。
- 一键清理当天已经完成的任务，为新重点腾出位置。
- 25 分钟番茄钟，支持开始、暂停和重置。
- 任务完成与计时结束时显示灵动岛式提示。
- 随手记文本区。
- 任务和笔记使用 `UserDefaults` 保存在本机。
- 菜单栏可快速查看任务和控制计时器。
- 无刘海的 Mac 会由 DynamicNotchKit 自动使用悬浮胶囊样式。

## 安装方法

要求：macOS 13 或更高版本、Swift 6 / Xcode 16 或更高版本。

```bash
git clone https://github.com/rongtaocheng32-ctrl/notchmemo.git
cd notchmemo
swift build
```

首次构建会通过 Swift Package Manager 下载 DynamicNotchKit。

## 使用方法

```bash
swift run NotchMemo
```

1. 在“今日重点”输入任务并按回车或点击“添加”。
2. 点击任务左侧圆圈将其标记完成；刘海区域会出现完成反馈。
3. 出现已完成任务后，可点击“清理已完成任务”批量移除。
4. 点击“开始”启动 25 分钟计时。
5. 在“随手记”输入临时想法，内容会自动保存。

## 输入输出示例

输入：

```text
今日重点：完成作品集首页
随手记：明天补充移动端截图
操作：点击任务左侧圆圈
```

输出：

```text
任务状态：已完成（1/1）
灵动岛提示：完成一项重点 · 完成作品集首页
本地保存：任务与笔记在重新启动后恢复
```

## 开源与致谢

本项目代码使用 MIT License。灵动岛窗口能力由 Kai Azim 的 [DynamicNotchKit](https://github.com/MrKai77/DynamicNotchKit) 提供，该依赖同样使用 MIT License。详见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。
