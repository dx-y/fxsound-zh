#define AppVersion GetEnv('FX_VERSION')
#ifndef AppVersion
  #define AppVersion '0.0.0'
#endif

[Setup]
AppId={{8F3A2C71-2B4D-4E19-9A6E-7C1D9B4E5A02}}
AppName=FxSound 中文预设增强版
AppVersion={#AppVersion}
AppPublisher=FxSound LLC / 汉化封装 dx-y
AppPublisherURL=https://www.fxsound.com
DefaultDirName={autopf}\FxSound LLC\FxSound
DisableDirPage=yes
UninstallDisplayName=FxSound 中文预设增强版 {#AppVersion}
OutputDir=..\dist
OutputBaseFilename=FxSound-zh-CN-{#AppVersion}-setup
Compression=lzma2/max
SolidCompression=yes
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
WizardStyle=modern

[Files]
Source: "..\vendor\fxsound_setup.exe"; DestDir: "{tmp}"; DestName: "fxsound_setup.exe"; Flags: deleteafterinstall
Source: "preset_names.tsv"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "install_core.ps1"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "..\presets\zh\*.fac"; DestDir: "{tmp}\zh"; Flags: deleteafterinstall

[Run]
Filename: "powershell.exe"; \
  Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{tmp}\install_core.ps1"" -OfficialSetup ""{tmp}\fxsound_setup.exe"" -PresetDir ""{tmp}\zh"" -TargetDir ""{app}"""; \
  StatusMsg: "正在安装 FxSound 官方组件并注入中文预设..."; \
  Flags: waituntilterminated runhidden

[UninstallRun]
Filename: "powershell.exe"; \
  Parameters: "-NoProfile -ExecutionPolicy Bypass -Command ""$k = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like 'FxSound*' } | Select-Object -First 1; if ($k -and $k.UninstallString) { Start-Process msiexec.exe -ArgumentList ('/x ' + ($k.PSChildName)) -Wait }"""; \
  Flags: runhidden waituntilterminated
