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

unit ormbr.driver.rest.dwcore;

interface

uses
  Classes,
  SysUtils,
  ormbr.client.dwcore,
  ormbr.client.methods,
  ormbr.driver.rest;

type
  /// <summary>
  /// Classe de conex�o concreta com DW Core
  /// </summary>
  TDriverRestDWCore = class(TDriverRest)
  protected
    FConnection: TRESTClientDWCore;
  public
    constructor Create(AConnection: TComponent); override;
    destructor Destroy; override;
    function GetBaseURL: String; override;
    function GetMethodGET: String; override;
    function GetMethodGETId: String; override;
    function GetMethodGETWhere: String; override;
    function GetMethodPOST: String; override;
    function GetMethodPUT: String; override;
    function GetMethodDELETE: String; override;
    function GetMethodGETNextPacket: String; override;
    function GetMethodGETNextPacketWhere: String; override;
    function GetServerUse: Boolean; override;
    function Execute(const AResource, ASubResource: String;
      const ARequestMethod: TRESTRequestMethodType; const AParams: TProc = nil): String; overload; override;
    procedure SetClassNotServerUse(const Value: Boolean); override;
    procedure AddParam(const AValue: String); override;
    procedure AddQueryParam(const AValue: String); override;
  end;

implementation

{ TDriverRestDWCore }

procedure TDriverRestDWCore.AddParam(const AValue: String);
begin
  inherited;
  FConnection.AddParam(AValue);
end;

procedure TDriverRestDWCore.AddQueryParam(const AValue: String);
begin
  inherited;
  FConnection.AddQueryParam(AValue);
end;

constructor TDriverRestDWCore.Create(AConnection: TComponent);
begin
  inherited;
  FConnection := AConnection as TRESTClientDWCore;
end;

destructor TDriverRestDWCore.Destroy;
begin
  FConnection := nil;
  inherited;
end;

function TDriverRestDWCore.Execute(const AResource, ASubResource: String;
  const ARequestMethod: TRESTRequestMethodType; const AParams: TProc): String;
begin
  Result := FConnection
              .Execute(AResource, ASubResource, ARequestMethod, AParams);
end;

function TDriverRestDWCore.GetBaseURL: String;
begin
  Result := FConnection.BaseURL;
end;

function TDriverRestDWCore.GetMethodDELETE: String;
begin
  Result := FConnection.MethodDelete;
end;

function TDriverRestDWCore.GetMethodPOST: String;
begin
  Result := FConnection.MethodPOST;
end;

function TDriverRestDWCore.GetMethodGETNextPacket: String;
begin
  Result := FConnection.MethodGETNextPacket;
end;

function TDriverRestDWCore.GetMethodGETNextPacketWhere: String;
begin
  Result := FConnection.MethodGETNextPacketWhere;
end;

function TDriverRestDWCore.GetMethodGET: String;
begin
  Result := FConnection.MethodGET;
end;

function TDriverRestDWCore.GetMethodGETId: String;
begin
  Result := FConnection.MethodGETId;
end;

function TDriverRestDWCore.GetMethodGETWhere: String;
begin
  Result := FConnection.MethodGETWhere;
end;

function TDriverRestDWCore.GetMethodPUT: String;
begin
  Result := FConnection.MethodPUT;
end;

function TDriverRestDWCore.GetServerUse: Boolean;
begin
  Result := FConnection.ORMBrServerUse;
end;

procedure TDriverRestDWCore.SetClassNotServerUse(const Value: Boolean);
begin
  FConnection.SetClassNotServerUse(Value);
end;

end.
