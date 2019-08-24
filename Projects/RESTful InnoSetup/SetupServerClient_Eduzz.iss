; Script generated by the Inno Script Studio Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!
#include <.\Core_Eduzz.iss>

[Setup]
AppId={{286F16C1-BB84-4E10-BDBF-4080BDF3D227}
OutputBaseFilename=SetupServerClient_{#FrameworkName}

[Files]
Source: "..\RESTful Install\RESTfulInstall_{#FrameworkName}.exe"; DestDir: "{app}"; Flags: ignoreversion replacesameversion
Source: "..\..\Source\RESTful Components\Client\RestCoreClient.dres"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\RestClient{#FrameworkName}.dres"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\RestCoreClient.identcache"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\RestClient{#FrameworkName}.identcache"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\RestCoreClient.dproj.local"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\RestClient{#FrameworkName}.dproj.local"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\RestCoreClient.stat"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\RestClient{#FrameworkName}.stat"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\RestCoreClient.res"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\RestClient{#FrameworkName}.res"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\*.dfm"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\RestCoreClient.dpk"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\RestClient{#FrameworkName}.dpk"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\RestCoreClient.dproj"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\RestClient{#FrameworkName}.dproj"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Common\ormbr.rest.classes.pas"; DestDir: "{app}\Source\RESTful Components\Common\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\ormbr.client.about.pas"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\ormbr.client.base.pas"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\ormbr.client.consts.pas"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\ormbr.client.{#Framework}.pas"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\ormbr.client.{#Framework}.reg.pas"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\ormbr.client.interfaces.pas"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\ormbr.client.methods.pas"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\ormbr.client.pas"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\ormbr.client.reg.pas"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\ormbr.driver.rest.{#Framework}.pas"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\ormbr.driver.rest.pas"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\ormbr.factory.rest.{#Framework}.pas"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\ormbr.factory.rest.pas"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\ormbr.restobjectset.adapter.pas"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\ormbr.session.rest.pas"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\RestCoreClientResource.rc"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\RestClient{#FrameworkName}Resource.rc"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\Images\{#FrameworkName}.bmp"; DestDir: "{app}\Source\RESTful Components\Client\Images\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Client\RestClientGroup_{#FrameworkName}.groupproj"; DestDir: "{app}\Source\RESTful Components\Client\"; Flags: ignoreversion
;Server
Source: "..\..\Source\RESTful Components\Server\ormbr.rest.query.parse.pas"; DestDir: "{app}\Source\RESTful Components\Server\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Server\ormbr.server.resource.pas"; DestDir: "{app}\Source\RESTful Components\Server\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Server\ormbr.server.rest.manager.pas"; DestDir: "{app}\Source\RESTful Components\Server\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Server\ormbr.server.rest.objectset.pas"; DestDir: "{app}\Source\RESTful Components\Server\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Server\ormbr.server.rest.session.pas"; DestDir: "{app}\Source\RESTful Components\Server\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Server\ormbr.server.{#Framework}.pas"; DestDir: "{app}\Source\RESTful Components\Server\"; Flags: ignoreversion
Source: "..\..\Source\RESTful Components\Server\ormbr.server.resource.{#Framework}.pas"; DestDir: "{app}\Source\RESTful Components\Server\"; Flags: ignoreversion
;Exemplo
Source: "..\..\Demo\RESTFul via Driver\{#FrameworkName}\*.*"; DestDir: "{app}\Demo\RESTFul via Driver\{#FrameworkName}\"; Flags: ignoreversion
Source: "..\..\Demo\RESTFul via Driver\{#FrameworkName}\Client\*.*"; DestDir: "{app}\Demo\RESTFul via Driver\{#FrameworkName}\Client\"; Flags: ignoreversion
Source: "..\..\Demo\RESTFul via Driver\{#FrameworkName}\Server\*.*"; DestDir: "{app}\Demo\RESTFul via Driver\{#FrameworkName}\Server\"; Flags: ignoreversion
;Banco de dados
Source: "..\..\Demo\Data\Database\*.*"; DestDir: "{app}\Demo\RESTFul via Driver\Data\Database\"; Flags: ignoreversion

[Run]
Filename: "{app}\{#MyAppExeName}"; Flags: nowait postinstall skipifsilent runascurrentuser; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"