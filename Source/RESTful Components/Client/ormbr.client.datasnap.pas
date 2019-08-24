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

{$INCLUDE ..\..\ormbr.inc}

unit ormbr.client.datasnap;

interface

uses
  DB,
  SysUtils,
  StrUtils,
  Classes,
  ormbr.rest.classes,
  ormbr.client,
  ormbr.client.base,
  ormbr.client.methods,
  {$IFDEF DELPHI15_UP}
  JSON,
  {$ELSE}
  DBXJSON,
  {$ENDIF}
  REST.Client,
  REST.Types,
  IPPeerClient;

type
  TRESTClientDataSnap = class(TORMBrClient)
  private
    FRESTResponse: TRESTResponse;
    FRESTRequest: TRESTRequest;
    FRESTClient: TRESTClient;
    procedure SetProxyParamsClientValue;
    procedure SetParamsBodyValue;
    procedure SetAuthenticatorTypeValues;
    procedure SetParamValues;
    function DoGET(const AResource, ASubResource: String): String;
    function DoPOST(const AResource, ASubResource: String): String;
    function DoPUT(const AResource, ASubResource: String): String;
    function DoDELETE(const AResource, ASubResource: String): String;
    function RemoveContextServerUse(const Value: String): string;
  protected
    procedure DoAfterCommand; override;
    procedure SetBaseURL; override;
    procedure SetServerUse(const Value: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddQueryParam(AValue: String); override;
    function Execute(const AResource, ASubResource: String;
      const ARequestMethod: TRESTRequestMethodType;
      const AParamsProc: TProc = nil): String;
  published
    property APIContext;
    property RESTContext;
    property ORMBrServerUse;
  end;

implementation

uses
  ormbr.factory.rest.datasnap;

{$R 'RESTClientDataSnap.res'}

{ TRESTClientDataSnap }

procedure TRESTClientDataSnap.AddQueryParam(AValue: String);
var
  LPos: Integer;
begin
  LPos := Pos('=', AValue);
  if LPos = 0 then
    Exit;

  with FQueryParams.Add as TParam do
  begin
    Name := Copy(AValue, 1, LPos -1);
    DataType := ftString;
    ParamType := ptInput;
    Value := Copy(AValue, LPos +1, MaxInt);
  end;
end;

constructor TRESTClientDataSnap.Create(AOwner: TComponent);
begin
  inherited;
  FRESTFactory := TFactoryRestDatasnap.Create(Self);
  FRESTClient := TRESTClient.Create(Self);
  FRESTRequest := TRESTRequest.Create(Self);
  FRESTResponse := TRESTResponse.Create(Self);
  FRESTRequest.Client := FRESTClient;
  FRESTRequest.Response := FRESTResponse;
  FRESTResponse.RootElement := 'result';
  FAPIContext := 'datasnap';
  FRESTContext := '';
  /// <summary> Monta a URL base </summary>
  SetBaseURL;
end;

destructor TRESTClientDataSnap.Destroy;
begin
  FRESTClient.Free;
  FRESTResponse.Free;
  FRESTRequest.Free;
  inherited;
end;

procedure TRESTClientDataSnap.DoAfterCommand;
begin
  FStatusCode := FRESTRequest.Response.StatusCode;
  inherited;
end;

function TRESTClientDataSnap.DoDELETE(const AResource, ASubResource: String): String;
begin
  FRequestMethod := 'DELETE';
  FRESTRequest.Method := TRESTRequestMethod.rmDELETE;
  /// <summary> Define valores dos par�metros </summary>
  SetParamValues;
  /// <summary> DELETE </summary>
  try
    FRESTRequest.Execute;
    Result := (FRESTRequest.Response.JSONValue as TJSONArray).Items[0].ToJSON;
  except
    on E: Exception do
    begin
      if Assigned(FErrorCommand) then
        FErrorCommand(GetBaseURL,
                      AResource,
                      ASubResource,
                      FRequestMethod,
                      E.Message,
                      FRESTRequest.Response.StatusCode)
      else
        raise ERESTConnectionError
                .Create(FRESTClient.BaseURL,
                        AResource,
                        ASubResource,
                        FRequestMethod,
                        FRESTRequest.Response.Content,
                        FRESTRequest.Response.StatusCode);
    end;
  end;
end;

function TRESTClientDataSnap.DoGET(const AResource, ASubResource: String): String;
begin
  FRequestMethod := 'GET';
  FRESTRequest.Method := TRESTRequestMethod.rmGET;
  /// <summary> Define valores dos par�metros </summary>
  SetParamValues;
  /// <summary> DELETE </summary>
  try
    FRESTRequest.Execute;
    Result := (FRESTRequest.Response.JSONValue as TJSONArray).Items[0].ToJSON
  except
    on E: Exception do
    begin
      if Assigned(FErrorCommand) then
        FErrorCommand(GetBaseURL,
                      AResource,
                      ASubResource,
                      FRequestMethod,
                      E.Message,
                      FRESTRequest.Response.StatusCode)
      else
        raise ERESTConnectionError
                .Create(FRESTClient.BaseURL,
                        AResource,
                        ASubResource,
                        FRequestMethod,
                        FRESTRequest.Response.Content,
                        FRESTRequest.Response.StatusCode);
    end;
  end;

end;

function TRESTClientDataSnap.DoPOST(const AResource, ASubResource: String): String;
begin
  FRequestMethod := 'POST';
  FRESTRequest.Method := TRESTRequestMethod.rmPUT;
  /// <summary> Define valores dos par�metros </summary>
  SetParamsBodyValue;
  /// <summary> POST </summary>
  try
    FRESTRequest.Execute;
    Result := (FRESTRequest.Response.JSONValue as TJSONArray).Items[0].ToJSON;
  except
    on E: Exception do
    begin
      if Assigned(FErrorCommand) then
        FErrorCommand(GetBaseURL,
                      AResource,
                      ASubResource,
                      FRequestMethod,
                      E.Message,
                      FRESTRequest.Response.StatusCode)
      else
        raise ERESTConnectionError
                .Create(FRESTClient.BaseURL,
                        AResource,
                        ASubResource,
                        FRequestMethod,
                        FRESTRequest.Response.Content,
                        FRESTRequest.Response.StatusCode);
    end;
  end;
end;

function TRESTClientDataSnap.DoPUT(const AResource, ASubResource: String): String;
begin
  FRequestMethod := 'PUT';
  FRESTRequest.Method := TRESTRequestMethod.rmPOST;
  /// <summary> Define valores dos par�metros </summary>
  SetParamsBodyValue;
  /// <summary> PUT </summary>
  try
    FRESTRequest.Execute;
  except
    on E: Exception do
    begin
      if Assigned(FErrorCommand) then
        FErrorCommand(GetBaseURL,
                      AResource,
                      ASubResource,
                      FRequestMethod,
                      E.Message,
                      FRESTRequest.Response.StatusCode)
      else
        raise ERESTConnectionError
                .Create(FRESTClient.BaseURL,
                        AResource,
                        ASubResource,
                        FRequestMethod,
                        FRESTRequest.Response.Content,
                        FRESTRequest.Response.StatusCode);
    end;
  end;
end;

function TRESTClientDataSnap.Execute(const AResource, ASubResource: String;
      const ARequestMethod: TRESTRequestMethodType;
      const AParamsProc: TProc = nil): String;
var
  LFor: Integer;

  procedure SetURLValue;
  begin
    FRESTClient.BaseURL := GetBaseURL;
    /// <summary>
    ///   Trata a URL Base caso o componente esteja para usar o servidor,
    ///   mas a classe n�o.
    /// </summary>
    if (FServerUse) and (FClassNotServerUse) then
      FRESTClient.BaseURL := RemoveContextServerUse(FRESTClient.BaseURL);

    FRESTRequest.Params.Clear;
    FRESTRequest.ResetToDefaults;
    FRESTRequest.Resource := AResource;
    FRESTRequest.ResourceSuffix := ASubResource;
  end;

begin
  Result := '';
  /// <summary> Executa a procedure de adi��o dos par�metros </summary>
  if Assigned(AParamsProc) then
    AParamsProc();
  /// <summary> Define valor da URL </summary>
  SetURLValue;
  /// <summary> Define dados do proxy </summary>
  SetProxyParamsClientValue;
  /// <summary> Define valores de autentica��o </summary>
  SetAuthenticatorTypeValues;

  for LFor := 0 to FParams.Count -1 do
    if FParams.Items[LFor].AsString = 'None' then
      FParams.Items[LFor].AsString := '';
  try
    /// <summary> DoBeforeCommand </summary>
    DoBeforeCommand;

    case ARequestMethod of
      TRESTRequestMethodType.rtPOST:
        begin
          DoPOST(AResource, ASubResource);
        end;
      TRESTRequestMethodType.rtPUT:
        begin
          DoPUT(AResource, ASubResource);
        end;
      TRESTRequestMethodType.rtGET:
        begin
          DoGET(AResource, ASubResource);
        end;
      TRESTRequestMethodType.rtDELETE:
        begin
          DoDELETE(AResource, ASubResource);
        end;
      TRESTRequestMethodType.rtPATCH: ;
    end;
    /// <summary>
    ///   Passao JSON para a VAR que poder� ser manipulada no evento AfterCommand
    /// </summary>
    FResponseString := Result;
    /// <summary> DoAfterCommand </summary>
    DoAfterCommand;
    /// <summary>
    ///   Pega de volta o JSON manipulado ou n�o no evento AfterCommand
    /// </summary>
    Result := FResponseString;
  finally
    FResponseString := '';
    FParams.Clear;
    FQueryParams.Clear;
    FBodyParams.Clear;
  end;
end;

function TRESTClientDataSnap.RemoveContextServerUse(
  const Value: String): string;
begin
  Result := ReplaceStr(Value, '/ormbr/app', '');
end;

procedure TRESTClientDataSnap.SetAuthenticatorTypeValues;
begin
  case FAuthenticator.AuthenticatorType of
    atNoAuth:
      ;
    atBasicAuth:
      begin
//        FRESTResponse. UserName := FAuthenticator.Username;
//        FRESTToken.Password := FAuthenticator.Password;
      end;
    atBearerToken:
      begin
//        FRESTToken.UserName := FAuthenticator.Username;
//        FRESTToken.Password := FAuthenticator.Password;
//        FRESTToken.Token := FAuthenticator.Token;
      end;
    atOAuth1:
      begin

      end;
    atOAuth2:
      begin

      end;
  end;
end;

procedure TRESTClientDataSnap.SetBaseURL;
begin
  inherited;
  FBaseURL := FBaseURL + FAPIContext;
  if Length(FRESTContext) > 0 then
    FBaseURL := FBaseURL + '/' + FRESTContext;
end;

procedure TRESTClientDataSnap.SetParamValues;
var
  LFor: Integer;
begin
  /// <summary> Params </summary>
  for LFor := 0 to FParams.Count -1 do
  begin
    FRESTRequest.ResourceSuffix := FRESTRequest.ResourceSuffix + '/{' +
                                   FParams.Items[LFor].Name + '}';
    FRESTRequest.Params.AddUrlSegment(FParams.Items[LFor].Name,
                                      FParams.Items[LFor].AsString);
  end;
  /// <summary> Query Params </summary>
  for LFor := 0 to FQueryParams.Count -1 do
    FRESTRequest.AddParameter(FQueryParams.Items[LFor].Name,
                              FQueryParams.Items[LFor].AsString);
end;

procedure TRESTClientDataSnap.SetParamsBodyValue;
var
  LFor: Integer;
begin
  if FBodyParams.Count = 0 then
    raise Exception.Create('N�o foi passado o par�metro com os dados do insert!');

  for LFor := 0 to FBodyParams.Count -1 do
    FRESTRequest.Body.Add(FBodyParams.Items[LFor].AsString, ContentTypeFromString('application/json'));
end;

procedure TRESTClientDataSnap.SetProxyParamsClientValue;
begin
  FRESTClient.ProxyServer := FProxyParams.ProxyServer;
  FRESTClient.ProxyPort := FProxyParams.ProxyPort;
  FRESTClient.ProxyUsername := FProxyParams.ProxyUsername;
  FRESTClient.ProxyPassword := FProxyParams.ProxyPassword;
end;

procedure TRESTClientDataSnap.SetServerUse(const Value: Boolean);
begin
  if FServerUse = Value then
    Exit;

  FServerUse := Value;
  FRESTContext := RemoveContextServerUse(FRESTContext);
  if FServerUse then
    FRESTContext := FRESTContext + '/ormbr/app';
  SetBaseURL;
end;

end.
