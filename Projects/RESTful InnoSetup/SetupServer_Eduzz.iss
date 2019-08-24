; Script generated by the Inno Script Studio Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!
#define MyAppName "ORMBr - REST Server Components"
#define MyAppExeName "ORMBrInstall.exe"
#define VersionApp "1.5.1"
#define CopyRight "Copyright (C) 2018-2019 Isaque Pinhero, Inc."
#define URL "https://www.ormbr.com.br"
#define ProductName "ORMBr RESTful Components"
#define Company "Tecsis Informática Ltda"
#define Contact "ormbrframework@gmail.com (Isaque Pinheiro)"
#define Phone "(27) 9 9903-6808"

;#define Framework = "datasnap"
;#define FrameworkName = "Datasnap"

;#define Framework = "MARS"
;#define FrameworkName = "MARS"

;#define Framework = "WiRL"
;#define FrameworkName = "WiRL"

;#define Framework = "DMVC"
;#define FrameworkName = "DelphiMVC"

#define Framework = "DWCore"
#define FrameworkName = "DWCore"

[Setup]
PrivilegesRequired=admin
DefaultDirName=C:\ORMBr\
SetupIconFile=..\RESTful Install\ORMBrInstall_Icon.ico
Compression=lzma/max
SolidCompression=yes
UserInfoPage = yes
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{973E6520-F357-44A1-9C03-A3AAAF3A0033}
OutputBaseFilename=SetupServer_{#FrameworkName}
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

[Files]
Source: "..\..\Source\RESTful Components\Common\ormbr.rest.classes.pas"; DestDir: "{app}\Source\RESTful Components\Common\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Server\ormbr.rest.query.parse.pas"; DestDir: "{app}\Source\RESTful Components\Server\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Server\ormbr.server.resource.pas"; DestDir: "{app}\Source\RESTful Components\Server\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Server\ormbr.server.rest.manager.pas"; DestDir: "{app}\Source\RESTful Components\Server\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Server\ormbr.server.rest.objectset.pas"; DestDir: "{app}\Source\RESTful Components\Server\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Server\ormbr.server.rest.session.pas"; DestDir: "{app}\Source\RESTful Components\Server\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Server\ormbr.server.{#Framework}.pas"; DestDir: "{app}\Source\RESTful Components\Server\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Server\ormbr.server.resource.{#Framework}.pas"; DestDir: "{app}\Source\RESTful Components\Server\"; Flags: ignoreversion
; Exemplo
Source: "..\..\Demo\RESTFul via Driver\{#FrameworkName}\*.*"; DestDir: "{app}\Demo\RESTFul via Driver\{#FrameworkName}\"; Flags: ignoreversion
Source: "..\..\Demo\RESTFul via Driver\{#FrameworkName}\Client\*.*"; DestDir: "{app}\Demo\RESTFul via Driver\{#FrameworkName}\Client\"; Flags: ignoreversion
Source: "..\..\Demo\RESTFul via Driver\{#FrameworkName}\Server\*.*"; DestDir: "{app}\Demo\RESTFul via Driver\{#FrameworkName}\Server\"; Flags: ignoreversion
; Banco de dados
Source: "..\..\Demo\Data\Database\*.*"; DestDir: "{app}\Demo\RESTFul via Driver\Data\Database\"; Flags: ignoreversion

[Run]
Filename: "{app}\{#MyAppExeName}"; Flags: nowait postinstall skipifsilent runascurrentuser; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"