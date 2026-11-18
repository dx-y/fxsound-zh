# 组装便携版：官方完整程序文件 + 中文预设名 + 驱动安装/卸载脚本
# 用法: .\make_portable.ps1 -AppRoot <FxSound 程序目录> -Version <版本号> -OutDir <输出目录>
param(
  [Parameter(Mandatory=$true)][string]$AppRoot,
  [Parameter(Mandatory=$true)][string]$Version,
  [Parameter(Mandatory=$true)][string]$OutDir
)
$ErrorActionPreference = 'Stop'
$name  = "FxSound-zh-CN-$Version-portable"
$stage = Join-Path $OutDir $name
New-Item -ItemType Directory -Force -Path $stage | Out-Null
Copy-Item (Join-Path $AppRoot '*') $stage -Recurse -Force

# ---- 定位官方驱动文件（按已知布局优先，避免递归误取）----
$infCandidates = @(
  'Drivers\win10\x64\fxvad.inf',
  'Drivers\win10\x86\fxvad.inf',
  'Drivers\win7\x64\fxvad.inf',
  'Drivers\win7\x86\fxvad.inf',
  'Drivers\Version13\dfx12.inf'
)
$infRel = $null
foreach ($c in $infCandidates) {
  if (Test-Path (Join-Path $stage $c)) { $infRel = $c; break }
}
if (-not $infRel) {
  $hit = Get-ChildItem -Path $stage -Recurse -File -Filter '*.inf' -ErrorAction SilentlyContinue |
         Where-Object { $_.Name -match '^(fxvad|dfx)' } | Select-Object -First 1
  if ($hit) { $infRel = $hit.FullName.Substring($stage.Length + 1) }
}
if (-not $infRel) { throw "未找到驱动 inf 文件，无法生成驱动安装脚本" }

$infDir = Split-Path $infRel -Parent
$devRel = $null
foreach ($n in @('fxdevcon64.exe','fxdevcon32.exe','ptdevcon64.exe','ptdevcon32.exe')) {
  $try1 = if ($infDir) { Join-Path $infDir $n } else { $n }
  if (Test-Path (Join-Path $stage $try1)) { $devRel = $try1; break }
}
if (-not $devRel) {
  foreach ($n in @('ptdevcon64.exe','ptdevcon32.exe','fxdevcon64.exe','fxdevcon32.exe')) {
    $hit = Get-ChildItem -Path $stage -Recurse -File -Filter $n -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($hit) { $devRel = $hit.FullName.Substring($stage.Length + 1); break }
  }
}
if (-not $devRel) { throw "未找到 devcon 驱动安装器（fxdevcon/ptdevcon）" }
Write-Host ">> 驱动 inf = $infRel"
Write-Host ">> 驱动 devcon = $devRel"

$readme = @"
FxSound 中文预设增强版（便携版）$Version
========================================
1. 本目录 = 官方 $Version 完整程序文件 + 13 个中文预设名（仅汉化预设名，其余与官方一致）。
2. FxSound 需要虚拟音频驱动才能出声：首次使用请右键「安装驱动.cmd」→ 以管理员身份运行。
   不想手动装驱动？直接用安装版，安装流程与官方一致，驱动自动装好。
3. 卸载驱动：右键「卸载驱动.cmd」以管理员身份运行。
4. 预设名对照：通用 / 音乐 / 人声 / 音量增强 / 游戏 / 经典处理 / 轻处理 / 低音增强 /
   流媒体视频 / 电影 / 电视 / 语音转录 / 默认。
"@
$readme | Out-File -FilePath (Join-Path $stage '说明.txt') -Encoding UTF8

$drvCmd = @"
@echo off
chcp 65001 >nul
cd /d "%~dp0"
if not exist "%~dp0$devRel" goto NODRV
if not exist "%~dp0$infRel" goto NODRV
echo 正在安装 FxSound 虚拟音频驱动（需管理员权限）...
"%~dp0$devRel" install "%~dp0$infRel" Root\FXVAD
if errorlevel 1 (
  echo 驱动安装失败：可改用安装版，由官方安装器自动完成。
) else (
  echo 驱动安装完成，现在可以运行 FxSound.exe。
)
pause
exit /b 0
:NODRV
echo 未找到驱动文件（$infRel / $devRel），请改用安装版。
pause
"@
$drvCmd | Out-File -FilePath (Join-Path $stage '安装驱动.cmd') -Encoding Default

$unCmd = @"
@echo off
chcp 65001 >nul
cd /d "%~dp0"
if exist "%~dp0$devRel" "%~dp0$devRel" remove Root\FXVAD
echo 已尝试移除 FxSound 虚拟音频驱动。
pause
"@
$unCmd | Out-File -FilePath (Join-Path $stage '卸载驱动.cmd') -Encoding Default

$zip = Join-Path $OutDir "$name.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($stage, $zip, [System.IO.Compression.CompressionLevel]::Optimal, $true)
$len = [math]::Round((Get-Item $zip).Length / 1MB, 2)
$sha = (Get-FileHash $zip -Algorithm SHA256).Hash
New-Item -ItemType Directory -Force -Path (Join-Path $OutDir 'checksums') | Out-Null
"$sha  $name.zip" | Out-File -FilePath (Join-Path $OutDir 'checksums\SHA256SUMS.txt') -Encoding ASCII
Write-Host "便携版: $zip ($len MB)"
Write-Host "PORTABLE=$zip"
