# 卸载版核心：调用官方卸载入口，保证程序/驱动/注册表由官方安装器干净移除
param([string]$TargetDir = (Join-Path $env:ProgramFiles 'FxSound LLC\FxSound'))
$ErrorActionPreference = 'Continue'

$keys = @(
  'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
  'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
$entry = Get-ItemProperty $keys -ErrorAction SilentlyContinue |
         Where-Object { $_.DisplayName -like 'FxSound*' } |
         Select-Object -First 1

if ($entry) {
  Write-Host ">> 发现官方卸载项: $($entry.DisplayName) / $($entry.PSChildName)"
  $uninstall = $entry.UninstallString
  if ($uninstall -match 'msiexec') {
    $product = $entry.PSChildName
    Write-Host ">> msiexec /x $product /qn"
    $p = Start-Process msiexec.exe -ArgumentList @('/x', $product, '/qn', '/norestart') -Wait -PassThru
    Write-Host "   exit=$($p.ExitCode)"
  } else {
    Write-Host ">> 调用: $uninstall"
    $p = Start-Process -FilePath $uninstall -ArgumentList '/exenoui', '/qn', '/norestart' -Wait -PassThru
    Write-Host "   exit=$($p.ExitCode)"
  }
} else {
  Write-Host ">> 未发现 FxSound 卸载注册项，跳过官方卸载"
}

Write-Host ">> 卸载流程结束"
