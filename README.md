# FxSound 中文预设增强版

把 [FxSound](https://www.fxsound.com) 官方安装包的预设**显示名**换成中文，并跟随官方正式版自动构建。
**非官方版本，与 FxSound LLC 无隶属关系，未获其背书。**

## 下载

见 [Releases](https://github.com/dx-y/fxsound-zh/releases)。

| 产物 | 说明 |
| --- | --- |
| `FxSound-zh-CN-<ver>-setup.exe` | 安装版：内嵌官方安装包，驱动、服务、更新任务均由官方安装器完成 |
| `FxSound-zh-CN-<ver>-portable.zip` | 便携版：官方程序文件 + 中文预设名 + 驱动安装/卸载脚本 |

## 改动范围

仅修改 `Factsoft\*.fac` 第 3 行的预设显示名。界面中文由官方安装包自带语言资源提供，
程序本体、音频处理与虚拟音频驱动均未做任何修改。

| 原名 | 中文 | 原名 | 中文 |
| --- | --- | --- | --- |
| General | 通用 | Music | 音乐 |
| Voice | 人声 | Volume Boost | 音量增强 |
| Gaming | 游戏 | Classic Processing | 经典处理 |
| Light Processing | 轻处理 | Bass Boost | 低音增强 |
| Streaming Video | 流媒体视频 | Movies | 电影 |
| TV | 电视 | Transcription | 语音转录 |
| Default | 默认 | | |

## 使用

- 安装版：运行 `FxSound-zh-CN-<ver>-setup.exe`，流程与官方一致。
- 便携版：解压后以管理员身份运行 `安装驱动.cmd`（不装驱动则无输出设备），再启动 `FxSound.exe`。

## 构建

| 工作流 | 触发 | 作用 |
| --- | --- | --- |
| `follow-upstream.yml` | 每日定时 / 手动 | 检查上游最新正式版，未构建过则下载官方包、注入中文预设名、产出两份包并上传 Artifact |
| `publish-release.yml` | 手动 | 把指定版本的 Artifact 发布为 Release |

## 说明

- 驱动与安装程序均为官方原件，数字签名未被改动；本项目不重签、不修改 `inf/sys/cat`。
- 仅供个人学习与自用，请支持官方正版：<https://www.fxsound.com>。
- 对应完整源码见上游仓库 [fxsound2/fxsound-app](https://github.com/fxsound2/fxsound-app)（AGPL-3.0）。

## 许可

本仓库的脚本与预设数据以 AGPL-3.0 发布。FxSound 名称、程序与驱动版权归 FxSound LLC 所有。
