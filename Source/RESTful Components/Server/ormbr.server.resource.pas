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
//{$DEFINE TRIAL}

unit ormbr.server.resource;

interface

uses
  Classes,
  SysUtils,
  Variants,
  Rtti,
  Generics.Collections,
  // ORMBr JSON
  ormbr.rest.json,
  ormbr.json.utils,
  // ORMBr
  ormbr.rest.query.parse,
  ormbr.mapping.repository,
  ormbr.server.rest.objectset,
  dbebr.factory.interfaces;

type
  TAppResourceBase = class
  private
    FConnection: IDBConnection;
    FRepository: TMappingRepository;
    function ResolverFindToSkip(AObjectSet: TRESTObjectSet; AQuery: TRESTQuery): String;
    function ResolverFindFilter(AObjectSet: TRESTObjectSet; AQuery: TRESTQuery): String;
    function ResolverFindID(AObjectSet: TRESTObjectSet; AQuery: TRESTQuery): String;
    function ResolverFindAll(AObjectSet: TRESTObjectSet): String;
  protected
    function ParseInsert(AQuery: TRESTQuery; AValue: String): String;
    function ParseUpdate(AQuery: TRESTQuery; AValue: String): String;
  public
    constructor Create(AConnection: IDBConnection); overload; virtual;
    destructor Destroy; override;
    function ParseFind(AQuery: TRESTQuery): String;
    function ParseDelete(AQuery: TRESTQuery): String;
    function select(AResource: String): String; overload; virtual;
    function insert(AResource: String; AValue: String): String; overload; virtual;
    function update(AResource: String; AValue: String): String; overload; virtual;
    function delete(AResource: String): String; overload; virtual;
  end;

implementation

uses
  ormbr.objects.helper,
  ormbr.mapping.explorer,
  ormbr.mapping.classes,
  ormbr.rtti.helper,
  ormbr.core.consts;

{ TAppResourceBase }

constructor TAppResourceBase.Create(AConnection: IDBConnection);
begin
//  {$IFDEF TRIAL}
//  MessageDlg('Esta é uma versão de demonstração do ORMBr - REST Server Components. Adquira a versão completa pelo E-mail isaquesp@gmail.com', mtInformation, [mbOk], 0);
//  {$ENDIF}
  FConnection := AConnection;
  FRepository := TMappingExplorer.GetInstance.Repository;
end;

function TAppResourceBase.delete(AResource: String): String;
begin
  Result := AResource;
end;

destructor TAppResourceBase.Destroy;
begin

  inherited;
end;

function TAppResourceBase.insert(AResource, AValue: String): String;
var
  LQuery: TRESTQuery;
begin
  LQuery := TRESTQuery.Create;
  try
    LQuery.ParseQuery(AResource);
    // Parse da Query passada na URI
    if LQuery.ResourceName = '' then
      raise Exception.Create('{"exception":"Class T' + AResource + ' not found!"}');
    Result := ParseInsert(LQuery, AValue)
  finally
    LQuery.Free;
  end;
end;

function TAppResourceBase.update(AResource, AValue: String): String;
var
  LQuery: TRESTQuery;
begin
  LQuery := TRESTQuery.Create;
  try
    // Parse da Query passada na URI
    LQuery.ParseQuery(AResource);
    if LQuery.ResourceName = '' then
      raise Exception.Create('{"exception":"Class T' + AResource + ' not found!"}');
    Result := ParseUpdate(LQuery, AValue)
  finally
    LQuery.Free;
  end;
end;

function TAppResourceBase.ParseDelete(AQuery: TRESTQuery): String;
var
  LObject: TObject;
  LClassType: TClass;
  LObjectSet: TRESTObjectSet;

  procedure ExceptionExecute;
  begin
    if LObject = nil then
      raise Exception.Create('{"result":"No records found to delete, with the filter entered!"}');
  end;

  procedure FilterExecuteFind;
  begin
    if Length(AQuery.Filter) > 0  then
      LObject := LObjectSet.FindOne(AQuery.Filter);
  end;

  procedure IDExecuteFind;
  begin
    if LObject <> nil then
      Exit;
    if AQuery.ID = Null then
      raise Exception.Create('{"exception":"The delete method needs the ID parameter!"}');
    LObject := LObjectSet.Find(VarToStr(AQuery.ID));
  end;

begin
  Result := '';
  LObject := nil;
  LClassType := FRepository.FindEntityByName(AQuery.ResourceName);
  if LClassType = nil then
    Exit;
  try
    LObjectSet := TRESTObjectSet.Create(FConnection, LClassType);
    try
      // Busca o registro pelo filtro
      FilterExecuteFind;
      // Busca o registro pelo ID
      IDExecuteFind;
      // Caso nenhum dos dois métodos encontre um registro, é gerado uma
      // exceção com uma mensagem de registro não encontrado para quem requisitou
      ExceptionExecute;
      // Se passar tudo ok, será executado o método do ORMBr
      LObjectSet.Delete(LObject);
      Result := '{"result":"Class ' + AQuery.ResourceName + ' delete command executed successfully"}';
    finally
      if LObject <> nil then
        LObject.Free;
      LObjectSet.Free;
    end;
  except
    on E: Exception do
    begin
      raise Exception.Create(E.Message);
    end;
  end;
end;

function TAppResourceBase.ParseFind(AQuery: TRESTQuery): String;
var
  LClassType: TClass;
  LObjectSet: TRESTObjectSet;
begin
  LClassType := FRepository.FindEntityByName(AQuery.ResourceName);
  if LClassType = nil then
    raise Exception.Create('{"exception":"Class [' + AQuery.ResourceName + '] not registered on the server!"}');

  LObjectSet := TRESTObjectSet.Create(FConnection, LClassType);
  try
    if AQuery.Top > 0 then
      Result := ResolverFindToSkip(LObjectSet, AQuery)
    else
    if Length(AQuery.Filter) > 0  then
      Result := ResolverFindFilter(LObjectSet, AQuery)
    else
    if AQuery.ID <> Null then
      Result := ResolverFindID(LObjectSet, AQuery)
    else
      Result := ResolverFindAll(LObjectSet);
  finally
    LObjectSet.Free;
  end;
end;

function TAppResourceBase.ParseInsert(AQuery: TRESTQuery; AValue: String): String;
var
  LPrimaryKey: TPrimaryKeyColumnsMapping;
  LColumn: TColumnMapping;
  LObject: TObject;
  LClassType: TClass;
  LObjectSet: TRESTObjectSet;
  LValues: String;
begin
  LClassType := FRepository.FindEntityByName(AQuery.ResourceName);
  if LClassType = nil then
    raise Exception.Create('{"exception":"Class [' + AQuery.ResourceName + '] not registered on the server!"}');

  try
    LObjectSet := TRESTObjectSet.Create(FConnection, LClassType);
    LObject := LClassType.Create;
    LObject.MethodCall('Create', []);

    TORMBrJson.JsonToObject(AValue, LObject);
    if LObject = nil then
      Exit;

    try
      LObjectSet.Insert(LObject);
      Result := '{"result":"Class ' + AQuery.ResourceName
              + ' insert command executed successfully",'
              + ' "params":[{%s}]}';
      LValues := '';
      LPrimaryKey := TMappingExplorer.GetInstance
                       .GetMappingPrimaryKeyColumns(LObject.ClassType);
      if LPrimaryKey = nil then
        raise Exception.Create(cMESSAGEPKNOTFOUND);

      for LColumn in LPrimaryKey.Columns do
        LValues := LValues + '"'  + LColumn.ColumnProperty.Name
                           + '":' + VarToStr(LColumn.ColumnProperty.GetNullableValue(LObject).AsVariant)
                           + ',';

      LValues[Length(LValues)] := ' ';
      Result := Format(Result, [Trim(LValues)]);
    finally
      LObject.Free;
      LObjectSet.Free;
    end;
  except
    on E: Exception do
    begin
      raise Exception.Create(E.Message);
    end;
  end;
end;

function TAppResourceBase.ParseUpdate(AQuery: TRESTQuery; AValue: String): String;
var
  LObjectOld: TObject;
  LObjectNew: TObject;
  LClassType: TClass;
  LObjectSet: TRESTObjectSet;
  LPrimaryKey: TPrimaryKeyColumnsMapping;
  LColumn: TColumnMapping;
  LWhere: String;
begin
  LClassType := FRepository.FindEntityByName(AQuery.ResourceName);
  if LClassType = nil then
    Exit;
  try
    LObjectSet := TRESTObjectSet.Create(FConnection, LClassType);
    LObjectNew := LClassType.Create;
    LObjectNew.MethodCall('Create', []);

    TORMBrJson.JsonToObject(AValue, LObjectNew);
    if LObjectNew = nil then
      raise Exception.Create('{"exception":"There was an error in trying to convert JSON into the class [' + AQuery.ResourceName + ']!"}');

    try
      LWhere := '';
      LPrimaryKey := TMappingExplorer.GetInstance
                       .GetMappingPrimaryKeyColumns(LObjectNew.ClassType);
      if LPrimaryKey = nil then
        raise Exception.Create(cMESSAGEPKNOTFOUND);

      for LColumn in LPrimaryKey.Columns do
        LWhere := LWhere + '(' + LObjectNew.GetTable.Name + '.' + LColumn.ColumnName
                         + '=' + VarToStr(LColumn.ColumnProperty.GetNullableValue(LObjectNew).AsVariant) + ') AND ';
      LWhere := Copy(LWhere, 1, Length(LWhere) -5);
      LObjectOld := LObjectSet.FindOne(LWhere);
      if LObjectOld = nil then
        Exit;

      try
        LObjectSet.Modify(LObjectOld);
        LObjectSet.Update(LObjectNew);
        Result := '{"result":"Class ' + AQuery.ResourceName + ' update command executed successfully"}';
      finally
        LObjectOld.Free;
      end;
    finally
      LObjectNew.MethodCall('Destroy', []);
      LObjectSet.Free;
    end;
  except
    on E: Exception do
    begin
      raise Exception.Create(E.Message);
    end;
  end;
end;

function TAppResourceBase.ResolverFindAll(AObjectSet: TRESTObjectSet): String;
var
  LObjectList: TObjectList<TObject>;
begin
  LObjectList := AObjectSet.Find;
  try
    Result := TORMBrJson.ObjectListToJsonString(LObjectList);
  finally
    LObjectList.Clear;
    LObjectList.Free;
  end;
end;

function TAppResourceBase.ResolverFindFilter(AObjectSet: TRESTObjectSet; AQuery: TRESTQuery): String;
var
  LObjectList: TObjectList<TObject>;
begin
  LObjectList := AObjectSet.FindWhere(AQuery.Filter, AQuery.OrderBy);
  try
    Result := TORMBrJson.ObjectListToJsonString(LObjectList);
  finally
    LObjectList.Clear;
    LObjectList.Free;
  end;
end;

function TAppResourceBase.ResolverFindID(AObjectSet: TRESTObjectSet; AQuery: TRESTQuery): String;
var
  LObject: TObject;
begin
  LObject := AObjectSet.Find(VarToStr(AQuery.ID));
  try
    Result := TORMBrJson.ObjectToJsonString(LObject);
  finally
    LObject.Free;
  end;
end;

function TAppResourceBase.ResolverFindToSkip(AObjectSet: TRESTObjectSet; AQuery: TRESTQuery): String;
var
  LObjectList: TObjectList<TObject>;
begin
  LObjectList := AObjectSet.NextPacket(AQuery.Filter, AQuery.OrderBy, AQuery.Top, AQuery.Skip);
  try
    Result := TORMBrJson.ObjectListToJsonString(LObjectList);
  finally
    LObjectList.Clear;
    LObjectList.Free;
  end;
end;

function TAppResourceBase.select(AResource: String): String;
begin
  Result := AResource;
end;

end.
