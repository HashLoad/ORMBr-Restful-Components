program ORMBrClient;

uses
  Forms,
  SysUtils,
  uMainFormORM in 'uMainFormORM.pas' {Form3},
  ormbr.model.client in '..\ormbr.model.client.pas',
  ormbr.model.detail in '..\ormbr.model.detail.pas',
  ormbr.model.lookup in '..\ormbr.model.lookup.pas',
  ormbr.model.master in '..\ormbr.model.master.pas',
  ormbr.session.rest in '..\..\..\..\Source\RESTful Components\Client\ormbr.session.rest.pas',
  ormbr.client.horse in '..\..\..\..\Source\RESTful Components\Client\ormbr.client.horse.pas',
  ormbr.driver.rest.horse in '..\..\..\..\Source\RESTful Components\Client\ormbr.driver.rest.horse.pas',
  ormbr.factory.rest.horse in '..\..\..\..\Source\RESTful Components\Client\ormbr.factory.rest.horse.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
