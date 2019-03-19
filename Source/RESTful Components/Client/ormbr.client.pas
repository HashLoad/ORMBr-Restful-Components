{
      ORM Brasil � um ORM simples e descomplicado para quem utiliza Delphi

                   Copyright (c) 2018, Isaque Pinheiro
                          All rights reserved.
}

{
  @abstract(REST Componentes)
  @created(20 Jun 2018)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
  @author(Skype : ispinheiro)
  @abstract(Website : http://www.ormbr.com.br)
  @abstract(Telagram : https://t.me/ormbr)
}

unit ormbr.client;

interface

uses
  DB,
  Dialogs,
  SysUtils,
  StrUtils,
  Classes,
  ormbr.client.methods,
  ormbr.client.base;

type
  TBeforeCommandEvent = procedure (ARequestMethod: String) of object;
  TAfterCommandEvent = procedure (AStatusCode: Integer;
                              var AResponseString: String;
                                  ARequestMethod: String) of object;

  TRestProtocol = (Http, Https);

  TORMBrClient = class(TORMBrClientBase)
  private
    FBeforeCommand: TBeforeCommandEvent;
    FAfterCommand: TAfterCommandEvent;
    function GetMethodGET: String;
    procedure SetMethodGET(const Value: String);
    function GetMethodGETId: String;
    procedure SetMethodGETId(const Value: String);
    function GetMethodGETWhere: String;
    procedure SetMethodGETWhere(const Value: String);
    function GetMethodPOST: String;
    procedure SetMethodPOST(const Value: String);
    function GetMethodPUT: String;
    procedure SetMethodPUT(const Value: String);
    function GetMethodDELETE: String;
    procedure SetMethodDELETE(const Value: String);
    function GetMethodGETNextPacketWhere: String;
    procedure SetMethodGETNextPacketWhere(const Value: String);
    function GetMethodGETNextPacket: String;
    procedure SetMethodGETNextPacket(const Value: String);
    function GetMethodToken: String;
    procedure SetMethodToken(const Value: String);
    function GetHost: String;
    procedure SetHost(const Value: String);
    function GetPort: Integer;
    procedure SetPort(const Value: Integer);
    function GetAPIContext: String;
    procedure SetAPIContext(const Value: String);
    function GetRESTContext: String;
    procedure SetRESTContext(const Value: String);
    function GetProtocol: TRestProtocol;
    procedure SetProtocol(const Value: TRestProtocol);
  protected
    FProtocol: TRestProtocol;
    FParams: TParams;
    FQueryParams: TParams;
    FBaseURL: String;
    FAPIContext: String;
    FRESTContext: String;
    FHost: String;
    FPort: Integer;
    FServerUse: Boolean;
    FClassNotServerUse: Boolean;
    FMethodSelect: String;
    FMethodSelectID: String;
    FMethodSelectWhere: String;
    FMethodInsert: String;
    FMethodUpdate: String;
    FMethodDelete: String;
    FMethodNextPacket: String;
    FMethodNextPacketWhere: String;
    FMethodToken: String;
    /// <summary> Variables the Events </summary>
    FRequestMethod: String;
    FResponseString: String;
    FStatusCode: Integer;
    procedure SetServerUse(const Value: Boolean); virtual;
    procedure SetBaseURL; virtual;
    function GetBaseURL: String;
    procedure DoBeforeCommand; virtual;
    procedure DoAfterCommand; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetClassNotServerUse(const Value: Boolean);
    procedure AddParam(AValue: String); virtual;
    procedure AddQueryParam(AValue: String); virtual;
    property MethodGET: String read GetMethodGET write SetMethodGET;
    property MethodPOST: String read GetMethodPOST write SetMethodPOST;
    property MethodPUT: String read GetMethodPUT write SetMethodPUT;
    property MethodDELETE: String read GetMethodDELETE write SetMethodDELETE;
    property MethodToken: String read GetMethodToken write SetMethodToken;
    property APIContext: String read GetAPIContext write SetAPIContext;
    property RESTContext: String read GetRESTContext write SetRESTContext;
    property ORMBrServerUse: Boolean read FServerUse write SetServerUse;
  published
    property Protocol: TRestProtocol read GetProtocol write SetProtocol;
    property Host: String read GetHost write SetHost;
    property Port: Integer read GetPort write SetPort;
    property MethodGETId: String read GetMethodGETId write SetMethodGETId;
    property MethodGETWhere: String read GetMethodGETWhere write SetMethodGETWhere;
    property MethodGETNextPacket: String read GetMethodGETNextPacket write SetMethodGETNextPacket;
    property MethodGETNextPacketWhere: String read GetMethodGETNextPacketWhere write SetMethodGETNextPacketWhere;
    property BaseURL: String read GetBaseURL;
    property BeforeCommand: TBeforeCommandEvent read FBeforeCommand write FBeforeCommand;
    property AfterCommand: TAfterCommandEvent read FAfterCommand write FAfterCommand;
  end;

implementation

{ TORMBrClient }

procedure TORMBrClient.AddQueryParam(AValue: String);
begin
  with FQueryParams.Add as TParam do
  begin
    Name := 'param_' + IntToStr(FQueryParams.Count -1);
    DataType := ftString;
    ParamType := ptInput;
    Value := AValue;
  end;
end;

constructor TORMBrClient.Create(AOwner: TComponent);
begin
  inherited;
  {$IFDEF TRIAL}
  MessageDlg('Esta � uma vers�o de demonstra��o do ORMBr - REST Client Components. Adquira a vers�o completa pelo E-mail ormbrframework@gmail.com', mtInformation, [mbOk], 0);
  {$ENDIF}
  FParams := TParams.Create(Self);
  FQueryParams := TParams.Create(Self);
  FServerUse := False;
  FClassNotServerUse := False;
  FHost := 'localhost';
  FPort := 8080;
  FMethodSelect := '';
  FMethodInsert := '';
  FMethodUpdate := '';
  FMethodDelete := '';
  FMethodSelectID := 'selectid';
  FMethodSelectWhere := 'selectwhere';
  FMethodNextPacket := 'nextpacket';
  FMethodNextPacketWhere := 'nextpacketwhere';
  FMethodToken := 'token';
  FAPIContext := '';
  FRESTContext := '';
  FProtocol := TRestProtocol.Http;
  FResponseString := '';
  FRequestMethod := '';
  FStatusCode := 0;
  /// <summary> Monta a URL base </summary>
  SetBaseURL;
end;

destructor TORMBrClient.Destroy;
begin
  FParams.Clear;
  FParams.Free;
  FQueryParams.Clear;
  FQueryParams.Free;
  inherited;
end;

procedure TORMBrClient.DoAfterCommand;
begin
  if Assigned(FAfterCommand) then
    FAfterCommand(FStatusCode, FResponseString, FRequestMethod);
end;

procedure TORMBrClient.DoBeforeCommand;
begin
  if Assigned(FBeforeCommand) then
    FBeforeCommand(FRequestMethod);
end;

procedure TORMBrClient.AddParam(AValue: String);
begin
  with FParams.Add as TParam do
  begin
    Name := 'param_' + IntToStr(FParams.Count -1);
    DataType := ftString;
    ParamType := ptInput;
    Value := AValue;
  end;
end;

procedure TORMBrClient.SetBaseURL;
var
  LProtocol: String;
begin
  LProtocol := ifThen(FProtocol = TRestProtocol.Http, 'http://', 'https://');
  FBaseURL := LProtocol + FHost;
  if FPort > 0 then
    FBaseURL := FBaseURL + ':' + IntToStr(FPort) + '/';
end;

procedure TORMBrClient.SetClassNotServerUse(const Value: Boolean);
begin
  FClassNotServerUse := Value;
end;

function TORMBrClient.GetBaseURL: String;
begin
  Result := FBaseURL;
end;

function TORMBrClient.GetAPIContext: String;
begin
  Result := FAPIContext;
end;

function TORMBrClient.GetMethodDELETE: String;
begin
  Result := FMethodDelete;
end;

function TORMBrClient.GetHost: String;
begin
  Result := FHost;
end;

function TORMBrClient.GetMethodPOST: String;
begin
  Result := FMethodInsert;
end;

function TORMBrClient.GetMethodGETNextPacket: String;
begin
  Result := FMethodNextPacket;
end;

function TORMBrClient.GetMethodGETNextPacketWhere: String;
begin
  Result := FMethodNextPacketWhere;
end;

function TORMBrClient.GetPort: Integer;
begin
  Result := FPort;
end;

function TORMBrClient.GetProtocol: TRestProtocol;
begin
  Result := FProtocol;
end;

function TORMBrClient.GetRESTContext: String;
begin
  Result := FRESTContext;
end;

function TORMBrClient.GetMethodGET: String;
begin
  Result := FMethodSelect;
end;

function TORMBrClient.GetMethodGETId: String;
begin
  Result := FMethodSelectID;
end;

function TORMBrClient.GetMethodGETWhere: String;
begin
  Result := FMethodSelectWhere;
end;

function TORMBrClient.GetMethodToken: String;
begin
  Result := FMethodToken;
end;

function TORMBrClient.GetMethodPUT: String;
begin
  Result := FMethodUpdate;
end;

procedure TORMBrClient.SetAPIContext(const Value: String);
begin
  if FAPIContext <> Value then
  begin
    FAPIContext := Value;
    /// <summary> Monta a URL base </summary>
    SetBaseURL;
  end;
end;

procedure TORMBrClient.SetMethodDELETE(const Value: String);
begin
  if FMethodDelete <> Value then
    FMethodDelete := Value;
end;

procedure TORMBrClient.SetHost(const Value: String);
begin
  if FHost <> Value then
  begin
    FHost := Value;
    /// <summary> Monta a URL base </summary>
    SetBaseURL;
  end;
end;

procedure TORMBrClient.SetMethodPOST(const Value: String);
begin
  if FMethodInsert <> Value then
    FMethodInsert := Value;
end;

procedure TORMBrClient.SetMethodGETNextPacket(const Value: String);
begin
  if FMethodNextPacket <> Value then
    FMethodNextPacket := Value;
end;

procedure TORMBrClient.SetMethodGETNextPacketWhere(const Value: String);
begin
  if FMethodNextPacketWhere <> Value then
    FMethodNextPacketWhere := Value;
end;

procedure TORMBrClient.SetPort(const Value: Integer);
begin
  if FPort <> Value then
  begin
    FPort := Value;
    /// <summary> Monta a URL base </summary>
    SetBaseURL;
  end;
end;

procedure TORMBrClient.SetProtocol(const Value: TRestProtocol);
begin
  if FProtocol <> Value then
  begin
    FProtocol := Value;
    /// <summary> Monta a URL base </summary>
    SetBaseURL;
  end;
end;

procedure TORMBrClient.SetRESTContext(const Value: String);
begin
  if FRESTContext <> Value then
  begin
    FRESTContext := Value;
    /// <summary> Monta a URL base </summary>
    SetBaseURL;
  end;
end;

procedure TORMBrClient.SetServerUse(const Value: Boolean);
begin
  if FServerUse <> Value then
  begin
    FServerUse := Value;
    if FServerUse then
    begin
      if Pos('/ORMBR', UpperCase(FAPIContext)) = 0 then
        FAPIContext := FAPIContext + '/ormbr';
    end
    else
      FAPIContext := ReplaceStr(FAPIContext, '/ormbr', '');
  end;
end;

procedure TORMBrClient.SetMethodGET(const Value: String);
begin
  if FMethodSelect <> Value then
    FMethodSelect := Value;
end;

procedure TORMBrClient.SetMethodGETId(const Value: String);
begin
  if FMethodSelectID <> Value then
    FMethodSelectID := Value;
end;

procedure TORMBrClient.SetMethodGETWhere(const Value: String);
begin
  if FMethodSelectWhere <> Value then
    FMethodSelectWhere := Value;
end;

procedure TORMBrClient.SetMethodToken(const Value: String);
begin
  if FMethodToken <> Value then
    FMethodToken := Value;
end;

procedure TORMBrClient.SetMethodPUT(const Value: String);
begin
  if FMethodUpdate <> Value then
    FMethodUpdate := Value;
end;

end.
