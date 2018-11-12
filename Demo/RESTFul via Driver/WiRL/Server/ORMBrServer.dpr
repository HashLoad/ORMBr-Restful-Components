{******************************************************************************}
{                                                                              }
{       WiRL: RESTful Library for Delphi                                       }
{                                                                              }
{       Copyright (c) 2015-2017 WiRL Team                                      }
{                                                                              }
{       https://github.com/delphi-blocks/WiRL                                  }
{                                                                              }
{******************************************************************************}
program ORMBrServer;

uses
  Forms,
  Server.Forms.Main in 'Server.Forms.Main.pas' {MainForm},
  Server.Resources in 'Server.Resources.pas',
  ormbr.model.client in '..\ormbr.model.client.pas',
  ormbr.model.detail in '..\ormbr.model.detail.pas',
  ormbr.model.lookup in '..\ormbr.model.lookup.pas',
  ormbr.model.master in '..\ormbr.model.master.pas',
  Server.Datamodule in 'Server.Datamodule.pas' {ServerDataModule: TDataModule},
  ormbr.rest.query.parse in '..\..\..\..\Source\RESTful Components\Server\ormbr.rest.query.parse.pas',
  ormbr.server.resource in '..\..\..\..\Source\RESTful Components\Server\ormbr.server.resource.pas',
  ormbr.server.resource.wirl in '..\..\..\..\Source\RESTful Components\Server\ormbr.server.resource.wirl.pas',
  ormbr.server.rest.manager in '..\..\..\..\Source\RESTful Components\Server\ormbr.server.rest.manager.pas',
  ormbr.server.rest.objectset in '..\..\..\..\Source\RESTful Components\Server\ormbr.server.rest.objectset.pas',
  ormbr.server.rest.session in '..\..\..\..\Source\RESTful Components\Server\ormbr.server.rest.session.pas',
  ormbr.server.wirl in '..\..\..\..\Source\RESTful Components\Server\ormbr.server.wirl.pas',
  ormbr.dml.generator.sqlite in '..\..\..\..\Source\Core\ormbr.dml.generator.sqlite.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TServerDataModule, ServerDataModule);
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
