# FxSound 中文预设增强版（私有自用）

跟随 [fxsound2/fxsound-app](https://github.com/fxsound2/fxsound-app) 官方最新版自动打包的汉化封装工程。
**上游本体开源（C++ / AGPL-3.0），本仓库只存放汉化数据与打包流水线，不存放上游源码二进制以外的任何商业资源。**

## 产物（每次构建同时出两份）

| 产物 | 说明 |
| --- | --- |
| `FxSound-zh-CN-<ver>-portable.zip` | 便携版：官方完整程序文件 + 中文预设名 + 驱动安装/卸载 cmd |
| `FxSound-zh-CN-<ver>-setup.exe` | 安装版：Inno 安装器内嵌官方安装包，安装流程与官方完全一致（驱动、服务、更新任务全由官方安装器完成），装完只多了预设名汉化 |

## 汉化范围

仅替换预设名（`Factsoft\*.fac` 第 3 行），界面中文由官方安装包自带（`Installer/Apps/Version13/dfxui_zh-CN.exe`），
因此自制包**不会出现界面变英文**的问题——我们是在官方成品上改名，不是从源码重编。

| 文件 | 官方名 | 汉化名 |
| --- | --- | --- |
| 1.fac | General | 通用 |
| 2.fac | Music | 音乐 |
| 3.fac | Voice | 人声 |
| 4.fac | Volume Boost | 音量增强 |
| 5.fac | Gaming | 游戏 |
| 6.fac | Classic Processing | 经典处理 |
| 7.fac | Light Processing | 轻处理 |
| 8.fac | Bass Boost | 低音增强 |
| 9.fac | Streaming Video | 流媒体视频 |
| 10.fac | Movies | 电影 |
| 11.fac | TV | 电视 |
| 12.fac | Transcription | 语音转录 |
| Default.fac | Default | 默认 |

## 流水线约定（重要）

- `follow-upstream.yml`：每天 03:17 UTC 检查上游最新正式版（或手动 `channel=beta`），
  已构建过的版本自动跳过；**只上传 Actions Artifact，绝不自动发 Release**。
- `publish-release.yml`：**仅手动触发**。只有主人明确说「同步」时，才用它把 Artifact 发布成 Release。
- 仓库保持 **private**，未授权前不改可见性。

## 目录

```
presets/zh/            13 个已汉化的 .fac 成品
presets/preset-map.json 上游名→中文名映射（脚本按文件名+行号定位，上游改名不影响）
scripts/fetch_upstream.py  探测上游版本 → GITHUB_OUTPUT
scripts/unpack_official.ps1 静默安装官方 setup.exe 后复制安装目录 → 定位程序目录（回退 7z+msiexec /a）
scripts/patch_presets.py   幂等注入中文预设名
packaging/make_portable.ps1 组装便携 zip + SHA256
packaging/install_core.ps1  安装版核心逻辑（官方静默安装 + 覆盖中文预设 + 失败回退交互安装）
packaging/uninstall_core.ps1 卸载时调用官方卸载入口，保证程序/驱动干净移除
packaging/installer.iss     Inno Setup 安装器工程
```

## 已知边界

- 安装版依赖官方安装器的静默参数（`/exenoui /qn` → `/quiet` → `/i /qn` 依次尝试，全失败则回退交互式安装），
  不同大版本若改打包器需同步调整 `install_core.ps1`。
- 便携版必须手动装一次虚拟音频驱动（`安装驱动.cmd`，调用上游自带 `fxdevcon64.exe install Drivers\win10\x64\fxvad.inf Root\FXVAD`），
  不装驱动则 FxSound 无输出设备。
- 上游驱动带官方签名，禁止重签或修改 inf/sys/cat。

## 许可

上游 FxSound 为 AGPL-3.0。本仓库为个人自用汉化封装，再分发须遵守 AGPL-3.0 并保留上游版权与源码获取方式。
