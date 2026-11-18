# 取得官方安装包内的完整文件树，并定位 FxSound 程序根目录
# 参数: -SetupPath <setup.exe> -WorkDir <工作目录>
# 输出: APP_ROOT=<绝对路径> / FILE_VERSION=<FxSound.exe 文件版本>
#
# 说明：官方包由 Advanced Installer 打包（PE + 内嵌 CAB，7z 只能按 PE 读取，
# 无法直接展开 MSI），因此首选「静默安装 → 复制默认安装目录」，
# 这样拿到的文件与官方安装后完全一致；失败才回退 msiexec /a 或 7z 整树。
param([Parameter(Mandatory=$true)][string]$SetupPath, [Parameter(Mandatory=$true)][string]$WorkDir)
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null

$setupAbs = (Resolve-Path $SetupPath).Path
$appDir = Join-Path $WorkDir 'app'
$defaultDst = 'C:\Program Files\FxSound LLC\FxSound'
New-Item -ItemType Directory -Force -Path $appDir | Out-Null

Write-Host ">> 策略1：静默安装官方包（/exenoui /qn）"
$proc = Start-Process -FilePath $setupAbs -ArgumentList '/exenoui', '/qn', '/norestart' -PassThru
if (-not $proc.WaitForExit(900000)) {
  Write-Host "   安装器 900s 未退出，强杀"
  try { $proc.Kill() } catch {}
} else {
  Write-Host "   安装器 exit=$($proc.ExitCode)"
}
Start-Sleep -Seconds 3

if (Test-Path (Join-Path $defaultDst 'FxSound.exe')) {
  Write-Host ">> 官方文件已落地：$defaultDst，开始复制"
  robocopy $defaultDst $appDir /E /NFL /NDL /NJH /NJS /NP | Out-Null
  Write-Host "   robocopy exit=$LASTEXITCODE"
}

$exe = Get-ChildItem $appDir -Recurse -Filter 'FxSound.exe' -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $exe) {
  Write-Host ">> 策略1 失效，回退策略2：7z 拆包 + msiexec /a"
  $sevenZip = 'C:\Program Files\7-Zip\7z.exe'
  if (-not (Test-Path $sevenZip)) {
    $cand = (Get-Command 7z -ErrorAction SilentlyContinue).Source
    if ($cand) { $sevenZip = $cand } else { $sevenZip = '7z' }
  }
  $bootDir = Join-Path $WorkDir 'bootstrapper'
  New-Item -ItemType Directory -Force -Path $bootDir | Out-Null
  & $sevenZip x $setupAbs "-o$bootDir" -y | Out-Null
  $msi = Get-ChildItem $bootDir -Recurse -Filter *.msi -ErrorAction SilentlyContinue | Select-Object -First 1
  $extractDir = Join-Path $WorkDir 'files'
  New-Item -ItemType Directory -Force -Path $extractDir | Out-Null
  if ($msi) {
    Write-Host "   找到 MSI: $($msi.FullName)，管理员展开"
    $log = Join-Path $WorkDir 'msiexec-admin.log'
    $mp = Start-Process msiexec.exe -ArgumentList @('/a', "`"$($msi.FullName)`"", '/qn', "TARGETDIR=`"$extractDir`"", '/L*v', "`"$log`"") -Wait -PassThru
    Write-Host "   msiexec exit=$($mp.ExitCode)"
    Copy-Item (Join-Path $extractDir '*') $appDir -Recurse -Force -ErrorAction SilentlyContinue
  } else {
    Write-Host "   未发现 MSI，直接把 bootstrapper 内容作为文件树"
    Copy-Item (Join-Path $bootDir '*') $appDir -Recurse -Force -ErrorAction SilentlyContinue
  }
  $exe = Get-ChildItem $appDir -Recurse -Filter 'FxSound.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
}

if (-not $exe) {
  Write-Host "!! 未找到 FxSound.exe，目录树前 40 项："
  Get-ChildItem $appDir -Recurse -Depth 3 -ErrorAction SilentlyContinue | Select-Object -First 40 FullName | ForEach-Object { Write-Host "   $($_.FullName)" }
  throw 'APP_ROOT 定位失败'
}

$appRoot = $exe.Directory.FullName
$fileVersion = $exe.VersionInfo.FileVersion
Write-Host ">> APP_ROOT=$appRoot"
Write-Host ">> FILE_VERSION=$fileVersion"
if (Test-Path (Join-Path $appRoot 'Drivers')) {
  Write-Host ">> 驱动目录存在"
  Get-ChildItem (Join-Path $appRoot 'Drivers') -Directory -ErrorAction SilentlyContinue | Select-Object -First 6 Name | ForEach-Object { Write-Host "   Drivers\$($_.Name)" }
} else {
  Write-Host "!! 注意：安装目录内未发现 Drivers 子目录"
}
Get-ChildItem (Join-Path $appRoot 'Factsoft') -Filter '*.fac' -ErrorAction SilentlyContinue | Measure-Object | ForEach-Object { Write-Host ">> 预设文件数: $($_.Count)" }

Write-Output "APP_ROOT=$appRoot"
Write-Output "FILE_VERSION=$fileVersion"
