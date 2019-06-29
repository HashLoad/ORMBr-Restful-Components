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

{$INCLUDE ..\..\ormbr.inc}

unit ormbr.client.ws;

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
  TRESTClientWS = class(TORMBrClient)
  private
    FRESTResponse: TRESTResponse;
    FRESTRequest: TRESTRequest;
    FRESTClient: TRESTClient;
    FRootElement: String;
    procedure SetProxyParamsClient;
    function GetRootElement: String;
    procedure SetRootElement(const Value: String);
  protected
    procedure DoAfterCommand; override;
    procedure SetBaseURL; override;
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
    property RootElement: String read GetRootElement write SetRootElement;
  end;

implementation

uses
  ormbr.factory.rest.ws;

{$R 'RESTClientWS.res'}

{ TRESTClientWS }

procedure TRESTClientWS.AddQueryParam(AValue: String);
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

constructor TRESTClientWS.Create(AOwner: TComponent);
begin
  inherited;
  FRESTFactory := TFactoryRestWS.Create(Self);
  FRESTClient := TRESTClient.Create(Self);
  FRESTRequest := TRESTRequest.Create(Self);
  FRESTResponse := TRESTResponse.Create(Self);
  FRESTRequest.Client := FRESTClient;
  FRESTRequest.Response := FRESTResponse;
  FRESTResponse.RootElement := '';
  FAPIContext := '';
  FRESTContext := '';
  /// <summary> Monta a URL base </summary>
  SetBaseURL;
end;

destructor TRESTClientWS.Destroy;
begin
  FRESTClient.Free;
  FRESTResponse.Free;
  FRESTRequest.Free;
  inherited;
end;

procedure TRESTClientWS.DoAfterCommand;
begin
  FStatusCode := FRESTRequest.Response.StatusCode;
  inherited;
end;

function TRESTClientWS.Execute(const AResource, ASubResource: String;
  const ARequestMethod: TRESTRequestMethodType;
  const AParamsProc: TProc): String;
var
  LFor: Integer;
begin
  Result := '';
  /// <summary> Executa a procedure de adição dos parâmetros </summary>
  if Assigned(AParamsProc) then
    AParamsProc();

  /// <summary> Define dados do proxy </summary>
  SetProxyParamsClient;

  for LFor := 0 to FParams.Count -1 do
    if FParams.Items[LFor].AsString = 'None' then
      FParams.Items[LFor].AsString := '';

  FRESTClient.BaseURL := GetBaseURL;

  FRESTRequest.Params.Clear;
  FRESTRequest.ResetToDefaults;
  FRESTRequest.Resource := AResource;
  FRESTRequest.ResourceSuffix := ASubResource;
  try
    /// <summary> DoBeforeCommand </summary>
    DoBeforeCommand;

    case ARequestMethod of
      TRESTRequestMethodType.rtPOST:
        begin
          FRequestMethod := 'POST';
          FRESTRequest.Method := TRESTRequestMethod.rmPOST;
          try
            for LFor := 0 to FBodyParams.Count -1 do
              FRESTRequest.Body.Add(FBodyParams.Items[LFor].AsString, ContentTypeFromString('application/json'));
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
                                E.Message,
                                FRESTRequest.Response.StatusCode);
            end;
          end;
        end;
      TRESTRequestMethodType.rtPUT:
        begin
          FRequestMethod := 'PUT';
          FRESTRequest.Method := TRESTRequestMethod.rmPUT;
          try
            for LFor := 0 to FBodyParams.Count -1 do
              FRESTRequest.Body.Add(FBodyParams.Items[LFor].AsString, ContentTypeFromString('application/json'));
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
                                E.Message,
                                FRESTRequest.Response.StatusCode);
            end;
          end;
        end;
      TRESTRequestMethodType.rtGET:
        begin
          FRequestMethod := 'GET';
          FRESTRequest.Method := TRESTRequestMethod.rmGET;
          try
            /// <summary> Params </summary>
            for LFor := 0 to FParams.Count -1 do
            begin
              FRESTRequest.ResourceSuffix := FRESTRequest.ResourceSuffix + '/{' +
                                             FParams.Items[LFor].Name + '}';
              FRESTRequest.Params.AddUrlSegment(FParams.Items[LFor].Name,
                                                FParams.Items[LFor].AsString);
            end;
            for LFor := 0 to FQueryParams.Count -1 do
              FRESTRequest.AddParameter(FQueryParams.Items[LFor].Name,
                                        FQueryParams.Items[LFor].AsString);
            FRESTRequest.Execute;
            if Length(FRESTResponse.RootElement) > 0 then
              Result := (FRESTRequest.Response.JSONValue as TJSONArray).Items[0].ToJSON
            else
              Result := FRESTRequest.Response.JSONValue.ToJSON
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
                                E.Message,
                                FRESTRequest.Response.StatusCode);
            end;
          end;
        end;
      TRESTRequestMethodType.rtDELETE:
        begin
          FRequestMethod := 'DELETE';
          FRESTRequest.Method := TRESTRequestMethod.rmDELETE;
          try
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
                                E.Message,
                                FRESTRequest.Response.StatusCode);
            end;
          end;
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

procedure TRESTClientWS.SetBaseURL;
begin
  inherited;
  FBaseURL := FBaseURL + FAPIContext;
  if Length(FRESTContext) > 0 then
    FBaseURL := FBaseURL + '/' + FRESTContext;
end;

procedure TRESTClientWS.SetProxyParamsClient;
begin
  FRESTClient.ProxyServer := FProxyParams.ProxyServer;
  FRESTClient.ProxyPort := FProxyParams.ProxyPort;
  FRESTClient.ProxyUsername := FProxyParams.ProxyUsername;
  FRESTClient.ProxyPassword := FProxyParams.ProxyPassword;
end;

function TRESTClientWS.GetRootElement: String;
begin
  Result := FRootElement;
end;

procedure TRESTClientWS.SetRootElement(const Value: String);
begin
  FRootElement := Value;
  FRESTResponse.RootElement := FRootElement;
end;

end.
