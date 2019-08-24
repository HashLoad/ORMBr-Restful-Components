{
      ORM Brasil é um ORM simples e descomplicado para quem utiliza Delphi

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

unit ormbr.client.dmvc;

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

  MVCFramework.RESTClient;

type
  TRESTClientDelphiMVC = class(TORMBrClient)
  private
    FRESTClient: TRESTClient;
    FRESTResponse: IRESTResponse;
    procedure SetProxyParamsClientValues;
    procedure SetAuthenticatorTypeValues;
    procedure SetParamsBodyValue;
    procedure SetParamValues(AParams: PClientParam);
    function DoGET(const AURL, AResource, ASubResource: String;
      const AParams: array of string): String;
    function DoPOST(const AURL, AResource, ASubResource: String;
      const AParams: array of string): String;
    function DoPUT(const AURL, AResource, ASubResource: String;
      const AParams: array of string): String;
    function DoDELETE(const AURL, AResource, ASubResource: String;
      const AParams: array of string): String;
    function RemoveContextServerUse(const Value: String): string;
  protected
    procedure DoAfterCommand; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute(const AResource, ASubResource: String;
      const ARequestMethod: TRESTRequestMethodType;
      const AParamsProc: TProc = nil): String;
  published
    property APIContext;
    property ORMBrServerUse;
  end;

implementation

uses
  ormbr.factory.rest.dmvc;

{$R 'RESTClientDelphiMVC.res'}

{ TRESTClientDelphiMVC }

constructor TRESTClientDelphiMVC.Create(AOwner: TComponent);
begin
  inherited;
  FRESTFactory := TFactoryRestDMVC.Create(Self);
  /// <summary> Monta a URL base </summary>
  SetBaseURL;
end;

destructor TRESTClientDelphiMVC.Destroy;
begin
  if Assigned(FRESTClient) then
    FRESTClient.Free;
  inherited;
end;

procedure TRESTClientDelphiMVC.DoAfterCommand;
begin
  FStatusCode := FRESTResponse.ResponseCode;
  inherited;
end;

function TRESTClientDelphiMVC.DoDELETE(const AURL, AResource,
  ASubResource: String; const AParams: array of string): String;
begin
  FRequestMethod := 'DELETE';
  try
    FRESTResponse := FRESTClient.doDELETE(AURL, AParams);
    Result := FRESTResponse.BodyAsString;
    if FRESTResponse.HasError then
      raise Exception.Create(FRESTResponse.Error.ExceptionMessage);
  except
    on E: Exception do
    begin
      if Assigned(FErrorCommand) then
        FErrorCommand(GetBaseURL,
                      AResource,
                      ASubResource,
                      FRequestMethod,
                      E.Message,
                      FRESTResponse.ResponseCode)
      else
        raise ERESTConnectionError.Create(GetBaseURL,
                                          AResource,
                                          ASubResource,
                                          FRequestMethod,
                                          E.Message,
                                          FRESTResponse.ResponseCode);
    end;
  end;
end;

function TRESTClientDelphiMVC.DoGET(const AURL, AResource, ASubResource: String;
      const AParams: array of string): String;
begin
  FRequestMethod := 'GET';
  try
    FRESTResponse := FRESTClient.doGET(AURL, AParams);
    Result := FRESTResponse.BodyAsString;
    if FRESTResponse.HasError then
      raise Exception.Create(FRESTResponse.Error.ExceptionMessage);
  except
    on E: Exception do
    begin
      if Assigned(FErrorCommand) then
        FErrorCommand(GetBaseURL,
                      AResource,
                      ASubResource,
                      FRequestMethod,
                      E.Message,
                      FRESTResponse.ResponseCode)
      else
        raise ERESTConnectionError
                .Create(GetBaseURL,
                        AResource,
                        ASubResource,
                        FRequestMethod,
                        E.Message,
                        FRESTResponse.ResponseCode);
    end;
  end;
end;

function TRESTClientDelphiMVC.DoPOST(const AURL, AResource,
  ASubResource: String; const AParams: array of string): String;
begin
  FRequestMethod := 'POST';
  /// <summary> Define valores dos parâmetros </summary>
  SetParamsBodyValue;
  /// <summary> POST </summary>
  try
    FRESTResponse := FRESTClient.doPOST(AURL, AParams, FRESTClient.BodyParams.Text);
    Result := FRESTResponse.BodyAsString;
    if FRESTResponse.HasError then
      raise Exception.Create(FRESTResponse.Error.ExceptionMessage);
  except
    on E: Exception do
    begin
      if Assigned(FErrorCommand) then
        FErrorCommand(GetBaseURL,
                      AResource,
                      ASubResource,
                      FRequestMethod,
                      E.Message,
                      FRESTResponse.ResponseCode)
      else
        raise ERESTConnectionError
                .Create(GetBaseURL,
                        AResource,
                        ASubResource,
                        FRequestMethod,
                        E.Message,
                        FRESTResponse.ResponseCode);
    end;
  end;
end;

function TRESTClientDelphiMVC.DoPUT(const AURL, AResource, ASubResource: String;
  const AParams: array of string): String;
begin
  FRequestMethod := 'PUT';
  /// <summary> Define valores dos parâmetros </summary>
  SetParamsBodyValue;
  /// <summary> POST </summary>
  try
    FRESTResponse := FRESTClient.doPUT(AURL, AParams, FRESTClient.BodyParams.Text);
    Result := FRESTResponse.BodyAsString;
    if FRESTResponse.HasError then
      raise Exception.Create(FRESTResponse.Error.ExceptionMessage);
  except
    on E: Exception do
    begin
      if Assigned(FErrorCommand) then
        FErrorCommand(GetBaseURL,
                      AResource,
                      ASubResource,
                      FRequestMethod,
                      E.Message,
                      FRESTResponse.ResponseCode)
      else
        raise ERESTConnectionError
                .Create(GetBaseURL,
                        AResource,
                        ASubResource,
                        FRequestMethod,
                        E.Message,
                        FRESTResponse.ResponseCode);
    end;
  end;
end;

function TRESTClientDelphiMVC.Execute(const AResource, ASubResource: String;
  const ARequestMethod: TRESTRequestMethodType;
  const AParamsProc: TProc): String;
var
  LURL: String;
  LParams: TClientParam;

  procedure SetURLValue;
  var
    LResource: String;
    LSubResource: String;
  begin
    /// <summary>
    ///   Trata URL Base caso componente esteja usando servidor, mas a classe não.
    /// </summary>
    if (FServerUse) and (not FClassNotServerUse) then
      LResource := FAPIContext;
    /// <summary> Nome do recurso </summary>
    LResource := LResource + '/' + AResource;
    /// <summary> Nome do sub-recurso </summary>
    if Length(ASubResource) > 0 then
      LSubResource := '/' + ASubResource;
    /// <summary> URL completa </summary>
    LURL := LResource + LSubResource;
  end;

begin
  Result := '';
  /// <summary> Passa os dados de acesso para o RESTClient do Delphi MVC </summary>
  if not Assigned(FRESTClient) then
    FRESTClient := TRESTClient.Create(FHost, FPort);
  /// <summary> Define valores de autenticação </summary>
  SetAuthenticatorTypeValues;
  /// <summary> Executa a procedure de adição dos parâmetros </summary>
  if Assigned(AParamsProc) then
    AParamsProc();
  /// <summary> Define valor da URL </summary>
  SetURLValue;
  /// <summary> Define dados do proxy </summary>
  SetProxyParamsClientValues;
  /// <summary> Define valores dos parâmetros </summary>
  SetParamValues(@LParams);
  try
    /// <summary> DoBeforeCommand </summary>
    DoBeforeCommand;

    case ARequestMethod of
      TRESTRequestMethodType.rtPOST:
        begin
          Result := DoPOST(LURL, AResource, ASubResource, LParams);
        end;
      TRESTRequestMethodType.rtPUT:
        begin
          Result := DoPUT(LURL, AResource, ASubResource, LParams);
        end;
      TRESTRequestMethodType.rtGET:
        begin
          Result := DoGET(LURL, AResource, ASubResource, LParams);
        end;
      TRESTRequestMethodType.rtDELETE:
        begin
          Result := DoDELETE(LURL, AResource, ASubResource, LParams);
        end;
      TRESTRequestMethodType.rtPATCH: ;
    end;
    /// <summary>
    ///   Passao JSON para VAR que poderá ser manipulada no evento AfterCommand
    /// </summary>
    FResponseString := Result;
    /// <summary> DoAfterCommand </summary>
    DoAfterCommand;
    /// <summary>
    ///   Pega de volta JSON manipulado ou não no evento AfterCommand
    /// </summary>
    Result := FResponseString;
  finally
    FResponseString := '';
    FParams.Clear;
    FQueryParams.Clear;
    FBodyParams.Clear;
    FRESTClient.ClearHeaders;
  end;
end;

procedure TRESTClientDelphiMVC.SetAuthenticatorTypeValues;
var
  LAuthorized: Boolean;
begin
  LAuthorized := False;
  /// <summary> Dispara evento OnAuthentication </summary>
//  if Assigned(FAuthentication) and (not FPerformingAuthentication) then
//  begin
//    FPerformingAuthentication := True;
//    try
//      FAuthentication(LAuthorized);
//      if not LAuthorized then
//        raise Exception.Create('Unauthorized Authentication');
//    finally
//      FPerformingAuthentication := False;
//    end
//  end;
  case FAuthenticator.AuthenticatorType of
    atNoAuth:
      ;
    atBasicAuth:
      begin
        FRESTClient.UserName := FAuthenticator.Username;
        FRESTClient.Password := FAuthenticator.Password;
        FRESTClient.UseBasicAuthentication := True;
      end;
    atBearerToken:
      begin
        FRESTClient.UseBasicAuthentication := False;
        if Length(FAuthenticator.Token) > 0 then
        begin
          FRESTClient.Header('Authentication', 'bearer ' + FAuthenticator.Token);
          Exit;
        end;
        FRESTClient.Header('jwtusername', FAuthenticator.Username);
        FRESTClient.Header('jwtpassword', FAuthenticator.Password);
      end;
    atOAuth1:
      begin
        FRESTClient.UseBasicAuthentication := True;
      end;
    atOAuth2:
      begin
        FRESTClient.UseBasicAuthentication := True;
      end;
  end;
end;

function TRESTClientDelphiMVC.RemoveContextServerUse(const Value: String): string;
begin
  Result := '';
end;

procedure TRESTClientDelphiMVC.SetParamsBodyValue;
var
  LFor: Integer;
begin
  /// <summary>
  ///   Passa os valores do BodyParams externo para o string
  /// </summary>
  for LFor := 0 to FBodyParams.Count -1 do
    FRESTClient.BodyParams.Add(FBodyParams.Items[LFor].AsString);
end;

procedure TRESTClientDelphiMVC.SetParamValues(AParams: PClientParam);
var
  LFor: Integer;
begin
  /// <summary> Define o parametro do tipo array necessário para o Delphi MVC </summary>
  if FParams.Count > 0 then
  begin
    SetLength(AParams^, FParams.Count);
    /// <summary> Passa os valores do Params externo para o array </summary>
    for LFor := 0 to FParams.Count -1 do
      AParams^[LFor] := FParams.Items[LFor].AsString;
  end;
  /// <summary> Passa os valores do Query Params externo para o array </summary>
  for LFor := 0 to FQueryParams.Count -1 do
    FRESTClient.QueryStringParams.Add(FQueryParams.Items[LFor].AsString);
end;

procedure TRESTClientDelphiMVC.SetProxyParamsClientValues;
begin
  FRESTClient.ProxyServer := FProxyParams.ProxyServer;
  FRESTClient.ProxyPort := FProxyParams.ProxyPort;
  FRESTClient.Username := FProxyParams.ProxyUsername;
  FRESTClient.Password := FProxyParams.ProxyPassword;
end;

end.
