# 同步到 GitHub Release 的操作步骤

默认行为：**不发布**。仓库只积累 Artifact。

## 何时发布

主人明确说「同步」（或「发布」「发 Release」）时才执行。

## 步骤

1. 打开 Actions → `follow-upstream` → Run workflow，选 `stable` 或 `beta`；如需重建同版本勾 `force`。
2. 等构建完成，记下 Artifact 名：`fxsound-zh-<version>`。
3. Actions → `publish-release` → Run workflow：
   - `version` 填第 2 步的版本号
   - `draft` 默认 true（先草稿，确认后再手动公开）
4. 生成 Release：tag `v<version>-zh`，附便携 zip、安装 setup.exe、VERSION.txt。

## 校验

- `VERSION.txt` 内含上游 tag、发布日期、官方安装包 SHA256。
- 便携版 zip 的 SHA256 见 Artifact 内 `checksums/SHA256SUMS.txt`。

## 手动本地构建（不依赖 Actions）

```powershell
# 1. 下载官方安装包放到 vendor\fxsound_setup.exe
# 2. 解包
.\scripts\unpack_official.ps1 -SetupPath vendor\fxsound_setup.exe -WorkDir work\unpack
# 3. 汉化
python scripts\patch_presets.py --app-root work\unpack\files\...\FxSound
# 4. 便携版
.\packaging\make_portable.ps1 -AppRoot <上一步目录> -Version 1.2.17.0 -OutDir dist
# 5. 安装版
$env:FX_VERSION='1.2.17.0'; & "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" packaging\installer.iss
```
