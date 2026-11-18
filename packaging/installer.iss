; FxSound 中文预设增强版 —— 安装版
; 设计：内嵌官方安装包，安装时先静默跑官方安装器（驱动/服务/更新任务全部由官方完成，
;       与官方安装体验一致），再把 Factsoft\*.fac 的预设名替换为中文；卸载走官方卸载入口。
#define AppVersion GetEnv('FX_VERSION')
#ifndef AppVersion
  #define AppVersion '0.0.0'
#endif

[Setup]
AppId={{8F3A2C71-2B4D-4E19-9A6E-7C1D9B4E5A02}
AppName=FxSound
AppVersion={#AppVersion}
AppVerName=FxSound {#AppVersion} 中文预设增强版
AppPublisher=FxSound LLC
AppPublisherURL=https://www.fxsound.com
AppSupportURL=https://github.com/dx-y/fxsound-zh
DefaultDirName={autopf}\FxSound LLC\FxSound
DisableDirPage=yes
DisableProgramGroupPage=yes
UninstallDisplayName=FxSound {#AppVersion} 中文预设增强版
UninstallDisplayIcon={app}\FxSound.exe
OutputDir=..\dist
OutputBaseFilename=FxSound-zh-CN-{#AppVersion}-setup
Compression=lzma2/max
SolidCompression=yes
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
WizardStyle=modern

[Languages]
Name: "chinesesimplified"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "..\vendor\fxsound_setup.exe"; DestDir: "{tmp}"; DestName: "fxsound_setup.exe"; Flags: deleteafterinstall
Source: "preset_names.tsv"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "install_core.ps1"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "uninstall_core.ps1"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "..\presets\zh\*.fac"; DestDir: "{tmp}\zh"; Flags: deleteafterinstall

[Run]
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{tmp}\install_core.ps1"" -OfficialSetup ""{tmp}\fxsound_setup.exe"" -PresetDir ""{tmp}\zh"" -TargetDir ""{app}"""; StatusMsg: "正在安装 FxSound 官方组件并注入中文预设..."; Flags: waituntilterminated runhidden

[UninstallRun]
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{tmp}\uninstall_core.ps1"""; Flags: runhidden waituntilterminated; RunOnceId: "FxSoundOfficialUninstall"
