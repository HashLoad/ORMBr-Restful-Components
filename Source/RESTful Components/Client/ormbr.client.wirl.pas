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

unit ormbr.client.wirl;

interface

uses
  DB,
  JSON,
  SysUtils,
  StrUtils,
  Classes,
  Generics.Collections,
  ormbr.rest.classes,
  ormbr.client,
  ormbr.client.base,
  ormbr.client.methods,

  WiRL.Client.CustomResource,
  WiRL.Client.Resource, WiRL.Client.Resource.JSON, WiRL.Client.Application,
  WiRL.http.Client, WiRL.http.Client.Indy, WiRL.Client.SubResource,
  WiRL.Client.SubResource.JSON, WiRL.Client.Messaging.Resource,
  WiRL.http.Request, WiRL.http.Response, WiRL.Core.Utils, WiRL.Client.Token;

type
  TRESTClientWiRL = class(TORMBrClient)
  private
    FRESTClient: TWiRLClient;
    FRESTClientApp: TWiRLClientApplication;
    FRESTResource: TWiRLClientResourceJSON;
    FRESTSubResource: TWiRLClientSubResourceJSON;
    FRESTToken: TWiRLClientToken;
    procedure SetProxyParamsClientValue;
    procedure SetProxyParamsBodyValue(var AParams: String);
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
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute(const AResource, ASubResource: String;
      const ARequestMethod: TRESTRequestMethodType;
      const AParamsProc: TProc = nil): String;
  published
    property APIContext;
    property RESTContext;
    property MethodToken;
    property ORMBrServerUse;
  end;

implementation

uses
  ormbr.factory.rest.wirl;

{$R 'RESTClientWiRL.res'}

{ TRESTClientWiRL }

constructor TRESTClientWiRL.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRESTFactory := TFactoryRestWiRL.Create(Self);
  FRESTClient := TWiRLClient.Create(Self);
//  FRESTClient.ClientVendor := 'TIdHttp (Indy)';
  FRESTClientApp := TWiRLClientApplication.Create(Self);
  FRESTClientApp.Client := FRESTClient;
  FRESTResource := TWiRLClientResourceJSON.Create(Self);
  FRESTResource.Application := FRESTClientApp;
  FRESTSubResource := TWiRLClientSubResourceJSON.Create(Self);
  FRESTSubResource.Application := FRESTClientApp;
  FRESTSubResource.ParentResource := FRESTResource;
  FRESTToken := TWiRLClientToken.Create(Self);
  FRESTToken.Application := FRESTClientApp;
  FAPIContext := 'app';
  FRESTContext := 'rest';
  /// <summary> Monta a URL base </summary>
  SetBaseURL;
end;

destructor TRESTClientWiRL.Destroy;
begin
  FRESTSubResource.Free;
  FRESTResource.Free;
  FRESTClientApp.Free;
  FRESTClient.Free;
  inherited;
end;

procedure TRESTClientWiRL.DoAfterCommand;
begin
  FStatusCode := FRESTClient.Response.StatusCode;
  inherited;
end;

function TRESTClientWiRL.DoDELETE(const AResource, ASubResource: String): String;
begin
  FRequestMethod := 'DELETE';
  /// <summary> Define valores dos parâmetros </summary>
  SetParamValues;
  /// <summary> DELETE </summary>
  FRESTSubResource.DELETE(nil,
                          procedure
                          begin
                            FResponseString := FRESTResource.Response.ToJSON;
                          end,
                          procedure(E: Exception)
                          begin
                            if Assigned(FErrorCommand) then
                              FErrorCommand(GetBaseURL,
                                            AResource,
                                            ASubResource,
                                            FRequestMethod,
                                            E.Message,
                                            FRESTClient.Response.StatusCode)
                            else
                              raise ERESTConnectionError
                                      .Create(FRESTClient.WiRLEngineURL,
                                              AResource,
                                              ASubResource,
                                              FRequestMethod,
                                              E.Message,
                                              FRESTClient.Response.StatusCode);
                          end );
  Result := FResponseString;
  //          FRESTClient.Response.ReasonString;
end;

function TRESTClientWiRL.DoGET(const AResource, ASubResource: String): String;
begin
  FRequestMethod := 'GET';
  /// <summary> Define valores dos parâmetros </summary>
  SetParamValues;
  /// <summary> GET </summary>
  Result := FRESTSubResource.GETAsString(nil, nil,
                                         procedure(E: Exception)
                                         begin
                                           if Assigned(FErrorCommand) then
                                             FErrorCommand(GetBaseURL,
                                                           AResource,
                                                           ASubResource,
                                                           FRequestMethod,
                                                           E.Message,
                                                           FRESTClient.Response.StatusCode)
                                           else
                                             raise ERESTConnectionError
                                                     .Create(FRESTClient.WiRLEngineURL,
                                                             AResource,
                                                             ASubResource,
                                                             FRequestMethod,
                                                             E.Message,
                                                             FRESTClient.Response.StatusCode);
                                         end );
end;

function TRESTClientWiRL.DoPOST(const AResource, ASubResource: String): String;
var
  LParams: String;
begin
  FRequestMethod := 'POST';
  /// <summary> Define valores dos parâmetros </summary>
  SetProxyParamsBodyValue(LParams);
  /// <summary> POST </summary>
  FRESTSubResource.POST(procedure(AContent: TMemoryStream)
                        var
                          LWriter: TStreamWriter;
                        begin
                          LWriter := TStreamWriter.Create(AContent);
                          try
                            LWriter.Write(LParams);
                            AContent.Position := 0;
                          finally
                            LWriter.Free;
                          end;
                        end,
                        procedure (AResponse: TStream)
                        begin
                          AResponse.Position := 0;
                          FResponseString := StreamToString(AResponse);
                        end,
                        procedure(E: Exception)
                        begin
                          if Assigned(FErrorCommand) then
                            FErrorCommand(GetBaseURL,
                                          AResource,
                                          ASubResource,
                                          FRequestMethod,
                                          E.Message,
                                          FRESTClient.Response.StatusCode)
                          else
                            raise ERESTConnectionError
                                    .Create(FRESTClient.WiRLEngineURL,
                                            AResource,
                                            ASubResource,
                                            FRequestMethod,
                                            E.Message,
                                            FRESTClient.Response.StatusCode);
                        end );
  Result := FResponseString;
end;

function TRESTClientWiRL.DoPUT(const AResource, ASubResource: String): String;
var
  LParams: String;
begin
  FRequestMethod := 'PUT';
  /// <summary> Define valores dos parâmetros </summary>
  SetProxyParamsBodyValue(LParams);
  /// <summary> PUT </summary>
  FRESTSubResource.PUT(procedure(AContent: TMemoryStream)
                       var
                         LWriter: TStreamWriter;
                       begin
                         LWriter := TStreamWriter.Create(AContent);
                         try
                           LWriter.Write(LParams);
                           AContent.Position := 0;
                         finally
                           LWriter.Free;
                         end;
                       end,
                       procedure (AResponse: TStream)
                       begin
                         AResponse.Position := 0;
                         FResponseString := StreamToString(AResponse);
                       end,
                       procedure(E: Exception)
                       begin
                         if Assigned(FErrorCommand) then
                           FErrorCommand(GetBaseURL,
                                         AResource,
                                         ASubResource,
                                         FRequestMethod,
                                         E.Message,
                                         FRESTClient.Response.StatusCode)
                         else
                           raise ERESTConnectionError
                                   .Create(FRESTClient.WiRLEngineURL,
                                           AResource,
                                           ASubResource,
                                           FRequestMethod,
                                           E.Message,
                                           FRESTClient.Response.StatusCode);
                       end );
  Result := FResponseString;
end;

function TRESTClientWiRL.Execute(const AResource, ASubResource: String;
  const ARequestMethod: TRESTRequestMethodType;
  const AParamsProc: TProc): String;

  procedure SetURLValue;
  begin
    FRESTClientApp.AppName := FAPIContext;
    /// <summary>
    ///   Trata a URL Base caso o componente esteja para usar o servidor,
    ///   mas a classe não.
    /// </summary>
    if (FServerUse) and (FClassNotServerUse) then
      FRESTClientApp.AppName := RemoveContextServerUse(FRESTClientApp.AppName);

    FRESTClient.WiRLEngineURL := GetBaseURL;
    FRESTResource.Resource := AResource;
    FRESTSubResource.Resource := ASubResource;
    FRESTSubResource.PathParamsValues.Clear;
    FRESTSubResource.QueryParams.Clear;
  end;

begin
  Result := '';
  /// <summary> Executa a procedure de adição dos parâmetros </summary>
  if Assigned(AParamsProc) then
    AParamsProc();
  /// <summary> Define valor da URL </summary>
  SetURLValue;
  /// <summary> Define dados do proxy </summary>
  SetProxyParamsClientValue;
  /// <summary> Define valores de autenticação </summary>
  SetAuthenticatorTypeValues;
  try
    /// <summary> DoBeforeCommand </summary>
    DoBeforeCommand;

    case ARequestMethod of
      TRESTRequestMethodType.rtPOST:
        begin
          Result := DoPOST(AResource, ASubResource);
        end;
      TRESTRequestMethodType.rtPUT:
        begin
          Result := DoPUT(AResource, ASubResource);
        end;
      TRESTRequestMethodType.rtGET:
        begin
          Result := DoGET(AResource, ASubResource);
        end;
      TRESTRequestMethodType.rtDELETE:
        begin
          Result := DoDELETE(AResource, ASubResource);
        end;
      TRESTRequestMethodType.rtPATCH: ;
    end;
    /// <summary>
    ///   Passao JSON para a VAR que poderá ser manipulada no evento AfterCommand
    /// </summary>
    FResponseString := Result;
    /// <summary> DoAfterCommand </summary>
    DoAfterCommand;
    /// <summary>
    ///   Pega de volta o JSON manipulado ou não no evento AfterCommand
    /// </summary>
    Result := FResponseString;
  finally
    FResponseString := '';
    FParams.Clear;
    FQueryParams.Clear;
    FBodyParams.Clear;
  end;
end;

function TRESTClientWiRL.RemoveContextServerUse(
  const Value: String): string;
begin
  Result := ReplaceStr(Value, '/ormbr', '');
end;

procedure TRESTClientWiRL.SetAuthenticatorTypeValues;
begin
  case FAuthenticator.AuthenticatorType of
    atNoAuth:
      ;
    atBasicAuth:
      begin
        FRESTToken.UserName := FAuthenticator.Username;
        FRESTToken.Password := FAuthenticator.Password;
      end;
    atBearerToken:
      begin
        FRESTClient.Request.HeaderFields.AddPair('username', FAuthenticator.Username);
        FRESTClient.Request.HeaderFields.AddPair('password', FAuthenticator.Password);
        FRESTClient.Request.HeaderFields.AddPair('bearertoken', FAuthenticator.Token);
      end;
    atOAuth1:
      begin

      end;
    atOAuth2:
      begin

      end;
  end;
end;

procedure TRESTClientWiRL.SetBaseURL;
begin
  inherited;
  FBaseURL := FBaseURL + FRESTContext;
end;

procedure TRESTClientWiRL.SetParamValues;
var
  LFor: Integer;
begin
  /// <summary> Params </summary>
  for LFor := 0 to FParams.Count -1 do
    FRESTSubResource.PathParamsValues.Add(FParams.Items[LFor].AsString);
  /// <summary> Query Params </summary>
  for LFor := 0 to FQueryParams.Count -1 do
    FRESTSubResource.QueryParams.Add(FQueryParams.Items[LFor].AsString);
end;

procedure TRESTClientWiRL.SetProxyParamsBodyValue(var AParams: String);
var
  LFor: Integer;
begin
  if FBodyParams.Count = 0 then
    raise Exception.Create('Não foi passado o parâmetro com os dados do insert!');

  for LFor := 0 to FBodyParams.Count -1 do
    AParams := AParams + FBodyParams.Items[LFor].AsString;
end;

procedure TRESTClientWiRL.SetProxyParamsClientValue;
begin
  FRESTClient.ProxyParams.BasicAuthentication := FProxyParams.BasicAuthentication;
  FRESTClient.ProxyParams.ProxyServer := FProxyParams.ProxyServer;
  FRESTClient.ProxyParams.ProxyPort := FProxyParams.ProxyPort;
  FRESTClient.ProxyParams.ProxyUsername := FProxyParams.ProxyUsername;
  FRESTClient.ProxyParams.ProxyPassword := FProxyParams.ProxyPassword;
end;

end.
