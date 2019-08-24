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

unit ormbr.client.dwcore;

interface

uses
  DB,
  SysUtils,
  StrUtils,
  Classes,
  Generics.Collections,
  ormbr.rest.classes,
  ormbr.client,
  ormbr.client.base,
  ormbr.client.methods,

  uDWAbout, uDWConsts, uRESTDWBase, uDWJSONObject, uDWConstsData;

type
  TRESTClientPoolerHacker = class(TRESTClientPooler)
  end;

  TRESTClientDWCore = class(TORMBrClient)
  private
    FDWParams: TDWParams;
    FRESTClient: TRESTClientPooler;
    procedure ClearDWParams;
    procedure SetProxyParamsClientValue;
    procedure SetParamsBodyValue;
    procedure SetAuthenticatorTypeValues;
    procedure SetParamValues;
    function DoGET(const AResource, ASubResource: String): String;
    function DoPOST(const AResource, ASubResource: String): String;
    function DoPUT(const AResource, ASubResource: String): String;
    function DoDELETE(const AResource, ASubResource: String): String;
  protected
    procedure SetServerUse(const Value: Boolean); override;
    procedure DoAfterCommand; override;
    procedure SetBaseURL; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute(const AResource, ASubResource: String;
      const ARequestMethod: TRESTRequestMethodType;
      const AParamsProc: TProc = nil): String;
  published
    property MethodGET;
    property MethodPOST;
    property MethodPUT;
    property MethodDELETE;
    property APIContext;
    property ORMBrServerUse;
  end;

implementation

uses
  ormbr.factory.rest.dwcore;

{$R 'RESTClientDWCore.res'}

{ TRESTClientDWCore }

constructor TRESTClientDWCore.Create(AOwner: TComponent);
begin
  inherited;
  FRESTFactory := TFactoryRestDWCore.Create(Self);
  FDWParams := TDWParams.Create;
  FRESTClient := TRESTClientPooler.Create(Self);
  FRESTClient.DataCompression := False;
  FRESTClient.hEncodeStrings := False;
  FDWParams.Encoding := FRESTClient.Encoding;
  FPort := 8082;
  FAuthenticator.Username := 'testserver';
  FAuthenticator.Password := 'testserver';
  FMethodSelect := 'select';
  FMethodInsert := 'insert';
  FMethodUpdate := 'update';
  FMethodDelete := 'delete';
  FAPIContext := 'restdataware';
  FRESTContext := '';
  /// <summary> Monta a URL base </summary>
  SetBaseURL;
end;

destructor TRESTClientDWCore.Destroy;
begin
  ClearDWParams;
  FDWParams.Free;
  FRESTClient.Free;
  inherited;
end;

procedure TRESTClientDWCore.DoAfterCommand;
begin
  FStatusCode := TRESTClientPoolerHacker(FRESTClient).HttpRequest.ResponseCode;
  inherited;
end;

function TRESTClientDWCore.DoDELETE(const AResource, ASubResource: String): String;
begin
  FRequestMethod := 'DELETE';
  /// <summary> Define valores dos par�metros </summary>
  SetParamValues;
  /// <summary> DELETE </summary>
  try
    Result := FRESTClient.SendEvent(ASubResource,
                                    FDWParams,
                                    sePOST, //seDELETE,
                                    jmPureJSON,
                                    AResource); // DELETE
    if ContainsStr(Result, 'Exception:') then
      raise Exception.Create(Result);
  except
    on E: Exception do
    begin
      if Assigned(FErrorCommand) then
        FErrorCommand(GetBaseURL,
                      AResource,
                      ASubResource,
                      FRequestMethod,
                      E.Message,
                      TRESTClientPoolerHacker(FRESTClient).HttpRequest.ResponseCode)
      else
        raise ERESTConnectionError
                .Create(GetBaseURL,
                        AResource,
                        ASubResource,
                        FRequestMethod,
                        E.Message,
                        TRESTClientPoolerHacker(FRESTClient).HttpRequest.ResponseCode);
    end;
  end;
end;

function TRESTClientDWCore.DoGET(const AResource, ASubResource: String): String;
begin
  FRequestMethod := 'GET';
  /// <summary> Define valores dos par�metros </summary>
  SetParamValues;
  /// <summary> GET </summary>
  try
    Result := FRESTClient.SendEvent(ASubResource,
                                    FDWParams,
                                    sePOST, //seGET,
                                    jmPureJSON,
                                    AResource);  // GET
    if ContainsStr(Result, 'Exception:') then
      raise Exception.Create(Result);
  except
    on E: Exception do
    begin
      if Assigned(FErrorCommand) then
        FErrorCommand(GetBaseURL,
                      AResource,
                      ASubResource,
                      FRequestMethod,
                      E.Message,
                      TRESTClientPoolerHacker(FRESTClient).HttpRequest.ResponseCode)
      else
        raise ERESTConnectionError
                .Create(GetBaseURL,
                        AResource,
                        ASubResource,
                        FRequestMethod,
                        E.Message,
                        TRESTClientPoolerHacker(FRESTClient).HttpRequest.ResponseCode);
    end;
  end;
end;

function TRESTClientDWCore.DoPOST(const AResource, ASubResource: String): String;
begin
  FRequestMethod := 'POST';
  /// <summary> Define valores dos par�metros </summary>
  SetParamsBodyValue;
  /// <summary> POST </summary>
  try
    Result := FRESTClient.SendEvent(ASubResource,
                                    FDWParams,
                                    sePOST,
                                    jmPureJSON,
                                    AResource); // POST
    if ContainsStr(Result, 'Exception:') then
      raise Exception.Create(Result);
  except
    on E: Exception do
    begin
      if Assigned(FErrorCommand) then
        FErrorCommand(GetBaseURL,
                      AResource,
                      ASubResource,
                      FRequestMethod,
                      E.Message,
                      TRESTClientPoolerHacker(FRESTClient).HttpRequest.ResponseCode)
      else
        raise ERESTConnectionError
                .Create(GetBaseURL,
                        AResource,
                        ASubResource,
                        FRequestMethod,
                        E.Message,
                        TRESTClientPoolerHacker(FRESTClient).HttpRequest.ResponseCode);
    end;
  end;
end;

function TRESTClientDWCore.DoPUT(const AResource, ASubResource: String): String;
begin
  FRequestMethod := 'PUT';
  /// <summary> Define valores dos par�metros </summary>
  SetParamsBodyValue;
  /// <summary> PUT </summary>
  try
    Result := FRESTClient.SendEvent(ASubResource,
                                    FDWParams,
                                    sePOST, //sePUT,
                                    jmPureJSON,
                                    AResource); // PUT
    if ContainsStr(Result, 'Exception:') then
      raise Exception.Create(Result);
  except
    on E: Exception do
    begin
      if Assigned(FErrorCommand) then
        FErrorCommand(GetBaseURL,
                      AResource,
                      ASubResource,
                      FRequestMethod,
                      E.Message,
                      TRESTClientPoolerHacker(FRESTClient).HttpRequest.ResponseCode)
      else
        raise ERESTConnectionError
                .Create(GetBaseURL,
                        AResource,
                        ASubResource,
                        FRequestMethod,
                        E.Message,
                        TRESTClientPoolerHacker(FRESTClient).HttpRequest.ResponseCode);
    end;
  end;
end;

procedure TRESTClientDWCore.ClearDWParams;
var
  LFor: Integer;
begin
  for LFor := FDWParams.Count -1 downto 0 do
    FDWParams.Items[LFor].Free;
  FDWParams.Clear;
end;

function TRESTClientDWCore.Execute(const AResource, ASubResource: String;
  const ARequestMethod: TRESTRequestMethodType;
  const AParamsProc: TProc): String;
var
  LFor: Integer;
  LJSONParam: TJSONParam;
  LResource: String;
  LSubResource: String;

  function GetRequestMethod: String;
  begin
    case ARequestMethod of
      TRESTRequestMethodType.rtPOST:   Result := 'POST';
      TRESTRequestMethodType.rtPUT:    Result := 'PUT';
      TRESTRequestMethodType.rtGET:    Result := 'GET';
      TRESTRequestMethodType.rtDELETE: Result := 'DELETE';
      TRESTRequestMethodType.rtPATCH: ;
    end;
  end;

begin
  Result := '';
  LResource := AResource;
  LSubResource := ASubResource;
  /// <summary>
  ///    Executa a procedure de adi��o dos par�metros
  /// </summary>
  if Assigned(AParamsProc) then
    AParamsProc();
  /// <summary> Define dados do proxy </summary>
  SetProxyParamsClientValue;
  /// <summary> Define valores de autentica��o </summary>
  SetAuthenticatorTypeValues;
  /// <summary>
  ///   Passa os dados de acesso para o RESTClient do DW Core
  /// </summary>
  FRESTClient.Host := FHost;
  FRESTClient.Port := FPort;
  if FProtocol = TRestProtocol.Http then
    FRESTClient.TypeRequest := trHttp
  else
    FRESTClient.TypeRequest := trHttps;

  if FServerUse then
  begin
    /// <summary>
    ///   Param com nome do attributo Table() do modelo.
    /// </summary>
    LJSONParam := TJSONParam.Create(FDWParams.Encoding);
    LJSONParam.ParamName := 'requesttype';
    LJSONParam.ObjectDirection := odIN;
    LJSONParam.JsonMode := jmPureJSON;
    LJSONParam.AsString := GetRequestMethod;
    FDWParams.Add(LJSONParam);
    /// <summary>
    ///   Param com nome do attributo Table() do modelo.
    /// </summary>
    LJSONParam := TJSONParam.Create(FDWParams.Encoding);
    LJSONParam.ParamName := 'resource';
    LJSONParam.ObjectDirection := odIN;
    LJSONParam.JsonMode := jmPureJSON;
    LJSONParam.AsString := AResource;
    FDWParams.Add(LJSONParam);
    ///
    LResource := 'ormbr';
    LSubResource := 'api';
  end;
  try
    /// <summary> DoBeforeCommand </summary>
    DoBeforeCommand;

    case ARequestMethod of
      TRESTRequestMethodType.rtPOST:
        begin
          Result := DoPOST(LResource, LSubResource);
        end;
      TRESTRequestMethodType.rtPUT:
        begin
          Result := DoPUT(LResource, LSubResource);
        end;
      TRESTRequestMethodType.rtGET:
        begin
          Result := DoGET(LResource, LSubResource);
        end;
      TRESTRequestMethodType.rtDELETE:
        begin
          Result := DoDELETE(LResource, LSubResource);
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
    /// <summary>
    ///   Limpa a lista de param�tros do DW Core
    /// </summary>
    ClearDWParams;
  end;
end;

procedure TRESTClientDWCore.SetAuthenticatorTypeValues;
begin
  case FAuthenticator.AuthenticatorType of
    atNoAuth:
      ;
    atBasicAuth:
      begin
        FRESTClient.UserName := FAuthenticator.Username;
        FRESTClient.Password := FAuthenticator.Password;
      end;
    atBearerToken:
      begin
      end;
    atOAuth1:
      begin
      end;
    atOAuth2:
      begin
      end;
  end;
end;

procedure TRESTClientDWCore.SetBaseURL;
begin
  inherited;
  FBaseURL := FBaseURL + FAPIContext;
end;

procedure TRESTClientDWCore.SetParamValues;
var
  LFor: Integer;
  LJSONParam: TJSONParam;

  function GetParamName(const AParamName, AValue: String): string;
  var
    LPos: Integer;
  begin
    Result := AParamName;
    LPos := Pos('=', AValue);
    if LPos = 0 then
      Exit;
    Result := Copy(AValue, 1, LPos -1);
  end;

  function GetParamValue(const AValue: String): string;
  var
    LPos: Integer;
  begin
    Result := AValue;
    LPos := Pos('=', AValue);
    if LPos = 0 then
      Exit;
    Result := Copy(AValue, LPos +1, Length(AValue));
  end;

begin
  for LFor := 0 to FParams.Count -1 do
  begin
    LJSONParam := TJSONParam.Create(FDWParams.Encoding);
    LJSONParam.ParamName := GetParamName(FParams.Items[LFor].Name, FParams.Items[LFor].AsString);
    LJSONParam.ObjectDirection := odIN;
    LJSONParam.JsonMode := jmPureJSON;
    LJSONParam.AsString := GetParamValue(FParams.Items[LFor].AsString);
    ///
    FDWParams.Add(LJSONParam);
  end;
  for LFor := 0 to FQueryParams.Count -1 do
  begin
    LJSONParam := TJSONParam.Create(FDWParams.Encoding);
    LJSONParam.ParamName := GetParamName(FQueryParams.Items[LFor].Name, FQueryParams.Items[LFor].AsString);
    LJSONParam.ObjectDirection := odIN;
    LJSONParam.JsonMode := jmPureJSON;
    LJSONParam.AsString := GetParamValue(FQueryParams.Items[LFor].AsString);
    ///
    FDWParams.Add(LJSONParam);
  end;
end;

procedure TRESTClientDWCore.SetParamsBodyValue;
var
  LFor: Integer;
  LJSONParam: TJSONParam;
begin
  if FBodyParams.Count = 0 then
    raise Exception.Create('N�o foi passado o par�metro com os dados do insert!');

  for LFor := 0 to FBodyParams.Count -1 do
  begin
    LJSONParam := TJSONParam.Create(FDWParams.Encoding);
    LJSONParam.ParamName := 'json';
    LJSONParam.ObjectDirection := odIN;
    LJSONParam.JsonMode := jmPureJSON;
    LJSONParam.AsString := FBodyParams.Items[LFor].AsString;
    ///
    FDWParams.Add(LJSONParam);
  end;
end;

procedure TRESTClientDWCore.SetProxyParamsClientValue;
begin
  FRESTClient.ProxyOptions.BasicAuthentication := FProxyParams.BasicAuthentication;
  FRESTClient.ProxyOptions.ProxyServer := FProxyParams.ProxyServer;
  FRESTClient.ProxyOptions.ProxyPort := FProxyParams.ProxyPort;
  FRESTClient.ProxyOptions.ProxyUsername := FProxyParams.ProxyUsername;
  FRESTClient.ProxyOptions.ProxyPassword := FProxyParams.ProxyPassword;
end;

procedure TRESTClientDWCore.SetServerUse(const Value: Boolean);
begin
  if FServerUse = Value then
    Exit;

  FServerUse := Value;
  if FServerUse then
  begin
    if Pos('/ORMBR/API', UpperCase(FAPIContext)) = 0 then
      FAPIContext := FAPIContext + '/ormbr/api';
  end
  else
    FAPIContext := ReplaceStr(FAPIContext, '/ormbr/api', '');
end;

end.
