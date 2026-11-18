# 从官方 setup.exe 解包出完整文件树，并定位 FxSound 程序根目录
# 参数: -SetupPath <setup.exe> -WorkDir <工作目录>
# 输出: 最后一行为 APP_ROOT=<绝对路径>
param([Parameter(Mandatory=$true)][string]$SetupPath, [Parameter(Mandatory=$true)][string]$WorkDir)
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null
$bootDir = Join-Path $WorkDir 'bootstrapper'
New-Item -ItemType Directory -Force -Path $bootDir | Out-Null

$sevenZip = 'C:\Program Files\7-Zip\7z.exe'
if (-not (Test-Path $sevenZip)) {
  $cand = (Get-Command 7z -ErrorAction SilentlyContinue).Source
  if ($cand) { $sevenZip = $cand } else { $sevenZip = '7z' }
}

Write-Host ">> 解包 outer bootstrapper"
& $sevenZip x $SetupPath "-o$bootDir" -y | Out-Null

$msi = Get-ChildItem $bootDir -Recurse -Filter *.msi -ErrorAction SilentlyContinue | Select-Object -First 1
$extractDir = Join-Path $WorkDir 'files'
New-Item -ItemType Directory -Force -Path $extractDir | Out-Null

if ($msi) {
  Write-Host ">> 找到 MSI: $($msi.FullName)，执行管理员安装展开"
  $log = Join-Path $WorkDir 'msiexec-admin.log'
  $p = Start-Process msiexec.exe -ArgumentList @('/a', "`"$($msi.FullName)`"", '/qn', "TARGETDIR=`"$extractDir`"", '/L*v', "`"$log`"") -Wait -PassThru
  Write-Host "   msiexec exit=$($p.ExitCode)"
} else {
  Write-Host ">> 未发现 MSI，直接把 bootstrapper 内容作为文件树"
  Copy-Item (Join-Path $bootDir '*') $extractDir -Recurse -Force
}

$exe = Get-ChildItem $extractDir -Recurse -Filter 'FxSound.exe' -ErrorAction SilentlyContinue |
       Sort-Object { $_.FullName.Length } | Select-Object -First 1
if (-not $exe) {
  Write-Host "!! 未在解包结果中找到 FxSound.exe，目录树前 40 项："
  Get-ChildItem $extractDir -Recurse -Depth 3 | Select-Object -First 40 FullName | ForEach-Object { Write-Host "   $($_.FullName)" }
  throw 'APP_ROOT 定位失败'
}
$appRoot = $exe.Directory.FullName
Write-Host ">> APP_ROOT=$appRoot"
Write-Host "APP_ROOT=$appRoot"
