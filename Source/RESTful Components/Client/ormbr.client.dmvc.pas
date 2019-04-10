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
    FBeforeCommand: TBeforeCommandEvent;
    FAfterCommand: TAfterCommandEvent;
    procedure SetProxyParamsClient;
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
    property BeforeCommand: TBeforeCommandEvent read FBeforeCommand write FBeforeCommand;
    property AfterCommand: TAfterCommandEvent read FAfterCommand write FAfterCommand;
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

function TRESTClientDelphiMVC.Execute(const AResource, ASubResource: String;
  const ARequestMethod: TRESTRequestMethodType;
  const AParamsProc: TProc): String;
var
  LFor: Integer;
  LParams: array of String;
  LResource: String;
  LSubResource: String;
  LURL: String;
begin
  Result := '';
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

  /// <summary> Passa os dados de acesso para o RESTClient do Delphi MVC </summary>
  if not Assigned(FRESTClient) then
    FRESTClient := TRESTClient.Create(FHost, FPort);

  FRESTClient.UserName := FAuthenticator.Username;
  FRESTClient.Password := FAuthenticator.Password;

  /// <summary> Executa a procedure de adição dos parâmetros </summary>
  if Assigned(AParamsProc) then
    AParamsProc();

  /// <summary> Define dados do proxy </summary>
  SetProxyParamsClient;

  /// <summary> Define o parametro do tipo array necessário para o Delphi MVC </summary>
  if FParams.Count > 0 then
    SetLength(LParams, FParams.Count);

  /// <summary> Passa os valores do Params externo para o array </summary>
  for LFor := 0 to FParams.Count -1 do
    LParams[LFor] := FParams.Items[LFor].AsString;

  /// <summary> Passa os valores do BodyParams externo para o string </summary>
  for LFor := 0 to FBodyParams.Count -1 do
    FRESTClient.BodyParams.Add(FBodyParams.Items[LFor].AsString);

  /// <summary> Passa os valores do Query Params externo para o array </summary>
  for LFor := 0 to FQueryParams.Count -1 do
    FRESTClient.QueryStringParams.Add(FQueryParams.Items[LFor].AsString);

  try
    /// <summary> DoBeforeCommand </summary>
    DoBeforeCommand;

    case ARequestMethod of
      TRESTRequestMethodType.rtPOST:
        begin
          FRequestMethod := 'POST';
          if FBodyParams.Count = 0 then
            raise Exception.Create('Não foi passado o parâmetro com os dados do insert!');
          try
            FRESTResponse := FRESTClient.doPOST(LURL, LParams, FRESTClient.BodyParams.Text);
            Result := FRESTResponse.BodyAsString;
          except
            on E: Exception do
            begin
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
      TRESTRequestMethodType.rtPUT:
        begin
          FRequestMethod := 'PUT';
          if FBodyParams.Count = 0 then
            raise Exception.Create('Não foi passado o parâmetro com os dados do update!');
          try
            FRESTResponse := FRESTClient.doPUT(LURL, LParams, FRESTClient.BodyParams.Text);
            Result := FRESTResponse.BodyAsString;
          except
            on E: Exception do
            begin
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
      TRESTRequestMethodType.rtGET:
        begin
          FRequestMethod := 'GET';
          try
            FRESTResponse := FRESTClient.doGET(LURL, LParams);
            Result := FRESTResponse.BodyAsString;
          except
            on E: Exception do
            begin
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
      TRESTRequestMethodType.rtDELETE:
        begin
          FRequestMethod := 'DELETE';
          try
            FRESTResponse := FRESTClient.doDELETE(LURL, LParams);
            Result := FRESTResponse.BodyAsString;
          except
            on E: Exception do
            begin
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
    FBodyParams.Clear;
    FQueryParams.Clear;
  end;
end;

function TRESTClientDelphiMVC.RemoveContextServerUse(
  const Value: String): string;
begin

end;

procedure TRESTClientDelphiMVC.SetProxyParamsClient;
begin
  FRESTClient.UseBasicAuthentication := FProxyParams.BasicAuthentication;
  FRESTClient.ProxyServer := FProxyParams.ProxyServer;
  FRESTClient.ProxyPort := FProxyParams.ProxyPort;
  FRESTClient.Username := FProxyParams.ProxyUsername;
  FRESTClient.Password := FProxyParams.ProxyPassword;
end;

end.
