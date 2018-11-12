program ORMBrServer;
{$APPTYPE GUI}

uses
  Vcl.Forms,
  Web.WebReq,
  IdHTTPWebBrokerBridge,
  uFormServer in 'uFormServer.pas' {Form1},
  uMasterServerModule in 'uMasterServerModule.pas' {apimaster: TDSServerModule},
  uWebModule in 'uWebModule.pas' {WebModule1: TWebModule},
  ormbr.model.client in '..\ormbr.model.client.pas',
  ormbr.model.detail in '..\ormbr.model.detail.pas',
  ormbr.model.lookup in '..\ormbr.model.lookup.pas',
  ormbr.model.master in '..\ormbr.model.master.pas',
  uLookupServerModule in 'uLookupServerModule.pas' {apilookup: TDSServerModule},
  uDataModuleServer in 'uDataModuleServer.pas' {DataModuleServer: TDataModule},
  ormbr.rest.query.parse in '..\..\..\..\Source\RESTful Components\Server\ormbr.rest.query.parse.pas',
  ormbr.server.datasnap in '..\..\..\..\Source\RESTful Components\Server\ormbr.server.datasnap.pas',
  ormbr.server.resource.datasnap in '..\..\..\..\Source\RESTful Components\Server\ormbr.server.resource.datasnap.pas',
  ormbr.server.resource in '..\..\..\..\Source\RESTful Components\Server\ormbr.server.resource.pas',
  ormbr.server.rest.manager in '..\..\..\..\Source\RESTful Components\Server\ormbr.server.rest.manager.pas',
  ormbr.server.rest.objectset in '..\..\..\..\Source\RESTful Components\Server\ormbr.server.rest.objectset.pas',
  ormbr.server.rest.session in '..\..\..\..\Source\RESTful Components\Server\ormbr.server.rest.session.pas';

{$R *.res}

begin
  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;
  Application.Initialize;
  Application.CreateForm(TDataModuleServer, DataModuleServer);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
