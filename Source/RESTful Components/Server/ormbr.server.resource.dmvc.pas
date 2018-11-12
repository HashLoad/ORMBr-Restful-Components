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

unit ormbr.server.resource.dmvc;

interface

uses
  SysUtils,
  /// Delphi MVC
  MVCFramework.Commons,
  MVCFramework,
  /// ORMBr
  ormbr.rest.query.parse,
  ormbr.server.resource;

type
  [MVCPath('/')]
  TAppResource = class(TMVCController)
  public
    [MVCPath('/($resource)')]
    [MVCHTTPMethod([httpGET])]
    procedure select(ctx: TWebContext);

    [MVCPath('/($resource)/($value)')]
    [MVCHTTPMethod([httpPOST])]
    procedure insert(resource: String;
                     value: String);

    [MVCPath('/($resource)/($value)')]
    [MVCHTTPMethod([httpPUT])]
    procedure update(resource: String;
                     value: String);

    [MVCPath('/($resource)')]
    [MVCHTTPMethod([httpDELETE])]
    procedure delete(ctx: TWebContext);
  end;

implementation

uses
  ormbr.server.dmvc;

{ TAppResource }

procedure TAppResource.select(ctx: TWebContext);
var
  LAppResource: TAppResourceBase;
  LQuery: TRESTQuery;
  LResult: String;
begin
  LQuery := TRESTQuery.Create;
  LAppResource := TAppResourceBase.Create(TRESTServerDMVC.GetConnection);
  try
    /// <summary> Parse da Query passada na URI </summary>
    LQuery.ParseQuery(ctx.Request.Params['resource']);
    if LQuery.ResourceName <> '' then
    begin
      LQuery.SetFilter(ctx.Request.Params['$filter']);
      LQuery.SetOrderBy(ctx.Request.Params['$orderby']);
      LQuery.SetTop(ctx.Request.Params['$top']);
      LQuery.SetSkip(ctx.Request.Params['$skip']);
      LQuery.SetCount(ctx.Request.Params['$count']);
      /// <summary> Retorno JSON </summary>
      LResult := LAppResource.ParseFind(LQuery);
      Render(LResult);
      /// <summary> Add Count Record no JSON Result </summary>
//      if LQuery.Count then
    end
    else
      raise Exception.Create('Class ' + LQuery.ResourceName + 'not found!');
  finally
    LAppResource.Free;
    LQuery.Free;
  end;
end;

procedure TAppResource.insert(resource: String; value: String);
var
  LAppResource: TAppResourceBase;
  LResult: String;
begin
  LAppResource := TAppResourceBase.Create(TRESTServerDMVC.GetConnection);
  try
    LResult := LAppResource.insert(resource, value);
    Render(LResult);
  finally
    LAppResource.Free;
  end;
end;

procedure TAppResource.update(resource: String; value: String);
var
  LAppResource: TAppResourceBase;
  LResult: String;
begin
  LAppResource := TAppResourceBase.Create(TRESTServerDMVC.GetConnection);
  try
    LResult := LAppResource.update(resource, value);
    Render(LResult);
  finally
    LAppResource.Free;
  end;
end;

procedure TAppResource.delete(ctx: TWebContext);
var
  LAppResource: TAppResourceBase;
  LQuery: TRESTQuery;
  LResult: String;
begin
  LQuery := TRESTQuery.Create;
  LAppResource := TAppResourceBase.Create(TRESTServerDMVC.GetConnection);
  try
    /// <summary> Parse da Query passada na URI </summary>
    LQuery.ParseQuery(ctx.Request.Params['resource']);
    if LQuery.ResourceName <> '' then
    begin
      LQuery.SetFilter(ctx.Request.Params['$filter']);
      /// <summary> Retorno JSON </summary>
      LResult := LAppResource.ParseFind(LQuery);
      Render(LResult);
    end
    else
      raise Exception.Create('Class ' + LQuery.ResourceName + 'not found!');
  finally
    LAppResource.Free;
    LQuery.Free;
  end;
end;

end.
