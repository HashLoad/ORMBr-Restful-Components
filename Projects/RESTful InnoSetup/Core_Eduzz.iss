#define MyAppName "ORMBr - REST Server/Client Components"
#define MyAppExeName "RESTfulInstall"
#define VersionApp "1.5.1"
#define CopyRight "Copyright (C) 2018-2019 Isaque Pinhero, Inc."
#define URL "https://www.ormbr.com.br"
#define ProductName "ORMBr RESTful Components"
#define Company "Tecsis Informática Ltda"
#define Contact "ormbrframework@gmail.com (Isaque Pinheiro)"
#define Phone "(27) 9 9903-6808"

;#define Framework = "datasnap"
;#define FrameworkName = "DataSnap"
;#define Framework = "mars"
;#define FrameworkName = "MARS"
;#define Framework = "wirl"
;#define FrameworkName = "WiRL"
;#define Framework = "dmvc"
;#define FrameworkName = "DelphiMVC"
;#define Framework = "dwcore"
;#define FrameworkName = "DWCore"
#define Framework = "Horse"
#define FrameworkName = "Horse"

[Setup]
PrivilegesRequired=admin
DefaultDirName=C:\ORMBr\
SetupIconFile=..\RESTful Install\RESTfulInstall_Icon.ico
Compression=lzma/max
SolidCompression=yes
; UserInfoPage = yes
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppName={#MyAppName}
DefaultGroupName={#MyAppName}
AppCopyright={#CopyRight}
AppPublisher={#Company}
AppPublisherURL={#URL}
AppSupportURL={#URL}
AppUpdatesURL={#URL}
AppContact={#Contact}
AppVersion={#VersionApp}
AppVerName={#MyAppName} {#VersionApp}
UninstallDisplayName={#ProductName}
VersionInfoVersion={#VersionApp}
VersionInfoCompany={#Company}
VersionInfoCopyright={#CopyRight}
VersionInfoProductName={#ProductName}
AppSupportPhone={#Phone}

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Messages]
SelectDirBrowseLabel=Pra continuar, clique em Próximo. Informe a pasta que o ORMBr está instalado clicando em Procurar.

[Code]
function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = wpSelectDir then
  begin
    if not FileExists(WizardDirValue + '\Source\ormbr.inc') then
    begin
      MsgBox('Diretório selecionado, não é o mesmo dos fontes do ORMBr.', mbInformation, MB_OK);
      Result := False;
    end;
  end;
end;