# 组装便携版
# 参数: -AppRoot <解包得到的 FxSound 程序目录> -Version <版本号> -OutDir <输出目录>
param([Parameter(Mandatory=$true)][string]$AppRoot,[Parameter(Mandatory=$true)][string]$Version,[Parameter(Mandatory=$true)][string]$OutDir)
$ErrorActionPreference = 'Stop'
$name = "FxSound-zh-CN-$Version-portable"
$stage = Join-Path $OutDir $name
New-Item -ItemType Directory -Force -Path $stage | Out-Null
Copy-Item (Join-Path $AppRoot '*') $stage -Recurse -Force

$readme = @"
FxSound 中文预设增强版（便携版）$Version
=====================================
1. 本目录 = 官方 $Version 完整程序文件 + 13 个中文预设名（汉化）。
2. FxSound 需要虚拟音频驱动才能工作，首次使用请右键"安装驱动.cmd"以管理员身份运行；
   或直接使用安装版（安装版会自动完成驱动安装，效果与官方安装一致）。
3. 卸载驱动：右键"卸载驱动.cmd"以管理员身份运行。
4. 预设名汉化清单：通用 / 音乐 / 人声 / 音量增强 / 游戏 / 经典处理 / 轻处理 / 低音增强 /
   流媒体视频 / 电影 / 电视 / 语音转录 / 默认。
"@
$readme | Out-File -FilePath (Join-Path $stage '说明.txt') -Encoding UTF8

$drvCmd = @"
@echo off
cd /d "%~dp0"
if exist "Drivers\Version13\dfx12.inf" (
  echo 正在安装 FxSound 虚拟音频驱动...
  "%~dp0Drivers\Version13\ptdevcon64.exe" install "%~dp0Drivers\Version13\dfx12.inf" Root\FXVAD
) else (
  echo 未找到驱动文件，请改用安装版。
)
pause
"@
$drvCmd | Out-File -FilePath (Join-Path $stage '安装驱动.cmd') -Encoding OEM

$unCmd = @"
@echo off
cd /d "%~dp0"
if exist "Drivers\Version13\ptdevcon64.exe" (
  "%~dp0Drivers\Version13\ptdevcon64.exe" remove Root\FXVAD
)
pause
"@
$unCmd | Out-File -FilePath (Join-Path $stage '卸载驱动.cmd') -Encoding OEM

$zip = Join-Path $OutDir "$name.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip -CompressionLevel Optimal
$sha = (Get-FileHash $zip -Algorithm SHA256).Hash
New-Item -ItemType Directory -Force -Path (Join-Path $OutDir 'checksums') | Out-Null
"$sha  $name.zip" | Out-File -FilePath (Join-Path $OutDir 'checksums\SHA256SUMS.txt') -Encoding ASCII
Write-Host "便携版: $zip ($([math]::Round((Get-Item $zip).Length/1MB,2)) MB)"
Write-Host "PORTABLE=$zip"
