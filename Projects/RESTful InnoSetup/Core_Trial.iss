#define MyAppVersion "1.0"
#define MyAppPublisher "ORMBr"
#define MyAppURL "http://www.ormbr.com/"

[Setup]
PrivilegesRequired=admin
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName=C:\ORMBr\
SetupIconFile=D:\ORMBr\Projects\RESTful Install\ORMBrInstall_Icon.ico
Compression=lzma/max
SolidCompression=yes
AppCopyright=Copyright (C) 2018-2018 Isaque Pinhero, Inc.
AppContact=Isaque Pinheiro (isaquesp@gmail.com)
UserInfoPage = no

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Messages]
SelectDirBrowseLabel=Pra continuar, clique em Próximo. Informe a pasta que o ORMBr está instalado clicando em Procurar.

[Code]