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

unit ormbr.client.mars;

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

  MARS.Client.CustomResource,
  MARS.Client.Resource, MARS.Client.Resource.JSON, MARS.Client.Application,
  MARS.Client.Client, MARS.Client.Client.Indy, MARS.Client.SubResource,
  MARS.Client.SubResource.JSON, MARS.Client.Messaging.Resource, MARS.Core.Utils,
  MARS.Client.Token;

type
  TRESTClientMARS = class(TORMBrClient)
  private
    FRESTClient: TMARSClient;
    FRESTClientApp: TMARSClientApplication;
    FRESTResource: TMARSClientResourceJSON;
    FRESTSubResource: TMARSClientSubResourceJSON;
    FRESTToken: TMARSClientToken;
    procedure SetProxyParamsClient;
    function RemoveContextServerUse(const Value: String): string;
  protected
    procedure DoAfterCommand; override;
    procedure SetBaseURL; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute(const AResource, ASubResource: String;
      const ARequestMethod: TRESTRequestMethodType;
      const AParamsProc: TProc = nil;
      const AQueryParamsProc: TProc = nil): String;
  published
    property APIContext;
    property RESTContext;
    property MethodToken;
    property ORMBrServerUse;
  end;

implementation

uses
  ormbr.factory.rest.mars;

{$R 'RESTClientMARS.res'}

{ TRESTClientMARS }

constructor TRESTClientMARS.Create(AOwner: TComponent);
begin
  inherited;
  FRESTFactory := TFactoryRestMARS.Create(Self);
  FRESTClient := TMARSClient.Create(Self);
  FRESTClientApp := TMARSClientApplication.Create(Self);
  FRESTClientApp.Client := FRESTClient;
  FRESTResource := TMARSClientResourceJSON.Create(Self);
  FRESTResource.Application := FRESTClientApp;
  FRESTSubResource := TMARSClientSubResourceJSON.Create(Self);
  FRESTSubResource.Application := FRESTClientApp;
  FRESTSubResource.ParentResource := FRESTResource;
  FRESTToken := TMARSClientToken.Create(Self);
  FRESTToken.Application := FRESTClientApp;
  FAPIContext := 'default';
  FRESTContext := 'rest';
  /// <summary> Monta a URL base </summary>
  SetBaseURL;
end;

destructor TRESTClientMARS.Destroy;
begin
  FRESTSubResource.Free;
  FRESTResource.Free;
  FRESTClientApp.Free;
  FRESTClient.Free;
  inherited;
end;

procedure TRESTClientMARS.DoAfterCommand;
begin
  FStatusCode := FRESTClient.ResponseStatusCode;
  inherited;
end;

function TRESTClientMARS.Execute(const AResource, ASubResource: String;
  const ARequestMethod: TRESTRequestMethodType;
  const AParamsProc: TProc;
  const AQueryParamsProc: TProc): String;
var
  LFor: Integer;
  LParams: String;
begin
  Result := '';
  LParams := '';
  /// <summary> Executa a procedure de adi��o dos par�metros </summary>
  if Assigned(AParamsProc) then
    AParamsProc();

  /// <summary> Executa a procedure de adi��o dos querys par�metros </summary>
  if Assigned(AQueryParamsProc) then
    AQueryParamsProc();

  /// <summary> Define dados do proxy </summary>
  SetProxyParamsClient;

  FRESTClientApp.AppName := FAPIContext;
  /// <summary>
  /// Trata a URL Base caso o componente esteja para usar o servidor,
  /// mas a classe n�o.
  /// </summary>
  if (FServerUse) and (FClassNotServerUse) then
    FRESTClientApp.AppName := RemoveContextServerUse(FRESTClientApp.AppName);

  FRESTClient.MARSEngineURL := GetBaseURL;
  FRESTResource.Resource := AResource;
  FRESTSubResource.Resource := ASubResource;
  FRESTSubResource.PathParamsValues.Clear;
  FRESTSubResource.QueryParams.Clear;
  FRESTToken.UserName := FAuthenticator.Username;
  FRESTToken.Password := FAuthenticator.Password;
  try
    /// <summary> DoBeforeCommand </summary>
    DoBeforeCommand;

    case ARequestMethod of
      TRESTRequestMethodType.rtPOST:
        begin
          FRequestMethod := 'POST';
          if FParams.Count = 0 then
            raise Exception.Create('N�o foi passado o par�metro com os dados do insert!');

          for LFor := 0 to FParams.Count -1 do
            LParams := LParams + FParams.Items[LFor].AsString;
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
                                procedure(AResponse: TStream)
                                begin
                                  AResponse.Position := 0;
                                  FResponseString := StreamToString(AResponse);
                                end,
                                procedure(E: Exception)
                                begin
                                  raise ERESTConnectionError
                                          .Create(FRESTClient.MARSEngineURL,
                                                  AResource,
                                                  ASubResource,
                                                  E.Message,
                                                  FRequestMethod,
                                                  FRESTClient.ResponseStatusCode);
                                end );
          Result := FResponseString;
        end;
      TRESTRequestMethodType.rtPUT:
        begin
          FRequestMethod := 'POST';
          if FParams.Count = 0 then
            raise Exception.Create('N�o foi passado o par�metro com os dados do update!');

          for LFor := 0 to FParams.Count -1 do
            LParams := LParams + FParams.Items[LFor].AsString;
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
                               procedure(AResponse: TStream)
                               begin
                                 AResponse.Position := 0;
                                 FResponseString := StreamToString(AResponse);
                               end,
                               procedure(E: Exception)
                               begin
                                 raise ERESTConnectionError
                                         .Create(FRESTClient.MARSEngineURL,
                                                 AResource,
                                                 ASubResource,
                                                 FRequestMethod,
                                                 E.Message,
                                                 FRESTClient.ResponseStatusCode);
                               end );
          Result := FResponseString;
        end;
      TRESTRequestMethodType.rtGET:
        begin
          FRequestMethod := 'GET';
          /// <summary> Params </summary>
          for LFor := 0 to FParams.Count -1 do
            FRESTSubResource.PathParamsValues.Add(FParams.Items[LFor].AsString);
          /// <summary> Query Params </summary>
          for LFor := 0 to FQueryParams.Count -1 do
            FRESTSubResource.QueryParams.Add(FQueryParams.Items[LFor].AsString);
          /// <summary> Query GET </summary>
          Result := FRESTSubResource.GETAsString(nil, nil,
                                                 procedure(E: Exception)
                                                 begin
                                                   raise ERESTConnectionError
                                                           .Create(FRESTClient.MARSEngineURL,
                                                                   AResource,
                                                                   ASubResource,
                                                                   FRequestMethod,
                                                                   E.Message,
                                                                   FRESTClient.ResponseStatusCode);
                                                 end );
        end;
      TRESTRequestMethodType.rtDELETE:
        begin
          FRequestMethod := 'DELETE';
          /// <summary> Params </summary>
          for LFor := 0 to FParams.Count -1 do
            FRESTSubResource.PathParamsValues.Add(FParams.Items[LFor].AsString);
          /// <summary> Query Params </summary>
          for LFor := 0 to FQueryParams.Count -1 do
            FRESTSubResource.QueryParams.Add(FQueryParams.Items[LFor].AsString);
          /// <summary> DELETE </summary>
          FRESTSubResource.DELETE(procedure(AContent: TMemoryStream)
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
                                  procedure(AResponse: TStream)
                                  begin
                                    AResponse.Position := 0;
                                    FResponseString := StreamToString(AResponse);
                                  end,
                                  procedure(E: Exception)
                                  begin
                                    raise ERESTConnectionError
                                            .Create(FRESTClient.MARSEngineURL,
                                                    AResource,
                                                    ASubResource,
                                                    FRequestMethod,
                                                    E.Message,
                                                    FRESTClient.ResponseStatusCode);
                                  end );
          Result := FResponseString;
        end;
      TRESTRequestMethodType.rtPATCH: ;
    end;
    /// <summary>
    /// Passao JSON para a VAR que poder� ser manipulada no evento AfterCommand
    /// </summary>
    FResponseString := Result;
    /// <summary> DoAfterCommand </summary>
    DoAfterCommand;
    /// <summary>
    /// Pega de volta o JSON manipulado ou n�o no evento AfterCommand
    /// </summary>
    Result := FResponseString;
  finally
    FResponseString := '';
    FParams.Clear;
    FQueryParams.Clear;
  end;
end;

function TRESTClientMARS.RemoveContextServerUse(const Value: String): string;
begin
  Result := ReplaceStr(Value, '/ormbr', '');
end;

procedure TRESTClientMARS.SetBaseURL;
begin
  inherited;
  FBaseURL := FBaseURL + FRESTContext;
end;

procedure TRESTClientMARS.SetProxyParamsClient;
begin
  FRESTClient.HttpClient.ProxyParams.BasicAuthentication := FProxyParams.BasicAuthentication;
  FRESTClient.HttpClient.ProxyParams.ProxyServer := FProxyParams.ProxyServer;
  FRESTClient.HttpClient.ProxyParams.ProxyPort := FProxyParams.ProxyPort;
  FRESTClient.HttpClient.ProxyParams.ProxyUsername := FProxyParams.ProxyUsername;
  FRESTClient.HttpClient.ProxyParams.ProxyPassword := FProxyParams.ProxyPassword;
end;

end.