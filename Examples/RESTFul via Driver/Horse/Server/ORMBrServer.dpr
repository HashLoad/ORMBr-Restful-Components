program ORMBrServer;
{$APPTYPE GUI}

uses
  Vcl.Forms,
  ormbr.model.client in '..\ormbr.model.client.pas',
  ormbr.model.detail in '..\ormbr.model.detail.pas',
  ormbr.model.lookup in '..\ormbr.model.lookup.pas',
  ormbr.model.master in '..\ormbr.model.master.pas',
  uDataModuleServer in 'uDataModuleServer.pas' {DataModuleServer: TDataModule},
  ormbr.server.horse in '..\..\..\..\Source\RESTful Components\Server\ormbr.server.horse.pas',
  ormbr.server.resource.horse in '..\..\..\..\Source\RESTful Components\Server\ormbr.server.resource.horse.pas',
  Main.Form in 'Main.Form.pas' {FrmVCL};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDataModuleServer, DataModuleServer);
  Application.CreateForm(TFrmVCL, FrmVCL);
  Application.Run;
end.
