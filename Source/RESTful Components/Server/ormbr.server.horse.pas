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

unit ormbr.server.horse;

interface

uses
  Classes,
  SysUtils,
  ormbr.rest.classes,
  // DBEBr Conexão
  dbebr.factory.interfaces,
  // HorseCore
  Horse,
  Horse.Core;

type
  TRESTServerHorse = class(TORMBrComponent)
  private
    class var
    FConnection: IDBConnection;
  private
    procedure SetConnection(const AConnection: IDBConnection);
    procedure AddResource;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function GetConnection: IDBConnection;
    property Connection: IDBConnection read GetConnection write SetConnection;
  published

  end;

implementation

uses
  ormbr.server.resource.horse;

{ TRESTServerHorse }

constructor TRESTServerHorse.Create(AOwner: TComponent);
begin
  inherited;
  // Define as rotas para no horse e verbos
  AddResource;
end;

destructor TRESTServerHorse.Destroy;
begin
  inherited;
end;

class function TRESTServerHorse.GetConnection: IDBConnection;
begin
  Result := FConnection;
end;

procedure TRESTServerHorse.SetConnection(const AConnection: IDBConnection);
begin
  FConnection := AConnection;
end;

procedure TRESTServerHorse.AddResource;
begin
  THorse.Get('api/ormbr/:resource',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LAppResource: TAppResource;
    begin
      LAppResource := TAppResource.Create;
      try
        try
          Res.Send(LAppResource.select(Req.Params['resource'], Req.Params, Req.Query));
        except
          on E: Exception do
            Res.Send(E.Message);
        end;
      finally
        LAppResource.Free;
      end;
    end);

  THorse.Post('api/ormbr/:resource',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LAppResource: TAppResource;
    begin
      LAppResource := TAppResource.Create;
      try
        try
          Res.Send(LAppResource.insert(Req.Params['resource'], Req.Body));
        except
          on E: Exception do
            Res.Send(E.Message);
        end;
      finally
        LAppResource.Free;
      end;
    end);

  THorse.Put('api/ormbr/:resource',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LAppResource: TAppResource;
    begin
      LAppResource := TAppResource.Create;
      try
        try
          Res.Send(LAppResource.update(Req.Params['resource'], Req.Body));
        except
          on E: Exception do
            Res.Send(E.Message);
        end;
      finally
        LAppResource.Free;
      end;
    end);

  THorse.Delete('api/ormbr/:resource',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LAppResource: TAppResource;
    begin
      LAppResource := TAppResource.Create;
      try
        try
          if Req.Query.Count = 0 then
            Res.Send(LAppResource.delete(Req.Params['resource']))
          else
            Res.Send(LAppResource.delete(Req.Params['resource'], Req.Query['$filter']));
        except
          on E: Exception do
            Res.Send(E.Message);
        end;
      finally
        LAppResource.Free;
      end;
    end);
end;

end.
