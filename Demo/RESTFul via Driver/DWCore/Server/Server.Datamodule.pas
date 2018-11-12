unit Server.Datamodule;

interface

uses
  Windows,
  SysUtils,
  StrUtils,
  Classes,
  SysTypes,
  Generics.Collections,

  uDWJSONObject,
  uDWConsts,
  uDWConstsData,
  UDWDatamodule,
  uDWMassiveBuffer,
  uDWAbout,
  uRESTDWServerEvents,

  JSON,
  /// ORMBr JSON
  ormbr.rest.json,
  ormbr.json.utils,

  Server.Resources,

  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Comp.UI, uRESTDWPoolerDB, uRESTDWServerContext;

type
{$METHODINFO ON}
  TServerDataModule = class(TServerMethodDataModule)
    FDConnection1: TFDConnection;
    Master: TDWServerEvents;
    Lookup: TDWServerEvents;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    procedure MasterEventsselectidReplyEvent(
      var Params: TDWParams; var Result: string);
    procedure MasterEventsselectwhereReplyEvent(
      var Params: TDWParams; var Result: string);
    procedure MasterEventsinsertReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure MasterEventsupdateReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure MasterEventsdeleteReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure LookupEventsselectReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure MasterEventsnextpacketwhereReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure MasterEventsnextpacketReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure MasterEventsselectReplyEvent(var Params: TDWParams;
      var Result: string);
  private
    { Private declarations }
    FMasterResource: TMasterResource;
  public
    { Public declarations }
  end;
{$METHODINFO OFF}

var
  ServerDataModule: TServerDataModule;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TServerDataModule.DataModuleCreate(Sender: TObject);
begin
  FMasterResource := TMasterResource.Create;
end;

procedure TServerDataModule.DataModuleDestroy(Sender: TObject);
begin
  FMasterResource.Free;
  inherited;
end;

procedure TServerDataModule.MasterEventsdeleteReplyEvent(
  var Params: TDWParams; var Result: string);
begin
  if Params.Count = 1 then
    Result := FMasterResource
                .delete(Params.Items[0].AsInteger);
end;

procedure TServerDataModule.MasterEventsinsertReplyEvent(
  var Params: TDWParams; var Result: string);
var
  LJSONValue: TJSONValue;
begin
  if Params.Count = 1 then
  begin
    LJSONValue := TORMBrJSONUtil.JSONStringToJSONValue(Params.Items[0].AsString);
    try
      Result := FMasterResource
                  .insert(LJSONValue)
    finally
      LJSONValue.Free;
    end;
  end;
end;

procedure TServerDataModule.MasterEventsnextpacketReplyEvent(
  var Params: TDWParams; var Result: string);
begin
  Result := FMasterResource
              .nextpacket(Params.Items[0].AsInteger,
                          Params.Items[1].AsInteger).ToJSON;
end;

procedure TServerDataModule.MasterEventsnextpacketwhereReplyEvent(
  var Params: TDWParams; var Result: string);
begin
  Result := FMasterResource
              .nextpacketwhere(Params.Items[0].AsString,
                               Params.Items[1].AsString,
                               Params.Items[2].AsInteger,
                               Params.Items[3].AsInteger).ToJSON;
end;

procedure TServerDataModule.MasterEventsselectidReplyEvent(
  var Params: TDWParams; var Result: string);
begin
  if Params.Count = 1 then
    Result := FMasterResource
                .selectid(Params.Items[0].AsInteger);
end;

procedure TServerDataModule.MasterEventsselectReplyEvent(var Params: TDWParams;
  var Result: string);
begin
  Result := FMasterResource
              .select.ToJSON;
end;

procedure TServerDataModule.MasterEventsselectwhereReplyEvent(
  var Params: TDWParams; var Result: string);
begin
  if Params.Count = 2 then
    Result := FMasterResource
                .selectwhere(Params.Items[0].AsString,
                             Params.Items[1].AsString).ToJSON;
end;

procedure TServerDataModule.MasterEventsupdateReplyEvent(
  var Params: TDWParams; var Result: string);
var
  LJSONValue: TJSONValue;
begin
  if Params.Count = 1 then
  begin
    LJSONValue := TORMBrJSONUtil.JSONStringToJSONValue(Params.Items[0].AsString);
    try
      Result := FMasterResource
                  .update(LJSONValue);
    finally
      LJSONValue.Free;
    end;
  end;
end;

procedure TServerDataModule.LookupEventsselectReplyEvent(
  var Params: TDWParams; var Result: string);
begin
  Result := FMasterResource
              .selectlookup.ToJSON;
end;

end.
