!include "FileFunc.nsh"
!include "LogicLib.nsh"

Name "TinyTestInstaller"
OutFile "TinyTestSetup.exe"
InstallDir "$PROGRAMFILES\TinyTest"
RequestExecutionLevel admin

SilentInstall normal   ; ← can be overridden with /S
SilentUnInstall normal

Var /GLOBAL InstDirCustom
Var /GLOBAL FeatureX

Section "Main"
  SetOutPath "$InstDir"

  ; Fake "installation"
  FileOpen $0 "$InstDir\installed.txt" w
  FileWrite $0 "Installed at: $InstDir$\r$\n"
  FileWrite $0 "Timestamp: ${__TIMESTAMP__}$\r$\n"

  ${If} $FeatureX == "yes"
    FileWrite $0 "FeatureX was enabled$\r$\n"
  ${Else}
    FileWrite $0 "FeatureX was NOT enabled$\r$\n"
  ${EndIf}

  ${If} $InstDirCustom != ""
    FileWrite $0 "Custom dir requested: $InstDirCustom$\r$\n"
  ${EndIf}

  FileClose $0

  WriteUninstaller "$InstDir\uninstall.exe"
SectionEnd

Section "Uninstall"
  Delete "$InstDir\installed.txt"
  Delete "$InstDir\uninstall.exe"
  RMDir "$InstDir"
SectionEnd

Function .onInit
  ${GetParameters} $R0

  ; /S = silent (NSIS built-in)
  ${GetOptions} $R0 "/S" $1
  ${IfNot} ${Errors}
    SetSilent silent
  ${EndIf}

  ; Custom parameters examples
  ${GetOptions} $R0 "/DIR=" $InstDirCustom
  ${IfNot} ${Errors}
    StrCpy $InstDir $InstDirCustom
  ${EndIf}

  ${GetOptions} $R0 "/FEATUREX" $1
  ${IfNot} ${Errors}
    StrCpy $FeatureX "yes"
  ${EndIf}

  ; You can add more: /TOKEN=abc123 /MODE=server etc.
FunctionEnd