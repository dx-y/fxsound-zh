# 安装版核心：先跑官方安装器（保真：驱动/服务/更新任务全部由官方完成），再把预设名换成中文
# 由 Inno Setup 安装器以管理员身份调用
param(
  [Parameter(Mandatory=$true)][string]$OfficialSetup,
  [Parameter(Mandatory=$true)][string]$PresetDir,
  [string]$TargetDir = (Join-Path $env:ProgramFiles 'FxSound LLC\FxSound')
)
$ErrorActionPreference = 'Continue'
$exe = Join-Path $TargetDir 'FxSound.exe'

function Try-Silent([string]$argList) {
  Write-Host ">> 尝试官方安装参数: $argList"
  try {
    $p = Start-Process -FilePath $OfficialSetup -ArgumentList $argList -Wait -PassThru
    Write-Host "   exit=$($p.ExitCode)"
  } catch { Write-Host "   异常: $($_.Exception.Message)" }
  Start-Sleep -Seconds 2
  return (Test-Path $exe)
}

$ok = $false
foreach ($a in @('/exenoui /qn', '/quiet', '/i /qn')) {
  if (Try-Silent $a) { $ok = $true; break }
}
if (-not $ok) {
  Write-Host ">> 静默安装未生效，回退到官方交互式安装（请按提示操作）"
  Start-Process -FilePath $OfficialSetup -Wait
  Start-Sleep -Seconds 2
  $ok = Test-Path $exe
}
if (-not $ok) { throw "官方安装未完成，未找到 $exe" }

# 注入中文预设名
$fac = Join-Path $TargetDir 'Factsoft'
if (-not (Test-Path $fac)) { throw "未找到预设目录 $fac" }
$map = @{}
Get-Content (Join-Path $PSScriptRoot 'preset_names.tsv') -Encoding UTF8 | ForEach-Object {
  $kv = $_ -split "`t"
  if ($kv.Count -ge 2) { $map[$kv[0]] = $kv[1] }
}
$changed = 0
foreach ($k in $map.Keys) {
  $f = Join-Path $fac $k
  if (-not (Test-Path $f)) { continue }
  $lines = [System.IO.File]::ReadAllLines($f, [System.Text.Encoding]::UTF8)
  if ($lines.Count -lt 3) { continue }
  if ($lines[2] -ne $map[$k]) {
    $lines[2] = $map[$k]
    [System.IO.File]::WriteAllLines($f, $lines, (New-Object System.Text.UTF8Encoding($false)))
    $changed++
  }
}
Write-Host ">> 中文预设注入完成，改动 $changed 个文件"
