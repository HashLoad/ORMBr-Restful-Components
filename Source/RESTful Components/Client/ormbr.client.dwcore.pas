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

unit ormbr.client.dwcore;

interface

uses
  DB,
  SysUtils,
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
    procedure AddDWParams;
    procedure ClearDWParams;
    procedure SetProxyParamsClient;
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
    property MethodGET;
    property MethodPOST;
    property MethodPUT;
    property MethodDELETE;
    property APIContext;
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
  FDWParams.Free;
  FRESTClient.Free;
  inherited;
end;

procedure TRESTClientDWCore.DoAfterCommand;
begin
  FStatusCode := TRESTClientPoolerHacker(FRESTClient).HttpRequest.ResponseCode;
  inherited;
end;

procedure TRESTClientDWCore.AddDWParams;
var
  LFor: Integer;
  LJSONParam: TJSONParam;
begin
  for LFor := 0 to FParams.Count -1 do
  begin
    LJSONParam := TJSONParam.Create(FDWParams.Encoding);
    LJSONParam.ParamName := FParams.Items[LFor].Name;
    LJSONParam.ObjectDirection := odIN;
    LJSONParam.JsonMode := jmPureJSON;
    LJSONParam.AsString := FParams.Items[LFor].AsString;
    ///
    FDWParams.Add(LJSONParam);
  end;
  for LFor := 0 to FQueryParams.Count -1 do
  begin
    LJSONParam := TJSONParam.Create(FDWParams.Encoding);
    LJSONParam.ParamName := FQueryParams.Items[LFor].Name;
    LJSONParam.ObjectDirection := odIN;
    LJSONParam.JsonMode := jmPureJSON;
    LJSONParam.AsString := FQueryParams.Items[LFor].AsString;
    ///
    FDWParams.Add(LJSONParam);
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
  const AParamsProc: TProc;
  const AQueryParamsProc: TProc): String;
var
  LFor: Integer;
begin
  Result := '';
  /// <summary> Executa a procedure de adição dos parâmetros </summary>
  if Assigned(AParamsProc) then
    AParamsProc();

  /// <summary> Executa a procedure de adição dos parâmetros </summary>
  if Assigned(AQueryParamsProc) then
    AQueryParamsProc();

  /// <summary> Define dados do proxy </summary>
  SetProxyParamsClient;

  /// <summary> Passa os dados de acesso para o RESTClient do DW Core </summary>
  FRESTClient.Host := FHost;
  FRESTClient.Port := FPort;
  FRESTClient.UserName := FAuthenticator.Username;
  FRESTClient.Password := FAuthenticator.Password;
  /// <summary> Adiciona os paramêtros do DW Core </summary>
  AddDWParams;
  try
    /// <summary> DoBeforeCommand </summary>
    DoBeforeCommand;

    case ARequestMethod of
      TRESTRequestMethodType.rtPOST:
        begin
          FRequestMethod := 'POST';
          if FParams.Count = 0 then
            raise Exception.Create('Não foi passado o parâmetro com os dados do insert!');
          try
            FResponseString := FRESTClient.SendEvent(ASubResource,
                                                     FDWParams,
                                                     sePOST,
                                                     jmPureJSON,
                                                     AResource); // POST
            Result := FResponseString;
            if Pos('NOT FOUND', UpperCase(Result)) > 0 then
              raise Exception.Create('404 Not Found');
          except
            on E: Exception do
            begin
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
      TRESTRequestMethodType.rtPUT:
        begin
          FRequestMethod := 'PUT';
          if FParams.Count = 0 then
            raise Exception.Create('Não foi passado o parâmetro com os dados do update!');
          try
            FResponseString := FRESTClient.SendEvent(ASubResource,
                                                     FDWParams,
                                                     sePOST,
                                                     jmPureJSON,
                                                     AResource); // PUT
            Result := FResponseString;
            if Pos('NOT FOUND', UpperCase(Result)) > 0 then
              raise Exception.Create('404 Not Found');
          except
            on E: Exception do
            begin
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
      TRESTRequestMethodType.rtGET:
        begin
          FRequestMethod := 'GET';
          try
            Result := FRESTClient.SendEvent(ASubResource,
                                            FDWParams,
                                            seGET,
                                            jmPureJSON,
                                            AResource);  // GET
            if Pos('NOT FOUND', UpperCase(Result)) > 0 then
              raise Exception.Create('404 Not Found');
          except
            on E: Exception do
            begin
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
      TRESTRequestMethodType.rtDELETE:
        begin
          FRequestMethod := 'DELETE';
          try
            FResponseString := FRESTClient.SendEvent(ASubResource,
                                                     FDWParams,
                                                     sePOST,
                                                     jmPureJSON,
                                                     AResource); // DELETE
            Result := FResponseString;
            if Pos('NOT FOUND', UpperCase(Result)) > 0 then
              raise Exception.Create('404 Not Found');
          except
            on E: Exception do
            begin
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
      TRESTRequestMethodType.rtPATCH: ;
    end;
    /// <summary>
    /// Passao JSON para a VAR que poderá ser manipulada no evento AfterCommand
    /// </summary>
    FResponseString := Result;
    /// <summary> DoAfterCommand </summary>
    DoAfterCommand;
    /// <summary>
    /// Pega de volta o JSON manipulado ou não no evento AfterCommand
    /// </summary>
    Result := FResponseString;
  finally
    FResponseString := '';
    FParams.Clear;
    FQueryParams.Clear;
    /// <summary> Limpa a lista de paramêtros do DW Core </summary>
    ClearDWParams;
  end;
end;

procedure TRESTClientDWCore.SetBaseURL;
begin
  inherited;
  FBaseURL := FBaseURL + FAPIContext;
end;

procedure TRESTClientDWCore.SetProxyParamsClient;
begin
  FRESTClient.ProxyOptions.BasicAuthentication := FProxyParams.BasicAuthentication;
  FRESTClient.ProxyOptions.ProxyServer := FProxyParams.ProxyServer;
  FRESTClient.ProxyOptions.ProxyPort := FProxyParams.ProxyPort;
  FRESTClient.ProxyOptions.ProxyUsername := FProxyParams.ProxyUsername;
  FRESTClient.ProxyOptions.ProxyPassword := FProxyParams.ProxyPassword;
end;

end.
