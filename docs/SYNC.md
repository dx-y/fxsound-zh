# 发布与本地构建

## 发布流程

1. Actions → `follow-upstream` → Run workflow，频道选 `stable` 或 `beta`；需要重建同版本时勾 `force`。
2. 构建完成后记录产物名：`fxsound-zh-<version>`。
3. Actions → `publish-release` → Run workflow，`version` 填上一步的版本号；希望先自检再公开时勾 `draft`。
4. Release 标签为 `v<version>-zh`，包含 `setup.exe`、`portable.zip` 与 `VERSION.txt`。

## 校验

- `VERSION.txt` 记录上游 tag、发布日期与官方安装包 SHA256。
- 便携版压缩包的 SHA256 见 Artifact 内 `checksums/SHA256SUMS.txt`。

## 本地构建（不依赖 Actions）

```powershell
# 1. 下载官方安装包放到 vendor\fxsound_setup.exe
# 2. 解包
.\scripts\unpack_official.ps1 -SetupPath vendor\fxsound_setup.exe -WorkDir work\unpack
# 3. 写入中文预设名
python scripts\patch_presets.py --app-root work\unpack\files\...\FxSound
# 4. 便携版
.\packaging\make_portable.ps1 -AppRoot <上一步目录> -Version 1.2.17.0 -OutDir dist
# 5. 安装版
$env:FX_VERSION='1.2.17.0'; iscc packaging\installer.iss
```
